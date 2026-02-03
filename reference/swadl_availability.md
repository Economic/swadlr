# Find available data across all indicators

Searches across all indicators to find which data is available matching
specified criteria. Useful for answering questions like "Which
indicators have state-level data by race?"

## Usage

``` r
swadl_availability(
  indicator = NULL,
  measure = NULL,
  date_interval = NULL,
  geo_level = NULL,
  dimensions = NULL,
  dimensions_match = c("exact", "all", "any")
)
```

## Arguments

- indicator:

  Character vector of indicator IDs to filter to. If `NULL` (the
  default), includes all indicators.

- measure:

  Character vector of measure IDs to filter to. If `NULL` (the default),
  includes all measures.

- date_interval:

  Character vector of date intervals to filter to. Valid values are
  `"year"`, `"quarter"`, and `"month"`. If `NULL` (the default),
  includes all date intervals.

- geo_level:

  Character vector of geographic levels to filter to. Valid values are
  `"national"`, `"state"`, and `"division"`. If `NULL` (the default),
  includes all geographic levels.

- dimensions:

  Character vector of dimension IDs to match. How these are matched
  depends on `dimensions_match`. If `NULL` (the default), no dimension
  filtering is applied.

- dimensions_match:

  How to match the `dimensions` argument:

  `"exact"`

  :   The dimensions column must exactly match the provided dimensions
      (order-insensitive). For example, `c("gender", "race")` matches
      `"gender × race"` but not `"age_group × gender × race"`.

  `"all"`

  :   The dimensions column must contain ALL provided dimensions (may
      contain more). For example, `c("gender", "race")` matches both
      `"gender × race"` and `"age_group × gender × race"`.

  `"any"`

  :   The dimensions column must contain ANY of the provided dimensions.
      For example, `c("gender", "race")` matches `"gender"`, `"race"`,
      `"gender × race"`, and `"age_group × gender"`.

## Value

A tibble with columns:

- indicator_id:

  Indicator identifier

- indicator_name:

  Human-readable indicator name

- date_interval:

  `"year"`, `"quarter"`, or `"month"`

- measure_id:

  Measure identifier

- geo_level:

  `"national"`, `"state"`, or `"division"`

- dimensions:

  Dimension combination (e.g., `"gender × race"`) or `"overall"` for
  aggregate data

- date_start:

  Start of available date range

- date_end:

  End of available date range

## See also

[`swadl_indicator()`](https://economic.github.io/swadlr/reference/swadl_indicator.md)
for detailed information about a single indicator,
[`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
to list all indicators.

## Examples

``` r
# \donttest{
# Find all indicators with state-level gender data
swadl_availability(geo_level = "state", dimensions = "gender",
  dimensions_match = "any")
#> # A tibble: 87 × 8
#>    indicator_id     indicator_name date_interval measure_id geo_level dimensions
#>    <chr>            <chr>          <chr>         <chr>      <chr>     <chr>     
#>  1 hourly_wage_mean Hourly wage, … year          nominal_w… state     gender    
#>  2 hourly_wage_mean Hourly wage, … year          real_wage… state     gender    
#>  3 hourly_wage_med… Hourly wage, … year          nominal_w… state     gender    
#>  4 hourly_wage_med… Hourly wage, … year          real_wage… state     gender    
#>  5 hourly_wage_per… Hourly wage p… year          wage_ratio state     gender × …
#>  6 hourly_wage_per… Hourly wage p… year          nominal_w… state     gender × …
#>  7 hourly_wage_per… Hourly wage p… year          real_wage… state     gender × …
#>  8 labor_force_emp  Employment by… month         count_emp… state     gender    
#>  9 labor_force_emp  Employment by… month         dist_shar… state     gender    
#> 10 labor_force_emp  Employment by… month         percent_e… state     gender    
#> # ℹ 77 more rows
#> # ℹ 2 more variables: date_start <date>, date_end <date>

# Find indicators with a specific measure
swadl_availability(measure = "percent_emp")
#> # A tibble: 33 × 8
#>    indicator_id    indicator_name  date_interval measure_id geo_level dimensions
#>    <chr>           <chr>           <chr>         <chr>      <chr>     <chr>     
#>  1 labor_force_emp Employment by … year          percent_e… division  age_group 
#>  2 labor_force_emp Employment by … year          percent_e… division  education 
#>  3 labor_force_emp Employment by … year          percent_e… division  fpl200    
#>  4 labor_force_emp Employment by … year          percent_e… division  gender    
#>  5 labor_force_emp Employment by … year          percent_e… division  race      
#>  6 labor_force_emp Employment by … year          percent_e… division  overall   
#>  7 labor_force_emp Employment by … year          percent_e… national  age_group…
#>  8 labor_force_emp Employment by … year          percent_e… national  age_group…
#>  9 labor_force_emp Employment by … year          percent_e… national  age_group…
#> 10 labor_force_emp Employment by … year          percent_e… national  age_group…
#> # ℹ 23 more rows
#> # ℹ 2 more variables: date_start <date>, date_end <date>

# Find all availability for a specific indicator
swadl_availability(indicator = "hourly_wage_percentiles")
#> # A tibble: 48 × 8
#>    indicator_id     indicator_name date_interval measure_id geo_level dimensions
#>    <chr>            <chr>          <chr>         <chr>      <chr>     <chr>     
#>  1 hourly_wage_per… Hourly wage p… year          nominal_w… division  education…
#>  2 hourly_wage_per… Hourly wage p… year          nominal_w… division  gender × …
#>  3 hourly_wage_per… Hourly wage p… year          nominal_w… division  race × wa…
#>  4 hourly_wage_per… Hourly wage p… year          nominal_w… division  wage_perc…
#>  5 hourly_wage_per… Hourly wage p… year          nominal_w… national  age_group…
#>  6 hourly_wage_per… Hourly wage p… year          nominal_w… national  age_group…
#>  7 hourly_wage_per… Hourly wage p… year          nominal_w… national  age_group…
#>  8 hourly_wage_per… Hourly wage p… year          nominal_w… national  education…
#>  9 hourly_wage_per… Hourly wage p… year          nominal_w… national  education…
#> 10 hourly_wage_per… Hourly wage p… year          nominal_w… national  gender × …
#> # ℹ 38 more rows
#> # ℹ 2 more variables: date_start <date>, date_end <date>

# Find indicators with exact "gender × race" combinations at national level
swadl_availability(geo_level = "national",
  dimensions = c("gender", "race"), dimensions_match = "exact")
#> # A tibble: 59 × 8
#>    indicator_id     indicator_name date_interval measure_id geo_level dimensions
#>    <chr>            <chr>          <chr>         <chr>      <chr>     <chr>     
#>  1 hourly_wage_mean Hourly wage, … year          nominal_w… national  gender × …
#>  2 hourly_wage_mean Hourly wage, … year          real_wage… national  gender × …
#>  3 hourly_wage_med… Hourly wage, … year          nominal_w… national  gender × …
#>  4 hourly_wage_med… Hourly wage, … year          real_wage… national  gender × …
#>  5 labor_force_ann… Time at work   year          hours_wor… national  gender × …
#>  6 labor_force_ann… Time at work   year          hours_wor… national  gender × …
#>  7 labor_force_ann… Time at work   year          weeks_wor… national  gender × …
#>  8 labor_force_emp  Employment by… month         count_emp… national  gender × …
#>  9 labor_force_emp  Employment by… month         percent_e… national  gender × …
#> 10 labor_force_emp  Employment by… year          count_emp  national  gender × …
#> # ℹ 49 more rows
#> # ℹ 2 more variables: date_start <date>, date_end <date>
# }
```
