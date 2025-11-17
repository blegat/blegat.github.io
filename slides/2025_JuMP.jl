### A Pluto.jl notebook ###
# v0.20.20

using Markdown
using InteractiveUtils

# ╔═╡ d86cdbb6-aa04-4cbb-9427-5118754b12c7
using Pkg

# ╔═╡ 1f7ad6eb-6a79-4a7f-adba-9f408e1c2ed6
Pkg.activate("/home/blegat/.julia/dev/GenOpt")

# ╔═╡ c3229e00-5d23-4986-994f-1d19911d9a03
using PlutoUI, HypertextLiteral, PlutoTeachingTools, JuMP, HiGHS, LinearAlgebra, SparseArrays, NLPModelsIpopt, BenchmarkTools, GenOpt, MadNLP, MadNLPGPU, CUDA

# ╔═╡ 8e1d4a42-698d-469e-8c8b-b25ac806455e
md"# Introduction"

# ╔═╡ 80e60e94-0309-4513-a5af-ebce2738be11
md"""
* ExaModels and MadNLP can differentiate and solve problems on GPU
  - Winners of COIN-OR Cup 2023 and JuMP-dev 2025
* ExaModels need common structure to be grouped together but JuMP does not communicate this structure
* ExaModels tries to rebuild this structure in its JuMP interface
* [MathOptSymbolicAD](https://github.com/lanl-ansi/MathOptSymbolicAD.jl) also regroups these to save symbolic differentiation time
* We discussed on how to better integrate ExaModels in JuMP during JuMP-dev 2025 hackathon with Miles and Alexis.
"""

# ╔═╡ 87b15eed-0ddd-4814-98cf-5f7c538eeaf6
md"## Objectives"

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

# ╔═╡ a3528c53-1163-456e-90f1-525119cdef4b
md"# Example"

# ╔═╡ 243d79be-f55c-4388-8f65-eecce19aefea
md"""
[Quadrotor tutorial from ExaModels](https://exanauts.github.io/ExaModels.jl/dev/quad/).
Repeated structures are:
* Similar constraints along time steps
* Sum of similar terms in the objective
"""

# ╔═╡ eef717ab-ae1f-43ff-a929-65b511d47167
md"## Example with GenOpt"

# ╔═╡ a7d672cc-3f55-496b-80c4-76e597a16bc1
md"Problem data (copy-pasted from [ExaModels' example](https://exanauts.github.io/ExaModels.jl/stable/quad/)]):"

# ╔═╡ abb9340f-167e-4b2c-bfc7-c9df0ef9319e
begin
N = 3

n = 9
p = 4
d(i, j, N) =
    (j == 1 ? 1 * sin(2 * pi / N * i) : 0.0) +
    (j == 3 ? 2 * sin(4 * pi / N * i) : 0.0) +
    (j == 5 ? 2 * i / N : 0.0)
dt = 1/N
R = fill(1 / 10, 4)
Q = [1, 0, 1, 0, 1, 0, 1, 1, 1]
Qf = [1, 0, 1, 0, 1, 0, 1, 1, 1] / dt

x0 = zeros(n)
model = Model()

@variable(model, x[1:(N+1), 1:n])
@variable(model, u[1:N, 1:p])
end

# ╔═╡ 75f362c6-e69e-4cd1-8af7-6a7b6df06f25
md"## Approach of GenOpt"

# ╔═╡ 4c421cff-464a-41e2-b884-31011d5a07ec
md"""
Users already group constraints with containers, the container receives a function and the iterators, like `Base.Generator`.
"""

# ╔═╡ d06d4bdb-a4e4-4bfd-9243-1878723d2629
@constraint(model, classical[i in 1:n], x[1, i] == x0[i])

# ╔═╡ 326db900-7214-4121-aee5-ada44cc749f2
delete(model, classical)

# ╔═╡ 5ae8f51d-ad92-4862-8980-5ae5ed7b0be3
md"`ExaModels.constraint` expect a `Base.Generator` as well so containers seems to be the right approach. We use a custom container that gives custom objects for `i` and handle interaction with `JuMP.NonlinearExpr` with **operator overloading**."

# ╔═╡ 368b603a-198c-4a4d-a14e-98a3e270e33b
begin
@constraint(
    model,
    start[i in 1:n],
    x[1, i] == x0[i],
    container = GenOpt.ParametrizedArray,
);
println(start)
end

# ╔═╡ a0758565-57dd-4d51-bd63-97b993b45617
md"## Constraints"

