### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 952ad135-1b95-4474-b375-8ea4b3e71379
using PlutoUI, HypertextLiteral, PlutoTeachingTools, JuMP, HiGHS, LinearAlgebra, SparseArrays, DataFrames, Ipopt, BenchmarkTools

# ╔═╡ fc798481-a32c-498f-90d9-9af8894649ff
md"# Introduction"

# ╔═╡ 89bb53e7-18b5-45ed-aa81-5dafade4cc01
example = Model(HiGHS.Optimizer)

# ╔═╡ 50122d7d-2891-4d35-94a3-f1d9a10e5dcf
tip(md"Thes solver can be specified later or changed with `set_optimizer`")

# ╔═╡ 50dcaf9a-87ff-4e66-8b1c-0dc020d45232
md"## Creating variables

Scalar variables:"

# ╔═╡ 8453a153-5ebb-4df1-9110-af9b860cda0c
@variable(example, x >= 0)

# ╔═╡ 10f1eff4-7ee8-4ba4-af5e-01d952588e8a
md"Container of variables:"

# ╔═╡ 04212258-76fe-4411-9958-cdd76c52403d
@variable(example, 0 <= y[i=1:3] <= i)

# ╔═╡ e4df9dc8-0af6-4d07-af41-ade507ba7591
md"## Objective function"

# ╔═╡ 4d6c04b9-c582-47ff-bae1-f3feafc16347
@objective(example, Min, 12x + 20sum(y))

# ╔═╡ e525be42-cce5-42ce-bc17-988292270c44
md"## Constraints"

# ╔═╡ 44b27e6a-17e1-4996-badf-a57549db15de
@constraint(example, c1, 6x + 8y[1] - y[2] >= 100)

# ╔═╡ a3e4fe05-e764-4aae-aa9c-dada2822cd8b
md"Container of constraints:"

# ╔═╡ e04f0e3c-6fe6-4a10-8c35-f4ffb033bf12
@constraint(example, c2[i=1:3], 7x + 12y[i] >= 120)

# ╔═╡ ac37e82f-c54d-4541-bf80-9a1b3e079492
tip(md"Give names to constraints for easy access to the dual")

# ╔═╡ be747399-7c08-4e39-bf73-07e179d4b063
md"## Printing the model"

# ╔═╡ 554985ea-c9a5-4863-81b7-a77ecfc8344c
example

# ╔═╡ 3f022f36-c3ac-4e16-aaad-b16315e3a8b5
print(example)

# ╔═╡ da5a2cde-06ed-405e-a523-4f336048f3a4
md"## Optimization"

# ╔═╡ e528d104-54fa-4be2-b647-3ef2b5783f4b
optimize!(example)

# ╔═╡ 31dc3684-3354-4e8d-82d3-1f3fb68a69d9
tip(md"""
* Solver log is helpful to see progress of long-running solve but it can be deactivated with `set_silent(example)`
* Tweak solver parameters with `set_attribute`
""")

# ╔═╡ b72767b7-626c-4b4a-b216-fa8af274e8a9
md"## Fetching the result"

# ╔═╡ 0b237820-3cec-4127-82c9-4c5860a098c9
warning_box(md"JuMP does not throw any warning if the solver failed, ran into numerical errors, found the problem to be infeasible or unbounded, you **always** need to check it **explicitly**!")

# ╔═╡ 19aeb37c-080c-4320-8dd6-e4e73913452b
md"The quick diagnostic:"

# ╔═╡ 0b8ab782-0d2e-485e-a677-c686a238be10
is_solved_and_feasible(example)

# ╔═╡ c1f0ed47-e098-454c-a607-703020b56707
md"The detailed version:"

# ╔═╡ 8a07a37f-b46e-4457-a8fb-e19ab80211a8
solution_summary(example)

# ╔═╡ 6194d682-356c-4727-a12a-9eaf2c9198d2
md"You can query each of these programmatically with the corresponding function:"

# ╔═╡ e8be65af-33b0-4364-84ea-2174124f30e4
termination_status(example)

# ╔═╡ 33b891ba-d146-4af3-85a6-17a73c542779
md"Now we know what the solution corresponds to:"

