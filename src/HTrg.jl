module HTrg

using CSV
using Geodesy
using ZipFile
using NearestNeighbors
using RemoteFiles
using JSON

include("get_path.jl")
include("reverse_geocode.jl")

greet() = print("Hello World! HTrg")

end # module
