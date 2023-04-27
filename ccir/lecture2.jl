# ## Univariate optimization
# 
# ### Linear polynomial
# 
# What is the minimum of $x + 1$ ?

using Plots
x = range(-3, stop=8, length=100)
p(x) = x + 1
plot(x, p.(x), label="")

p.(x)

# ### Quadratic polynomial
# 
# What is the minimum of $x^2 - 2x + 1$ ?

p(x) = x^2 - 2x + 1 # (x - 1)^2
plot(x, p.(x), label="")
scatter!([1], [p(1)], label="")

# 

dp(x) = 2*(x - 1)
plot(x, dp.(x), label="")
scatter!([1], [dp(1)], label="")

plot(x, p.(x), label="")
tangent(x, y) = p(x) + (y - x) * dp(x)
@show dp(2)
y2 = range(1, stop=3, length=100)
plot!(y2, tangent.(2, y2))
@show dp(4)
y4 = range(3, stop=5, length=100)
plot!(y4, tangent.(4, y4))
@show dp(1)
y1 = range(0, stop=2, length=100)
plot!(y1, tangent.(1, y1))
y_1 = range(-2, stop=0, length=100)
plot!(y_1, tangent.(-1, y_1))

# ### Quartic univariate polynomial:
# 
# How to minimize $x^4 - 8x^3 + 4x^2 - 6x + 1$ ?

using Plots
x = range(-3, stop=8, length=1000)
p(x) = x^4 - 8x^3 + 4x^2 - 6*x + 1
plot(x, p.(x))

# Is that related to its derivative ?

dp(x) = 4x^3 - 24x^2 + 8x - 6
plot(x, dp.(x))

ddp(x) = 12x^2 - 48x + 8
plot(x, ddp.(x))

# Is the zero-derivative condition sufficient ?

x = range(-3, stop=8, length=1000)
plot(x, x -> x * sin(x))

x = range(-3, stop=8, length=100)
plot(x, x .* cos.(x) + sin.(x))

# Zero derivative is necessary for $x$ to be a global minimizer but there are 3 cases of zero derivative:
# 
# 1. local minimum: when it's decreasing before $x$ and then increasing
# 2. local maximum: when it's increasing before $x$ and then decreasing
# 3. saddle point: when it's increasing (resp. decreasing) before $x$ and then increasing (resp. decreasing) after $x$

x = range(-1, stop=1, length=100)
plot(x, x.^5)

# ## Multivariate optimization


#using Plots
x = range(-4, stop=4, length=100)
y = range(-4, stop=4, length=100)
p(x, y) = 2x^2 + x*y + 2y^2 - 2x + 3y + 1
#surface(x, y, p)

# $p(x, y) = 2x^2 + xy + 2y^2 - 2x + 3y + 1$

# $\frac{\partial p}{\partial x} = 4x + y - 2$

# $\frac{\partial p}{\partial y} = x + 4y + 3$

dx -> +1 -> 0 * 1 -> 0
dy -> +2 -> 0 * 2 -> 0
0 * 1 + 0 * 2 -> 0

# The notation $\partial$ is defined such that $\frac{\partial y}{\partial x} = 0$ and $\frac{\partial x}{\partial y} = 0$

dpdx(x, y) = 4x + y - 2
dpdy(x, y) = x + 4y + 3

# From the plot, it seems $(1, -1)$ is close to be a local minimizer, is it ?

p(1, -1)

dpdx(1, -1)

dpdy(1, -1)

# $\frac{\partial p}{\partial x}$ is positive so it's increasing in $x$. So, should we increase or decrease $x$ to get closer to a local minimizer ?

p(1, -1)

p(1.1, -1)

p(0.75, -1)

p(0.74, -1)

p(0.77, -1)

p(0.78, -1)

dpdx(0.75, -1)

dpdy(0.75, -1)

# Now it's constant in $x$ but decreasing in $y$

p(0.75, -0.94)

p(0.75, -0.93)

# The *gradient* is defined as the concatenation of all the partial derivatives.
# Having a zero gradient is **necessary** to be a local minimizer. Again, it's not **sufficient** as it could also be a local maximizer or a saddle point.

∇p(x, y) = [dpdx(x, y), dpdy(x, y)]

-∇p(0.75, -0.938)

x = 0.75
y = -0.938

xnew = x - 0.2 * dpdx(x, y)

ynew = y - 0.2 * dpdy(x, y)

x, y = x - 0.2 * dpdx(x, y), y - 0.2 * dpdy(x, y)

v = [x, y]

∇p(v...)

v = v - 0.1 * ∇p(v...)

v = [2.2/3, -2.8/3]

∇p((x - 0.2*∇p(x...))...)

x = x - 0.3*∇p(x...)

# ## Gradient method
# 
# A local minimizer of $f(x)$ can be found numerically as follows:
# 
# 1. Compute gradient $\nabla f(x)$
# 2. If approximately zero -> done
# 3. Follow direction $-\nabla f(x)$, find how long you follow it: line search and go to 1.

# For our example, $\nabla p(x, y) = 0$ is a linear system so we can find the global minimizer by solving this system:
# $$4x + y = 2$$
# $$x + 4y = -3$$

A = [
    4 1
    1 4
]

b = [2, -3]

x, y = A \ b

dpdx(x, y)

dpdy(x, y)

∇p(x, y)

rationalize(x)

rationalize(y)

# ## Finding minimizers numerically with JuMP

using Pkg
pkg"add NLopt"

using JuMP
import NLopt
model = Model(NLopt.Optimizer)
set_optimizer_attribute(model, "algorithm", :LD_MMA)
set_optimizer_attribute(model, "ftol_rel", 1e-16)
set_optimizer_attribute(model, "xtol_rel", 1e-16)

@variable(model, x)

@variable(model, y)

p(x, y)

@objective(model, Min, p(x, y))

model

println(model)

JuMP.optimize!(model)

# NLopt found a point with gradient zero and for which the function is locally increasing in every direction around the point. It therefore knows that it is a local minimizer but does not know whether it is a global minimizer. For this reason, its termination status is `LOCALLY_SOLVED`.

solution_summary(model)

value(x)

value(y)

# We can try as well with Ipopt without having to change the model

pkg"add Ipopt"

using Ipopt
set_optimizer(model, Ipopt.Optimizer)

JuMP.optimize!(model)

solution_summary(model)

value(x)

value(y)

# It's important to check for the `solution_summary` to check that it's `LOCALLY_SOLVED`.

using JuMP
import NLopt
model = Model(Ipopt.Optimizer)
@variable(model, x)
@variable(model, y)
@objective(model, Max, p(x, y))
JuMP.optimize!(model)

value(x)

value(y)

solution_summary(model)

# Here, it is `NORM_LIMIT` because it is unbounded
