# swadlr: Access the EPI State of Working America Data Library API

The swadlr package provides access to the Economic Policy Institute's
[State of Working America Data Library](https://data.epi.org) (SWADL)
API. It enables users to explore available indicators, measures, and
dimensions, and to fetch time series data at national, regional, and
state levels.

## Data retrieval

The main function for fetching data is
[`get_swadl_series()`](https://economic.github.com/swadlr/reference/get_swadl_series.md),
which returns time series data for a specified indicator, measure,
geography, and dimension combination.

## Indicator information

Use
[`get_swadl_info()`](https://economic.github.com/swadlr/reference/get_swadl_info.md)
to get detailed information about an indicator, including available
measures, dimensions, date ranges, and geographic availability.

## Exploring available data

Several functions help you explore what data is available:

- [`swadlr_topics()`](https://economic.github.com/swadlr/reference/swadlr_topics.md):
  List available topics

- [`swadlr_indicators()`](https://economic.github.com/swadlr/reference/swadlr_indicators.md):
  List available indicators

- [`swadlr_measures()`](https://economic.github.com/swadlr/reference/swadlr_measures.md):
  List available measures

- [`swadlr_dimensions()`](https://economic.github.com/swadlr/reference/swadlr_dimensions.md):
  List available dimensions

- [`swadlr_geographies()`](https://economic.github.com/swadlr/reference/swadlr_geographies.md):
  List available geographies

## Cache management

Metadata is cached within your R session. Use
[`swadlr_clear_cache()`](https://economic.github.com/swadlr/reference/swadlr_clear_cache.md)
to refresh the cache if needed.

## See also

Useful links:

- <https://economic.github.com/swadlr/>

- <https://github.com/benzipperer/swadlr>

- Report bugs at <https://github.com/benzipperer/swadlr/issues>

## Author

**Maintainer**: Ben Zipperer <benzipperer@gmail.com>
