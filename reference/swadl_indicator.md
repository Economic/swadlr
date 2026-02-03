# Get detailed information about an indicator

Returns detailed information about a specific indicator including
available measures, dimension combinations, date ranges, geographic
availability, and sources.

## Usage

``` r
swadl_indicator(indicator)
```

## Arguments

- indicator:

  The indicator ID (e.g., `"hourly_wage_percentiles"`). Use
  [`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
  to see available indicators.

## Value

An S3 object of class `swadl_indicator_info` with the following
components:

- id:

  Indicator identifier

- name:

  Human-readable indicator name

- topic:

  Topic ID the indicator belongs to

- updated:

  Date the indicator was last updated

- measures:

  Tibble of available measures with columns: `id`, `name`, `format`

- availability:

  Tibble of availability information with columns: `date_interval`,
  `measure_id`, `geo_level`, `dimensions`, `date_start`, `date_end`. The
  `dimensions` column contains dimension IDs joined with `x` (using
  multiplication sign), or `"overall"` for aggregate data.

- sources:

  Tibble of sources with columns: `measure_id`, `source`, `url`

## See also

[`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
to list available indicators, measures, and dimensions.

## Examples

``` r
# \donttest{
# Get information about hourly wage percentiles
info <- swadl_indicator("hourly_wage_percentiles")
print(info)
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

# Access specific components
info$measures
#> # A tibble: 2 × 3
#>   id             name                     format
#>   <chr>          <chr>                    <chr> 
#> 1 real_wage_2025 Real hourly wage (2025$) dollar
#> 2 nominal_wage   Nominal hourly wage      dollar
info$availability
#> # A tibble: 48 × 6
#>    date_interval measure_id   geo_level dimensions         date_start date_end  
#>    <chr>         <chr>        <chr>     <chr>              <date>     <date>    
#>  1 year          nominal_wage division  education × wage_… 1978-01-01 2025-01-01
#>  2 year          nominal_wage division  gender × wage_per… 1978-01-01 2025-01-01
#>  3 year          nominal_wage division  race × wage_perce… 1978-01-01 2025-01-01
#>  4 year          nominal_wage division  wage_percentile    1978-01-01 2025-01-01
#>  5 year          nominal_wage national  age_group × gende… 1973-01-01 2025-01-01
#>  6 year          nominal_wage national  age_group × race … 1973-01-01 2025-01-01
#>  7 year          nominal_wage national  age_group × wage_… 1973-01-01 2025-01-01
#>  8 year          nominal_wage national  education × wage_… 1973-01-01 2025-01-01
#>  9 year          nominal_wage national  education × gende… 1973-01-01 2025-01-01
#> 10 year          nominal_wage national  gender × wage_per… 1973-01-01 2025-01-01
#> # ℹ 38 more rows
# }
```
