# CLAUDE.md

Guidance for agents.

## Important!
Always keep this file up to date.

## Project description
This project will be an R package called `swadlr` that retrieves data from the undocumented EPI State of Working America Data Library: https://data.epi.org

The main users of this package want to grab a time series or value from EPI SWADL, either to use directly or as a benchmark for another calculation.

## Possible functions

### get_swadl_series

Returns a tibble (data frame in long format).

```r
get_swadl_series(
    indicator,
    measure,
    date_interval = c("year", "month"),
    geography = "national",
    dimension = "overall",
    date = NULL
)
```

### get_swadl_info

Return structured summary for an indicator.

```r
get_swadl_info(indicator)
```

Returns an S3 object of class `swadlr_indicator_info` with a nice print method.

## Implementation

See [plans/2026-01-24-implementation-plan.md](plans/2026-01-24-implementation-plan.md) for the full implementation plan.
