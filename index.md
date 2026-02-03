# swadlr

swadlr provides access to the [EPI State of Working America Data
Library](https://data.epi.org) (SWADL) API. It enables users to explore
available indicators, measures, and dimensions, and to fetch time series
data at national, regional, and state levels.

## Installation

You can install swadlr from r-universe:

``` r
install.packages("swadlr", repos = c("https://economic.r-universe.dev", "https://cloud.r-project.org"))
```

## Example

Fetch median hourly wages over time:

``` r
library(swadlr)

# Explore what's available
swadl_id_names("topics")
swadl_id_names("indicators", topic = "wages")

# Get detailed information about an indicator
swadl_indicator("hourly_wage_percentiles")

# Fetch the median hourly wage
get_swadl(
  indicator = "hourly_wage_percentiles",
  measure = "nominal_wage",
  dimension = list("wage_percentile" = "wage_p50")
)
```

Fetch all wage percentiles:

``` r
get_swadl(
  indicator = "hourly_wage_percentiles",
  measure = "nominal_wage",
  dimension = "wage_percentile"
)
```

Fetch state-level data:

``` r
get_swadl(
  indicator = "hourly_wage_percentiles",
  measure = "nominal_wage",
  geography = "California",
  dimension = list("wage_percentile" = "wage_p50")
)
```

## Documentation

See the [package website](https://economic.github.io/swadlr/) for full
documentation and the [Getting started
vignette](https://economic.github.io/swadlr/articles/swadlr.html) for
more examples.
