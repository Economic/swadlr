# Public functions for exploring available SWADL data

#' List available topics
#'
#' Returns a data frame of available topics in the SWADL API. Topics are broad
#' categories that group related indicators.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{id}{Topic identifier (used for filtering indicators)}
#'     \item{name}{Human-readable topic name}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' swadlr_topics()
#' }
swadlr_topics <- function() {
  raw <- fetch_topics()

  data.frame(
    id = raw$topic$id,
    name = raw$topic$name,
    stringsAsFactors = FALSE
  )
}

#' List available indicators
#'
#' Returns a data frame of available indicators in the SWADL API. Indicators
#' are specific data series that can be retrieved with `get_swadl_series()`.
#'
#' @param topic Optional topic ID to filter indicators. Use [swadlr_topics()]
#'   to see available topics.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{id}{Indicator identifier (used in `get_swadl_series()`)}
#'     \item{name}{Human-readable indicator name}
#'     \item{topic_id}{ID of the topic this indicator belongs to}
#'     \item{updated_date}{Date the indicator was last updated}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' # List all indicators
#' swadlr_indicators()
#'
#' # List indicators for a specific topic
#' swadlr_indicators(topic = "wages")
#' }
swadlr_indicators <- function(topic = NULL) {
  raw <- fetch_indicators()

  result <- data.frame(
    id = raw$indicator$id,
    name = raw$indicator$name,
    topic_id = raw$indicator$fkTopicId,
    updated_date = as.character(as.Date(raw$indicator$updatedDate)),
    stringsAsFactors = FALSE
  )

  if (!is.null(topic)) {
    if (!is.character(topic) || length(topic) != 1) {
      stop("`topic` must be a single character string.", call. = FALSE)
    }
    result <- result[result$topic_id == topic, ]
    if (nrow(result) == 0) {
      available <- paste(unique(swadlr_topics()$id), collapse = ", ")
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

#' List available measures
#'
#' Returns a data frame of available measures in the SWADL API. Measures are
#' specific ways of presenting indicator data (e.g., nominal vs real wages,
#' counts vs rates).
#'
#' @param indicator Optional indicator ID to filter measures to only those
#'   available for a specific indicator. Use [swadlr_indicators()] to see
#'   available indicators.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{id}{Measure identifier (used in `get_swadl_series()`)}
#'     \item{name}{Human-readable measure name}
#'     \item{format}{Display format (e.g., "dollar", "rate", "count")}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' # List all measures
#' swadlr_measures()
#'
#' # List measures for a specific indicator
#' swadlr_measures(indicator = "hourly_wage_percentiles")
#' }
swadlr_measures <- function(indicator = NULL) {
  raw <- fetch_measures()

  result <- data.frame(
    id = raw$measure$id,
    name = raw$measure$name,
    format = raw$measure$format,
    stringsAsFactors = FALSE
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

#' List available dimensions
#'
#' Returns a data frame of available dimensions and their values in the SWADL
#' API. Dimensions allow subsetting data by demographic or other categories
#' (e.g., gender, race, education).
#'
#' @param indicator Optional indicator ID to filter dimensions to only those
#'   available for a specific indicator. Use [swadlr_indicators()] to see
#'   available indicators.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{dimension_id}{Dimension identifier}
#'     \item{dimension_name}{Human-readable dimension name}
#'     \item{value_id}{Dimension value identifier (used in `get_swadl_series()`
#'       with the `dimension` argument)}
#'     \item{value_name}{Human-readable dimension value name}
#'   }
#'
#' @export
#' @examples
#' \dontrun{
#' # List all dimensions
#' swadlr_dimensions()
#'
#' # List dimensions for a specific indicator
#' swadlr_dimensions(indicator = "hourly_wage_percentiles")
#' }
swadlr_dimensions <- function(indicator = NULL) {
  raw <- fetch_dimensions()

  # Build a data frame with all dimension values
  rows <- list()
  n_dims <- length(raw$dimension$id)

  for (i in seq_len(n_dims)) {
    dim_id <- raw$dimension$id[i]
    dim_name <- raw$dimension$name[i]
    dim_values <- raw$dimension_values[[i]]

    n_vals <- length(dim_values$dimension_value$id)
    for (j in seq_len(n_vals)) {
      rows[[length(rows) + 1]] <- data.frame(
        dimension_id = dim_id,
        dimension_name = dim_name,
        value_id = dim_values$dimension_value$id[j],
        value_name = dim_values$dimension_value$name[j],
        stringsAsFactors = FALSE
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

#' List available geographies
#'
#' Returns a data frame of available geographic units in the SWADL API. This
#' includes the national level, census regions, census divisions, and all
#' states plus the District of Columbia.
#'
#' @return A data frame with columns:
#'   \describe{
#'     \item{id}{Geography identifier (used in `get_swadl_series()`)}
#'     \item{level}{Geographic level ("national", "region", "division", or
#'       "state")}
#'     \item{name}{Human-readable geography name}
#'     \item{abbr}{Abbreviation (state postal code, "US" for national, or NA
#'       for regions/divisions)}
#'   }
#'
#' @export
#' @examples
#' swadlr_geographies()
#'
#' # Filter to just states
#' geographies <- swadlr_geographies()
#' geographies[geographies$level == "state", ]
swadlr_geographies <- function() {
  swadlr_geography_lookup
}
