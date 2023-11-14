import BibTeX
_, BIB = BibTeX.parse_bibtex(read("../Research/biblio.bib", String))

@enum(BibType, THESIS, CHAPTER, JOURNAL, CONF)
TYPE_MAP = Dict{String,BibType}(
    "article" => JOURNAL,
    "inproceedings" => CONF,
)

function _get(d::Dict, key)
    if !haskey(d, key)
        display(d)
        error("\"$(d["title"])\" does not have key `$key`.")
    end
    return d[key]
end

struct Bibs
    sub::Dict{BibType,Vector{Dict{String,String}}}
end

BIBS = Bibs(Dict{String,Vector{Dict{String,String}}}())

function month_id(d::Dict)
    month = get(d, "month", "dec")
    return Dates.monthabbr_to_value(month, Dates.LOCALES["english"])
end

using Dates
function year_month(d::Dict{String,String})
    return parse(Int, d["year"]), month_id(d)
end

function year_month_isless(a::Dict, b::Dict)
    return year_month(a) < year_month(b)
end

function add!(
    b::Bibs,
    entry::Dict;
    bib_type::BibType = TYPE_MAP[entry["type"]],
    kws...,
)
    if !haskey(b.sub, bib_type)
        b.sub[bib_type] = Dict{String,String}[]
    end
    entry = copy(entry)
    for (key, value) in kws
        k = string(key)
        if haskey(entry, k)
            @warn("Entry \"$(entry["title"])\" already has key $k")
        end
        if k != "url" && !(k in KEYS)
            error("Invalid key `$k`, it should be one of `$KEYS`")
        end
        entry[k] = value
    end
    push!(b.sub[bib_type], entry)
    return
end
function add!(
    key::String;
    kws...,
)
    add!(BIBS, BIB[key]; kws...)
    return
end

TITLE = Dict(
    THESIS => "Ph.D. thesis",
    CHAPTER => "Chapters",
    JOURNAL => "Journal Papers",
    CONF => "Conference Proceedings",
)

# Fix for a BibTeX shortcoming
function _fix(s::String)
    s = replace(s, "\\c { c } " => "ç")
    s = replace(s, " { \\ \" e } " => "ë")
    s = replace(s, " { \\ \" { e } } " => "ë")
    s = replace(s, "\\ \" { e } " => "ë")
    s = replace(s, " { \\' { e } } " => "é")
    s = replace(s, " { \\'a } " => "á")
    s = replace(s, " { \\' { a } } " => "á")
    s = replace(s, " { \\o } " => "ø")
    s = replace(s, " { \\^ { i } } " => "î")
    s = replace(s, " { \\^ { \\i } } " => "î")
    s = replace(s, " { \\^\\i } " => "î")
    s = replace(s, " { \\^i } " => "î")
    s = replace(s, "\\^ { \\i } " => "î")
    s = replace(s, " { \\'c } " => "ć")
    s = replace(s, " { \\v { s } } " => "š")
    s = replace(s, "- { " => "-")
    s = replace(s, "{ " => "")
    s = replace(s, " } " => "")
    s = replace(s, " }" => "")
    return s
end

function fix_author(author)
    return join(reverse(strip.(split(author, ','))), " ")
end

function fix_authors(authors)
    return join(fix_author.(split(authors, "and")), " and ")
end

function tag(args...)
    io = IOBuffer()
    tag(IOBuffer(), args...)
    return String(take!(io))
end

function href(args...)
    io = IOBuffer()
    href(io, args...)
    return String(take!(io))
end

function tag(io::IO, tag, content, options = "")
    print(io, "<")
    print(io, tag)
    if !isempty(options)
        print(io, ' ')
        print(io, options)
    end
    print(io, ">")
    print(io, content)
    print(io, "</")
    print(io, tag)
    print(io, ">")
end

function href(io, href, content)
    tag(io, "a", content, "href=\"$href\"")
end

doi_url(doi) = "https://doi.org/" * doi
arXiv_url(id) = "https://arxiv.org/abs/" * id

KEYS = ["arXiv", "Optimization_Online", "pdf", "code_doi", "code", "slides"]

function print_entry(io::IO, d::Dict)
    print(io, fix_authors(_fix(_get(d, "author"))))
    print(io, ". ")
    title = _fix(d["title"])
    if haskey(d, "url")
        title = href(d["url"], title)
    end
    tag(io, "strong", title)
    print(io, ".")
    if haskey(d, "journal")
        venue = d["journal"]
    elseif haskey(d, "booktitle")
        venue = d["booktitle"]
        if haskey(d, "series")
            venue = d["series"] * " : " * venue
        end
    elseif haskey(d, "series")
        venue = d["series"]
    else
        display(d)
        error("Missing venue")
    end
    print(io, " ")
    tag(io, "em", _fix(venue))
    print(io, ", ")
    if haskey(d, "month")
        print(io, Dates.monthname(month_id(d)), ' ')
    end
    print(io, d["year"], '.')
    if haskey(d, "doi")
        print(io, " ")
        doi = d["doi"]
        href(io, doi_url(doi), doi)
    end
    br_done = false
    for name in KEYS
        if haskey(d, name)
            if br_done
                print(io, " ")
            else
                print(io, "<br/>")
                br_done = true
            end
            value = d[name]
            if name == "code_doi"
                url = doi_url(value)
                content = "code " * value
            else
                if name == "arXiv"
                    url = arXiv_url(value)
                else
                    url = value
                end
                content = replace(name, "_" => " ")
            end
            href(io, url, content)
        end
    end
    println(io)
