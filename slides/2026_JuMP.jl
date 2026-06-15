### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# ╔═╡ 6ae6c41e-70f4-4d0e-b5b2-230143d6845b
using PlutoUI, HypertextLiteral, PlutoTeachingTools

# ╔═╡ a06e1c98-b999-4ae9-8333-c1d45536cbc0
md"""
## Semidefinite Program:

```math
\begin{align}
\min_{X \in \mathbb{R}^{n \times n}} & \;\; \langle C, X \rangle
&
\max_{y \in \mathbb{R}^m, Z \in \mathbb{R}^{n \times n}} & \;\; b^T y
\\
\;\;\text{s.t.} \;\; & \langle A_i, X \rangle = b_i
& \;\;\text{s.t.} \;\; & C - \sum_{i=1}^m A_i y_i = Z\\
& X \text{ is PSD} && Z \text{ is PSD}
\end{align}
```
"""

# ╔═╡ 2857027e-1971-4705-9561-a728b04698e6
TwoColumn(
	md"""
Pros:
* Convex. Guarantee to get optimal solution.
* Polynomial time algorithms.
* Many solvers: SOS, Mosek, Clarabel, CSDP, SDPA, ...
""",
	md"""
Cons:
* Number of variables is ``n^2``.
* Even if we know that there exists a low-rank solution for ``X`` or ``Z``, it cannot be exploited (except [ProxSDP.jl](https://github.com/mariohsouto/ProxSDP.jl) or [Loraine](https://github.com/kocvara/Loraine.jl))
* Geared towards high-rank solutions.
""",
)

# ╔═╡ 1e97c55e-7072-47c3-96dc-eef846677360
md"""
## Burer-Monteiro

```math
\begin{align}
\min_{U \in \mathbb{R}^{n \times r}} & \;\; \langle C, UU^\top \rangle
&
\max_{y \in \mathbb{R}^m, Z \in \mathbb{R}^{n \times n}} & \;\; b^T y
\\
\;\;\text{s.t.} \;\; & \langle A_i, UU^\top \rangle = b_i
& \;\;\text{s.t.} \;\; & C - \sum_{i=1}^m A_i y_i = Z\\
&&& Z \text{ 🤞 PSD}
\end{align}
```
"""

# ╔═╡ dd7c6532-5b3f-4217-aef8-1109c759d18f
TwoColumn(
	md"""
Pros:
* Number of variables is ``nr``.
* Can force the rank of solution to be small.
* **A postiori** guarantee that ``U`` is optimal if ``Z`` is PSD.
* No need to factorize ``X``.
""",
	md"""
Cons:
* Nonconvex:
  - harder to optimize
  - can get stuck at spurious local minima
""",
)

# ╔═╡ 11f6f875-73c0-4d5c-a75a-8a6dcf3e6c8f
md"""
## SDPA format
``X`` block-diagonal (scalars are ``1 \times 1`` blocks), ``A_i`` are symmetric sparse matrices
```math
\begin{align}
\min_{X_j \in \mathbb{R}^{n_j \times n_j}} & \;\; \sum_{j} \langle C_j, X_j \rangle
\\
\;\;\text{s.t.} \;\; & \sum_j \langle A_{ij}, X_j \rangle = b_i\\
& X_j \text{ is PSD}
\end{align}
```
"""

# ╔═╡ 141a9b90-767f-4489-98ac-3f760d6d7e8b
TwoColumn(
	md"""
Pros:
* ``A_{ij}`` matrices easy to obtain from JuMP's affine expressions.
* Similar to LPs, care-free modeling for user.
""",
	md"""
Cons:
* Inefficient representation of dense low-rank matrices
* Cannot do matrix-free, e.g.  ``A x`` → `fft(x)`
""",
)

