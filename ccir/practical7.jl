# In this session, we'll first get a glimpse at a few truth function of binary variables. We will then solve a scheduling problem with `Julia` and `JuMP`.

# ## Truth table
# 
# Let a and b be binary variables (remember that 0 = False and 1 = True),
# 
# $$
# \begin{array}{|c|c|c|c|c|c|c|c|c|c|}
# \hline
# a & b & a \Rightarrow b & b \Rightarrow a & a \& b & a | b & a \le b & a \ge b & a + b \ge 2 & a + b \ge 1\\
# \hline
# 1 & 0 & 0 & 1 & 0 & 1 & 0 & 1 & 0 & 1\\
# 0 & 1 & 1 & 0 & 0 & 1 & 1 & 0 & 0 & 1\\
# 1 & 1 & 1 & 1 & 1 & 1 & 1 & 1 & 1 & 1\\
# 0 & 0 & 1 & 1 & 0 & 0 & 1 & 1 & 0 & 0\\
# \hline
# \end{array}
# $$
# 
# Find more info on https://en.wikipedia.org/wiki/Truth_table.

# ## Scheduling
# 
# You want to schedule tasks for workers. 
# Completing these tasks requires resources and time. 
# Furthermore, some tasks cannot be undertaken until others have been addressed.
# 
# Let M be the number of tasks,
# N the number of wrokers available,
# R the ressources necessary to complete each task,
# and T the number of time steps to complete a maximum of those tasks.
# 
# A worker can handle at most one task at each time step. 
# A task can be undertaken by a certain worker only if the tasks on which it depends have been previsouly completed by the same worker. 
# Each task can be completed in one time step. 
# Finally, each ressource can be used at most once in each time step.
# 
# Let's write the problem,
# 
# * $M$ tasks
# * Dependency graph: task $i$ requires tasks $j_1, \ldots, j_k$ to be completed before by the same worker before being undertaken

dependency = [
    [4, 5], # Tasks 4 and 5 must be completed before task 1
    [8],
    [10],
    [6],
    [6],
    [7],
    Int[], # Nothing needs to be done beforehand
    [9],
    Int[],
    Int[],
]
M = length(dependency)

# * $R$ resources
# * Task $i$ requires using resources $r_1, \ldots, r_k$ to be completed

R = 5 
resources = [
    [1, 2], # Task 1 requires using ressources 1 and 2
    [2, 3],
    [1, 4],
    [2, 5],
    [5],
    [3],
    [2, 5],
    [1, 3],
    [3, 4],
    [1, 2, 3],
]

# * Number of workers $N$
# * Number of time steps $T$

N = 2
T = 5;

using JuMP
using HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, x[1:N, 1:T, 1:M], Bin) # N workers, T time steps, M tasks ; 
# x[n,t,m] = 1 if task completed, else 0

# Each worker should work on one task at once and at most at each time step

@constraint(model, [w in 1:N, t in 1:T], sum(x[w, t, :]) <= 1)

# Each task must be done at most once

@constraint(model, [i in 1:M], sum(x[:, :, i]) <= 1)

# Dependency: for each worker, the task depended on must be done before undertaking the task at hand

for j in dependency[i] # and for each task j that must be completed before worker w can undertake task i
    @constraint(
        model, 
        [w in 1:N, t in 1:T], 
        sum(x[w, t, i]) <= sum(x[w, 1:(t-1), j])
    )
end

# Each resource can be used at most once at each time step

for i in 1:M # For each task i
    for r in resources[i] # and for each resource needed to complete task i
        @constraint(
            model, 
            [t in 1:T, r in 1:R],
            sum(x[w, t, i] for w in 1:N for i in 1:M if r in resources[i]) <= 1,
        )
    end
end

# Now let's maximize the number of tasks completed with the time and ressources available

@objective(model, Max, sum(x));

optimize!(model)

solution_summary(model)

function extract(x)
    for t in 1:T
        println("At time $t:")
        for w in 1:N
            for i in 1:M
                if x[w, t, i] > 0.5
                    println("  worker $w does task $i (uses resources $(resources[i]), requires $(dependency[i]))")
                end
            end
        end
    end
end

extract(value.(x))
