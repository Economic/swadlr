# Functions for getting detailed indicator information

#' Get detailed information about an indicator
#'
#' Returns detailed information about a specific indicator including available
#' measures, dimensions, date ranges, geographic availability, and sources.
#'
#' @param indicator The indicator ID (e.g., `"hourly_wage_percentiles"`). Use
#'   [swadlr_indicators()] to see available indicators.
#'
#' @return An S3 object of class `swadlr_indicator_info` with the following
#'   components:
#'   \describe{
#'     \item{id}{Indicator identifier}
#'     \item{name}{Human-readable indicator name}
#'     \item{topic}{Topic ID the indicator belongs to}
#'     \item{updated}{Date the indicator was last updated}
#'     \item{measures}{Data frame of available measures with columns: `id`,
#'       `name`, `format`}
#'     \item{dimensions}{Data frame of available dimensions with columns:
#'       `dimension_id`, `dimension_name`, `value_id`, `value_name`}
#'     \item{availability}{List with date ranges and geographic availability}
#'     \item{sources}{Data frame of sources with columns: `measure_id`,
#'       `source`, `url`}
#'   }
#'
#' @seealso [swadlr_indicators()] to list available indicators,
#'   [swadlr_measures()] to list measures, [swadlr_dimensions()] to list
#'   dimensions.
#'
#' @export
#' @examples
#' \dontrun{
#' # Get information about hourly wage percentiles
#' info <- get_swadl_info("hourly_wage_percentiles")
#' print(info)
#'
#' # Access specific components
#' info$measures
#' info$availability$date_range
#' }
get_swadl_info <- function(indicator) {
  if (!is.character(indicator) || length(indicator) != 1) {
    stop("`indicator` must be a single character string.", call. = FALSE)
  }

  # Fetch all metadata
  indicators_raw <- fetch_indicators()
  indicator_idx <- which(indicators_raw$indicator$id == indicator)

  if (length(indicator_idx) == 0) {
    available <- paste(indicators_raw$indicator$id, collapse = ", ")
    stop(
      "Unknown indicator: \"",
      indicator,
      "\"\n",
      "Available indicators: ",
      available,
      call. = FALSE
    )
  }

  # Extract indicator info
  ind <- indicators_raw$indicator
  ind_id <- ind$id[indicator_idx]
  ind_name <- ind$name[indicator_idx]
  ind_topic <- ind$fkTopicId[indicator_idx]
  ind_updated <- as.Date(ind$updatedDate[indicator_idx])

  # Get availability data for this indicator
  availability <- indicators_raw$availability[[indicator_idx]]

  # Build measures data frame
  measures <- build_indicator_measures(indicator, availability)

  # Build dimensions data frame
  dimensions <- build_indicator_dimensions(indicator, availability)

  # Build availability summary
  avail_summary <- build_availability_summary(availability)

  # Build sources data frame
  sources <- build_indicator_sources(indicator)

  result <- list(
    id = ind_id,
    name = ind_name,
    topic = ind_topic,
    updated = ind_updated,
    measures = measures,
    dimensions = dimensions,
    availability = avail_summary,
    sources = sources
  )

  class(result) <- "swadlr_indicator_info"
  result
}


#' @export
print.swadlr_indicator_info <- function(x, ...) {
  cat("##", x$id, "\n\n")
  cat(x$name, "\n\n")
  cat("**Topic:**", x$topic, "\n")
  cat("**Last updated:**", format(x$updated, "%Y-%m-%d"), "\n\n")

  # Measures table
  cat("### Available measures\n\n")
  if (nrow(x$measures) > 0) {
    cat("| ID | Name | Format |\n")
    cat("|----|------|--------|\n")
    for (i in seq_len(nrow(x$measures))) {
      cat(
        "|",
        x$measures$id[i],
        "|",
        x$measures$name[i],
        "|",
        x$measures$format[i],
        "|\n"
      )
    }
  } else {
    cat("No measures available.\n")
  }
  cat("\n")

  # Dimensions table
  cat("### Available dimensions\n\n")
  if (nrow(x$dimensions) > 0) {
    # Get unique dimensions
    unique_dims <- unique(x$dimensions[, c("dimension_id", "dimension_name")])
    cat("| ID | Name |\n")
    cat("|----|------|\n")
    for (i in seq_len(nrow(unique_dims))) {
      cat(
        "|",
        unique_dims$dimension_id[i],
        "|",
        unique_dims$dimension_name[i],
        "|\n"
      )
    }
  } else {
    cat("No dimensions available.\n")
  }
  cat("\n")

  # Date range
  cat("### Date range\n\n")
  if (!is.null(x$availability$date_range$year)) {
    yr <- x$availability$date_range$year
    cat(
      "- **Year:**",
      format(as.Date(yr$start), "%Y"),
      "-",
      format(as.Date(yr$end), "%Y"),
      "\n"
    )
  } else {
    cat("- **Year:** Not available\n")
  }
  if (!is.null(x$availability$date_range$month)) {
    mo <- x$availability$date_range$month
    cat(
      "- **Month:**",
      format(as.Date(mo$start), "%Y-%m"),
      "-",
      format(as.Date(mo$end), "%Y-%m"),
      "\n"
    )
  } else {
    cat("- **Month:** Not available\n")
  }
  cat("\n")

  # Geographic availability
  cat("### Geographic availability\n\n")
  geo_avail <- x$availability$geo_availability
  if (length(geo_avail) > 0) {
    for (geo_level in names(geo_avail)) {
      dims <- geo_avail[[geo_level]]
      if (length(dims) == 0) {
        cat("-", geo_level, ": overall only\n")
      } else {
        cat("-", geo_level, ":", paste(dims, collapse = ", "), "\n")
      }
    }
  } else {
    cat("No geographic availability information.\n")
  }
  cat("\n")

  # Sources
  cat("### Sources\n\n")
  if (nrow(x$sources) > 0) {
    for (i in seq_len(nrow(x$sources))) {
      src <- x$sources[i, ]
      cat("-", src$measure_id, ":", src$source)
      if (!is.na(src$url) && nchar(src$url) > 0) {
        cat(" (", src$url, ")", sep = "")
      }
      cat("\n")
    }
  } else {
    cat("No sources available.\n")
  }

  invisible(x)
}


