# Find $x_1, x_2, x_3$ such that:
# $$
# \begin{alignat*}{7}
#  3x_1 &&\; + \;&& 2x_2 &&\; - \;&&  x_3 &&\; = \;&& 1 & \\
#  2x_1 &&\; - \;&& 2x_2 &&\; + \;&& 4x_3 &&\; = \;&& -2 & \\
# -2x_1 &&\; + \;&& 1x_2 &&\; - \;&& 2x_3 &&\; = \;&& 0 &
# \end{alignat*}
# $$

A = [
     3  2 -1
     2 -2  4
    -2  1 -2
]

b = [1, -2, 0]

# ## Symbolic approach

using RowEchelon
rref([A b])

# *Symbolic* as amenable to exact arithmetic:

rref(Rational{Int}.([A b]))

# ## Numerical approach

A \ b

# # Overdetermined system
# 
# Find $x_1, x_2$ such that:
# $$
# \begin{alignat*}{7}
# 3x_1 &&\; + \;&& 2x_2             &&\; = \;&& 1 & \\
# 2x_1 &&\; - \;&& 2x_2             &&\; = \;&& -2 & \\
# -2x_1 &&\; + \;&& 1x_2 &&\; = \;&& 0 &
# \end{alignat*}
# $$

B = A[:, 1:2]

using RowEchelon
rref([B b])

# This gives the system
# $$
# \begin{alignat*}{7}
# x_1 &&\;  \;&&     &&\; = \;&& 0 & \\
#     &&\;  \;&& x_2 &&\; = \;&& 0 & \\
#     &&\;  \;&&     &&\; = \;&& 1 & \\
# \end{alignat*}
# $$
# The system has no solution.

x = B \ b

e = B * x - b

# The system has no solution.
# We want to minimize the error $e$ : *multi-objective optimization*.
# Reduce to one objective with sum of squares.
# $$
# \begin{aligned}
# \min_{x_1,x_2} & \, e_1^2 + e_2^2 + e_3^2\\
# \text{s.t. }e = & \, Bx - b
# \end{aligned}
# $$
# 
# In general, $B \in \mathbb{R}^{m \times n}$, $b \in \mathbb{R}^m$:
# $$
# \begin{aligned}
# \min_{x \in \mathbb{R}^n} & \|Bx - b\|_2
# \end{aligned}
# $$
# where $\|e\|_2 = e_1^2 + e_2^2 + \cdots e_m^2$ is the *Euclidean norm*.
# 
# *Unconstrained* mathematical optimization program:
# 
# * *Decision variables*: $x \in \mathbb{R}^n$
# * *Objective function*: $\|Bx - b\|_2$
# 
# Optimal solution: solution of $B^\top B x = B^\top b$. If $B^\top B$ is invertible, $x = (B^\top B)^{-1} B^\top b$.

B' * e

# # Underdetermined system
# 
# Find $x_1, x_2, x_3$ such that:
# $$
# \begin{alignat*}{7}
# 3x_1 &&\; + \;&& 2x_2 &&\; - \;&&  x_3 &&\; = \;&& 1 & \\
# 2x_1 &&\; - \;&& 2x_2 &&\; + \;&& 4x_3 &&\; = \;&& -2 & \\
# \end{alignat*}
# $$

C = A[1:2, :]

c = b[1:2]

using RowEchelon
rref([C c])

# This gives the system
# $$
# \begin{alignat*}{7}
# x_1 &&\;  \;&&  &&\; + \;&&  0.6x_3 &&\; = \;&& -0.2 & \\
#  &&\;  \;&& x_2 &&\; - \;&& 1.4x_3 &&\; = \;&& 0.8 & \\
# \end{alignat*}
# $$
# The system has infinitely solutions: It has a solution $(-0.2 - 0.6x_3, 0.8 + 1.4x_3)$ for any $x_3$.

x = C \ c

C * x - c

# Suppose we want to minimize $\|x\|_2$:
# $$
# \begin{aligned}
# \min_{x \in \mathbb{R}^n}& \|x\|_2\\
# \text{s.t. }Cx & = c
# \end{aligned}
# $$
# 
# Mathematical optimization program:
# 
# * *Decision variables*: $x \in \mathbb{R}^n$
# * *Objective function*: $\|x\|_2$
# * *Constraints*: $Cx = c$
# 
# Optimal solution: $x = C^\top \lambda$ where $\lambda$ is a solution of $CC^\top \lambda = c$.
# If $CC^\top$ is invertible, $x = C^\top (CC^\top)^{-1} c$.

C \ c

C' * ((C * C') \ c)
