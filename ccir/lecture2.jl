# In this section, we illustrate the fundamental link between derivative and optimization.
#
# ## Univariate optimization
# 
# ### Linear polynomial
# 
# The arguably simplest functions are affine function so let's start with the minimization of an affine function.
# What is the minimum of $x + 1$ ?
# Let's plot this function:

using Plots
x = range(-8, stop=8, length=50)
p(x) = x + 1
plot(x, p.(x), label="")

ReLU(x) = (x < 0) ? 0.0 : x
plot(x, p.(x), label="")

# In order to plot, we generate `100` equally spaced numbers between `-8` and `8`:

x

# We can see the elements in this range by converting into a vector with `collect`:

collect(x)

p.(x)

# ### Quadratic polynomial
# 
# What is the minimum of $x^2 - 2x + 1$ ?

x = range(0, stop=2, length=50)
p(x) = x^2 - 2x + 1 # (x - 1)^2
plot(x, p.(x), label="")
scatter!([1], [p(1)], label="")

plotly()

ε = 1e-1
c = 0.1
f = ReLU
x0 = range(c-ε, stop=c+ε, length=50)
plot(x0, f.(x0), label="", linewidth=4, ratio=:equal)

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

plot(x, x)
plot(x, x.^2)
plot(x, x.^5)
plot(x, x.^4)
plot(x, -x.^4)

dp(x) = 4x^3 - 24x^2 + 8x - 6
plot(x, dp.(x))

ddp(x) = 12x^2 - 48x + 8
plot(x, ddp.(x))

# Is the zero-derivative condition sufficient ?

x = range(-3, stop=64, length=1000)
plot(x, x -> x * sin(x))

plot(x, x .* cos.(x) + sin.(x))

plot(x, cos.(x) - x .* sin.(x) + cos.(x))

# Zero derivative is necessary for $x$ to be a global minimizer but there are 3 cases of zero derivative:
# 
# 1. local minimum: when it's decreasing before $x$ and then increasing
# 2. local maximum: when it's increasing before $x$ and then decreasing
# 3. saddle point: when it's increasing (resp. decreasing) before $x$ and then increasing (resp. decreasing) after $x$

# Say the first derivative of `f(x)` that is nonzero is the `k`-th derivative `f^{(k)}(x)` then
# * if `k` is odd then it is not a local extremum
# * if `k` is even and the value is positive then it is a local minimum
# * if `k` is even and the value is negative then it is a local maximum

x = range(-1, stop=1, length=100)
plot(x, -x.^5)

# ## Multivariate optimization

using Plots
x = range(-4, stop=4, length=100)
y = range(-4, stop=4, length=100)
p(x, y) = 2x^2 + x*y + 2y^2 - 2x + 3y + 1
plotly()
surface(x, y, p)

# $z = p(x, y) = 2x^2 + xy + 2y^2 - 2x + 3y + 1$
#
# ∂z/∂x
# ∂z/∂y
# ∂z/∂(x + y) = ∂z/∂x + ∂z/∂y
# ∂z/∂(x + 2y) = ∂z/∂x + 2∂z/∂y
#
# $\frac{\partial p}{\partial x} = 4x + y - 2$
#
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

p(0.75, -0.938)

p(0.75, -0.939)

p(0.75, -0.937)

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

function gradient_descent(h, num_iters = 100, v = [1, -1])
    for _ in 1:num_iters
        v = v - h * ∇p(v...)
    end
    return v
end

# With a step size of `1`, we diverge

v = gradient_descent(1)

# With a step size of `0.1`, we converge

v = gradient_descent(0.1)

v = @time gradient_descent(0.001, 1000000)

# Looking at the solution, it looks rational

rationalize.(v, tol=1e-14)

# It seems that with a step size above `0.4` we do not converge
# and below `0.4` you converge.
# What happens with a step size of exactly `0.4` ?
# With the step 0.4: you converge to an orbit of period 2:

v = gradient_descent(0.4, 100)
v1 = rationalize.(v, tol=1e-10)

# At the next step, we get another one

v = gradient_descent(0.4, 101)
v2 = rationalize.(v, tol=1e-10)

# And then we cycle

v = gradient_descent(0.4, 102)
rationalize.(v, tol=1e-10)

# Indeed, here is the difference:

v1 - v2

# With a step from `v1`, we go form `v1` to `v2`

4 // 10 * ∇p(v1...)

# With a step from `v2`, we go back to `v1`

4 // 10 * ∇p(v2...)

# Now what happens with a step too small ?

gradient_descent(0.001, 1000)

# With a bit more steps ?

gradient_descent(0.001, 1000)

# And with even more steps ?

gradient_descent(0.001, 10000)

# So, we observed that
#
# * With a step size that is *too large* (in this case larger than 0.4),
#   the gradient method may diverge.
# * With a step size that is *too small*,
#   the method will converge but very slowly.

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
model = Model(Ipopt.Optimizer)
@variable(model, x)
@variable(model, y)
@objective(model, Max, p(x, y))
JuMP.optimize!(model)

value(x)

value(y)

solution_summary(model)

# Here, it is `NORM_LIMIT` because it is unbounded
