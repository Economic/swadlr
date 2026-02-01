# List available indicators

Returns a data frame of available indicators in the SWADL API.
Indicators are specific data series that can be retrieved with
[`get_swadl_series()`](https://economic.github.com/swadlr/reference/get_swadl_series.md).

## Usage

``` r
swadlr_indicators(topic = NULL)
```

## Arguments

- topic:

  Optional topic ID to filter indicators. Use
  [`swadlr_topics()`](https://economic.github.com/swadlr/reference/swadlr_topics.md)
  to see available topics.

## Value

A data frame with columns:

- id:

  Indicator identifier (used in
  [`get_swadl_series()`](https://economic.github.com/swadlr/reference/get_swadl_series.md))

- name:

  Human-readable indicator name

- topic_id:

  ID of the topic this indicator belongs to

- updated_date:

  Date the indicator was last updated

## Examples

``` r
if (FALSE) { # \dontrun{
# List all indicators
swadlr_indicators()

# List indicators for a specific topic
swadlr_indicators(topic = "wages")
} # }
```
