
function get_rg_root(k::String)
    file_to = joinpath(homedir(), ".juliaHTsetting.json")
    settings = Dict{String,Any}()
    if isfile(file_to)
        settings = JSON.parsefile(file_to)
    end
    if haskey(settings, k)
        p = settings[k]
    else
        p =  joinpath(homedir(), "juliaHTsetting_defaultpath_please_modify")
        settings[k] = p
        open(file_to, "w") do f
            JSON.print(f, settings, 4)
        end
    end
    if isdir(p) return p
    else throw(error("please modify $k in $file_to to your rinex_root path!"))
    end
end

const path_rg_root = get_rg_root("HTrg_data")

