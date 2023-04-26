using Literate, NodeJS

function gen_literate()
    milp = joinpath(@__DIR__, "ccir")
    nbpath  = joinpath(@__DIR__, "generated", "notebooks")
    isdir(nbpath) || mkpath(nbpath)

    for script in readdir(milp)
       if !endswith(script, ".jl")
           continue
       end
       # Generate markdown pages that Franklin will turn into html
       Literate.markdown(joinpath(milp, script), milp, documenter=false)
       # Generate annotated notebooks
       Literate.notebook(joinpath(milp, script), nbpath,
                         execute=false, documenter=false)
    end
    JS_GHP = """
        var ghpages = require('gh-pages');
        ghpages.publish('generated/', function(err) {});
        """
    run(`$(nodejs_cmd()) -e $JS_GHP`)
end

gen_literate()
