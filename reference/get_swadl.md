# Get time series data from SWADL

Retrieves time series data from the EPI State of Working America Data
Library API.

## Usage

``` r
get_swadl(
  indicator,
  measure,
  date_interval = c("year", "month"),
  geography = "national",
  dimension = "overall",
  date = NULL
)
```

## Arguments

- indicator:

  Indicator ID (e.g., `"hourly_wage_percentiles"`). Use
  [`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
  to see available indicators.

- measure:

  Measure ID (e.g., `"nominal_wage"`). Use
  [`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
  or
  [`swadl_indicator()`](https://economic.github.io/swadlr/reference/swadl_indicator.md)
  to see available measures.

- date_interval:

  Either `"year"` or `"month"`. Defaults to `"year"`.

- geography:

  A geography specification. Accepts state names (e.g., `"California"`),
  abbreviations (e.g., `"CA"`), region names (e.g., `"Midwest"`),
  division names (e.g., `"Pacific"`), or API IDs (e.g., `"state06"`).
  Defaults to `"national"`.

- dimension:

  Dimension specification. Can be:

  - `"overall"`: Returns aggregate data without demographic breakdown

  - A dimension ID (e.g., `"wage_percentile"`): Returns all values for
    that dimension

  - A list with named and/or unnamed elements:

    - Named elements filter to specific values:
      `list("wage_percentile" = "wage_p50")`

    - Unnamed elements return all values: `list("wage_percentile")`

    - Multiple dimensions can be cross-tabulated, but only one dimension
      can return all values; the others must specify values:
      `list("gender" = "gender_male", "age_group")`

- date:

  Optional date filter. Can be:

  - `NULL` (default): All available dates

  - A single date (character or Date): Returns only that date

  - A vector of two dates: Returns dates in that range (inclusive)

## Value

A tibble with columns:

- `date`: Observation date

- `value`: The observed value

- `geography`: Geography ID

- One column per dimension in the request, containing dimension value
  IDs

## See also

[`swadl_indicator()`](https://economic.github.io/swadlr/reference/swadl_indicator.md)
for indicator details,
[`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
to list indicators, measures, and dimensions.

## Examples

``` r
# \donttest{
# Median hourly wage over time
get_swadl(
  "hourly_wage_percentiles",
  "nominal_wage",
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

# All wage percentiles
get_swadl(
  "hourly_wage_percentiles",
  "nominal_wage",
  dimension = "wage_percentile"
)
#> # A tibble: 477 × 4
#>    date       value geography wage_percentile
#>    <date>     <dbl> <chr>     <chr>          
#>  1 1973-01-01  1.72 national  wage_p10       
#>  2 1973-01-01  6.51 national  wage_p90       
#>  3 1973-01-01  5.17 national  wage_p80       
#>  4 1973-01-01  4.48 national  wage_p70       
#>  5 1973-01-01  3.87 national  wage_p60       
#>  6 1973-01-01  3.35 national  wage_p50       
#>  7 1973-01-01  2.91 national  wage_p40       
#>  8 1973-01-01  2.47 national  wage_p30       
#>  9 1973-01-01  2.06 national  wage_p20       
#> 10 1974-01-01  1.95 national  wage_p10       
#> # ℹ 467 more rows

# Employment rate for males by age group
get_swadl(
  "labor_force_emp",
  "percent_emp",
  dimension = list("gender" = "gender_male", "age_group")
)
#> # A tibble: 150 × 5
#>    date       value geography gender      age_group  
#>    <date>     <dbl> <chr>     <chr>       <chr>      
#>  1 1976-01-01 0.624 national  gender_male age_16_24  
#>  2 1976-01-01 0.460 national  gender_male age_55_plus
#>  3 1976-01-01 0.895 national  gender_male age_25_54  
#>  4 1977-01-01 0.644 national  gender_male age_16_24  
#>  5 1977-01-01 0.457 national  gender_male age_55_plus
#>  6 1977-01-01 0.902 national  gender_male age_25_54  
#>  7 1978-01-01 0.460 national  gender_male age_55_plus
#>  8 1978-01-01 0.911 national  gender_male age_25_54  
#>  9 1978-01-01 0.663 national  gender_male age_16_24  
#> 10 1979-01-01 0.456 national  gender_male age_55_plus
#> # ℹ 140 more rows

# Filter to specific date range
get_swadl(
  "hourly_wage_percentiles",
  "nominal_wage",
  dimension = "wage_percentile",
  date = c("2000-01-01", "2024-01-01")
)
#> # A tibble: 225 × 4
#>    date       value geography wage_percentile
#>    <date>     <dbl> <chr>     <chr>          
#>  1 2000-01-01  6.14 national  wage_p10       
#>  2 2000-01-01 27.0  national  wage_p90       
#>  3 2000-01-01 20.6  national  wage_p80       
#>  4 2000-01-01 16.9  national  wage_p70       
#>  5 2000-01-01 14.2  national  wage_p60       
#>  6 2000-01-01 12.0  national  wage_p50       
#>  7 2000-01-01 10.2  national  wage_p40       
#>  8 2000-01-01  8.85 national  wage_p30       
#>  9 2000-01-01  7.46 national  wage_p20       
#> 10 2001-01-01  6.49 national  wage_p10       
#> # ℹ 215 more rows
# }
```
