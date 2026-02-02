# Public functions for exploring available SWADL data

#' List ID-name mappings for SWADL metadata
#'
#' Returns a tibble of ID-name mappings for SWADL metadata. Use this to
#' understand what each ID represents.
#'
#' @param what The type of metadata to list. One of:
#'   \describe{
#'     \item{`"topics"`}{Broad categories that group related indicators}
#'     \item{`"indicators"`}{Specific data series that can be retrieved with
#'       [get_swadl()]}
#'     \item{`"measures"`}{Ways of presenting indicator data (e.g., nominal vs
#'       real wages)}
#'     \item{`"dimensions"`}{Demographic categories for subsetting data (e.g.,
#'       gender, race)}
#'     \item{`"geographies"`}{Geographic units (national, regions, divisions,
#'       states)}
#'   }
#' @param topic For `what = "indicators"`, optionally filter to a specific
#'   topic ID.
#' @param indicator For `what = "measures"` or `what = "dimensions"`, optionally
#'   filter to those available for a specific indicator ID.
#'
#' @return A tibble. The columns depend on `what`:
#'   \describe{
#'     \item{topics}{`id`, `name`}
#'     \item{indicators}{`id`, `name`, `topic_id`, `updated_date`}
#'     \item{measures}{`id`, `name`, `format`}
#'     \item{dimensions}{`dimension_id`, `dimension_name`, `value_id`,
#'       `value_name`}
#'     \item{geographies}{`id`, `level`, `name`, `abbr`}
#'   }
#'
#' @seealso [swadl_indicator()] for detailed information about a single
#'   indicator, [get_swadl()] for fetching time series data.
#'
#' @export
#' @examples
#' \donttest{
#' # List all topics
#' swadl_id_names("topics")
#'
#' # List all indicators
#' swadl_id_names("indicators")
#'
#' # List indicators for a specific topic
#' swadl_id_names("indicators", topic = "wages")
#'
#' # List measures for a specific indicator
#' swadl_id_names("measures", indicator = "hourly_wage_percentiles")
#'
#' # List dimensions
#' swadl_id_names("dimensions")
#'
#' # List geographies
#' swadl_id_names("geographies")
#' }
swadl_id_names <- function(
  what = c("topics", "indicators", "measures", "dimensions", "geographies"),
  topic = NULL,
  indicator = NULL
) {
  what <- match.arg(what)

  switch(
    what,
    topics = list_topics(),
    indicators = list_indicators(topic),
    measures = list_measures(indicator),
    dimensions = list_dimensions(indicator),
    geographies = list_geographies()
  )
}


# Internal: list topics
list_topics <- function() {
  raw <- fetch_topics()

  tibble::tibble(
    id = raw$topic$id,
    name = raw$topic$name
  )
}


# Internal: list indicators
list_indicators <- function(topic = NULL) {
  raw <- fetch_indicators()

  result <- tibble::tibble(
    id = raw$indicator$id,
    name = raw$indicator$name,
    topic_id = raw$indicator$fkTopicId,
    updated_date = as.character(as.Date(raw$indicator$updatedDate))
  )

  if (!is.null(topic)) {
    if (!is.character(topic) || length(topic) != 1) {
      stop("`topic` must be a single character string.", call. = FALSE)
    }
    result <- result[result$topic_id == topic, ]
    if (nrow(result) == 0) {
      available <- paste(unique(list_topics()$id), collapse = ", ")
      stop(
        "Unknown topic: \"",
        topic,
        "\"\n",
        "Available topics: ",
        available,
        call. = FALSE
      )
    }
  }

  result
}


# Internal: list measures
list_measures <- function(indicator = NULL) {
  raw <- fetch_measures()

  result <- tibble::tibble(
    id = raw$measure$id,
    name = raw$measure$name,
    format = raw$measure$format
  )

  if (!is.null(indicator)) {
    if (!is.character(indicator) || length(indicator) != 1) {
      stop("`indicator` must be a single character string.", call. = FALSE)
    }

    # Get availability from the indicator to filter measures
    indicators_raw <- fetch_indicators()
    indicator_idx <- which(indicators_raw$indicator$id == indicator)

    if (length(indicator_idx) == 0) {
      stop("Unknown indicator: \"", indicator, "\"", call. = FALSE)
    }

    # Extract available measure IDs from the availability data
    availability <- indicators_raw$availability[[indicator_idx]]
    available_measures <- unique(availability$measure_id)

    result <- result[result$id %in% available_measures, ]
  }

  result
}


# Internal: list dimensions
list_dimensions <- function(indicator = NULL) {
  raw <- fetch_dimensions()

  # Build a tibble with all dimension values
  rows <- list()
  n_dims <- length(raw$dimension$id)

  for (i in seq_len(n_dims)) {
    dim_id <- raw$dimension$id[i]
    dim_name <- raw$dimension$name[i]
    dim_values <- raw$dimension_values[[i]]

    n_vals <- length(dim_values$dimension_value$id)
    for (j in seq_len(n_vals)) {
      rows[[length(rows) + 1]] <- tibble::tibble(
        dimension_id = dim_id,
        dimension_name = dim_name,
        value_id = dim_values$dimension_value$id[j],
        value_name = dim_values$dimension_value$name[j]
      )
    }
  }

  result <- do.call(rbind, rows)

  if (!is.null(indicator)) {
    if (!is.character(indicator) || length(indicator) != 1) {
      stop("`indicator` must be a single character string.", call. = FALSE)
    }

    # Get availability from the indicator to filter dimensions
    indicators_raw <- fetch_indicators()
    indicator_idx <- which(indicators_raw$indicator$id == indicator)

    if (length(indicator_idx) == 0) {
      stop("Unknown indicator: \"", indicator, "\"", call. = FALSE)
    }

    # Extract available dimension value IDs from the availability data
    availability <- indicators_raw$availability[[indicator_idx]]
    available_values <- unique(unlist(availability$dimension_values))

    result <- result[result$value_id %in% available_values, ]
  }

  result
}


# Internal: list geographies
list_geographies <- function() {
  swadlr_geography_lookup
}
