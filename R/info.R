# Functions for getting detailed indicator information

#' Get detailed information about an indicator
#'
#' Returns detailed information about a specific indicator including available
#' measures, dimension combinations, date ranges, geographic availability, and
#' sources.
#'
#' @param indicator The indicator ID (e.g., `"hourly_wage_percentiles"`). Use
#'   [swadl_id_names()] to see available indicators.
#'
#' @return An S3 object of class `swadl_indicator_info` with the following
#'   components:
#'   \describe{
#'     \item{id}{Indicator identifier}
#'     \item{name}{Human-readable indicator name}
#'     \item{topic}{Topic ID the indicator belongs to}
#'     \item{updated}{Date the indicator was last updated}
#'     \item{measures}{Tibble of available measures with columns: `id`,
#'       `name`, `format`}
#'     \item{availability}{Tibble of availability information with columns:
#'       `date_interval`, `measure_id`, `geo_level`, `dimensions`, `date_start`,
#'       `date_end`. The `dimensions` column contains dimension IDs joined with
#'       ` x ` (using multiplication sign), or `"overall"` for aggregate data.}
#'     \item{sources}{Tibble of sources with columns: `measure_id`,
#'       `source`, `url`}
#'   }
#'
#' @seealso [swadl_id_names()] to list available indicators, measures, and
#'   dimensions.
#'
#' @export
#' @examples
#' \donttest{
#' # Get information about hourly wage percentiles
#' info <- swadl_indicator("hourly_wage_percentiles")
#' print(info)
#'
#' # Access specific components
#' info$measures
#' info$availability
#' }
swadl_indicator <- function(indicator) {
  if (!is.character(indicator) || length(indicator) != 1) {
    stop("`indicator` must be a single character string.", call. = FALSE)
  }

  # Fetch indicator data (validates indicator exists)
  ind_data <- get_indicator_availability(indicator)

  # Extract indicator info
  ind <- ind_data$indicator
  ind_id <- ind$id
  ind_name <- ind$name
  ind_topic <- ind$fkTopicId
  ind_updated <- as.Date(ind$updatedDate)

  # Get availability data for this indicator
  availability <- ind_data$availability

  # Build measures data frame
  measures <- build_indicator_measures(indicator, availability)

  # Build availability tibble
  avail_tibble <- build_availability_tibble(availability)

  # Build sources data frame
  sources <- build_indicator_sources(indicator)

  result <- list(
    id = ind_id,
    name = ind_name,
    topic = ind_topic,
    updated = ind_updated,
    measures = measures,
    availability = avail_tibble,
    sources = sources
  )

  class(result) <- "swadl_indicator_info"
  result
}


#' @export
print.swadl_indicator_info <- function(x, ...) {
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

  # Dimension combinations by geography
  cat("### Dimension combinations by geography\n\n")
  avail <- x$availability
  if (nrow(avail) > 0) {
    geo_levels <- unique(avail$geo_level)
    for (geo in geo_levels) {
      geo_rows <- avail[avail$geo_level == geo, ]
      unique_dims <- unique(geo_rows$dimensions)

      # Calculate max depth (count of " x " plus 1)
      depths <- vapply(
        unique_dims,
        function(d) {
          if (d == "overall") {
            return(0L)
          }
          # Count multiplication signs
          length(gregexpr("\u00D7", d)[[1]]) + 1L
        },
        integer(1)
      )
      max_depth <- max(depths)

      # Format depth label
      if (max_depth == 0) {
        depth_label <- "overall only"
      } else if (max_depth == 1) {
        depth_label <- "1-way"
      } else {
        depth_label <- paste0("up to ", max_depth, "-way")
      }

      # Format dimension combinations
      # Sort by depth then alphabetically
      dim_order <- order(depths, unique_dims)
      sorted_dims <- unique_dims[dim_order]

      # Abbreviate if too many (more than 8)
      if (length(sorted_dims) > 8) {
        shown_dims <- sorted_dims[1:6]
        dims_str <- paste0(
          paste(shown_dims, collapse = ", "),
          ", ... (",
          length(sorted_dims),
          " combinations)"
        )
      } else {
        dims_str <- paste(sorted_dims, collapse = ", ")
      }

      cat("- **", geo, "** (", depth_label, "): ", dims_str, "\n", sep = "")
    }
  } else {
    cat("No dimension information available.\n")
  }
  cat("\n")

  # Date range (derived from availability tibble)
  cat("### Date range\n\n")
  if (nrow(avail) > 0) {
    for (interval in c("year", "quarter", "month")) {
      interval_rows <- avail[avail$date_interval == interval, ]
      if (nrow(interval_rows) > 0) {
        min_date <- min(interval_rows$date_start)
        max_date <- max(interval_rows$date_end)
        if (interval == "year") {
          cat(
            "- **Year:**",
            format(min_date, "%Y"),
            "-",
            format(max_date, "%Y"),
            "\n"
          )
        } else {
          cat(
            "- **",
            tools::toTitleCase(interval),
            ":** ",
            format(min_date, "%Y-%m"),
            " - ",
            format(max_date, "%Y-%m"),
            "\n",
            sep = ""
          )
        }
      } else {
        cat(
          "- **",
          tools::toTitleCase(interval),
          ":** Not available\n",
          sep = ""
        )
      }
    }
  } else {
    cat("- **Year:** Not available\n")
    cat("- **Quarter:** Not available\n")
    cat("- **Month:** Not available\n")
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


# Internal helper: build measures tibble for an indicator
build_indicator_measures <- function(indicator, availability) {
  measures_raw <- fetch_measures()

  # Get unique measure IDs from availability
  available_measure_ids <- unique(availability$measure_id)

  # Filter to measures available for this indicator
  measure_idx <- which(measures_raw$measure$id %in% available_measure_ids)

  if (length(measure_idx) == 0) {
    return(tibble::tibble(
      id = character(0),
      name = character(0),
      format = character(0)
    ))
  }

  tibble::tibble(
    id = measures_raw$measure$id[measure_idx],
    name = measures_raw$measure$name[measure_idx],
    format = measures_raw$measure$format[measure_idx]
  )
}


# Internal helper: build dimensions tibble for an indicator
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
        rows[[length(rows) + 1]] <- tibble::tibble(
          dimension_id = dim_id,
          dimension_name = dim_name,
          value_id = val_id,
          value_name = dim_values$dimension_value$name[j]
        )
      }
    }
  }

  if (length(rows) == 0) {
    return(tibble::tibble(
      dimension_id = character(0),
      dimension_name = character(0),
      value_id = character(0),
      value_name = character(0)
    ))
  }

  do.call(rbind, rows)
}