# ╔═╡ 6bee983d-add3-440d-bb71-9290f82bb23c
value(x), value(y), dual(c1), dual.(c2)

# ╔═╡ 97856d04-38c8-4958-bad8-1c1ab95390e6
tip(md"The `termination_status`, `primal_status` and `dual_status` are `enum`s so there are appropriate for programmatically checking the status. The `raw_status` allows the solver to communicate solver-specific status information. Other solver-specific results can be queried through custom [attributes](https://jump.dev/MathOptInterface.jl/stable/manual/models/#Attributes).")

# ╔═╡ a65d555a-c9c1-444e-8001-7dc4fa9c80d9
md"# AC Optimal Power Flow example"

# ╔═╡ 0008f72c-29e1-4a75-a892-fe1db3d6c062
md"Let's illustrate all these with [this example](https://jump.dev/JuMP.jl/stable/tutorials/applications/optimal_power_flow/)."

# ╔═╡ d133e4ae-46ae-47d0-ac35-c455d0128fbe
begin
N = 9
# Real generation: lower (`lb`) and upper (`ub`) bounds
P_Gen_lb = SparseArrays.sparsevec([1, 2, 3], [10, 10, 10], N)
P_Gen_ub = SparseArrays.sparsevec([1, 2, 3], [250, 300, 270], N)
# Reactive generation: lower (`lb`) and upper (`ub`) bounds
Q_Gen_lb = SparseArrays.sparsevec([1, 2, 3], [-5, -5, -5], N)
Q_Gen_ub = SparseArrays.sparsevec([1, 2, 3], [300, 300, 300], N)
# Power demand levels (real, reactive, and complex form)
P_Demand = SparseArrays.sparsevec([5, 7, 9], [54, 60, 75], N)
Q_Demand = SparseArrays.sparsevec([5, 7, 9], [18, 21, 30], N)
S_Demand = P_Demand + im * Q_Demand
branch_data = DataFrames.DataFrame([
    (1, 4, 0.0, 0.0576, 0.0, 250),
    (4, 5, 0.017, 0.092, 0.158, 250),
    (6, 5, 0.039, 0.17, 0.358, 150),
    (3, 6, 0.0, 0.0586, 0.0, 300),
    (6, 7, 0.0119, 0.1008, 0.209, 150),
    (8, 7, 0.0085, 0.072, 0.149, 250),
    (2, 8, 0.0, 0.0625, 0.0, 250),
    (8, 9, 0.032, 0.161, 0.306, 250),
    (4, 9, 0.01, 0.085, 0.176, 250),
]);
DataFrames.rename!(branch_data, [:F_BUS, :T_BUS, :BR_R, :BR_X, :BR_Bc, :RATE_A])
end

# ╔═╡ 51064083-af2c-4120-bf6a-e4bd631e7964
md"Let's define the [incidence matrix](https://en.wikipedia.org/wiki/Incidence_matrix):"

# ╔═╡ d17e39f1-d156-46c8-9dec-426a4827b431
B = let
	M = size(branch_data, 1)
	SparseArrays.sparse(branch_data.F_BUS, 1:M, 1, N, M) +
    SparseArrays.sparse(branch_data.T_BUS, 1:M, -1, N, M)
end

# ╔═╡ 290b541c-57cb-482a-a58c-9656e07ad5b1
tip(md"We still don't support units in JuMP but we have a [small development grant proposal](https://github.com/numfocus/small-development-grant-proposals/issues/54) for this so stay tuned.")

# ╔═╡ aeb2f947-6a30-4d81-a7cc-c83778cf0a3b
base_MVA = 100

# ╔═╡ c2e6ab06-19e3-43d2-bd4b-0ed045888286
md"Line impedance: resistance real part and reactance imaginary part."

# ╔═╡ 3ab81f14-3f52-4e6d-b601-b38901126d1a
z = (branch_data.BR_R .+ im * branch_data.BR_X) / base_MVA

# ╔═╡ b8d831bf-68ce-4425-a025-544b79de0166
model = Model(Ipopt.Optimizer)

# ╔═╡ 9227e9f9-791a-4519-b022-3af8d86aa4ad
tip(md"Easily create complex decision variables with `ComplexPlane()`. This in turns create two real variables for the solver but it allows you to use complex arithmetic to build the model.")

