using Documenter, HTrg

makedocs(;
    modules=[HTrg],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/htyeim/HTrg.jl/blob/{commit}{path}#L{line}",
    sitename="HTrg.jl",
    authors="htyeim <htyeim@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/htyeim/HTrg.jl",
)
