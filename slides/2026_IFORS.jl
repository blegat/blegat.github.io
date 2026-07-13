### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ fa2e13f9-b406-42c1-88e5-fe5607496d51
begin
import Pkg
Pkg.activate("/home/blegat/.julia/dev/ArrayDiff/perf/bench")
end

# ╔═╡ 24bf996e-03e9-40a7-a238-bd9d5050dc2b
Pkg.add("ShortCodes")

# ╔═╡ c3229e00-5d23-4986-994f-1d19911d9a03
using ShortCodes, PlutoUI, HypertextLiteral, PlutoTeachingTools, JuMP, LinearAlgebra, SparseArrays, BenchmarkTools, GenOpt, CUDA, ArrayDiff

# ╔═╡ 89cfbbb0-c3a7-11f0-bea8-6b8a0e78862d
@htl("""
<p align=center style=\"font-size: 40px;\">Accelerating energy system optimization on GPUs</p>
<p align=right><i>Benoît Legat, UCLouvain</i></p>
$(PlutoTeachingTools.ChooseDisplayMode())
$(PlutoUI.TableOfContents(depth=1))
""")

# ╔═╡ 8e1d4a42-698d-469e-8c8b-b25ac806455e
md"# Introduction"

# ╔═╡ 80e60e94-0309-4513-a5af-ebce2738be11
md"""
* ExaModels and MadNLP can respectively differentiate and solve problems on GPU
  - Winners of COIN-OR Cup 2023 and JuMP-dev 2025
* ExaModels need common structure to be grouped together to accelerate differentiation
* ExaModels tries to rebuild this structure in its JuMP interface
* [GenOpt](https://github.com/blegat/GenOpt.jl) extends JuMP to allow communicating this structure
* [MathOptSymbolicAD](https://github.com/lanl-ansi/MathOptSymbolicAD.jl) also regroups these to save symbolic differentiation time
* [ArrayDiff](https://github.com/blegat/ArrayDiff.jl/) allows to model AC-OPF in a vectorized form to be GPU-friendly.

$(DOI("10.1016/j.epsr.2024.110651"))
"""

# ╔═╡ 87b15eed-0ddd-4814-98cf-5f7c538eeaf6
md"## Objectives of GenOpt"

# ╔═╡ 4630c192-5783-4cb0-addf-09ef0bc7d6be
md"""
This talk present a new JuMP/MOI extension : [GenOpt](https://github.com/blegat/GenOpt.jl) whose objectives are twofolds

1. Define an MOI interface for groups of similar constraints or sum of similar terms.
   - This decouples the work of finding these similar patterns and exploiting them
   - This can allow drastic compression of the model for simpler communication (e.g., in a cluster environment)
2. Being able to write a **single** model compatible with both ExaModels and JuMP's AD backend.
   - Automatically dismantle these groups if the solvers cannot exploit them (with bridges!)
3. Add a JuMP interface for the user to explicitly specify these groups
4. Allow existing code base to use it without much changes
"""

# ╔═╡ eef717ab-ae1f-43ff-a929-65b511d47167
md"""
## AC-OPF with GenOpt

Classical version without GenOpt is in [rosetta-opf](https://github.com/lanl-ansi/rosetta-opf/blob/main/jump.jl)
"""

# ╔═╡ 2fd50dda-ac70-484c-93a6-d310af8b853c
md"## Grab needed constants"

# ╔═╡ f7dd7e17-0ed2-46f9-ac32-cb4b1bdefb32
md"""
## Specifying ExaModels and MadNLP
Ideally, ExaModels should be specified just as AD backend but it currently doesn't fit in our AD interface so we need to specify it as a meta-solver.
"""

# ╔═╡ cb885f89-6208-4ada-9f7e-4782533a7f98
md"""
## Creating variables

ExaModels needs the variables to be consecutive. But it's already the case so nothing changes here.
"""

