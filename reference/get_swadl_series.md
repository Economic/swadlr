# Get time series data from SWADL

Retrieves time series data from the EPI State of Working America Data
Library API.

## Usage

``` r
get_swadl_series(
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
  [`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md)
  to see available indicators.

- measure:

  Measure ID (e.g., `"real_wage_2024"`). Use
  [`swadlr_measures()`](https://economic.github.com/swadlr/reference/swadlr_measures.md)
  or
  [`get_swadl_info()`](https://economic.github.com/swadlr/reference/get_swadl_info.md)
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

    - Multiple dimensions are cross-tabulated:
      `list("gender" = "gender_male", "age_group")`

- date:

  Optional date filter. Can be:

  - `NULL` (default): All available dates

  - A single date (character or Date): Returns only that date

  - A vector of two dates: Returns dates in that range (inclusive)

## Value

A data frame with columns:

- `date`: Observation date

- `value`: The observed value

- `geography`: Geography ID

- One column per dimension in the request, containing dimension value
  IDs

## See also

[`get_swadl_info()`](https://economic.github.com/swadlr/reference/get_swadl_info.md)
for indicator details,
[`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md)
to list indicators,
[`swadlr_measures()`](https://economic.github.com/swadlr/reference/swadlr_measures.md)
to list measures,
[`swadlr_dimensions()`](https://economic.github.com/swadlr/reference/swadlr_dimensions.md)
to list dimensions.

## Examples

``` r
if (FALSE) { # \dontrun{
# Median hourly wage over time
get_swadl_series(
  "hourly_wage_percentiles",
  "real_wage_2024",
  dimension = list("wage_percentile" = "wage_p50")
)

# All wage percentiles
get_swadl_series(
  "hourly_wage_percentiles",
  "real_wage_2024",
  dimension = "wage_percentile"
)

# Employment rate for males by age group
get_swadl_series(
  "labor_force_emp",
  "percent_emp",
  date_interval = "month",
  dimension = list("gender" = "gender_male", "age_group")
)

# Filter to specific date range
get_swadl_series(
  "hourly_wage_percentiles",
  "real_wage_2024",
  dimension = "wage_percentile",
  date = c("2000-01-01", "2024-01-01")
)
} # }
```
