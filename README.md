# swadlr

<!-- badges: start -->
<!-- badges: end -->

swadlr provides access to the [EPI State of Working America Data
Library](https://data.epi.org) (SWADL) API. It enables users to explore
available indicators, measures, and dimensions, and to fetch time series data
at national, regional, and state levels.

## Installation

You can install the development version of swadlr from GitHub:

``` r
# install.packages("pak")
pak::pak("benzipperer/swadlr")
```

## Example

Fetch median hourly wages over time:

``` r
library(swadlr)

# Explore what's available
swadlr_topics()
swadlr_indicators(topic = "wages")

# Get detailed information about an indicator
get_swadl_info("hourly_wage_percentiles")

# Fetch the median hourly wage
get_swadl_series(
  indicator = "hourly_wage_percentiles",
  measure = "real_wage_2024",
  dimension = list("wage_percentile" = "wage_p50")
)
```

Fetch all wage percentiles:

``` r
get_swadl_series(
  indicator = "hourly_wage_percentiles",
  measure = "real_wage_2024",
  dimension = "wage_percentile"
)
```

Fetch state-level data:

``` r
get_swadl_series(
  indicator = "hourly_wage_percentiles",
  measure = "real_wage_2024",
  geography = "California",
  dimension = list("wage_percentile" = "wage_p50")
)
```

## Documentation

See the [package website](https://benzipperer.github.io/swadlr/) for full
documentation and the [Getting started
vignette](https://benzipperer.github.io/swadlr/articles/swadlr.html) for more
examples.
