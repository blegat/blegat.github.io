# ## Random variable

dice = 1:6

using Statistics
μ = Statistics.mean(dice)

sum(dice) / length(dice)

Statistics.var(dice, corrected=false)

sum((dice .- μ).^2 / length(dice))

Statistics.var(dice)

Statistics.std(dice)^2

sum((dice .- μ).^2 / (length(dice) - 1))

[1:6; 1:6]

Statistics.cor([1:6; 1:6])

[1:6; 6:-1:1]

Statistics.cor([1:6; 6:-1:1])

[1:6 6:-1:1]

Statistics.cor([1:6 6:-1:1])

# `rand` produces independent output so we should see a zero correlation. For small values we still see a bit of correlation

rand(6, 2)

Statistics.cor(rand(6, 2))

# But as we increase, the correlation goes to zero

Statistics.cor(rand(100, 2))

Statistics.cor(rand(100000, 2))

# ## Gaussian/Normal distribution

using Plots
μ = 0
σ = 1
f(x) = exp(-1/2*((x - μ) / σ)^2) / (σ * √(2π))

x = range(-4.0, stop=4.0, length=1000)
plot(x, f.(x))
z = randn(100)
scatter!(z, f.(z), markersize=2)

# ## Statistical inference

# *See Example 7.1 of Boyd & Vandenberghe "Convex Optimization" book.*
# 
# Suppose we observe $y_i = a_i^\top x + v_i$ where $v_i$ has a normal distribution $\mathcal{N}(\mu_i, \sigma_i^2)$.
# 
# We want to recover $x$ from the observation $y_i$ such that the $v_i$ are likely to occur.
# That is, we want to maximize $f(v_i)$. This is multi-objective. Instead, we can maximize the likelihood that they all occur. Since they are independent, it's the product.
# $$\prod_{i=1}^n f(v_i) = \prod_{i=1}^n \frac{1}{\sigma_i \sqrt{2\pi}}\exp(-\frac{(v_i - \mu_i)^2}{2\sigma_i^2})$$
# Since $\log$ is an increasing function, that is equivalent to maximizing the logarithm:
# $$\sum_{i=1}^n \log(\frac{1}{\sigma_i \sqrt{2\pi}}\exp(-\frac{(v_i - \mu_i)^2}{2\sigma_i^2}))$$
# which is equal to
# $$-\sum_{i=1}^n \log(\sigma_i) - \frac{n\log(2\pi)}{2} -\frac{1}{2\sigma_i^2} \sum_{i=1}^n (v_i - \mu_i)^2$$
# The first two terms do not depend on $v_i$ so we can drop them.
# $$-\frac{1}{2} \sum_{i=1}^n \frac{(v_i - \mu_i)^2}{\sigma_i^2}$$
# $-\frac{1}{2}$ is a negative constant so **maximizing** this expression is equivalent to **minimizing**
# $$\sum_{i=1}^n \frac{(v_i - \mu_i)^2}{\sigma_i^2}$$
# In terms of $x$, this is
# $$\min_x \sum_{i=1}^n \frac{(y_i - a_i^\top x - \mu_i)^2}{\sigma_i^2}$$

# If $\mu_i = 0$ and $\sigma_i$ does not depend on $i$ (same for all samples, we say they are independent and identially distributed (**i.i.d**)), this gives
# $$\min_x \lVert y - Ax \rVert_2$$
# where the $i$th row of $A$ is $a_i$.
# So the classical linear regression we saw during the first week assumes i.i.d. normal noise of zero mean.

# How to interpret the scaling $\sigma_i^2$ in terms of influence on $x$ for very noisy samples ?

n = 101
σ = [1000; ones(n - 1)]
μ = 100rand(n)
v = randn(n) .* σ .+ μ

m = 10
x = rand(m)
A = rand(n, m)
y = A * x + v

# Without taking the noise into account, we get large errors:

x - A \ y

# Taking $\mu$ into account can be done as follows:

x - A \ (y - μ)

# How do we take $\sigma$ into account ?
# 
# We know that `\ ` solves the least square
# $$\min_x \lVert y - Ax \rVert_2 = \sum_{i = 1}^n (y_i - a_i^\top x)^2$$
# but we want it to solve
# $$\sum_{i = 1}^n (y_i - a_i^\top x - \mu_i)^2 / \sigma_i^2$$
# instead. How do we do this ?
# The expression is equal to
# $$\sum_{i = 1}^n (\frac{y_i - \mu_i}{\sigma_i} - \frac{a_i^\top}{\sigma_i} x)^2$$
# so we can just scale $y$ and $A$:

x - (A ./ σ) \ ((y - μ) ./ σ)

# Now that's much better.