# ╔═╡ 77650a10-43fa-47fc-855d-04a10f567b12
md"""
## Deviations from the SDPA format

* [SDPLR (2002)](https://github.com/jump-dev/SDPLR.jl), [DSDP (2005)](https://github.com/jump-dev/DSDP.jl), [Loraine (2023)](https://github.com/kocvara/Loraine.jl), [SDPLRPlus (2024)](https://github.com/luotuoqingshan/SDPLRPlus.jl) : Low-rank ``A_i = F_i F_i^\top`` with dense factor ``F_i``
* [Hypatia](https://github.com/jump-dev/Hypatia.jl) : ``X`` only accessed via orthogonal rank-1 ``A_i``.
* [SketchyCGAL (2021)](https://github.com/alpyurtsever/SketchyCGAL) : ``A_i = I``.
* [BMSOS (2022)](https://github.com/JuliaAlgebra/BMSOS.jl) : ``A_i`` matrix-free with FFT.
* [SDPLRPlus (2024)](https://github.com/luotuoqingshan/SDPLRPlus.jl): ``A_i`` in either CSC or COO format. COO better if nnz ``\ll O(n)``.
* [cuHALLaR (2025)](https://arxiv.org/pdf/2505.13719) : ``A_i = F_iD_iF_i^\top``, ``D_i \in \mathbb{R}^{r_i \times r_i}`` **not** necessarily diagonal.
"""

# ╔═╡ 98cdc556-d8c5-4f87-8377-c5b3d216bb52
md"""## The format liberator

[LowRankOpt](github.com/blegat/LowRankOpt.jl/) introduces:
"""

# ╔═╡ 569d52de-1eb0-4a16-86c2-8758557fa23a
TwoColumn(
	md"""
`SetDotProducts{WITHOUT_SET}`
```math
\{(\langle A_1, X \rangle, \ldots, \langle A_m, X \rangle) \mid X \text{ is PSD}\}
```
`SetDotProducts{WITH_SET}`
```math
\{(X, \langle A_1, X \rangle, \ldots, \langle A_m, X \rangle) \mid X \text{ is PSD}\}
```
""",
	md"""
`LinearCombinationInSet{WITHOUT_SET}`
```math
\{ y \in \mathbb{R}^{m} : \sum_{i=1}^m y_i A_i \text{ is PSD} \}.
```
`LinearCombinationInSet{WITH_SET}`
```math
\{ (y, C) \in \mathbb{R}^{m} : \sum_{i=1}^m y_i A_i - C \text{ is PSD} \}.
```
""",
)

# ╔═╡ 2e54be0f-8ba3-4076-940c-810aa740f304
md"""
## Decoupling SDP solvers

[LowRankOpt](github.com/blegat/LowRankOpt.jl/) transforms SDP in MOI + `LinearCombinationInSet{WITH_SET}` into `NLPModels`.
"""

# ╔═╡ 1c8215e4-f0e1-42ec-9231-9037433b66ac
TwoColumn(
	md"""
Solver on ``X``

* Extends `NLPModels` interface for PSD specifics
* Solver never accesses ``A_i`` or ``C`` directly
* Proof of concept with [Loraine](https://github.com/kocvara/Loraine.jl/pull/29)
""",
	md"""
Burer-Monteiro on ``U``

* No need to extend `NLPModels` → existing `NLPModels` can be used
* Implicit dualization: `NLPModels` solver searches ``U``, user formulates with ``y``.
* Solvers like [SDPLRPlus](https://github.com/luotuoqingshan/SDPLRPlus.jl) can also exploit specifics of BM (e.g. easy line-search, rank update).
""",
)

# ╔═╡ 0d7799dc-71cb-41a3-92ca-044e756aeb6e
md"""
> This decoupling makes it **easier** to write an SDP solver, no need for an MOI interface. The solver **exploit new custom** ``A_i`` structure for free.
"""

# ╔═╡ 31f2c438-d1a2-4ebe-8414-0b8c29adf65d
md"## Extending NLPModels"

# ╔═╡ 9bee7b40-b906-430f-9260-ebca684272ca
TwoColumn(
	md"""
Solver on ``X``: [Loraine.jl](https://github.com/kocvara/Loraine.jl)

* KKT → System on ``\Delta X``, ``\Delta y``, ``\Delta Z``
* Nesterov–Todd scaling →
* System on ``\Delta y`` **only** : ``H \Delta y = r``
* Need ``r`` and *Schur complement* ``H``
""",
	md"""
Burer-Monteiro on ``U``: [SDPLRPlus.jl](https://github.com/luotuoqingshan/SDPLRPlus.jl)

* Line-search : Minimizes univariate quartic polynomial with [Polynomials](https://github.com/JuliaMath/Polynomials.jl)
* [Riemannian staircase](https://www.nicolasboumal.net/papers/The_staircase_method.pdf): Change the number of columns of ``U`` **during solve**
""",
)

