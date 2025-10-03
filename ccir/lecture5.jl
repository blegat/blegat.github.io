# # Linear Programming duality

# min x_1 + 2x_2
# s.t. x_1 >= 2
#      x_2 >= 3

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, x[1:2])
@constraint(model, c1, x[1] >= 2)
@constraint(model, c2, x[2] >= 3)
@constraint(model, x[1] + x[2] <= 10)
@objective(model, Min, x[1] + 2x[2])
optimize!(model)
solution_summary(model)
value.(x)
dual(c1)
dual(c2)

# Why 8 ?
# Let `γ` be the minimum.

# ## Upper bound given by the primal
# `x_1 = 2, x_2 = 3` is feasible and
# the objective value at `(2, 3)` is `2 + 2 * 3 = 8`
# We conclude that `γ ≤ 8`

# ## Lower bound given by the primal
# Suppose `x_1, x_2` is feasible
# Then `(x_1 - 2) ≥ 0` and `(x_2 - 3) ≥ 0`
# Then `1 * (x_1 - 2) + 2 * (x_2 - 3) ≥ 0`
# Simplifying `x_1 + 2x_2 - 8 ≥ 0`
# Therefore `x_1 + 2x_2 ≥ 8`
# We conclude that `γ ≥ 8`

# Combining both, `γ = 8`

using Polyhedra, Plots
plot(polyhedron(model))

# ## Primal
#
# Hey, I found `x = (3, 3)` is feasible.
# And the objective is `3 + 2 * 3 = 9`.
# It means that `9` is an upper bound to the optimal objective value.

# ## Dual
#
# If `x_1 >= 2` and `x_2 >= 3` then `x_1 + 2x_2 >= 2 + 2*3 = 8`
# In other words, if `x` is feasible then the objective function value at `x`
# is at least `8`.
# In other words, `8` is a lower bound to the optimal objective value.

# min x_1 + 2x_2 + 3x_3
# s.t. 
#    x_1 + 3x_2 + 4x_3 = 1
#   -x_2 + 2x_2 - 2x_3 = 3
#   2x_1 + 3x_2 + 5x_3 = 2
#
# If (3x_1 - x_2^2) * row_1 + 3 * row_2 - (5x_2*x_3) * row_3 = x_1 + 2x_2 + 3x_3 - 5
# then the objective value is `5` at any feasible solution.

using RowEchelon

# (x1 + 3x2 + 4x3 - 1) == 0

A = [
    1 3  4 1
   -1 2 -2 3
    2 3  5 2
]

using TypedPolynomials
@polyvar x[1:3]

rref(A)

A[1, :] = A[1, :] + A[3, :]

A

## Hilbert's Nullstellensatz

# ### Bad news from Algebraic Geometry:
#
# Start from polynomials $p_1, p_2, ..., p_m$, and you consider the set of solutions
# V = {x | p_1(x) = 0, p_2(x) = 0, ..., p_m(x) = 0}
# Now you want to find the set of $q(x)$ such that $q(x) = 0$ for all $x \in V$
#
# 1. You need to consider $q(x) = a_1(x) * p_1(x) + a_2(x) * p_2(x) + ... + a_m(x) * p_m(x)$
#    where `a_i(x)` are polynomials
# 2. But it might not be enough... Counter-example: if `p_1(x) = x^2`, we cannot generate
#    `q(x) = x`

# ### Good news from Linear Algebra:
#
# 1. If `p_1, p_2, ..., p_m` are affine then we can just take `a_1(x)`, `a_2(x)`, ... to be constants
# 2. We will always generate all `q(x)`

# ## Krivine–Stengle Positivstellensatz

# ### Bad news from Algebraic Geometry:

# Start from polynomials $p_1, p_2, ..., p_m$, and you consider the set of solutions
# V = {x | p_1(x) ≥ 0, p_2(x) ≥ 0, ..., p_m(x) ≥ 0}
# Now you want to find the set of $q(x)$ such that $q(x) ≥ 0$ for all $x \in V$
# E.g., `p_1(x) = 1 - x_1^2 - x_2^2` then `V = {x | x_1^2 + x_2^2 <= 1}` which is a 2-dimensional disk

# 1. You need to consider $q(x) = (a_11(x)^2 + a_12(x)^2 + ...) * p_1(x) + ...$
#    where `a_i(x)` are polynomials
# 2. But it might not be enough... But let's not go into details

# ### Good news from Polyhedral Computation:

# V is a polyhedron which is convex and for which the geometry is well understood

# 1. You can consider `a_i(x)` that are nonnegative constants
# 2. And it is enough to generate all `q(x)` !


# min x_1 + 2x_2 + 3x_3
# s.t. 
#    x_1 + 3x_2 + 4x_3 >= 1
#   -x_2 + 2x_2 - 2x_3 >= 3
#   2x_1 + 3x_2 + 5x_3 >= 2
#
# I want to find `λ_1, λ_2, λ_3 >= 0` that are nonnegative
# and such that `λ_1 * row_1 + λ_2 * row_3 + λ_3 * row_3 = x_1 + 2x_2 + 3x_3 + ?`
# where `?` can be any constant.

# For next week:

# 1. Can I find these `λ`s using Linear Programming ?
# 2. How can I get the best bound so kind of optimize on the `?` I get with these `λ`s ?



x + y <= 1 and -y <= 0 implies x <= 1