# Internal helper: build measures data frame for an indicator
build_indicator_measures <- function(indicator, availability) {
  measures_raw <- fetch_measures()

  # Get unique measure IDs from availability
  available_measure_ids <- unique(availability$measure_id)

  # Filter to measures available for this indicator
  measure_idx <- which(measures_raw$measure$id %in% available_measure_ids)

  if (length(measure_idx) == 0) {
    return(data.frame(
      id = character(0),
      name = character(0),
      format = character(0),
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    id = measures_raw$measure$id[measure_idx],
    name = measures_raw$measure$name[measure_idx],
    format = measures_raw$measure$format[measure_idx],
    stringsAsFactors = FALSE
  )
}


# Internal helper: build dimensions data frame for an indicator
build_indicator_dimensions <- function(indicator, availability) {
  dims_raw <- fetch_dimensions()

  # Get all dimension value IDs from availability
  all_dim_values <- unique(unlist(availability$dimension_values))

  # Build a lookup of dimension value ID to dimension info
  rows <- list()
  n_dims <- length(dims_raw$dimension$id)

  for (i in seq_len(n_dims)) {
    dim_id <- dims_raw$dimension$id[i]
    dim_name <- dims_raw$dimension$name[i]
    dim_values <- dims_raw$dimension_values[[i]]

    n_vals <- length(dim_values$dimension_value$id)
    for (j in seq_len(n_vals)) {
      val_id <- dim_values$dimension_value$id[j]
      if (val_id %in% all_dim_values) {
        rows[[length(rows) + 1]] <- data.frame(
          dimension_id = dim_id,
          dimension_name = dim_name,
          value_id = val_id,
          value_name = dim_values$dimension_value$name[j],
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(rows) == 0) {
    return(data.frame(
      dimension_id = character(0),
      dimension_name = character(0),
      value_id = character(0),
      value_name = character(0),
      stringsAsFactors = FALSE
    ))
  }

  do.call(rbind, rows)
}


# Internal helper: build availability summary
build_availability_summary <- function(availability) {
  # Date ranges by interval
  date_range <- list(year = NULL, month = NULL)

  for (interval in c("year", "month")) {
    interval_rows <- availability[availability$date_interval == interval, ]
    if (nrow(interval_rows) > 0) {
      date_range[[interval]] <- list(
        start = min(interval_rows$date_start),
        end = max(interval_rows$date_end)
      )
    }
  }

  # Geographic availability by level
  geo_levels <- unique(availability$geo_level)
  geo_availability <- list()

  for (geo_level in geo_levels) {
    level_rows <- availability[availability$geo_level == geo_level, ]
    # Get all dimension IDs available at this geo level
    all_dim_values <- unique(unlist(level_rows$dimension_values))

    # Map dimension values to dimension IDs
    if (length(all_dim_values) > 0) {
      dims_raw <- fetch_dimensions()
      dim_ids <- character(0)

      n_dims <- length(dims_raw$dimension$id)
      for (i in seq_len(n_dims)) {
        dim_values <- dims_raw$dimension_values[[i]]
        if (any(dim_values$dimension_value$id %in% all_dim_values)) {
          dim_ids <- c(dim_ids, dims_raw$dimension$id[i])
        }
      }

      geo_availability[[geo_level]] <- unique(dim_ids)
    } else {
      geo_availability[[geo_level]] <- character(0)
    }
  }

  list(
    date_range = date_range,
    geo_levels = geo_levels,
    geo_availability = geo_availability
  )
}


# Internal helper: build sources data frame for an indicator
build_indicator_sources <- function(indicator) {
  sources_raw <- fetch_sources()

  # Filter to sources for this indicator
  # The sources JSON has fkIndicatorId field
  source_idx <- which(sources_raw$fkIndicatorId == indicator)

  if (length(source_idx) == 0) {
    return(data.frame(
      measure_id = character(0),
      source = character(0),
      url = character(0),
      stringsAsFactors = FALSE
    ))
  }

  data.frame(
    measure_id = sources_raw$fkMeasureId[source_idx],
    source = sources_raw$source[source_idx],
    url = ifelse(
      is.null(sources_raw$url[source_idx]),
      NA_character_,
      sources_raw$url[source_idx]
    ),
    stringsAsFactors = FALSE
  )
}