# ╔═╡ 4f3664f8-1fee-4ee2-ad08-fd99e19e0fff
begin
    @variable(model, va[keys(ref[:bus])])
    @variable(model, ref[:bus][i]["vmin"] <= vm[i in keys(ref[:bus])] <= ref[:bus][i]["vmax"], start = 1.0)
    @variable(model, ref[:gen][i]["pmin"] <= pg[i in keys(ref[:gen])] <= ref[:gen][i]["pmax"])
    @variable(model, ref[:gen][i]["qmin"] <= qg[i in keys(ref[:gen])] <= ref[:gen][i]["qmax"])
    @variable(model, -ref[:branch][ref[:arcs][i][1]]["rate_a"] <= p[i in 1:narc] <= ref[:branch][ref[:arcs][i][1]]["rate_a"])
    @variable(model, -ref[:branch][ref[:arcs][i][1]]["rate_a"] <= q[i in 1:narc] <= ref[:branch][ref[:arcs][i][1]]["rate_a"])
end

# ╔═╡ 75f362c6-e69e-4cd1-8af7-6a7b6df06f25
md"## Approach of GenOpt"

# ╔═╡ 4c421cff-464a-41e2-b884-31011d5a07ec
md"""
Users already group constraints with containers, the container receives a function and the iterators, like `Base.Generator`.
"""

# ╔═╡ 07aaa337-4b7c-45c9-be3a-d6379daa6f76
container = GenOpt.ParametrizedArray

# ╔═╡ 9eb7720f-74d2-4b6b-8642-5debdab10aac
@constraint(model, [i in ref_buses], va[i] == 0, container = container);

# ╔═╡ 5ae8f51d-ad92-4862-8980-5ae5ed7b0be3
md"`ExaModels.constraint` expect a `Base.Generator` as well. We use a custom container that gives custom objects for `i` and handle interaction with `JuMP.NonlinearExpr` with **operator overloading**."

# ╔═╡ a0758565-57dd-4d51-bd63-97b993b45617
md"## Branch flows"

# ╔═╡ 33939427-62ac-4da4-8ed9-09251adb3063
begin
    @constraint(
        model,
        [i in keys(ref[:branch])],
        p[f_idx[i]] == (g[i] + g_fr[i]) / ttm[i] * vm[f_bus[i]]^2 +
        (-g[i] * tr[i] + b[i] * ti[i]) / ttm[i] *
        (vm[f_bus[i]] * vm[t_bus[i]] * cos(va[f_bus[i]] - va[t_bus[i]])) +
        (-b[i] * tr[i] - g[i] * ti[i]) / ttm[i] *
        (vm[f_bus[i]] * vm[t_bus[i]] * sin(va[f_bus[i]] - va[t_bus[i]])),
        container = container,
    )

    @constraint(
        model,
        [i in keys(ref[:branch])],
        q[f_idx[i]] +
        (b[i] + b_fr[i]) / ttm[i] * vm[f_bus[i]]^2 +
        (-b[i] * tr[i] - g[i] * ti[i]) / ttm[i] *
        (vm[f_bus[i]] * vm[t_bus[i]] * cos(va[f_bus[i]] - va[t_bus[i]])) ==
        (-g[i] * tr[i] + b[i] * ti[i]) / ttm[i] *
        (vm[f_bus[i]] * vm[t_bus[i]] * sin(va[f_bus[i]] - va[t_bus[i]])),
        container = container,
    )

    @constraint(
        model,
        [i in keys(ref[:branch])],
        p[t_idx[i]] - (g[i] + g_to[i]) * vm[t_bus[i]]^2 -
        (-g[i] * tr[i] - b[i] * ti[i]) / ttm[i] *
        (vm[t_bus[i]] * vm[f_bus[i]] * cos(va[t_bus[i]] - va[f_bus[i]])) ==
        (-b[i] * tr[i] + g[i] * ti[i]) / ttm[i] *
        (vm[t_bus[i]] * vm[f_bus[i]] * sin(va[t_bus[i]] - va[f_bus[i]])),
        container = container,
    )

    @constraint(
        model,
        [i in keys(ref[:branch])],
        q[t_idx[i]] +
        (b[i] + b_to[i]) * vm[t_bus[i]]^2 +
        (-b[i] * tr[i] + g[i] * ti[i]) / ttm[i] *
        (vm[t_bus[i]] * vm[f_bus[i]] * cos(va[t_bus[i]] - va[f_bus[i]])) ==
        (-g[i] * tr[i] - b[i] * ti[i]) / ttm[i] *
        (vm[t_bus[i]] * vm[f_bus[i]] * sin(va[t_bus[i]] - va[f_bus[i]])),
        container = container,
    )
