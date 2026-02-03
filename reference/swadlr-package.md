# swadlr: Access the EPI State of Working America Data Library API

The swadlr package provides access to the Economic Policy Institute's
[State of Working America Data Library](https://data.epi.org) (SWADL)
API. It enables users to explore available indicators, measures, and
dimensions, and to fetch time series data at national, regional, and
state levels.

## Data retrieval

The main function for fetching data is
[`get_swadl()`](https://economic.github.io/swadlr/reference/get_swadl.md),
which returns time series data for a specified indicator, measure,
geography, and dimension combination.

## Indicator information

Use
[`swadl_indicator()`](https://economic.github.io/swadlr/reference/swadl_indicator.md)
to get detailed information about an indicator, including available
measures, dimensions, date ranges, and geographic availability.

## Exploring available data

Use
[`swadl_id_names()`](https://economic.github.io/swadlr/reference/swadl_id_names.md)
to list available topics, indicators, measures, dimensions, and
geographies. Use
[`swadl_availability()`](https://economic.github.io/swadlr/reference/swadl_availability.md)
to search for data matching specific criteria.

## Cache management

Metadata is cached within your R session. Use
[`clear_swadlr_cache()`](https://economic.github.io/swadlr/reference/clear_swadlr_cache.md)
to refresh the cache if needed.

## See also

Useful links:

- <https://economic.github.io/swadlr/>

- <https://github.com/Economic/swadlr>

- Report bugs at <https://github.com/economic/swadlr/issues>

## Author

**Maintainer**: Ben Zipperer <benzipperer@gmail.com>

Other contributors:

- Economic Policy Institute \[copyright holder, funder\]
