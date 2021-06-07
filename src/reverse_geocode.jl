
export reverse_geocode

# Remote file: cities1000.zip
const _cities1000r = @RemoteFile(
    "https://download.geonames.org/export/dump/cities1000.zip",
    file = "cities1000.zip",
    dir = "$path_rg_root",
    updates = :yearly
    )

# Remote file: countryInfo.txt
const _countryInfor = @RemoteFile(
    "https://download.geonames.org/export/dump/countryInfo.txt",
    file = "countryInfo.txt",
    dir = "$path_rg_root",
    updates = :yearly
    )

#= 
a = """
geonameid         : integer id of record in geonames database
name              : name of geographical point (utf8) varchar(200)
asciiname         : name of geographical point in plain ascii characters, varchar(200)
alternatenames    : alternatenames, comma separated, ascii names automatically transliterated, convenience attribute from alternatename table, varchar(10000)
latitude          : latitude in decimal degrees (wgs84)
longitude         : longitude in decimal degrees (wgs84)
feature class     : see http://www.geonames.org/export/codes.html, char(1)
feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
country code      : ISO-3166 2-letter country code, 2 characters
cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 200 characters
admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) 
admin3 code       : code for third level administrative division, varchar(20)
admin4 code       : code for fourth level administrative division, varchar(20)
population        : bigint (8 byte int) 
elevation         : in meters, integer
dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30'' (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
timezone          : the iana timezone id (see file timeZone.txt) varchar(40)
modification date : date of last modification in yyyy-MM-dd format
"""
lines = split(a,'\n')
for iline in lines
    println('"',strip(iline[1:18],),'"',',','"',strip(iline[20:end]),'"')
end =#

function read_cities(file::String)
    
    coordinates1 = Array{Float64,1}()
    locations = Array{Tuple{String,String,},1}()
    # locations1 = Array{CSV.Row,1}()
    suggest_size = 160_000

    sizehint!(coordinates1, suggest_size * 3)
    sizehint!(locations, suggest_size)
    # sizehint!(locations1, suggest_size)
    if isfile(file)
        for row in CSV.File(file, delim='\t',header=[:gid,:name,:ascname,:altname,
                                            :lat,:lon,:fcl,:fco,:cc,
                                            :cc2,:a1c,:a2c,:a3c,:a4c,
                                            :pop,:ele,:dem,:tz,:md])
            e = ECEFfromLLA(wgs84)(LLA(row.lat, row.lon))
            push!(coordinates1, e.x)
            push!(coordinates1, e.y)
            push!(coordinates1, e.z)
            push!(locations, (row.cc, row.name))
            # push!(locations1, row)
            # @show row
            # break
        end
    end
    reshape(coordinates1, 3, :), locations
end

#= 
hs = "ISO	ISO3	ISO-Numeric	fips	Country	Capital	Area(in sq km)	Population	Continent	tld	CurrencyCode	CurrencyName	Phone	Postal Code Format	Postal Code Regex	Languages	geonameid	neighbours	EquivalentFipsCode" 

a =#
function read_countries(file::String)
    ci = Dict{String,Tuple{String,Int64,String,String,Float64,Float64}}()
    if isfile(file)
        for row in CSV.File(file, delim='\t',  comment="#", 
                                header=[:iso,:iso3,:ison,:fips,:name,:capital,:area,:pup,:cont,
                                            :c10,:c11, :c12, :c13, :c14,
                                            :c15, :c16, :c17, :c18, :c19,], )
            # @show file
            # @show row
            ci[row.iso] = row.iso3, row.ison,
                            row.name, ismissing(row.capital) ? "" : row.capital,
                            row.area, row.pup
            # push!(locations1, row)
            
            # break
        end
    end
    ci
end


function load_geocode(cities1000r::RemoteFile=_cities1000r, countryInfor::RemoteFile=_countryInfor, )

    for ifile in [countryInfor,cities1000r] download(ifile) end

    cities1000 = path(cities1000r)
    if endswith(cities1000, ".zip") 
        c = string(cities1000[1:end - 4], ".txt")
        bc = basename(c)
        if isfile(c) && mtime(cities1000) - mtime(c) < 86400
            cities1000 = c
        else
            r = ZipFile.Reader(cities1000);
            for f in r.files
                if f.name == bc
                    println("Filename: $(f.name)")
                    open(c, "w") do fo
                        write(fo, read(f, String));
                    end
                end
            end
            close(r)
            cities1000 = c
        end
    end
    # @show cities1000
    a, b = read_cities(cities1000);
    # @show path(countryInfor)
    c = read_countries(path(countryInfor))

    a, b, c
end

const coordinates, locations, countries =  load_geocode(_cities1000r, _countryInfor)
const kdtree = KDTree(coordinates)


function reverse_geocode(e1::ECEF, kdtree::KDTree=kdtree,
                    locations::Array{Tuple{String,String},1}=locations,
                    countries::Dict{String,Tuple{String,Int64,String,String,Float64,Float64}}=countries )
    idxs, dists = knn(kdtree, e1, 1, true)
    c, city = locations[idxs[1]]
    if haskey(countries, c)
        cc = countries[c]
    else
        cc = ("???", 0, "?", "?", NaN, NaN)
    end
    c, city, dists[1], cc
end