end;

# ╔═╡ 4844591b-a06a-44c7-975b-9e5feca118bd
@constraint(
    model,
    [i in keys(ref[:branch])],
    angmin[i] <= va[f_bus[i]] - va[t_bus[i]] <= angmax[i],
    container = container,
)

# ╔═╡ 1b8ab92c-47ae-492d-88d7-afc070fdbaa9
md"## Power limit"

# ╔═╡ b8fca168-725f-4309-b1a7-ed1d5f089ff9
begin
    @constraint(
        model,
        [i in keys(ref[:branch])],
        p[f_idx[i]]^2 + q[f_idx[i]]^2 <= rate_a_sq[i],
        container = container,
    )
    @constraint(
        model,
        [i in keys(ref[:branch])],
        p[t_idx[i]]^2 + q[t_idx[i]]^2 <= rate_a_sq[i],
        container = container,
    )
end;

# ╔═╡ 4b390042-d9bb-4df3-84d7-7ec4da34969b
md"## Lazy sum with filter"

# ╔═╡ ecda8485-1c19-4111-a859-e0fde43a7cea
begin
    @constraint(
        model,
        [i in keys(ref[:bus])],
        bus_pd[i] == -bus_gs[i] * vm[i]^2 -
        lazy_sum(p[j] for j in 1:narc if arc_bus[j] == i) +
        lazy_sum(pg[j] for j in keys(ref[:gen]) if gen_bus[j] == i),
        container = container,
    )

    @constraint(
        model,
        [i in keys(ref[:bus])],
        bus_qd[i] == bus_bs[i] * vm[i]^2 -
        lazy_sum(q[j] for j in 1:narc if arc_bus[j] == i) +
        lazy_sum(qg[j] for j in keys(ref[:gen]) if gen_bus[j] == i),
        container = container,
    )
end

# ╔═╡ 50045b20-4134-424f-aa73-84ea8161d292
md"""
## Objective

We shouldn't expand the sum, just leave a sum operator in the expression graph.
"""

# ╔═╡ 6ab07549-0166-4cc6-ae60-fa63b0d84602
@objective(
    model,
    Min,
    lazy_sum(cost1[i] * pg[i]^2 + cost2[i] * pg[i] + cost3[i] for i in keys(ref[:gen])),
);

# ╔═╡ 5dc820bf-49c8-4bfe-9189-7d61ba503754
md"## CPU solve with MadNLP"

# ╔═╡ d7a0b969-459e-4fb1-be89-c972169e8152
md"## GPU solve with MadNLP"

# ╔═╡ 1ea1e950-04f9-4a21-b4a9-6b68aaf4e08e
md"# Zooming on the details"

# ╔═╡ a571ead2-d002-4c35-a1c3-af3461008196
md"## Appending values to the iterators"

# ╔═╡ 44875521-8ed5-4c84-b0ad-24238df0ca30
md"""
Explicit with ExaModels:
```julia
x0 = zeros(n)
x0s = [(i, x0[i]) for i = 1:n]
constraint(c, x[1, i] - x0 for (i, x0) in x0s)
```
Implicit in GenOpt:
```julia
@constraint(
    model,
    [i in 1:n],
    x[1, i] == x0[i],
    container = ParametrizedArray,
)
```
"""

# ╔═╡ ad6a2913-f3e6-4a88-b09b-deae7f750629
md"## Cartesian products"

