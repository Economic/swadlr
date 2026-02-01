# List available dimensions

Returns a data frame of available dimensions and their values in the
SWADL API. Dimensions allow subsetting data by demographic or other
categories (e.g., gender, race, education).

## Usage

``` r
swadlr_dimensions(indicator = NULL)
```

## Arguments

- indicator:

  Optional indicator ID to filter dimensions to only those available for
  a specific indicator. Use
  [`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md)
  to see available indicators.

## Value

A data frame with columns:

- dimension_id:

  Dimension identifier

- dimension_name:

  Human-readable dimension name

- value_id:

  Dimension value identifier (used in
  [`get_swadl_series()`](https://economic.github.com/swadlr/reference/get_swadl_series.md)
  with the `dimension` argument)

- value_name:

  Human-readable dimension value name

## Examples

``` r
if (FALSE) { # \dontrun{
# List all dimensions
swadlr_dimensions()

# List dimensions for a specific indicator
swadlr_dimensions(indicator = "hourly_wage_percentiles")
} # }
```
