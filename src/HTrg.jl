module HTrg

using CSV
using Geodesy
using ZipFile
using NearestNeighbors
using RemoteFiles
using JSON

const path_rg_root = joinpath(homedir(), "RD", "RGEO")


include("reverse_geocode.jl")

greet() = print("Hello World! HTrg")

end # module
