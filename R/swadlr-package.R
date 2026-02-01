#' swadlr: Access the EPI State of Working America Data Library API
#'
#' The swadlr package provides access to the Economic Policy Institute's
#' [State of Working America Data Library](https://data.epi.org) (SWADL) API.
#' It enables users to explore available indicators, measures, and dimensions,
#' and to fetch time series data at national, regional, and state levels.
#'
#' @section Data retrieval:
#' The main function for fetching data is [get_swadl_series()], which returns
#' time series data for a specified indicator, measure, geography, and
#' dimension combination.
#'
#' @section Indicator information:
#' Use [get_swadl_info()] to get detailed information about an indicator,
#' including available measures, dimensions, date ranges, and geographic
#' availability.
#'
#' @section Exploring available data:
#' Several functions help you explore what data is available:
#' - [swadlr_topics()]: List available topics
#' - [swadlr_indicators()]: List available indicators
#' - [swadlr_measures()]: List available measures
#' - [swadlr_dimensions()]: List available dimensions
#' - [swadlr_geographies()]: List available geographies
#'
#' @section Cache management:
#' Metadata is cached within your R session. Use [swadlr_clear_cache()] to
#' refresh the cache if needed.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
