# # Building the graph and visualizing it

using Graphs
function build_graph()
    G = DiGraph(6)
    w = Int[]
    edge_ids = Dict{Pair{Int,Int},Int}()
    cur_id = 0
    function add(from, to, weight)
        cur_id += 1
        edge_ids[from => to] = cur_id
        add_edge!(G, from, to)
        push!(w, weight)
    end
    add(1, 2, 3)
    add(1, 3, 3)
    add(2, 3, 2)
    add(2, 4, 3)
    add(3, 5, 2)
    add(4, 5, 4)
    add(4, 6, 2)
    add(5, 6, 3)
    return G, w, edge_ids
end
G, w, edge_ids = build_graph()
using GraphPlot
gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = w)

edge_ids

w

edge_ids[3 => 5]

w[edge_ids[3 => 5]]

Graphs.outneighbors(G, 1)

[1 => to for to in Graphs.outneighbors(G, 1)]

[edge_ids[1 => to] for to in Graphs.outneighbors(G, 1)]

[x[edge_ids[1 => to]] for to in Graphs.outneighbors(G, 1)]

sum([x[edge_ids[1 => to]] for to in Graphs.outneighbors(G, 1)])

sum(x[edge_ids[1 => to]] for to in Graphs.outneighbors(G, 1))

# # Max-Flow

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, 0 <= x[i = 1:ne(G)] <= w[i])
@objective(model, Max, sum(x[edge_ids[1 => to]] for to in Graphs.outneighbors(G, 1)))
optimize!(model)

gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = ["$(Int(value(x[i])))/$(w[i])" for i in 1:ne(G)])

value.(x)

Graphs.outneighbors(G, 1)

collect(2:(nv(G) - 1))

edge_ids[2 => 3]

edge_ids[2 => 4]

sum(x[edge_ids[2 => to]] for to in outneighbors(G, 2))

@constraint(
    model,
    conservation_of_flow[node in 2:(nv(G) - 1)],
    sum(x[edge_ids[from => node]] for from in inneighbors(G, node))
    ==
    sum(x[edge_ids[node => to]] for to in outneighbors(G, node)),
)

model[:x]

println(model)

@objective(model, Max,  sum(x[edge_ids[from => nv(G)]] for from in inneighbors(G, nv(G))))

optimize!(model)
solution_summary(model)

gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = ["$(Int(value(x[i])))/$(w[i])" for i in 1:ne(G)])

# # Min-Cut

model = Model(HiGHS.Optimizer)
@variable(model, cut[1:ne(G)], Bin)

@objective(model, Min, sum(w[e] * cut[e] for e in 1:ne(G)))

optimize!(model)
solution_summary(model)

2cut[1] / 3cut[2] + 1

gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = value.(cut))

# | `side[from]` | `side[to]` | `side[to] - side[from]` |
# |-----|-----|---------|
# |  0  |  1  |    1    |
# |  1  |  0  |   -1    |
# |  1  |  1  |    0    |
# |  0  |  0  |    0    |

@variable(model, side[1:nv(G)], Bin)
@constraint(model, side[1] == 0)
@constraint(model, side[nv(G)] == 1)
@constraint(
    model,
    [from in 1:nv(G), to in outneighbors(G, from)],
    cut[edge_ids[from => to]] >= side[to] - side[from],
)

optimize!(model)
solution_summary(model)

gplot(G, nodesize=0.1, nodelabel = ["$(Int(value(side[node])))/$node" for node in 1:6], edgelabel = Int.(value.(cut)) .* w)
