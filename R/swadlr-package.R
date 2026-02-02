#' swadlr: Access the EPI State of Working America Data Library API
#'
#' The swadlr package provides access to the Economic Policy Institute's
#' [State of Working America Data Library](https://data.epi.org) (SWADL) API.
#' It enables users to explore available indicators, measures, and dimensions,
#' and to fetch time series data at national, regional, and state levels.
#'
#' @section Data retrieval:
#' The main function for fetching data is [get_swadl()], which returns
#' time series data for a specified indicator, measure, geography, and
#' dimension combination.
#'
#' @section Indicator information:
#' Use [swadl_indicator()] to get detailed information about an indicator,
#' including available measures, dimensions, date ranges, and geographic
#' availability.
#'
#' @section Exploring available data:
#' Use [swadl_id_names()] to list available topics, indicators, measures,
#' dimensions, and geographies. Use [swadl_availability()] to search for data
#' matching specific criteria.
#'
#' @section Cache management:
#' Metadata is cached within your R session. Use [clear_swadlr_cache()] to
#' refresh the cache if needed.
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom tibble tibble as_tibble
## usethis namespace: end
NULL
