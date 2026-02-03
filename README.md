
<!-- README.md is generated from README.Rmd. Please edit that file -->

# swadlr

<!-- badges: start -->

<!-- badges: end -->

swadlr provides access to the [EPI State of Working America Data
Library](https://data.epi.org) (SWADL) API.

## Examples

Use swadlr if you need to programmatically retrieve a time series from
SWADL:

``` r
library(swadlr)

get_swadl(
  indicator = "hourly_wage_percentiles",
  measure = "nominal_wage",
  dimension = list("wage_percentile" = "wage_p50")
)
#> # A tibble: 53 × 4
#>    date       value geography wage_percentile
#>    <date>     <dbl> <chr>     <chr>          
#>  1 1973-01-01  3.35 national  wage_p50       
#>  2 1974-01-01  3.62 national  wage_p50       
#>  3 1975-01-01  3.94 national  wage_p50       
#>  4 1976-01-01  4.12 national  wage_p50       
#>  5 1977-01-01  4.41 national  wage_p50       
#>  6 1978-01-01  4.73 national  wage_p50       
#>  7 1979-01-01  5.11 national  wage_p50       
#>  8 1980-01-01  5.63 national  wage_p50       
#>  9 1981-01-01  6.10 national  wage_p50       
#> 10 1982-01-01  6.46 national  wage_p50       
#> # ℹ 43 more rows
```

For a summary of what is available for a given indicator

``` r
swadl_indicator("hourly_wage_percentiles")
#> 
#> ── Indicator ──
#> 
#> • Name: Hourly wage percentiles
#> • Topic: wages
#> • Last updated: 2026-01-23
#> 
#> ── Measures ──
#> 
#> ID              Name                      Format
#> real_wage_2025  Real hourly wage (2025$)  dollar
#> nominal_wage    Nominal hourly wage       dollar
#> 
#> ── Dimensions by geography ──
#> 
#> division (up to 2-way)
#>   education × wage_percentile, gender × wage_percentile, race × wage_percentile, wage_percentile
#> national (up to 3-way)
#>   age_group × wage_percentile, education × wage_percentile, gender × wage_percentile, nativity × wage_percentile, public_sector × wage_percentile, race × wage_percentile, ... (12 total)
#> region (up to 2-way)
#>   education × wage_percentile, gender × wage_percentile, race × wage_percentile, wage_percentile
#> state (up to 2-way)
#>   education × wage_percentile, gender × wage_percentile, race × wage_percentile, wage_percentile
#> 
#> ── Dates ──
#> 
#> • Annual: 1973 — 2025
#> • Quarterly: Not available
#> • Monthly: Not available
#> 
#> ── Sources ──
#> 
#> • real_wage_2025: Deflated using the extended Chained CPI-U
#> • (all): Current Population Survey, EPI extracts
```

If you have the need to retrieve many time series, don’t use the API.
Instead, simply [download all the
data](https://economic.github.io/data/).

## Installation

You can install swadlr from
[r-universe](https://economic.r-universe.dev/swadlr):

``` r
install.packages(
  "swadlr",
  repos = c("https://economic.r-universe.dev", "https://cloud.r-project.org")
)
```

## Documentation

See the [package website](https://economic.github.io/swadlr/) for full
documentation and the [Getting started
vignette](https://economic.github.io/swadlr/articles/swadlr.html) for
more examples.