# ╔═╡ 78c3e3da-c714-452d-b247-7eb956e2c530
md"""
Explicit with ExaModels:
```julia
itr0 = [(i, j, R[j]) for (i, j) in Base.product(1:N, 1:p)]
objective(c, 0.5 * R * (u[i, j]^2) for (i, j, R) in itr0)
```
Implicit in GenOpt:
```julia
@objective(
    model,
    Min,
    lazy_sum(0.5 * R[j] * (u[i, j]^2) for i in 1:N, j in 1:p) +
    ...,
)
```
"""

# ╔═╡ 3ea6c5ed-defb-4ff0-9dea-a89b6f1bdf44
md"## Array of variables"

# ╔═╡ 4a8c7fc7-b6c9-4f65-912b-47caaf42a02e
md"""
Indexing an array of variable `(x::Vector{VariableRef}[i::Iterator])`:

* We require the indices of `x` to be continuous and transform `x` into a custom struct only containing the starting index and size.
* This will not be compatible with variable reordering/deletion.
* This means that we store array nodes in `JuMP.NonlinearExpr`/`MOI.ScalarNonlinearFunction`
  - This will also be helpful for [ArrayDiff.jl](github.com/blegat/ArrayDiff.jl/) and [Convex.jl](https://github.com/jump-dev/Convex.jl)
"""

# ╔═╡ 48be9851-9dd6-4206-84aa-b9b6cd4529f3
md"# Future work"

# ╔═╡ 88b0d3fc-cdae-4704-b24a-f847509123ae
md"""
* Adding groups of terms to groups of **different** constraints:
```julia
constraint!(w, c9, a.bus => p[a.i] for a in data.arc)
constraint!(w, c10, a.bus => q[a.i] for a in data.arc)

constraint!(w, c9, g.bus => -pg[g.i] for g in data.gen)
constraint!(w, c10, g.bus => -qg[g.i] for g in data.gen)
```
* Efficient bridge from group of constraints to individual constraints using MutableArithmetics.
  - Since the groups are dismantled at the MOI level, this might fix [JuMP#1654](https://github.com/jump-dev/JuMP.jl/issues/1654)
"""

# ╔═╡ 463bb8c3-7b1c-443d-9a70-44c2ff5623f6
html"<p align=center style=\"font-size: 20px; margin-bottom: 5cm; margin-top: 5cm;\">The End</p>"

# ╔═╡ 2b17c40c-f312-420a-8ce7-90b41a9925c4
md"## Utils"

# ╔═╡ eabfc65e-bfb6-4f50-bbe8-40e4830209b6
import PGLib, PowerModels, ExaModels, MadNLP

# ╔═╡ abb9340f-167e-4b2c-bfc7-c9df0ef9319e
ref = let
    pm = PGLib.pglib("case3_lmbd")
    PowerModels.standardize_cost_terms!(pm, order = 2)
    PowerModels.calc_thermal_limits!(pm)
    PowerModels.build_ref(pm)[:it][:pm][:nw][0]
end

