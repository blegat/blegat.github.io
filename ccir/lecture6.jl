# # Building the graph and visualizing it

using Graphs
function build_graph()
    G = DiGraph(6)
    w = Dict{Graphs.SimpleGraphs.SimpleEdge{Int},Int}()
    function add(from, to, weight)
        add_edge!(G, from, to)
        w[Edge(from => to)] = weight
    end
    add(1, 2, 3)
    add(1, 3, 3)
    add(2, 3, 2)
    add(2, 4, 3)
    add(3, 5, 2)
    add(4, 5, 4)
    add(4, 6, 2)
    add(5, 6, 3)
    return G, w
end
G, w = build_graph()
using GraphPlot
using Colors

gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = [w[e] for e in edges(G)], edgelabelsize = 2.0, edgelabelc = colorant"red")

# # Max-Flow

using JuMP
import HiGHS
model = Model(HiGHS.Optimizer)
@variable(model, 0 <= flow[edge in edges(G)] <= w[edge])
@objective(model, Max, sum(flow[Edge(1 => to)] for to in Graphs.outneighbors(G, 1)))
optimize!(model)

function viz()
    gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = ["$(Int(value(flow[edge])))/$(w[edge])" for edge in edges(G)], edgelabelc = colorant"red")
end
viz()

sum(x[edge_ids[3 => to]] for to in Graphs.outneighbors(G, 3))
sum(x[edge_ids[from => 3]] for from in Graphs.inneighbors(G, 3))

@constraint(model, sum(x[edge_ids[node => 3]] for node in inneighbors(G, 3)) == sum(x[edge_ids[3 => node]] for node in outneighbors(G, 3)))
optimize!(model)
viz()

@constraint(
    model,
    conservation_of_flow[node in 2:(nv(G) - 1)],
    sum(x[edge_ids[from => node]] for from in inneighbors(G, node))
    ==
    sum(x[edge_ids[node => to]] for to in outneighbors(G, node)),
)
optimize!(model)
solution_summary(model)
viz()

# # Min-Cut

model = Model(HiGHS.Optimizer)
@variable(model, 0 <= cut[1:ne(G)] <= 1)

@objective(model, Min, sum(w[e] * cut[e] for e in 1:ne(G)))

optimize!(model)
solution_summary(model)

2cut[1] / 3cut[2] + 1

gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = value.(cut), edgelabelc = colorant"red")

# | `side[from]` | `side[to]` | `side[to] - side[from]` |
# |-----|-----|---------|
# |  0  |  1  |    1    |
# |  1  |  0  |   -1    |
# |  1  |  1  |    0    |
# |  0  |  0  |    0    |

@variable(model, side[1:nv(G)])
@constraint(model, side[1] == 0)
@constraint(model, side[nv(G)] == 1)
@constraint(
    model,
    [from in 1:nv(G), to in outneighbors(G, from)],
    cut[edge_ids[from => to]] >= side[to] - side[from],
)

optimize!(model)
solution_summary(model)

gplot(G, nodesize=0.1, nodelabel = ["$(Int(value(side[node])))/$node" for node in 1:6], edgelabel = Int.(value.(cut)) .* w, edgelabelc = colorant"red")
