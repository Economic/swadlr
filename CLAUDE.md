# CLAUDE.md

Guidance for agents.

## Important!

Always keep this file up to date.

## Project description

This project will be an R package called `swadlr` that retrieves data
from the undocumented EPI State of Working America Data Library:
<https://data.epi.org>

The main users of this package want to grab a time series or value from
EPI SWADL, either to use directly or as a benchmark for another
calculation.

## Main functions

### get_swadl

Returns a tibble (data frame in long format).

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

### swadl_indicator

Return structured summary for an indicator.

``` r
swadl_indicator(indicator)
```

Returns an S3 object of class `swadl_indicator_info` with a nice print
method.

### swadl_id_names

List ID-name mappings for topics, indicators, measures, dimensions, or
geographies.

``` r
swadl_id_names(what = c("topics", "indicators", "measures", "dimensions", "geographies"))
```

### swadl_availability

Search for data availability across all indicators.

``` r
swadl_availability(indicator, measure, date_interval, geo_level, dimensions, dimensions_match)
```

### clear_swadlr_cache

Clear the cached metadata.

``` r
clear_swadlr_cache()
```

## Testing

Tests use httptest2 to mock API responses with fixtures in
`tests/testthat/fixtures/`. This avoids hitting the live API during
tests.

Key points: - httptest2 intercepts httr2 requests at `req_perform()` and
returns fixture data - The throttle (`throttle_if_needed()`) runs before
the request, so it would still delay even with mocked responses -
`tests/testthat/setup.R` sets `options(swadlr.throttle_interval = 0)` to
disable throttling during tests - Use `testthat::test_path("fixtures")`
in `with_mock_dir()` calls to ensure correct path resolution with
`devtools::test()`

To update fixtures when the live API changes:

``` r
httptest2::start_capturing("tests/testthat/fixtures")
devtools::test()
httptest2::stop_capturing()
```

## Implementation

See
[plans/2026-01-24-implementation-plan.md](https://economic.github.io/swadlr/plans/2026-01-24-implementation-plan.md)
for the full implementation plan.
