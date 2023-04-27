# # Linear Programming duality

using RowEchelon
A = [1 3 4 1
-1 2 -2 3
2 3 5 2]

rref(A)

A[1, :] = A[1, :] + A[3, :]

A

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