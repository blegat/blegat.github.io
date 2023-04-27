# The [diet problem](https://neos-guide.org/content/diet-problem) was one of the first problems in optimization. George Joseph Stigler formulated the problem of the optimal diet in the late 1930s in an attempt to satisfy the concern of the North American army to find the most economical way to feed its troops while at the same time ensuring certain nutritional requirements.  
# In this session, we will implement it in three different ways and solve it with `JuMP`.

# ## Hardcoded diet problem

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, corn <= 10)
@variable(model, milk <= 10)
@variable(model, bread <= 10)
@objective(model, Min, 0.18corn + 0.23milk + 0.05bread)
@constraint(model, 5000 <= 107corn + 500milk <= 50000)
@constraint(model, 2000 <= 72corn + 121milk + 65bread <= 2250)
println(model)

optimize!(model)
solution_summary(model)

value(corn), value(milk), value(bread)

# ## Generic diet problem with linear algebra

using LinearAlgebra # for `⋅`
function diet(max_serving, cost, min_requirements, max_requirements, quantity)
    m, n = size(quantity)
    model = Model()
    @variable(model, x[i in 1:n] <= max_serving[i])
    @objective(model, Min, cost ⋅ x)
    @constraint(model, min_requirements .<= quantity * x .<= max_requirements)
    return model
end

max_serving = [10, 10, 10]
cost = [0.18, 0.23, 0.05]
min_requirements = [5000, 2000]
max_requirements = [50000, 2250]
quantity = [
    107 500 0
    72 121 65
]
model = diet(max_serving, cost, min_requirements, max_requirements, quantity)
println(model)

set_optimizer(model, HiGHS.Optimizer)
optimize!(model)
solution_summary(model)

value.(model[:x])

# ## More readable generic diet problem

function diet(max_serving, cost, min_requirements, max_requirements, quantity)
    model = Model()
    requirements, food = axes(quantity)
    @variable(model, x[f in food] <= max_serving[f])
    @objective(model, Min, sum(cost[f] * x[f] for f in food))
    @constraint(
        model,
        [r in requirements],
        min_requirements[r] <= sum(quantity[r, f] * x[f] for f in food) <= max_requirements[r],
    )
    return model
end

food = ["Corn", "2% milk", "Wheat bread"]
requirements = ["Calories", "Vitamin A"]
model = diet(
    JuMP.Containers.DenseAxisArray(max_serving, food),
    JuMP.Containers.DenseAxisArray(cost, food),
    JuMP.Containers.DenseAxisArray(min_requirements, requirements),
    JuMP.Containers.DenseAxisArray(max_requirements, requirements),
    JuMP.Containers.DenseAxisArray(quantity, requirements, food),
)
println(model)

set_optimizer(model, HiGHS.Optimizer)
optimize!(model)
solution_summary(model)

value.(model[:x])

# ## Homework
# 
# Your homework consists in solving the cannery problem described in [Dantzig (1963)](https://www.rand.org/content/dam/rand/pubs/reports/2007/R366part1.pdf), pp. 2-4, using [`JuMP`](https://jump.dev/JuMP.jl/stable/).

plants = ["Portland", "Seattle", "San Diego"]
capacity = JuMP.Containers.DenseAxisArray(
    [250, 500, 750],
    plants,
)

markets = ["New-York", "Chicago", "Kansas City", "Dallas", "San Francisco"]
demand = JuMP.Containers.DenseAxisArray(
    [300, 300, 300, 300, 300],
    markets,
)

price = JuMP.Containers.DenseAxisArray(
    [
        0.9 1.0 1.5 1.8 2.7
        2.5 1.7 1.8 2.0 0.9
        2.5 1.8 1.4 1.6 0.6
    ],
    plants,
    markets,
)
