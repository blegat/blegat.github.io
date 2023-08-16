prices = [
    3 2 8
    1 9 3
    5 3 2
]
need = [5 3 19]
shops = 1:3
items = 1:3

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, 0 <= buy[shops, items])
for item in items
    @constraint(model, sum(buy[shop, item] for shop in shops) == need[item])
end
@objective(model, Min, sum(buy[shop, item] * prices[shop, item] for shop in shops, item in items))
println(model)

optimize!(model)
solution_summary(model)

value.(buy)

@variable(model, buy[shops, items])

collect(1:9)

@objective(model, Min, sum(prices[i, j] * buy[i, j] for i in 1:3, j in 1:3))

item = 1
sum(buy[shop, item] for shop in shops)

value(buy[2,1])

optimize!(model)

solution_summary(model)

value.(buy)

# # MILP

@variable(model, go[shop in shops], Bin)

@objective(model, Min, sum(buy[shop, item] * prices[shop, item] for shop in shops, item in items) + 5sum(go))


@constraint(model, [shop in shops, item in items], buy[shop, item] <= maximum(need) * go[shop])

@constraint(model, buy[1, 2] <= 10go[1])
@constraint(model, buy[2, 2] <= 10go[2])
@constraint(model, buy[3, 2] <= 10go[3])

for shop in shops
    for item in items
        @constraint(model, buy[shop,item] <= 10000000000 * go[shop])
    end
end

println(model)

optimize!(model)

solution_summary(model)

value.(buy)

value.(go)

@constraint(model, [shop in shops, item in items], buy[shop, item] <= need[item] * go[shop])

for shop in shops
    for item in items
        @constraint(model, buy[shop, item] <= need[item] * go[shop])
    end
end

@constraint(model, buy[1, 2] <= go[1])

@constraint(model, buy[1, 3] <= go[1])

# # Big-M formulation
# 
# If $b = 0$ then $a \le 0$. This is encoded as $a \le Mb$ where $M$ is a big enough constant.

@constraint(model, buy[1, 2] <= 3go[1])

optimize!(model)

solution_summary(model)

value.(buy)

value.(go)

Inf - Inf

for shop in shops
    for item in items
        @constraint(model, buy[shop, item] <= 1000000000go[shop])
    end
end

optimize!(model)

solution_summary(model)

value.(buy)

value.(go)

println(model)

for shop in shops
    for item in items
        @constraint(model, buy[shop, item] <= need[item] * go[shop])
    end
end

println(model)

# # Branch and Bound

prices = [
    3 2 8
    1 9 3
    5 3 2
]
need = [5.5 3 9]
using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
shops = 1:3
items = 1:3
@variable(model, 0 <= buy[shop in shops, item in items])
@constraint(model, [item in items], sum(buy[shop, item] for shop in shops) == need[item])
shop_fixed_cost = 10
#@variable(model, 0 <= go[shop in shops] <= 1, Bin)
@variable(model, 0 <= go[shop in shops] <= 1)
@objective(model, Min, sum(buy[shop, item] * prices[shop, item] for shop in shops, item in items) + shop_fixed_cost * sum(go))
@constraint(model, [shop in shops, item in items], buy[shop, item] <= need[item] * go[shop])
println(model)

optimize!(model)

value.(buy)

value.(go)

# ## Planar example

model = Model(HiGHS.Optimizer)
@variable(model,  0 <= x[1:2] <= 3)
@constraint(model, x[1] + 2x[2] <= 4)
@constraint(model, 2x[1] + x[2] <= 4)
@objective(model, Max, x[1] + x[2])
println(model)

@constraint(model, x[1] + x[2] <= 2)

optimize!(model)
value.(x)

using Plots, Polyhedra
plot(polyhedron(model), ratio = :equal)
#plot!([8/3, 0], [0, 8/3])
scatter!([1.333333333], [1.33333333])
scatter!([0, 0, 1, 1, 0, 2], [0, 1, 0, 1, 2, 0])
scatter!([1, 0, 2], [1, 2, 0])

set_upper_bound(x[1], 1)
set_upper_bound(x[2], 1)

#@constraint(model, x[1] <= 1)
set_lower_bound(x[1], 2)
println(model)

optimize!(model)
value.(x)

#@constraint(model, x[1] <= 1)
set_lower_bound(x[2], 2)
optimize!(model)
value.(x)

using Plots, Polyhedra
plot(polyhedron(model))
plot!([2.5, 0], [0, 2.5])
scatter!([1, 0, 2], [1, 2, 0])

model_11 = copy(model)
set_upper_bound(x[2], 1)
println(model)

optimize!(model)
value.(x)

using Plots, Polyhedra
plot(polyhedron(model))
plot!([2, 0], [0, 2])
scatter!([1], [1])

model_2 = copy(model)
set_lower_bound(x[1], 2)
println(model)

2^30

using Plots, Polyhedra
plot(polyhedron(model))
plot!([2, 0], [0, 2])
scatter!([1], [1])

objective_value(model)