# ╔═╡ 0b666954-58a7-42b6-bfc4-b331ecdeede3
@variable(
    model,
    S_G[i in 1:N] in ComplexPlane(),
    lower_bound = P_Gen_lb[i] + Q_Gen_lb[i] * im,
    upper_bound = P_Gen_ub[i] + Q_Gen_ub[i] * im,
)

# ╔═╡ 7410e7e4-d89e-422f-8796-60d7eef0ea8f
@variable(model, V[1:N] in ComplexPlane(), start = 1.0 + 0.0im)

# ╔═╡ f1b91972-e95c-4fb4-babb-0db92822805a
md"Bounds on voltages"

# ╔═╡ 1c03aa5a-2767-4f58-9d8d-363f158aadff
@constraint(model, [i in 1:N], 0.9^2 <= abs2(V[i]) <= 1.1^2)

# ╔═╡ 224c9b6c-c683-4e15-a48c-dd0b0b910d37
tip(md"`abs2(z)` of a complex number `z = a + b * im` gives `a^2 + b^2` so it is equivalent to `real(z)^2 + imag(z)^2`. If `z` is an `AffExpr`, this gives a `QuadExpr`, not a `NonlinearExpr`.")

# ╔═╡ 0e7ceb0f-5ccb-4ad9-93ad-d0a1efaf4f3e
md"The solution is invariant under rotation so let's break that symmetry."

# ╔═╡ beab4128-5c32-485f-8178-eb9fb964605c
@constraint(model, imag(V[1]) == 0)

# ╔═╡ e76bd264-64c1-48ca-ba84-42a5d6e62377
@constraint(model, real(V[1]) >= 0)

# ╔═╡ 21211a51-1240-427f-b927-9e7b731bc6df
P_G = real(S_G)

# ╔═╡ 676e846b-5eeb-40b0-b6e7-eb6e04f13711
@objective(
    model,
    Min,
    (0.11 * P_G[1]^2 + 5 * P_G[1] + 150) +
    (0.085 * P_G[2]^2 + 1.2 * P_G[2] + 600) +
    (0.1225 * P_G[3]^2 + P_G[3] + 335),
)

# ╔═╡ 8804d08b-fcfa-4143-a869-b4277be8a0b3
md"## Exercise:"

# ╔═╡ 50e109b5-8463-4278-a32e-6c54610c7a10
md"""
Implement the constraint:
```math
S_u = V_uI_u^*
```
for each node ``u``.
Given a branch ``b`` from ``u`` to ``v``:
* The current ``I_b`` is ``(V_v - V_u) / z_b``.
* The current ``I_u`` should be decreased ``I_b`` and the current ``I_v`` should be increased by ``I_b``.
"""

# ╔═╡ 902dfb1b-29cc-40fb-bb0f-f9aa039d5150
md"## Solution (don't scroll down!)"

# ╔═╡ 8840adfe-bf32-4efe-be3a-e583e07318ef
ΔV = B' * V

# ╔═╡ 2cdf86b0-3817-45d5-9ccc-8b0754b048b5
I_branches = ΔV ./ z

# ╔═╡ 3ab34add-c501-4706-a302-95f6d714117a
I_nodes = B * I_branches

# ╔═╡ e5ebd67c-e0e4-45b7-8fad-7d1098c3a747
@constraint(model, S_G - S_Demand .== V .* conj(I_nodes))

# ╔═╡ 27a83533-fd51-4dc0-8d09-5dd8d18311c6
optimize!(model)

# ╔═╡ 716551c3-731f-4637-bfb0-a9de52ac64da
assert_is_solved_and_feasible(model)

# ╔═╡ 446a4754-601d-425a-ab9a-2a0fcd00f42a
solution_summary(model)

# ╔═╡ 418775c7-cdbd-4ef0-8748-b3c4bfddf616
objective_value(model)

# ╔═╡ 5adc6654-0cb7-4afb-8e25-e41f4a1edb24
md"## Performance consideration"

# ╔═╡ 0121c1b6-fe2e-4508-a1c1-9f17dc57d16f
@which B * V

