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

value(sum(flow[Edge(3 => to)] for to in Graphs.outneighbors(G, 3)))
value(sum(flow[Edge(from => 3)] for from in Graphs.inneighbors(G, 3)))

@expression(
    model,
    incoming_flow[v in Graphs.vertices(G); v != 1],
    sum(flow[Edge(from => v)] for from in Graphs.inneighbors(G, v)),
)

@expression(
    model,
    outgoing_flow[v in Graphs.vertices(G); v != Graphs.nv(G)],
    sum(flow[Edge(v => to)] for to in Graphs.outneighbors(G, v)),
)

@constraint(model, [v in Graphs.vertices(G); v != 1 && v != Graphs.nv(G)], incoming_flow[v] == outgoing_flow[v])

@objective(model, Max, outgoing_flow[1])

optimize!(model)
solution_summary(model)
viz()

# # Min-Cut

model = Model(HiGHS.Optimizer)
@variable(model, 0 <= cut[Graphs.edges(G)] <= 1)

@objective(model, Min, sum(w[e] * cut[e] for e in Graphs.edges(G)))

optimize!(model)
solution_summary(model)

gplot(G, nodesize=0.1, nodelabel = 1:6, edgelabel = [w[e] * Int(value(cut[e])) for e in Graphs.edges(G)], edgelabelc = colorant"red")

# | `side[from]` | `side[to]` | `side[to] - side[from]` |
# |--------------|------------|-------------------------|
# |      0       |      1     |           1             |
# |      1       |      0     |          -1             |
# |      1       |      1     |           0             |
# |      0       |      0     |           0             |

@variable(model, 0 <= side[1:nv(G)] <= 1)
@constraint(model, side[1] == 0)
@constraint(model, side[nv(G)] == 1)

@constraint(model, [edge in Graphs.edges(G)], cut[edge] >= side[edge.dst] - side[edge.src])

optimize!(model)
solution_summary(model)

gplot(
    G,
    nodesize=0.1,
    nodefillc = [ifelse(round(value(side[node])) == 0, "red", "blue") for node in Graphs.vertices(G)],
    nodelabel = Graphs.vertices(G),
    edgelabel = [w[e] * Int(value(cut[e])) for e in Graphs.edges(G)],
    edgelabelc = colorant"red",
    edgestrokec = [ifelse(round(value(cut[edge])) == 0, "grey", "green") for edge in Graphs.edges(G)],
)