(x + y - 1) + (x - y - 0.5) # x <= 0.75

2(x + y - 1) + (x - y - 0.5) # 3x + y <= 2.5

1.5*(x + y - 1) + 0.5*(x - y - 0.5) # 2x + y <= 1.75

(a + b) * x + (a - b) * y - (a + 0.5b)

A = [1 1
1 -1]
b = [2, 1]
A \ b

var = 2

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, c <= 0)
@variable(model, d <= 0)
# (a + c + d) * x + (b + c - d) * y >= c + 0.5d
@constraint(model, c + d <= -2)
@constraint(model, c - d <= -1)
@objective(model, Max, c + 0.5d)
optimize!(model)
solution_summary(model)

value(c), value(d)

-1.5  <= -1.5x - 1.5y (c)
-0.25 <= -0.5x + 0.5y (d)
-1.75 <= -2x   -    y

(1 - x - y) >= 0
(0.5 - x + y) >= 0
(x + 1)^2 * (1 - x - y) * (0.5 - x + y) >= 0, Positivstellensatz

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, x >= 0) # a
@variable(model, y >= 0) # b
@constraint(model, λ, x + y <= 1) # c
@constraint(model, ν, x - y <= 0.5) # d
@objective(model, Min, -2x - y)
optimize!(model)
solution_summary(model)

@show dual(λ)
@show dual(ν)

# 0 <= a * x + b * y + c * (1 - x - y) + d * (0.5 - x + y) = -2x - y + σ
# -2x - y >= -σ

model = Model(HiGHS.Optimizer)
@variable(model, a >= 0)
@variable(model, b >= 0)
@variable(model, c >= 0)
@variable(model, d >= 0)
@constraint(model, a - c - d == -2)
@constraint(model, b - c + d == -1)
@objective(model, Max, -c - d/2)
optimize!(model)
solution_summary(model)
@show value(c)
@show value(d)

dual(LowerBoundRef(x)),dual(LowerBoundRef(y)),  dual(λ), dual(ν)

value(x), value(y)

objective_value(model)

# a >= 0, c >= 0
# b <= 0, d <= 0
# a * b + c * d

1.5 * (1 - x - y) + 0.5 * (0.5 + y - x)

2x + y - 1.75 <= 0 -> 2x + y <= 1.75

using Plots
using Polyhedra
plot(polyhedron(model))
plot!([0.875, 0.375], [0.0, 1.0])
scatter!([value(x)], [value(y)])

dual(LowerBoundRef(x))

dual(LowerBoundRef(y))

dual(λ)

dual(ν)

# * Primal feasible points give *lower* bounds to *maximal* objective value.
# * Primal feasible points give *upper* bounds to *minimal* objective value.
# 
# * Dual feasible points give *upper* bounds to *maximal* objective value.
# * Dual feasible points give *lower* bounds to *minimal* objective value.

using Dualization
dua = dualize(model)
v = all_variables(dua)
set_name(v[1], "λ")
set_name(v[2], "ν")
println(dua)

JuMP.dual(λ)

JuMP.dual(ν)

-0.5 * (-0.5) + 1.5

-1.5 * (x + y - 1) + (-0.5) * (x - y - 0.5)

2x + y <= 1.75

# $$(x + y \le 1) \text{ and } (x \le y + 0.5) \Rightarrow 2x + y \le 1.75$$

# $$(x + y \le 1) \text{ and } (x \le y + 0.5) \Rightarrow 2x + y \le \beta$$

# $$\lambda (x + y - 1) + \nu (x - y - 0.5) = 2x + y - \beta$$

# $$(\lambda + \nu - 2) x + (\lambda - \nu - 1) y + (-\lambda - 0.5\nu + \beta) = 0$$

d = Model(HiGHS.Optimizer)
@variable(d, λ >= 0)
@variable(d, ν >= 0)
@constraint(d, λ + ν >= 2)
@constraint(d, λ - ν >= 1)
@objective(d, Min, λ + 0.5ν)
optimize!(d)
termination_status(d)

value(λ)

value(ν)

# $$2x + y \le 2.2x + 1.5y \le 1.75$$

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, x >= 0, Int)
@variable(model, y >= 0, Int)
@constraint(model, λ, x + y <= 2)
@constraint(model, ν, x <= y + 1)
@objective(model, Max, 2x + y)
optimize!(model)
solution_summary(model)

value(x), value(y)

using Plots
using Polyhedra
plot(polyhedron(model))
plot!(2*[0.875, 0.375], 2*[0.0, 1.0])
scatter!([value(x)], [value(y)])

# Dual gives upper bound of 2.5. (1.0, 1.0) is feasible and gives 3.

# 3 <= restricted problem <= initial problem (Max) <= relaxed problem <= 3.5

# 1.5 <= branch (y <= 0) <= 2
# 3 <= branch (y >= 1) <= 3

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, z)
@variable(model, x >= 0, Int)
@variable(model, 0 <= y <= 0, Int)
@constraint(model, λ, x + y <= 2)
@constraint(model, ν, x <= y + 1)
@objective(model, Max, 2x + y)
optimize!(model)
solution_summary(model)

value(x), value(y)

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, z)
@variable(model, x >= 0)
@variable(model, 1 <= y)
@constraint(model, λ, x + y <= 2)
@constraint(model, ν, x <= y + 1)
@objective(model, Max, 2x + y)
optimize!(model)
solution_summary(model)

value(x), value(y)
