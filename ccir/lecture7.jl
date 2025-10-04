# # Visualization

n = 30
using Random
Random.seed!(1234)
x = rand(n)
y = rand(n)

using Plots
function p(x, y, order)
    scatter(x, y, label="")
    for i in 1:n
        from = order[i]
        to = order[mod1(i + 1, n)]
        plot!([x[from], x[to]], [y[from], y[to]], label="", color=:black)
    end
    plot!()
end

p(x, y, 1:12)

norm([x[1] - x[2], y[1] - y[2]])

cost(x, y, 1:10)

cost(x, y, [1, 4, 3, 2, 5, 9, 8, 6, 7, 10])

p(x, y, [1, 4, 3, 2, 5, 9, 8, 6, 7, 10])

using LinearAlgebra
function cost(x, y, order)
    n = length(x)
    s = 0.0
    for i in 1:n
        from = order[i]
        to = order[mod1(i + 1, n)]
        s += norm([x[to] - x[from], y[to] - y[from]])
    end
    return s
end

# # Brute-Force

using Combinatorics
using ProgressMeter
function brute_force(x, y)
    n = length(x)
    best_order = nothing
    best_cost = Inf
    @showprogress for order in Combinatorics.permutations(1:n)
        current_cost = cost(x, y, order)
        if current_cost < best_cost
            best_cost = current_cost
            best_order = order
        end
    end
    return best_order
end

best_order = @time brute_force(x, y)

cost(x, y, best_order)

p(x, y, best_order)

factorial(20)

# # Mixed-Integer Programming

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, z[i in 1:n, j in [1:(i-1); (i+1):n]], Bin);

@objective(model, Min, sum(z[i, j] * norm([x[j] - x[i], y[j] - y[i]]) for i in 1:n for j in 1:n if i != j));

optimize!(model)

termination_status(model)

value.(z)

@constraint(model, one_incoming_edge[j in 1:n], sum(z[i, j] for i in 1:n if i != j) == 1)

@constraint(model, one_outgoing_edge[i in 1:n], sum(z[i, j] for j in 1:n if i != j) == 1)

optimize!(model)
solution_summary(model)

value.(z)

function extract_order(x)
    next = zeros(Int, n)
    for i in 1:n
        for j in 1:n
            if i != j && isapprox(x[i, j], 1)
                if !iszero(next[i])
                    error("Two edges outgoing from $i")
                end
                next[i] = j
            end
        end
    end
    for i in 1:n
        if iszero(next[i])
            error("No outgoing edge from $i")
        end
    end
    @show next
    orders = Vector{Int}[]
    visited = falses(n)
    for start in 1:n
        if !visited[start]
            current = start
            order = Int[]
            while true
                visited[current] = true
                push!(order, current)
                current = next[current]
                if current == start
                    break
                end
            end
            push!(orders, order)
        end
    end
    return orders
end

mip_orders = extract_order(value.(z))

mip_order = reduce(vcat, mip_orders)

cost(x, y, mip_order)

p(x, y, mip_order)

@constraint(model, z[3, 10] + z[10, 7] + z[7, 8] + z[8, 3] <= 3)

@constraint(model, [i in 1:n, j in 1:n; i != j], z[i, j] + z[j, i] <= 1)

# # Miller-Tucker-Zemlin

@variable(model, 1 <= place[1:n] <= n)

# if `z[i, j]` is 1 then
#   `place[i] >= place[j] + 1`

@constraint(model, mtz[i in 1:n, j in 1:n; i != j && j != 1], n * (1 - z[i, j]) + place[i] >= place[j] + 1)

optimize!(model)
solution_summary(model)

value.(place)

mip_orders = extract_order(value.(z))

mip_order = reduce(vcat, mip_orders)

cost(x, y, mip_order)

p(x, y, mip_order)

factorial(big(30))