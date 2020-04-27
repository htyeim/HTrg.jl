using HTrg
using Test
using Geodesy


@testset "HTrg.jl" begin
    # Write your own tests here.

    p1 = LLA(51.5214588, -0.1729636)
    e1 = ECEFfromLLA(wgs84)(p1)
    
    code, city, dis, ci = reverse_geocode(e1)
    @test code == "GB"
    @test city == "Bayswater"
    @test isapprox(dis, 1388.453678654349)

    p2 = LLA(22.2710, 113.5767)
    e2 = ECEFfromLLA(wgs84)(p2)
    @show code, city, dis, ci = reverse_geocode(e2)
    @test code == "CN"
    @test city == "Zhuhai"
    @test isapprox(dis, 1130.3958719970858)

end