# ╔═╡ 39d51165-bb39-44c0-824b-3785ef7bbf7d
function matvec(B, z, V)
	ΔV = B' * V
	I_branches = ΔV ./ z
	return B * I_branches
end

# ╔═╡ a3114227-0bee-43fb-a1c3-ae8f197daf38
function matmat(B, z, V)
	Y = B * LinearAlgebra.Diagonal(inv.(z)) * B'
	Y * V
end

# ╔═╡ 10b0120c-13f3-4129-b872-993497e3c337
@benchmark matvec(B, z, V)

# ╔═╡ 67a35680-3904-4aaf-a8c1-7ca693127bfa
@benchmark matmat(B, z, V)

# ╔═╡ 081b7680-ec6c-4f18-b027-5224059a4aef
md"`n` = $(@bind n Slider(10:100, show_value = true))"

# ╔═╡ 2623e644-9edb-45f2-9b1c-d886ffc5672d
V_bigger = let
	bench = Model()
	@variable(bench, [1:n] in ComplexPlane())
end

# ╔═╡ 912c761e-e04f-43c5-af4e-9a4e886c6f1c
B_bigger = sparse(rand(1:n, n), 1:n, -1, n, n) + sparse(rand(1:n, n), 1:n, 1, n, n)

# ╔═╡ 65d52fc8-da8d-48b7-b4e6-0ed237b6b2f8
@benchmark matvec(B, z, V)

# ╔═╡ 7ae1de51-114d-4762-8737-96df360df2e5
@benchmark matmat($B, $z, $V)

# ╔═╡ 61cac904-79d1-43d9-8493-ef99d96624e4
z_bigger = rand(n)

# ╔═╡ 33a3dcfb-d4c8-400b-bd13-4fa45496b4b6
mat = rand(n, n)

# ╔═╡ 6013c01b-8ce4-4fc0-95dd-f0e3529a1219
@benchmark ($mat * $mat) * $V_bigger

# ╔═╡ 2f86d094-6062-47ed-90f2-1264cff73d2a
@benchmark $mat * ($mat * $V_bigger)

# ╔═╡ 7e670fce-c24a-46a9-829f-edc024e13283
md"### Utilities"

# ╔═╡ 6eb70f10-7596-4cc0-91c0-0a55185fa7b5
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

# ╔═╡ 070aa82a-9ef4-11f0-1925-43c1c741e3fc
@htl("""
<p align=center style=\"font-size: 40px;\">Optimization with JuMP</p>
<p align=right><i>Benoît Legat</i></p>
$(img("https://juliacon.org/assets/local/paris2025/img/logo_paris.svg", :width => 100))
$(PlutoTeachingTools.ChooseDisplayMode())
$(PlutoUI.TableOfContents(depth=1))
""")

# ╔═╡ fedb9b07-47c8-4c5e-b6c8-42f00a986a30
img("https://jump.dev/JuMP.jl/stable/assets/case9mod.png", :width => 350)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HiGHS = "87dc4568-4c63-4d18-b0c0-bb2238e4078b"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Ipopt = "b6b21f68-93f8-5de0-b562-5493be1d77c9"
JuMP = "4076af6c-e467-56ae-b986-b466b2749572"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
BenchmarkTools = "~1.8.0"
DataFrames = "~1.8.2"
HiGHS = "~1.24.1"
HypertextLiteral = "~1.0.0"
Ipopt = "~1.15.0"
JuMP = "~1.30.1"
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "8fd8ab362ca35093de2426de6d11379bbbe1455e"

