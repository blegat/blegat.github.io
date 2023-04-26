using Literate, NodeJS

function gen_literate()
    milp = joinpath(@__DIR__, "ccir")
    nbpath  = joinpath(@__DIR__, "generated", "notebooks")
    isdir(nbpath) || mkpath(nbpath)

    # By default, it is `dev` which is good with Documenter but not here with Franklin
    # hence there is an excess `dev/` in the binder and jupyterlab urls.
    config = Dict("devurl" => "")

    for script in readdir(milp)
       if !endswith(script, ".jl")
           continue
       end
       # Generate markdown pages that Franklin will turn into html
       Literate.markdown(joinpath(milp, script), milp, documenter=false, config=config)
       # Generate annotated notebooks
       Literate.notebook(joinpath(milp, script), nbpath,
                         execute=false, documenter=false, config=config)
    end
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
