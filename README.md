# HTrg

<!-- [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://htyeim.github.io/HTrg.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://htyeim.github.io/HTrg.jl/dev) -->
[![Build Status](https://travis-ci.com/htyeim/HTrg.jl.svg?branch=master)](https://travis-ci.com/htyeim/HTrg.jl)
[![Codecov](https://codecov.io/gh/htyeim/HTrg.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/htyeim/HTrg.jl)

Get geocode from ECEF

mainly based on [reverse_geocode](https://bitbucket.org/richardpenman/reverse_geocode) and [reverse-geocoder](https://github.com/thampiman/reverse-geocoder).


```
using Geodesy
using HTrg

p = LLA(22.2710, 113.5767)
e = ECEFfromLLA(wgs84)(p)

@show code, city, dis, ci = get_geocode(e);

(code, city, dis, ci) = get_geocode(e) = ("CN", "Zhuhai", 1130.3958719970858, ("CHN", 156, "China", "Beijing", 9.59696e6, 1.39273e9))

```