[[deps.ASL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6252039f98492252f9e47c312c8ffda0e3b9e78d"
uuid = "ae81ac8f-d209-56e5-92de-9978fef736f9"
version = "0.1.3+0"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "6c3913f4e9bdf6ba3c08041a446fb1332716cbc2"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "PrecompileTools", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "9670d3febc2b6da60a0ae57846ba74670290653f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.8.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "TranscodingStreams"]
git-tree-sha1 = "84990fa864b7f2b4901901ca12736e45ee79068c"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.8.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5fab31e2e01e70ad66e3e24c968c264d1cf166d6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.2"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "6fb53a69613a0b2b68a0d12671717d307ab8b24e"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.5"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "79a2aca180a85c690c58a020d47b426954b590f8"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.16.0"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "2c5d0b0e12088cde2cf84afb2784415b1ea3dfee"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "1.4.1"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.HiGHS]]
deps = ["HiGHS_jll", "LinearAlgebra", "MathOptIIS", "MathOptInterface", "OpenBLAS32_jll", "PrecompileTools", "SparseArrays"]
git-tree-sha1 = "01a5241985559c08a5baadbcebd6d87daaf84a84"
uuid = "87dc4568-4c63-4d18-b0c0-bb2238e4078b"
version = "1.24.1"

[[deps.HiGHS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Zlib_jll", "libblastrampoline_jll"]
git-tree-sha1 = "5814a4409f49e8430c184cbe4bc19fa2957bbf0a"
uuid = "8fd58aa0-07eb-5a78-9b36-339c94fd15ea"
version = "1.15.1+0"

[[deps.Hwloc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XML2_jll", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "c35847ca5b4997fc8418836354a56c459bcf48d8"
uuid = "e33a78d0-f292-5ffc-b300-72abe9b543c8"
version = "2.14.0+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.Ipopt]]
deps = ["Ipopt_jll", "LinearAlgebra", "OpenBLAS32_jll", "PrecompileTools"]
git-tree-sha1 = "f8443766032a81e1f2cddfd4f624a5650067f0d0"
uuid = "b6b21f68-93f8-5de0-b562-5493be1d77c9"
version = "1.15.0"
weakdeps = ["MathOptInterface"]

    [deps.Ipopt.extensions]
    IpoptMathOptInterfaceExt = "MathOptInterface"

[[deps.Ipopt_jll]]
deps = ["ASL_jll", "Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "MUMPS_seq_jll", "SPRAL_jll", "libblastrampoline_jll"]
git-tree-sha1 = "d58bb7f6393b8ec1f6fb39eb6c1a7a83b8f8b521"
uuid = "9cc047cb-c261-5740-88fc-0cf96f7bdcc7"
version = "300.1400.1902+0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "c89d196f5ffb64bfbf80985b699ea913b0d2c211"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.6.1"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c0c9b76f3520863909825cbecdef58cd63de705a"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.5+0"

[[deps.JuMP]]
deps = ["LinearAlgebra", "MacroTools", "MathOptInterface", "MutableArithmetics", "OrderedCollections", "PrecompileTools", "Printf", "SparseArrays"]
git-tree-sha1 = "6941586d9cf3c0af718bc6e6250dcf24057d412e"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "1.30.1"

    [deps.JuMP.extensions]
    JuMPDimensionalDataExt = "DimensionalData"

    [deps.JuMP.weakdeps]
    DimensionalData = "0703355e-b756-11e9-17c0-8b28908087d0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "bba2d9aa057d8f126415de240573e86a8f39d2a1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.1"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.METIS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2eefa8baa858871ae7770c98c3c2a7e46daba5b4"
uuid = "d00139f3-1899-568f-a2f0-47f597d42d70"
version = "5.1.3+0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MUMPS_seq_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "METIS_jll", "libblastrampoline_jll"]
git-tree-sha1 = "eb4f9c84cbe9139594752e3e5b71b2ed4be140b8"
uuid = "d7ed1dd3-d0ae-5e8e-bfb4-87a502085b8d"
version = "500.900.0+0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MathOptIIS]]
deps = ["MathOptInterface"]
git-tree-sha1 = "3b3d69130d8ab8c39d5fa4d30e20a8e6428c9d37"
uuid = "8c4f8055-bd93-4160-a86b-a0c04941dbff"
version = "0.2.0"

[[deps.MathOptInterface]]
deps = ["CodecBzip2", "CodecZlib", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "PrecompileTools", "Printf", "SparseArrays", "SpecialFunctions", "Test"]
git-tree-sha1 = "9f23c8c1667bd0b0e611110aaf80aa91c1bdf274"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.51.1"

    [deps.MathOptInterface.extensions]
    MathOptInterfaceBenchmarkToolsExt = "BenchmarkTools"
    MathOptInterfaceCliqueTreesExt = "CliqueTrees"

    [deps.MathOptInterface.weakdeps]
    BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
    CliqueTrees = "60701a23-6482-424a-84db-faee86b9b1f8"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "dc5b2c4c111c46bc79ac4405eeb563523b39c004"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.8.0"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "libblastrampoline_jll"]
git-tree-sha1 = "8b492aefdd20fb9dc1ebc377ff7e5fa1591c9acc"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.33+2"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "94ba93778373a53bfd5a0caaf7d809c445292ff4"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "32a4e09c5f29402573d673901778a0e03b0807b9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.6"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "90b41ced6bacd8c01bd05da8aed35c5458891749"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.7"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "REPL", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "624de6279ab7d94fc9f672f0068107eb6619732c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "3.3.2"

    [deps.PrettyTables.extensions]
    PrettyTablesTypstryExt = "Typstry"

    [deps.PrettyTables.weakdeps]
    Typstry = "f0ed7684-a786-439e-b1e3-3b82803b501e"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
deps = ["StyledStrings"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SPRAL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Hwloc_jll", "JLLWrappers", "Libdl", "METIS_jll", "libblastrampoline_jll"]
git-tree-sha1 = "139fa63f03a16b3d859d925ee9149dfc15f21ece"
uuid = "319450e9-13b8-58e8-aa9f-8fd1420848ab"
version = "2025.9.18+0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "084c47c7c5ce5cfecefa0a98dff69eb3646b5a80"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.10"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "6547cbdd8ce32efba0d21c5a40fa96d1a3548f9f"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.8.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "d05693d339e37d6ab134c5ab53c29fce5ee5d7d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.4"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "82bee338d650aa515f31866c460cb7e3bcef90b8"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.8.2"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "0f38a06c83f0007bbab3cf911262841c9a0f07e0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.13.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "80d3930c6347cfce7ccf96bd3bafdf079d9c0390"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.9+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"
"""

# ╔═╡ Cell order:
# ╟─070aa82a-9ef4-11f0-1925-43c1c741e3fc
# ╟─fc798481-a32c-498f-90d9-9af8894649ff
# ╠═89bb53e7-18b5-45ed-aa81-5dafade4cc01
# ╟─50122d7d-2891-4d35-94a3-f1d9a10e5dcf
# ╟─50dcaf9a-87ff-4e66-8b1c-0dc020d45232
# ╠═8453a153-5ebb-4df1-9110-af9b860cda0c
# ╟─10f1eff4-7ee8-4ba4-af5e-01d952588e8a
# ╠═04212258-76fe-4411-9958-cdd76c52403d
# ╟─e4df9dc8-0af6-4d07-af41-ade507ba7591
# ╠═4d6c04b9-c582-47ff-bae1-f3feafc16347
# ╟─e525be42-cce5-42ce-bc17-988292270c44
# ╠═44b27e6a-17e1-4996-badf-a57549db15de
# ╟─a3e4fe05-e764-4aae-aa9c-dada2822cd8b
# ╠═e04f0e3c-6fe6-4a10-8c35-f4ffb033bf12
# ╟─ac37e82f-c54d-4541-bf80-9a1b3e079492
# ╟─be747399-7c08-4e39-bf73-07e179d4b063
# ╠═554985ea-c9a5-4863-81b7-a77ecfc8344c
# ╠═3f022f36-c3ac-4e16-aaad-b16315e3a8b5
# ╟─da5a2cde-06ed-405e-a523-4f336048f3a4
# ╠═e528d104-54fa-4be2-b647-3ef2b5783f4b
# ╟─31dc3684-3354-4e8d-82d3-1f3fb68a69d9
# ╟─b72767b7-626c-4b4a-b216-fa8af274e8a9
# ╟─0b237820-3cec-4127-82c9-4c5860a098c9
# ╟─19aeb37c-080c-4320-8dd6-e4e73913452b
# ╠═0b8ab782-0d2e-485e-a677-c686a238be10
# ╟─c1f0ed47-e098-454c-a607-703020b56707
# ╠═8a07a37f-b46e-4457-a8fb-e19ab80211a8
# ╟─6194d682-356c-4727-a12a-9eaf2c9198d2
# ╠═e8be65af-33b0-4364-84ea-2174124f30e4
# ╟─33b891ba-d146-4af3-85a6-17a73c542779
# ╠═6bee983d-add3-440d-bb71-9290f82bb23c
# ╟─97856d04-38c8-4958-bad8-1c1ab95390e6
# ╟─a65d555a-c9c1-444e-8001-7dc4fa9c80d9
# ╟─0008f72c-29e1-4a75-a892-fe1db3d6c062
# ╟─fedb9b07-47c8-4c5e-b6c8-42f00a986a30
# ╟─d133e4ae-46ae-47d0-ac35-c455d0128fbe
# ╟─51064083-af2c-4120-bf6a-e4bd631e7964
# ╠═d17e39f1-d156-46c8-9dec-426a4827b431
# ╟─290b541c-57cb-482a-a58c-9656e07ad5b1
# ╠═aeb2f947-6a30-4d81-a7cc-c83778cf0a3b
# ╟─c2e6ab06-19e3-43d2-bd4b-0ed045888286
# ╠═3ab81f14-3f52-4e6d-b601-b38901126d1a
# ╠═b8d831bf-68ce-4425-a025-544b79de0166
# ╟─9227e9f9-791a-4519-b022-3af8d86aa4ad
# ╠═0b666954-58a7-42b6-bfc4-b331ecdeede3
# ╠═7410e7e4-d89e-422f-8796-60d7eef0ea8f
# ╟─f1b91972-e95c-4fb4-babb-0db92822805a
# ╠═1c03aa5a-2767-4f58-9d8d-363f158aadff
# ╟─224c9b6c-c683-4e15-a48c-dd0b0b910d37
# ╟─0e7ceb0f-5ccb-4ad9-93ad-d0a1efaf4f3e
# ╠═beab4128-5c32-485f-8178-eb9fb964605c
# ╠═e76bd264-64c1-48ca-ba84-42a5d6e62377
# ╠═21211a51-1240-427f-b927-9e7b731bc6df
# ╠═676e846b-5eeb-40b0-b6e7-eb6e04f13711
# ╟─8804d08b-fcfa-4143-a869-b4277be8a0b3
# ╟─50e109b5-8463-4278-a32e-6c54610c7a10
# ╟─902dfb1b-29cc-40fb-bb0f-f9aa039d5150
# ╠═8840adfe-bf32-4efe-be3a-e583e07318ef
# ╠═2cdf86b0-3817-45d5-9ccc-8b0754b048b5
# ╠═3ab34add-c501-4706-a302-95f6d714117a
# ╠═e5ebd67c-e0e4-45b7-8fad-7d1098c3a747
# ╠═27a83533-fd51-4dc0-8d09-5dd8d18311c6
# ╠═716551c3-731f-4637-bfb0-a9de52ac64da
# ╠═446a4754-601d-425a-ab9a-2a0fcd00f42a
# ╠═418775c7-cdbd-4ef0-8748-b3c4bfddf616
# ╟─5adc6654-0cb7-4afb-8e25-e41f4a1edb24
# ╠═0121c1b6-fe2e-4508-a1c1-9f17dc57d16f
# ╠═39d51165-bb39-44c0-824b-3785ef7bbf7d
# ╠═a3114227-0bee-43fb-a1c3-ae8f197daf38
# ╠═10b0120c-13f3-4129-b872-993497e3c337
# ╠═67a35680-3904-4aaf-a8c1-7ca693127bfa
# ╟─081b7680-ec6c-4f18-b027-5224059a4aef
# ╠═2623e644-9edb-45f2-9b1c-d886ffc5672d
# ╠═912c761e-e04f-43c5-af4e-9a4e886c6f1c
# ╠═65d52fc8-da8d-48b7-b4e6-0ed237b6b2f8
# ╠═7ae1de51-114d-4762-8737-96df360df2e5
# ╠═61cac904-79d1-43d9-8493-ef99d96624e4
# ╠═33a3dcfb-d4c8-400b-bd13-4fa45496b4b6
# ╠═6013c01b-8ce4-4fc0-95dd-f0e3529a1219
# ╠═2f86d094-6062-47ed-90f2-1264cff73d2a
# ╟─7e670fce-c24a-46a9-829f-edc024e13283
# ╠═952ad135-1b95-4474-b375-8ea4b3e71379
# ╠═6eb70f10-7596-4cc0-91c0-0a55185fa7b5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