# ╔═╡ bda9c311-714c-4b96-a9ba-1ce36d75f721
begin
    # Arcs are `(branch, from_bus, to_bus)` tuples without a natural scalar id, so the flow
    # variables `p`/`q` are indexed by their position in `ref[:arcs]`.
    narc = length(ref[:arcs])
    arcdict = Dict(a => k for (k, a) in enumerate(ref[:arcs]))

    # Generator / objective data (looked up at an iterator index)
    cost1 = Dict(k => v["cost"][1] for (k, v) in ref[:gen])
    cost2 = Dict(k => v["cost"][2] for (k, v) in ref[:gen])
    cost3 = Dict(k => v["cost"][3] for (k, v) in ref[:gen])
    gen_bus = Dict(k => v["gen_bus"] for (k, v) in ref[:gen])
    arc_bus = Dict(k => i for (k, (l, i, j)) in enumerate(ref[:arcs]))

    # Bus aggregated load / shunt data
    bus_pd = Dict(k => sum(ref[:load][l]["pd"] for l in ref[:bus_loads][k]; init = 0.0) for (k, v) in ref[:bus])
    bus_qd = Dict(k => sum(ref[:load][l]["qd"] for l in ref[:bus_loads][k]; init = 0.0) for (k, v) in ref[:bus])
    bus_gs = Dict(k => sum(ref[:shunt][s]["gs"] for s in ref[:bus_shunts][k]; init = 0.0) for (k, v) in ref[:bus])
    bus_bs = Dict(k => sum(ref[:shunt][s]["bs"] for s in ref[:bus_shunts][k]; init = 0.0) for (k, v) in ref[:bus])

    # The series admittance / transformer ratio come from PowerModels functions, so we precompute
    # them (together with the topology and the shunt terms); the coefficients `c1..c8` are then
    # plain algebra written inline in the constraints.
    g = Dict{Int,Float64}()
    b = Dict{Int,Float64}()
    tr = Dict{Int,Float64}()
    ti = Dict{Int,Float64}()
    ttm = Dict{Int,Float64}()
    g_fr = Dict{Int,Float64}()
    b_fr = Dict{Int,Float64}()
    g_to = Dict{Int,Float64}()
    b_to = Dict{Int,Float64}()
    rate_a_sq = Dict{Int,Float64}()
    f_idx = Dict{Int,Int}()
    t_idx = Dict{Int,Int}()
    f_bus = Dict{Int,Int}()
    t_bus = Dict{Int,Int}()
    angmin = Dict{Int,Float64}()
    angmax = Dict{Int,Float64}()
    for (k, branch) in ref[:branch]
        g[k], b[k] = PowerModels.calc_branch_y(branch)
        tr[k], ti[k] = PowerModels.calc_branch_t(branch)
        ttm[k] = tr[k]^2 + ti[k]^2
        g_fr[k] = branch["g_fr"]
        b_fr[k] = branch["b_fr"]
        g_to[k] = branch["g_to"]
        b_to[k] = branch["b_to"]
        rate_a_sq[k] = branch["rate_a"]^2
        f_idx[k] = arcdict[(k, branch["f_bus"], branch["t_bus"])]
        t_idx[k] = arcdict[(k, branch["t_bus"], branch["f_bus"])]
        f_bus[k] = branch["f_bus"]
        t_bus[k] = branch["t_bus"]
        angmin[k] = branch["angmin"]
        angmax[k] = branch["angmax"]
    end

    ref_buses = collect(keys(ref[:ref_buses]))
end

# ╔═╡ b797f82d-c65b-4f73-b05d-e314d09f659a
model = Model(() -> ExaModels.Optimizer(MadNLP.madnlp))

# ╔═╡ 2f3cee5a-8c14-481d-83d8-3a6e080e5929
optimize!(model)

# ╔═╡ 695a10b8-63cb-4e29-a3bc-8852c30710b0
if CUDA.functional()
	set_optimizer(model, () -> GenOpt.ExaOptimizer(madnlp, CUDABackend()))
	optimize!(model)
end

# ╔═╡ 0da26bb1-6908-46ad-b608-e4a2dbfd7b39
begin
struct Path
    path::String
end

function imgpath(path::Path)
    file = path.path
    if !('.' in file)
        file = file * ".png"
    end
    return joinpath(joinpath(@__DIR__, "images", file))
end

function img(path::Path, args...; kws...)
    return PlutoUI.LocalResource(imgpath(path), args...)
end

struct URL
    url::String
end

function save_image(url::URL, html_attributes...; name = split(url.url, '/')[end], kws...)
    path = joinpath("cache", name)
    return PlutoTeachingTools.RobustLocalResource(url.url, path, html_attributes...), path
end

function img(url::URL, args...; kws...)
    r, _ = save_image(url, args...; kws...)
    return r
end

