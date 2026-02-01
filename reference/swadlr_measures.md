# List available measures

Returns a data frame of available measures in the SWADL API. Measures
are specific ways of presenting indicator data (e.g., nominal vs real
wages, counts vs rates).

## Usage

``` r
swadlr_measures(indicator = NULL)
```

## Arguments

- indicator:

  Optional indicator ID to filter measures to only those available for a
  specific indicator. Use
  [`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md)
  to see available indicators.

## Value

A data frame with columns:

- id:

  Measure identifier (used in
  [`get_swadl_series()`](https://economic.github.com/swadlr/reference/get_swadl_series.md))

- name:

  Human-readable measure name

- format:

  Display format (e.g., "dollar", "rate", "count")

## Examples

``` r
if (FALSE) { # \dontrun{
# List all measures
swadlr_measures()

# List measures for a specific indicator
swadlr_measures(indicator = "hourly_wage_percentiles")
} # }
```