# ╔═╡ 33939427-62ac-4da4-8ed9-09251adb3063
begin
container = GenOpt.ParametrizedArray
@constraint(
    model,
    [i in 1:N],
    x[i+1, 1] == x[i, 1] + (x[i, 2]) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 2] ==
    x[i, 2] +
    (
        u[i, 1] * cos(x[i, 7]) * sin(x[i, 8]) * cos(x[i, 9]) +
        u[i, 1] * sin(x[i, 7]) * sin(x[i, 9])
    ) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 3] == x[i, 3] + (x[i, 4]) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 4] ==
    x[i, 4] +
    (
        u[i, 1] * cos(x[i, 7]) * sin(x[i, 8]) * sin(x[i, 9]) -
        u[i, 1] * sin(x[i, 7]) * cos(x[i, 9])
    ) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 5] == x[i, 5] + (x[i, 6]) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 6] == x[i, 6] + (u[i, 1] * cos(x[i, 7]) * cos(x[i, 8]) - 9.8) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 7] ==
    x[i, 7] +
    (u[i, 2] * cos(x[i, 7]) / cos(x[i, 8]) + u[i, 3] * sin(x[i, 7]) / cos(x[i, 8])) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 8] == x[i, 8] + (-u[i, 2] * sin(x[i, 7]) + u[i, 3] * cos(x[i, 7])) * dt,
    container = container,
)
@constraint(
    model,
    [i in 1:N],
    x[i+1, 9] ==
    x[i, 9] +
    (
        u[i, 2] * cos(x[i, 7]) * tan(x[i, 8]) +
        u[i, 3] * sin(x[i, 7]) * tan(x[i, 8]) +
        u[i, 4]
    ) * dt,
    container = container,
)
end;

# ╔═╡ 50045b20-4134-424f-aa73-84ea8161d292
md"## Objective"

# ╔═╡ 6ab07549-0166-4cc6-ae60-fa63b0d84602
begin
itr1 = [(i, j, d(i, j, N)) for i in 1:N, j in 1:n]
itr2 = [(j, d(N + 1, j, N)) for j in 1:n]
@objective(
    model,
    Min,
    lazy_sum(0.5 * R[j] * (u[i, j]^2) for i in 1:N, j in 1:p) +
    lazy_sum(0.5 * Q[it[2]] * (x[it[1], it[2]] - it[3])^2 for it in itr1) +
    lazy_sum(0.5 * Qf[it[1]] * (x[N+1, it[1]] - it[2])^2 for it in itr2),
)
end;

# ╔═╡ 5dc820bf-49c8-4bfe-9189-7d61ba503754
md"## CPU solve with MadNLP"

# ╔═╡ 2f3cee5a-8c14-481d-83d8-3a6e080e5929
begin
set_optimizer(model, () -> GenOpt.ExaOptimizer(madnlp))
optimize!(model)
end

# ╔═╡ d7a0b969-459e-4fb1-be89-c972169e8152
md"## GPU solve with MadNLP"

# ╔═╡ 695a10b8-63cb-4e29-a3bc-8852c30710b0
if CUDA.functional()
	set_optimizer(model, () -> GenOpt.ExaOptimizer(madnlp, CUDABackend()))
	optimize!(model)
end

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

# ╔═╡ 89cfbbb0-c3a7-11f0-bea8-6b8a0e78862d
@htl("""
<p align=center style=\"font-size: 40px;\">Large Scale JuMP Models with Constraint Generators</p>
<p align=right><i>Benoît Legat</i></p>
$(img("https://jump.dev/assets/jump-dev-workshops/2025/jump-dev-nz.png", :width => 100))
$(PlutoTeachingTools.ChooseDisplayMode())
$(PlutoUI.TableOfContents(depth=1))
""")

# ╔═╡ Cell order:
# ╟─89cfbbb0-c3a7-11f0-bea8-6b8a0e78862d
# ╟─8e1d4a42-698d-469e-8c8b-b25ac806455e
# ╟─80e60e94-0309-4513-a5af-ebce2738be11
# ╟─87b15eed-0ddd-4814-98cf-5f7c538eeaf6
# ╟─4630c192-5783-4cb0-addf-09ef0bc7d6be
# ╟─a3528c53-1163-456e-90f1-525119cdef4b
# ╟─243d79be-f55c-4388-8f65-eecce19aefea
# ╟─eef717ab-ae1f-43ff-a929-65b511d47167
# ╟─a7d672cc-3f55-496b-80c4-76e597a16bc1
# ╠═abb9340f-167e-4b2c-bfc7-c9df0ef9319e
# ╟─75f362c6-e69e-4cd1-8af7-6a7b6df06f25
# ╟─4c421cff-464a-41e2-b884-31011d5a07ec
# ╠═d06d4bdb-a4e4-4bfd-9243-1878723d2629
# ╠═326db900-7214-4121-aee5-ada44cc749f2
# ╟─5ae8f51d-ad92-4862-8980-5ae5ed7b0be3
# ╠═368b603a-198c-4a4d-a14e-98a3e270e33b
# ╟─a0758565-57dd-4d51-bd63-97b993b45617
# ╠═33939427-62ac-4da4-8ed9-09251adb3063
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
# ╠═d86cdbb6-aa04-4cbb-9427-5118754b12c7
# ╠═1f7ad6eb-6a79-4a7f-adba-9f408e1c2ed6
# ╠═c3229e00-5d23-4986-994f-1d19911d9a03
# ╟─0da26bb1-6908-46ad-b608-e4a2dbfd7b39
