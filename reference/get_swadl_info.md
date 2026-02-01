# Get detailed information about an indicator

Returns detailed information about a specific indicator including
available measures, dimensions, date ranges, geographic availability,
and sources.

## Usage

``` r
get_swadl_info(indicator)
```

## Arguments

- indicator:

  The indicator ID (e.g., `"hourly_wage_percentiles"`). Use
  [`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md)
  to see available indicators.

## Value

An S3 object of class `swadlr_indicator_info` with the following
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

  Data frame of available measures with columns: `id`, `name`, `format`

- dimensions:

  Data frame of available dimensions with columns: `dimension_id`,
  `dimension_name`, `value_id`, `value_name`

- availability:

  List with date ranges and geographic availability

- sources:

  Data frame of sources with columns: `measure_id`, `source`, `url`

## See also

[`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md)
to list available indicators,
[`swadlr_measures()`](https://economic.github.com/swadlr/reference/swadlr_measures.md)
to list measures,
[`swadlr_dimensions()`](https://economic.github.com/swadlr/reference/swadlr_dimensions.md)
to list dimensions.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get information about hourly wage percentiles
info <- get_swadl_info("hourly_wage_percentiles")
print(info)

# Access specific components
info$measures
info$availability$date_range
} # }
```
