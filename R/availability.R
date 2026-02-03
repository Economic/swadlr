# Functions for cross-indicator data availability discovery

#' Find available data across all indicators
#'
#' Searches across all indicators to find which data is available matching
#' specified criteria. Useful for answering questions like "Which indicators
#' have state-level data by race?"
#'
#' @param indicator Character vector of indicator IDs to filter to. If `NULL`
#'   (the default), includes all indicators.
#' @param measure Character vector of measure IDs to filter to. If `NULL`
#'   (the default), includes all measures.
#' @param date_interval Character vector of date intervals to filter to.
#'   Valid values are `"year"`, `"quarter"`, and `"month"`. If `NULL`
#'   (the default), includes all date intervals.
#' @param geo_level Character vector of geographic levels to filter to.
#'   Valid values are `"national"`, `"state"`, and `"division"`. If `NULL`
#'   (the default), includes all geographic levels.
#' @param dimensions Character vector of dimension IDs to match. How these
#'   are matched depends on `dimensions_match`. If `NULL` (the default),
#'   no dimension filtering is applied.
#' @param dimensions_match How to match the `dimensions` argument:
#'   \describe{
#'     \item{`"exact"`}{The dimensions column must exactly match the provided
#'       dimensions (order-insensitive). For example, `c("gender", "race")`
#'       matches `"gender × race"` but not `"age_group × gender × race"`.}
#'     \item{`"all"`}{The dimensions column must contain ALL provided dimensions
#'       (may contain more). For example, `c("gender", "race")` matches both
#'       `"gender × race"` and `"age_group × gender × race"`.}
#'     \item{`"any"`}{The dimensions column must contain ANY of the provided
#'       dimensions. For example, `c("gender", "race")` matches `"gender"`,
#'       `"race"`, `"gender × race"`, and `"age_group × gender"`.}
#'   }
#'
#' @return A tibble with columns:
#'   \describe{
#'     \item{indicator_id}{Indicator identifier}
#'     \item{indicator_name}{Human-readable indicator name}
#'     \item{date_interval}{`"year"`, `"quarter"`, or `"month"`}
#'     \item{measure_id}{Measure identifier}
#'     \item{geo_level}{`"national"`, `"state"`, or `"division"`}
#'     \item{dimensions}{Dimension combination (e.g., `"gender × race"`) or
#'       `"overall"` for aggregate data}
#'     \item{date_start}{Start of available date range}
#'     \item{date_end}{End of available date range}
#'   }
#'
#' @seealso [swadl_indicator()] for detailed information about a single
#'   indicator, [swadl_id_names()] to list all indicators.
#'
#' @export
#' @examples
#' \donttest{
#' # Find all indicators with state-level gender data
#' swadl_availability(geo_level = "state", dimensions = "gender",
#'   dimensions_match = "any")
#'
#' # Find indicators with a specific measure
#' swadl_availability(measure = "percent_emp")
#'
#' # Find all availability for a specific indicator
#' swadl_availability(indicator = "hourly_wage_percentiles")
#'
#' # Find indicators with exact "gender × race" combinations at national level
#' swadl_availability(geo_level = "national",
#'   dimensions = c("gender", "race"), dimensions_match = "exact")
#' }
swadl_availability <- function(
  indicator = NULL,
  measure = NULL,

  date_interval = NULL,
  geo_level = NULL,
  dimensions = NULL,
  dimensions_match = c("exact", "all", "any")
) {
  dimensions_match <- match.arg(dimensions_match)

  # Get the cached cross-indicator availability tibble
  result <- fetch_availability_tibble()

  # Apply filters
  if (!is.null(indicator)) {
    result <- result[result$indicator_id %in% indicator, ]
  }

  if (!is.null(measure)) {
    result <- result[result$measure_id %in% measure, ]
  }

  if (!is.null(date_interval)) {
    result <- result[result$date_interval %in% date_interval, ]
  }

  if (!is.null(geo_level)) {
    result <- result[result$geo_level %in% geo_level, ]
  }

  # Apply dimensions filter

  if (!is.null(dimensions)) {
    result <- filter_by_dimensions(result, dimensions, dimensions_match)
  }

  result
}


# Internal helper: filter availability tibble by dimensions
filter_by_dimensions <- function(data, dimensions, match_mode) {
  if (nrow(data) == 0) {
    return(data)
  }

  # Build the expected dimensions string for exact matching (sorted, joined)
  expected_str <- paste(sort(dimensions), collapse = " \u00D7 ")

  matches <- vapply(
    data$dimensions,
    function(dims_str) {
      if (match_mode == "exact") {
        # Exact match: dimensions must exactly equal the expected string
        dims_str == expected_str
      } else if (match_mode == "all") {
        # All match: all provided dimensions must appear in the string
        # Parse the dimensions from the string
        if (dims_str == "overall") {
          return(FALSE)
        }
        parsed_dims <- strsplit(dims_str, " \u00D7 ")[[1]]
        all(dimensions %in% parsed_dims)
      } else {
        # Any match: any provided dimension must appear in the string
        if (dims_str == "overall") {
          return(FALSE)
        }
        parsed_dims <- strsplit(dims_str, " \u00D7 ")[[1]]
        any(dimensions %in% parsed_dims)
      }
    },
    logical(1)
  )

  data[matches, ]
}


# Internal helper: fetch and cache the cross-indicator availability tibble
fetch_availability_tibble <- function() {
  if (cache_has("availability_tibble")) {
    return(cache_get("availability_tibble"))
  }

  indicators_raw <- fetch_indicators()
  n_indicators <- nrow(indicators_raw$indicator)

  rows <- list()
  for (i in seq_len(n_indicators)) {
    ind_id <- indicators_raw$indicator$id[i]
    ind_name <- indicators_raw$indicator$name[i]
    availability <- indicators_raw$availability[[i]]

    avail_tibble <- build_availability_tibble(availability)
    if (nrow(avail_tibble) > 0) {
      avail_tibble$indicator_id <- ind_id
      avail_tibble$indicator_name <- ind_name
      rows[[length(rows) + 1]] <- avail_tibble
    }
  }

  if (length(rows) == 0) {
    result <- tibble::tibble(
      indicator_id = character(0),
      indicator_name = character(0),
      date_interval = character(0),
      measure_id = character(0),
      geo_level = character(0),
      dimensions = character(0),
      date_start = as.Date(character(0)),
      date_end = as.Date(character(0))
    )
  } else {
    result <- do.call(rbind, rows)

    # Reorder columns to put indicator_id and indicator_name first
    result <- result[, c(
      "indicator_id",
      "indicator_name",
      "date_interval",
      "measure_id",
      "geo_level",
      "dimensions",
      "date_start",
      "date_end"
    )]
  }

  cache_set("availability_tibble", result)
  result
}
