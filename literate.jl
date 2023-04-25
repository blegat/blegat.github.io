using Literate, NodeJS

function gen_literate()
    milp = joinpath(@__DIR__, "teaching", "milp")
    nbpath  = joinpath(@__DIR__, "generated", "notebooks")
    isdir(nbpath) || mkpath(nbpath)

    for script in readdir(milp)
       # Generate annotated notebooks
       Literate.notebook(joinpath(ccir, script), nbpath,
                         execute=false, documenter=false)
    end
    JS_GHP = """
        var ghpages = require('gh-pages');
        ghpages.publish('generated/', function(err) {});
        """
    run(`$(nodejs_cmd()) -e $JS_GHP`)
end
