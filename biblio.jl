module Biblio

import Bibliography
BIB = nothing

function load!()
    BIB_FILE = joinpath(@__DIR__, "../Research/biblio.bib")
    global BIB = Bibliography.import_bibtex(BIB_FILE, check = :warn)
end

KEYS = ["arXiv", "Optimization_Online", "pdf", "code_doi", "code", "slides"]

# Fix for a BibTeX shortcoming
function _fix(s::String)
    s = replace(s, "\\c{c}" => "ç")
    s = replace(s, "{\\\"e}" => "ë")
    s = replace(s, "{\\\"{e}}" => "ë")
    s = replace(s, "\\\"{e}" => "ë")
    s = replace(s, "{\\'{e}}" => "é")
    s = replace(s, "{\\'a}" => "á")
    s = replace(s, "{\\'{a}}" => "á")
    s = replace(s, "{\\o}" => "ø")
    s = replace(s, "{\\^{i}}" => "î")
    s = replace(s, "{\\^{\\i}}" => "î")
    s = replace(s, "{\\^\\i}" => "î")
    s = replace(s, "{\\^i}" => "î")
    s = replace(s, "\\^{\\i} " => "î")
    s = replace(s, "{\\'c}" => "ć")
    s = replace(s, "{\\v{s}}" => "š")
    s = replace(s, "{" => "")
    s = replace(s, "}" => "")
    return s
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

function print_entry(io::IO, key::String; kws...)
    if isnothing(BIB)
        load!()
    end
    print_entry(io, BIB[key]; kws...)
end

function cite(d)
    return "[" * join([first(s.last) for s in d.authors]) * d.date.year[end-1:end] * "]"
end

function print_entry(io::IO, d; links = true, venue = true, doi = true, cite = false)
    if cite
        print(io, Biblio.cite(d))
        print(io, ' ')
    end
    print(io, _fix(Bibliography.xnames(d)))
    print(io, ". ")
    title = _fix(d.title)
    url = get(d.fields, "url", d.access.url)
    if !isempty(url)
        title = href(url, title)
    end
    tag(io, "strong", title)
    print(io, ".")
    if venue
        venue = Bibliography.xin(d)
        if isempty(venue)
            display(d)
            error("Missing venue")
        end
        print(io, " ")
        tag(io, "em", _fix(venue))
        print(io, ", ")
    end
    if doi
        _doi = d.access.doi
        if !isempty(_doi)
            print(io, " ")
            href(io, doi_url(_doi), _doi)
        end
    end
    if links
        br_done = false
        for name in KEYS
            if haskey(d.fields, name)
                if br_done
                    print(io, " ")
                else
                    print(io, "<br/>")
                    br_done = true
                end
                value = d.fields[name]
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
    end
    println(io)
end

end
