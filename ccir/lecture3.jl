# # Julia: lambda function

f(x) = x * sin(x)

plot_convexity(f, -1, 1)

plot_convexity(x -> x * sin(x), -1, 1)

# # Nonconvexity and local minima
# 
# A function $f(x)$ is *convex* if $f(\lambda x + (1 - \lambda) y) \le \lambda f(x) + (1 - \lambda) f(y)$ for all pairs $x, y$ and $0 \le \lambda \le 1$.

using Plots
function plot_convexity(f::Function, min_x, max_x)
    step = 100
    xs = range(min_x, stop = max_x, length = 10step + 1)
    plot(xs, f.(xs), label = "")
    for i in (step + 1):step:length(xs)
        a = xs[i - step]
        b = xs[i]
        ys = [a, b]
        cord = (f(a) + f(b)) / 2
        graph = f((a + b) / 2)
        color = if cord ≈ graph
            :orange
        elseif cord <= graph
            :red
        else
            :green
        end
        plot!(ys, f.(ys), color = color, label = "")
    end
    plot!()
end

plot_convexity(x -> x * sin(x), -12, 12)

using JuMP
import Ipopt
model = Model(Ipopt.Optimizer)
set_silent(model)
@variable(model, x, start=0.0)
@NLobjective(model, Min, x * sin(x))
optimize!(model)
solution_summary(model)

value(x)

set_start_value(x, 1)
optimize!(model)
solution_summary(model)

value(x)

# $3.4 \times 10^{-10}$

set_start_value(x, 6)
optimize!(model)
solution_summary(model)

value(x)

10^10

set_start_value(x, 10)
optimize!(model)
solution_summary(model)

value(x)

# # Convexity

exp10(4)

# $d(e^x)/dx = e^x$

exp(1)

plot_convexity(x -> -(exp(x) + exp(-3x)), -1, 3)

@NLobjective(model, Min, exp(x) + exp(-3x))
optimize!(model)
solution_summary(model)

value(x)

set_start_value(x, 10)
optimize!(model)
solution_summary(model)

value(x)

set_start_value(x, -3)
optimize!(model)
solution_summary(model)

value(x)

@NLobjective(model, Max, exp(x) + exp(-3x))
optimize!(model)
solution_summary(model)

value(x)

set_upper_bound(x, 3)
set_lower_bound(x, -1)
@NLobjective(model, Max, exp(x) + exp(-3x))
optimize!(model)
solution_summary(model)

value(x)

set_start_value(x, 2.5)
optimize!(model)
solution_summary(model)

value(x)

@NLobjective(model, Min, -(exp(x) + exp(-3x)))
optimize!(model)
solution_summary(model)

value(x)

plot_convexity(x -> max(exp(x) + exp(-3x), 5), -1, 3)

# Minimizing convex function or maximizing concave function over a convex feasible set:
# * The set of local minimizers is a convex set and they are all global.
# 
# Minimizing concave function or maximizing convex function over a convex feasible set:
# * There are local minimizers that are not global. There exists one global minimum that is an extreme point.

model = Model(Ipopt.Optimizer)
@variable(model, x)
set_start_value(x, 0.1)
set_lower_bound(x, -1)
set_upper_bound(x, 3)
@NLobjective(model, Min, max(exp(x) + exp(-3x), 5))
optimize!(model)
solution_summary(model)

value(x)

# ## Operations of convex functions

plot_convexity(x -> exp(x), -1, 3)

plot_convexity(x -> exp(x) + exp(-3x), -1, 3)

plot_convexity(x -> exp(x) - log(x), 0.1, 3)

# A function $f$ is *concave* if $-f$ is convex.

plot_convexity(x -> -log(x), 0.1, 3)

plot_convexity(x -> x * sin(x), 0.1, 3)

plot_convexity(x -> x, 0.1, 3)

plot_convexity(x -> exp(x) + log(x), 0.01, 2)

plot_convexity(x -> 2exp(x) + (-exp(x)), -1, 2) # exp(x)

# # Linear Programs

import HiGHS
model = Model(HiGHS.Optimizer)
set_silent(model)
@variable(model, x >= -1)
@variable(model, y >= -1)
@constraint(model, 2x + y <= 1)
@constraint(model, x + 3y <= 1)
@objective(model, Max, x + 2y)
optimize!(model)
solution_summary(model)

value(x)

value(y)

using Polyhedra
plot(polyhedron(model))
scatter!([value(x)], [(value(y))])
xs = range(-0.5, stop=1, length=100)
plot!(xs, (objective_value(model) .- xs) / 2)

1D: 2, 2
2D: 4, 4
3D: 6, 8
4D: 8, 16
5D: 10, 32
nD: 2n, 2^n

model = Model()
@variable(model, -1 <= x[1:50] <= 1)
println(model)

50^2
