using Convex

x = Variable(3)

A = [ 1     -1.131  0;
      1      0     -0.784;
      0      1     -0.693;
     -0.884  1      0;
     -1.275  0      1;
      0     -1.441  1]
problem = satisfy([A*x >= 0, x >= 4])
solve!(problem)
println(problem.status)
println(x.value)
