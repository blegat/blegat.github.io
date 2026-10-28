using GLMakie
using Polyhedra

julia_blue_a = RGBAf(0.251, 0.388, 0.847, 0.2)
julia_blue = RGBAf(0.251, 0.388, 0.847)
julia_green = RGBf(0.22, 0.596, 0.149)
julia_purple_a = RGBAf(0.584, 0.345, 0.698, 0.2)
julia_purple = RGBf(0.584, 0.345, 0.698)
julia_red = RGBf(0.796, 0.235, 0.2)

function v(n, s = 4, l = s)
    V = rand(n, 3)
    f = Figure()
    fig = LScene(f[1, 1])
    r = div(n, 2)
    scatter!(fig, V[1:r, :], color = julia_red, markersize = s)
    scatter!(fig, V[r .+ (1:r), :], color = julia_green, markersize = s)
    #r = div(n, 4)
    #scatter!(fig, V[1:r, :], color = julia_blue)
    #scatter!(fig, V[r .+ (1:r), :], color = julia_green)
    #scatter!(fig, V[2r .+ (1:r), :], color = julia_purple)
    #scatter!(fig, V[3r .+ (1:r), :], color = julia_red)

    p = polyhedron(vrep(V))
    m = Polyhedra.Mesh(p)
    Makie.mesh!(fig, m, color=julia_purple_a, transparency = true)
    Makie.wireframe!(fig, m, color=julia_blue, linewidth = l)

    return f
end

using LinearAlgebra

function h(n, s = 4, l = s)
    V = rand(n, 2)
    #f = Figure()
    #fig = LScene(f[1, 1])
    f = plot()
    for i in 1:n
        v = V[i, :]
        p = polyhedron(intersect(HalfSpace(V[i, :], 1)))
        plot!(f, p)
        #m = Polyhedra.Mesh(p)
        #Makie.mesh!(fig, m, color=julia_purple_a, transparency = true)
    end
    return f
end