# Internal helper: build availability summary
build_availability_summary <- function(availability) {
  # Date ranges by interval
  date_range <- list(year = NULL, month = NULL)

  for (interval in c("year", "month")) {
    interval_rows <- filter_availability(availability, date_interval = interval)
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
    level_rows <- filter_availability(availability, geo_level = geo_level)
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


# Internal helper: build availability tibble from raw indicator availability data
#
# Takes the availability list element for a single indicator (from fetch_indicators())
# and returns a tibble with columns: date_interval, measure_id, geo_level, dimensions,
# date_start, date_end.
#
# The dimensions column contains dimension IDs joined with " × " (multiplication sign,
# U+00D7), sorted alphabetically. For aggregate data without demographic breakdown,
# the value is "overall".
build_availability_tibble <- function(availability) {
  if (length(availability) == 0) {
    return(tibble::tibble(
      date_interval = character(0),
      measure_id = character(0),
      geo_level = character(0),
      dimensions = character(0),
      date_start = as.Date(character(0)),
      date_end = as.Date(character(0))
    ))
  }

  rows <- list()

  for (i in seq_len(nrow(availability))) {
    entry <- availability[i, ]
    geo_avail <- entry$geo_availability[[1]]

    if (is.null(geo_avail) || length(geo_avail) == 0) {
      # No geo_availability, skip this entry
      next
    }

    # geo_avail is a data frame with dimensions and geo_ids columns (both list cols)
    n_geo <- if (is.data.frame(geo_avail)) {
      nrow(geo_avail)
    } else {
      length(geo_avail)
    }

    for (j in seq_len(n_geo)) {
      dims <- if (is.data.frame(geo_avail)) {
        geo_avail$dimensions[[j]]
      } else {
        geo_avail[[j]]$dimensions
      }

      # Build dimensions string
      if (is.null(dims) || length(dims) == 0) {
        dims_str <- "overall"
      } else if (length(dims) == 1 && dims[1] == "overall") {
        dims_str <- "overall"
      } else {
        # Sort alphabetically and join with multiplication sign
        dims_str <- paste(sort(dims), collapse = " \u00D7 ")
      }

      rows[[length(rows) + 1]] <- tibble::tibble(
        date_interval = entry$date_interval,
        measure_id = entry$measure_id,
        geo_level = entry$geo_level,
        dimensions = dims_str,
        date_start = as.Date(entry$date_start),
        date_end = as.Date(entry$date_end)
      )
    }
  }

  if (length(rows) == 0) {
    return(tibble::tibble(
      date_interval = character(0),
      measure_id = character(0),
      geo_level = character(0),
      dimensions = character(0),
      date_start = as.Date(character(0)),
      date_end = as.Date(character(0))
    ))
  }

  do.call(rbind, rows)
}


# Internal helper: build sources tibble for an indicator
build_indicator_sources <- function(indicator) {
  sources_raw <- fetch_sources()

  # Filter to sources for this indicator
  # The sources JSON has fkIndicatorId field
  source_idx <- which(sources_raw$fkIndicatorId == indicator)

  if (length(source_idx) == 0) {
    return(tibble::tibble(
      measure_id = character(0),
      source = character(0),
      url = character(0)
    ))
  }

  tibble::tibble(
    measure_id = sources_raw$fkMeasureId[source_idx],
    source = sources_raw$source[source_idx],
    url = ifelse(
      is.null(sources_raw$url[source_idx]),
      NA_character_,
      sources_raw$url[source_idx]
    )
  )
}