end

function Base.show(io::IO, b::Bibs)
    for bib_type in sort(collect(keys(b.sub)))
        sub = b.sub[bib_type]
        sort!(sub, lt = year_month_isless, rev = true)
        println(io)
        println(io, "## $(TITLE[bib_type])")
        println(io)
        println(io, "~~~")
        println(io, "<ul>")
        for entry in sub
            println(io, "  <li>")
            print(io, "    ")
            print_entry(io, entry)
            println(io, "  </li>")
        end
        println(io, "</ul>")
        println(io, "~~~")
    end
end

add!("legat2022computation",
    code_doi = "10.24433/CO.5065309.v1",
    bib_type = CHAPTER,
)
add!("besancon2023flexible",
    url = "https://pubsonline.informs.org/doi/abs/10.1287/ijoc.2022.0283",
    arXiv = "2206.06135",
    code = "https://github.com/jump-dev/DiffOpt.jl",
)
add!("legat2023lowrank",
    url = "https://epubs.siam.org/doi/10.1137/22M1516208",
    arXiv = "2205.11466",
    code_doi = "10.24433/CO.7364738.v1",
)
add!("lubin2023jump",
    url = "https://link.springer.com/article/10.1007/s12532-023-00239-3",
    arXiv = "2206.03866",
    code = "https://cs.paperswithcode.com/paper/jump-1-0",
)
add!("legat2022geometric",
    url = "https://www.sciencedirect.com/science/article/pii/S1751570X2200084X?via%3Dihub",
    code_doi = "10.24433/CO.4907777.v2",
)
add!("legat2021piecewise",
    url = "https://ieeexplore.ieee.org/document/9126839",
    arXiv = "2007.02770",
    code_doi = "10.24433/CO.6396918.v1",
)
add!("legat2021limits",
    url = "https://www.mdpi.com/1424-8220/21/11/3700",
)
add!("legat2021mathoptinterface",
    url = "https://pubsonline.informs.org/doi/10.1287/ijoc.2021.1067",
    arXiv = "https://arxiv.org/abs/2002.03447",
    Optimization_Online = "http://www.optimization-online.org/DB_HTML/2020/02/7609.html",
    code = "https://github.com/jump-dev/MOIPaperBenchmarks",
)
add!("legat2020sum",
    url = "https://www.sciencedirect.com/science/article/pii/S1751570X20300054",
    code = "https://github.com/blegat/SwitchOnSafety.jl",
)
add!("legat2020certifying",
    url = "https://epubs.siam.org/doi/10.1137/18M1173460",
    arXiv = "1710.01814",
    pdf = "https://drive.google.com/open?id=0B1axlYz3_XXKd0lTektfekU2eGc",
    code_doi = "10.24433/CO.9148109.v2",
)
add!("legat2019entropy",
    url = "https://ieeexplore.ieee.org/document/8657769",
    code_doi = "10.24433/CO.0452244.v1",
)
add!("Martin2018",
    url = "https://www.sciencedirect.com/science/article/pii/S0003267018303490?via%3Dihub",
    code = "https://github.com/ManonMartin/PepsNMR",
)

add!("cunis2023sequential",
    url = "https://ieeexplore.ieee.org/document/10156153/",
    arXiv = "2210.02142",
)
add!("calbert2021alternating",
    url = "https://ieeexplore.ieee.org/document/9683448",
    code = "https://github.com/dionysos-dev/Dionysos.jl",
)
add!("legat2021geometric",
    url = "https://ieeexplore.ieee.org/document/9683448",
    arXiv = "2101.06990",
    code_doi = "10.24433/CO.6266939.v1",
)
add!("legat2021abstractionbased",
    url = "https://proceedings.mlr.press/v144/legat21a.html",
    arXiv = "2011.11029",
    code = "https://github.com/dionysos-dev/Dionysos.jl",
)
add!("legat2020stability",
    url = "https://ieeexplore.ieee.org/document/9304152",
    arXiv = "https://arxiv.org/abs/2009.04505",
)
add!("gomes2017stable",
    url = "https://link.springer.com/chapter/10.1007/978-3-030-14883-6_5",
    bib_type = CONF,
)
add!("legat2018computing",
    url = "https://www.sciencedirect.com/science/article/pii/S2405896318311480",
    arXiv = "1802.04522",
    code = "https://github.com/blegat/SwitchOnSafety.jl",
)
add!("gomes2018minimally",
    url = "https://ieeexplore.ieee.org/abstract/document/8619223",
    arXiv = "https://arxiv.org/abs/1809.02648",
)
add!("legat2016parallel",
    url = "http://sites.uclouvain.be/sitb2016/Proceedings_SITB2016_preliminary.pdf",
    pdf = "https://drive.google.com/open?id=0B1axlYz3_XXKNTRjZTVuSmtWTXM",
    code = "https://github.com/blegat/EntropicCone.jl",
    slides = "https://drive.google.com/open?id=0B1axlYz3_XXKa3BXZTlsdUJJZzA",
)
add!("legat2016generating",
    url = "http://dl.acm.org/citation.cfm?id=2883821",
    pdf = "https://drive.google.com/open?id=0B1axlYz3_XXKeGRabkFCN3R0Y00",
    code = "https://github.com/blegat/RPHSCC2016",
    slides = "https://drive.google.com/open?id=0B1axlYz3_XXKNm13eWU5R3E1RVE",
)
#add!("legat2021mutablearithmetics")

show(BIBS)
open("publications.md", "a") do io
    print(io, BIBS)
end
