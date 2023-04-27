using Literate, NodeJS

function _badge(io, tool, img, session, id)
    println(io, "#md # ~~~")
    println(io, "#md # <a href=\"@__$(tool)_ROOT_URL__/generated/notebooks/$session$id.ipynb\"><span class=\"badge\">")
    println(io, "#md # ~~~")
    println(io, "#md # ![]($img.svg)")
    println(io, "#md # ~~~")
    println(io, "#md # </span></a>")
    println(io, "#md # ~~~")
end

start_cap(name) = string(uppercase(name[1]), name[2:end])

function add_header(io::IO, script::AbstractString, session::AbstractString, id::Integer, title)
    println(io, "# # $(start_cap(session)) $id &ndash; $title")
    println(io, "#")
    _badge(io, "BINDER", "https://mybinder.org/badge_logo", session, id)
    _badge(io, "NBVIEWER", "https://img.shields.io/badge/show-nbviewer-579ACA", session, id)
    println(io, "#")
    println(io, "# ---")
    println(io, "#")
    for line in eachline(script)
        println(io, line)
    end
    return io
end

function add_header(output::AbstractString, args...)
    open(io -> add_header(io, args...), output, "w")
    return
end

function gen_literate(session, index_in, index_out)
    jlpath = joinpath(@__DIR__, "ccir")
    nbpath  = joinpath(@__DIR__, "generated", "notebooks")
    isdir(nbpath) || mkpath(nbpath)

    # By default, it is `dev` which is good with Documenter but not here with Franklin
    # hence there is an excess `dev/` in the binder and jupyterlab urls.
    config = Dict("devurl" => "")

    index = read(joinpath(jlpath, index_in), String)

    open(joinpath(jlpath, index_out), "w") do io
        @info("Generating $(session)s...")
        println(io, index)
        println(io)
        println(io, "### $(start_cap(session))s")
        println(io)
        for (id, title) in enumerate(eachline(joinpath(jlpath, session * "s.txt")))
            println(io, "* [$(start_cap(session)) $id](/ccir/$session$id) &ndash; $title")
            sessionid = string(session, id)
            jl = sessionid * ".jl"
            tmp = joinpath(jlpath, "_" * jl)
            add_header(tmp, joinpath(jlpath, jl), session, id, title)
            # Generate markdown pages that Franklin will turn into html
            Literate.markdown(tmp, jlpath, documenter=false, config=config)
            mv(joinpath(jlpath, "_" * sessionid * ".md"), joinpath(jlpath, sessionid * ".md"), force=true)
            # Generate annotated notebooks
            Literate.notebook(tmp, nbpath, execute=false, documenter=false, config=config)
            mv(joinpath(nbpath, "_" * sessionid * ".ipynb"), joinpath(nbpath, sessionid * ".ipynb"), force=true)
        end
    end
end

function gen_literate()
    gen_literate("lecture", "_index.md", "index.md")
    gen_literate("practical", "index.md", "index.md")

    if get(ENV, "CI", "false") == "true"
        @info("Copying `generated` folder in the `gh-pages` branch...")
        JS_GHP = """
            var ghpages = require('gh-pages');
            ghpages.publish('generated/', function(err) {});
            """
        run(`$(nodejs_cmd()) -e $JS_GHP`)
    end
end

gen_literate()