function img(file::String, args...; kws...)
    if startswith(file, "http")
        img(URL(file), args...; kws...)
    else
        img(Path(file), args...; kws...)
    end
end
end

# ╔═╡ Cell order:
# ╟─89cfbbb0-c3a7-11f0-bea8-6b8a0e78862d
# ╟─8e1d4a42-698d-469e-8c8b-b25ac806455e
# ╟─80e60e94-0309-4513-a5af-ebce2738be11
# ╟─87b15eed-0ddd-4814-98cf-5f7c538eeaf6
# ╟─4630c192-5783-4cb0-addf-09ef0bc7d6be
# ╟─eef717ab-ae1f-43ff-a929-65b511d47167
# ╠═abb9340f-167e-4b2c-bfc7-c9df0ef9319e
# ╟─2fd50dda-ac70-484c-93a6-d310af8b853c
# ╠═bda9c311-714c-4b96-a9ba-1ce36d75f721
# ╟─f7dd7e17-0ed2-46f9-ac32-cb4b1bdefb32
# ╠═b797f82d-c65b-4f73-b05d-e314d09f659a
# ╟─cb885f89-6208-4ada-9f7e-4782533a7f98
# ╠═4f3664f8-1fee-4ee2-ad08-fd99e19e0fff
# ╟─75f362c6-e69e-4cd1-8af7-6a7b6df06f25
# ╟─4c421cff-464a-41e2-b884-31011d5a07ec
# ╠═07aaa337-4b7c-45c9-be3a-d6379daa6f76
# ╠═9eb7720f-74d2-4b6b-8642-5debdab10aac
# ╟─5ae8f51d-ad92-4862-8980-5ae5ed7b0be3
# ╟─a0758565-57dd-4d51-bd63-97b993b45617
# ╠═33939427-62ac-4da4-8ed9-09251adb3063
# ╠═4844591b-a06a-44c7-975b-9e5feca118bd
# ╟─1b8ab92c-47ae-492d-88d7-afc070fdbaa9
# ╠═b8fca168-725f-4309-b1a7-ed1d5f089ff9
# ╟─4b390042-d9bb-4df3-84d7-7ec4da34969b
# ╠═ecda8485-1c19-4111-a859-e0fde43a7cea
# ╟─50045b20-4134-424f-aa73-84ea8161d292
# ╠═6ab07549-0166-4cc6-ae60-fa63b0d84602
# ╟─5dc820bf-49c8-4bfe-9189-7d61ba503754
# ╠═2f3cee5a-8c14-481d-83d8-3a6e080e5929
# ╟─d7a0b969-459e-4fb1-be89-c972169e8152
# ╠═695a10b8-63cb-4e29-a3bc-8852c30710b0
# ╟─1ea1e950-04f9-4a21-b4a9-6b68aaf4e08e
# ╟─a571ead2-d002-4c35-a1c3-af3461008196
# ╟─44875521-8ed5-4c84-b0ad-24238df0ca30
# ╟─ad6a2913-f3e6-4a88-b09b-deae7f750629
# ╟─78c3e3da-c714-452d-b247-7eb956e2c530
# ╟─3ea6c5ed-defb-4ff0-9dea-a89b6f1bdf44
# ╟─4a8c7fc7-b6c9-4f65-912b-47caaf42a02e
# ╟─48be9851-9dd6-4206-84aa-b9b6cd4529f3
# ╟─88b0d3fc-cdae-4704-b24a-f847509123ae
# ╟─463bb8c3-7b1c-443d-9a70-44c2ff5623f6
# ╟─2b17c40c-f312-420a-8ce7-90b41a9925c4
# ╠═fa2e13f9-b406-42c1-88e5-fe5607496d51
# ╠═24bf996e-03e9-40a7-a238-bd9d5050dc2b
# ╠═c3229e00-5d23-4986-994f-1d19911d9a03
# ╠═eabfc65e-bfb6-4f50-bbe8-40e4830209b6
# ╟─0da26bb1-6908-46ad-b608-e4a2dbfd7b39