# ╔═╡ 8fa41b95-f05c-408c-8f66-8f989f50769f
md"""
## Supporting arbitrary matrix types

* Number of matrix types in a given model is small
* Transform `Vector{AbstractMatrix}` -> `Vector{Union{...}}` before calling the solver
* No runtime dispatch thanks to [Julia's union-splitting](https://julialang.org/blog/2018/08/union-splitting/)
```julia
convert(Array{Union{unique(typeof.(A))...}}, A)
```
"""

# ╔═╡ 64a3ccea-60c8-42a5-890c-d60e6454d6ba
md"## Benchmark"

# ╔═╡ 5466dcad-20c2-443c-9b3f-75d467a74bc1
html"<p align=center style=\"font-size: 20px; margin-bottom: 5cm; margin-top: 5cm;\">The End</p>"

# ╔═╡ dd939c2f-93a2-46e1-be93-490eb99f74ca
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
end;

# ╔═╡ b0789776-5c1a-11f1-9355-0b1c7aa428ee
@htl("""
<p align=center style=\"font-size: 30px;\">Second-Order GPU solver for Burer-Monteiro</p>
<p align=right><i>Benoît Legat</i>, 1st June 2026</p>
$(img("https://upload.wikimedia.org/wikipedia/commons/7/72/UCLouvain_logo.svg", :height => 32))
$(img("https://jump.dev/assets/jump-dev-workshops/2026/logo.png", :height => 64))
$(PlutoTeachingTools.ChooseDisplayMode())
$(PlutoUI.TableOfContents(depth=1))
""")

# ╔═╡ d917bc6f-89c8-4ba2-b110-f26a91ee0016
TwoColumnWideLeft(
	img("$(pwd())/bench.png"),
	md"""
Benchmark instance of Section 7 of [arxiv#2205.11466](https://arxiv.org/abs/2205.11466), rank-4. [SumOfSquares](https://github.com/jump-dev/SumOfSquares.jl/) Trigo + Lagrange bases
* NLopt → [JSOSolvers](https://github.com/JuliaSmoothOptimizers/JSOSolvers.jl)' `lbfgs` and `trunk`.
* FFT uses [AbstractFFTs](https://github.com/JuliaMath/AbstractFFTs.jl) : [FFTW.jl](https://github.com/JuliaMath/FFTW.jl) on CPU and [`CUDA.CUFFT`](https://github.com/JuliaGPU/CUDA.jl) on GPU
* NVIDIA RTX PRO 1000 Blackwell Laptop gen
* Done with François Pacaud
""",
)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~1.0.0"
PlutoTeachingTools = "~0.4.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "a518f0c8cc9ee7a4a5dc07db334f747fa08c32e1"

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

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c0c9b76f3520863909825cbecdef58cd63de705a"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.5+0"

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

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

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

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
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

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

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
"""

# ╔═╡ Cell order:
# ╟─b0789776-5c1a-11f1-9355-0b1c7aa428ee
# ╟─a06e1c98-b999-4ae9-8333-c1d45536cbc0
# ╟─2857027e-1971-4705-9561-a728b04698e6
# ╟─1e97c55e-7072-47c3-96dc-eef846677360
# ╟─dd7c6532-5b3f-4217-aef8-1109c759d18f
# ╟─11f6f875-73c0-4d5c-a75a-8a6dcf3e6c8f
# ╟─141a9b90-767f-4489-98ac-3f760d6d7e8b
# ╟─77650a10-43fa-47fc-855d-04a10f567b12
# ╟─98cdc556-d8c5-4f87-8377-c5b3d216bb52
# ╟─569d52de-1eb0-4a16-86c2-8758557fa23a
# ╟─2e54be0f-8ba3-4076-940c-810aa740f304
# ╟─1c8215e4-f0e1-42ec-9231-9037433b66ac
# ╟─0d7799dc-71cb-41a3-92ca-044e756aeb6e
# ╟─31f2c438-d1a2-4ebe-8414-0b8c29adf65d
# ╟─9bee7b40-b906-430f-9260-ebca684272ca
# ╟─8fa41b95-f05c-408c-8f66-8f989f50769f
# ╟─64a3ccea-60c8-42a5-890c-d60e6454d6ba
# ╟─d917bc6f-89c8-4ba2-b110-f26a91ee0016
# ╟─5466dcad-20c2-443c-9b3f-75d467a74bc1
# ╟─6ae6c41e-70f4-4d0e-b5b2-230143d6845b
# ╟─dd939c2f-93a2-46e1-be93-490eb99f74ca
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
