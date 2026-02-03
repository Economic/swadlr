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
  # Indicator
  cli::cli_h2("Indicator")
  cli::cli_bullets(c(
    "*" = "Name: {x$name}",
    "*" = "Topic: {x$topic}",
    "*" = "Last updated: {format(x$updated, '%Y-%m-%d')}"
  ))

  # Measures table
  cli::cli_h2("Measures")
  if (nrow(x$measures) > 0) {
    print_cli_table(
      x$measures,
      col_names = c("ID", "Name", "Format")
    )
  } else {
    cli::cli_text("No measures available.")
  }

  # Dimension combinations by geography
  cli::cli_h2("Dimensions by geography")
  avail <- x$availability
  if (nrow(avail) > 0) {
    print_geo_dimensions(avail)
  } else {
    cli::cli_text("No dimension information available.")
  }

  # Dates
  cli::cli_h2("Dates")
  print_date_range(avail)

  # Sources
  cli::cli_h2("Sources")
  if (nrow(x$sources) > 0) {
    source_bullets <- build_source_bullets(x$sources)
    cli::cli_bullets(source_bullets)
  } else {
    cli::cli_text("No sources available.")
  }

  invisible(x)
}


# Internal: print a data frame as an aligned table using cli
print_cli_table <- function(df, col_names = NULL) {
  if (is.null(col_names)) {
    col_names <- names(df)
  }

  # Calculate column widths
  widths <- vapply(
    seq_along(df),
    function(i) {
      max(nchar(as.character(df[[i]])), nchar(col_names[i]))
    },
    integer(1)
  )

  # Build header with bold formatting
  header <- paste(
    mapply(
      function(name, width) format(name, width = width),
      col_names,
      widths
    ),
    collapse = "  "
  )
  cli::cli_verbatim(cli::style_bold(header))

  # Print rows
  for (i in seq_len(nrow(df))) {
    row <- paste(
      mapply(
        function(val, width) format(as.character(val), width = width),
        df[i, ],
        widths
      ),
      collapse = "  "
    )
    cli::cli_verbatim(row)
  }
}


# Internal: print geography dimensions in a structured format
print_geo_dimensions <- function(avail) {
  geo_levels <- unique(avail$geo_level)

  for (geo in geo_levels) {
    geo_rows <- avail[avail$geo_level == geo, ]
    unique_dims <- unique(geo_rows$dimensions)

    # Calculate max depth
    depths <- vapply(
      unique_dims,
      function(d) {
        if (d == "overall") {
          return(0L)
        }
        length(gregexpr("\u00D7", d)[[1]]) + 1L
      },
      integer(1)
    )
    max_depth <- max(depths)

    # Format depth label
    depth_label <- if (max_depth == 0) {
      "overall only"
    } else if (max_depth == 1) {
      "1-way"
    } else {
      paste0("up to ", max_depth, "-way")
    }

    # Sort dimensions by depth then alphabetically
    dim_order <- order(depths, unique_dims)
    sorted_dims <- unique_dims[dim_order]

    # Print geography header
    cli::cli_text("{.strong {geo}} ({depth_label})")

    # Print dimensions, truncating if too many
    if (length(sorted_dims) > 8) {
      shown_dims <- sorted_dims[1:6]
      dims_text <- paste0(
        paste(shown_dims, collapse = ", "),
        ", ... (",
        length(sorted_dims),
        " total)"
      )
    } else {
      dims_text <- paste(sorted_dims, collapse = ", ")
    }
    cli::cli_verbatim(paste0("  ", dims_text))
  }
}


# Internal: print date range using cli
print_date_range <- function(avail) {
  labels <- c(year = "Annual", quarter = "Quarterly", month = "Monthly")

  for (interval in c("year", "quarter", "month")) {
    interval_rows <- avail[avail$date_interval == interval, ]
    label <- labels[[interval]]

    if (nrow(interval_rows) > 0) {
      min_date <- min(interval_rows$date_start)
      max_date <- max(interval_rows$date_end)

      if (interval == "year") {
        value <- paste(format(min_date, "%Y"), "\u2014", format(max_date, "%Y"))
      } else {
        value <- paste(
          format(min_date, "%B %Y"),
          "\u2014",
          format(max_date, "%B %Y")
        )
      }
      cli::cli_bullets(c("*" = paste0(label, ": ", value)))
    } else {
      cli::cli_bullets(c("*" = paste0(label, ": {.emph Not available}")))
    }
  }
}


# Internal: build source bullets for display
build_source_bullets <- function(sources) {
  bullets <- vapply(
    seq_len(nrow(sources)),
    function(i) {
      src <- sources[i, ]
      measure <- if (is.na(src$measure_id)) "(all)" else src$measure_id
      paste0(measure, ": ", src$source)
    },
    character(1)
  )

  stats::setNames(bullets, rep("*", length(bullets)))
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
  iterate_dimension_values(
    dims_raw,
    function(dim_id, dim_name, val_id, val_name) {
      if (val_id %in% all_dim_values) {
        rows[[length(rows) + 1]] <<- tibble::tibble(
          dimension_id = dim_id,
          dimension_name = dim_name,
          value_id = val_id,
          value_name = val_name
        )
      }
    }
  )

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
    geo_availability[[geo_level]] <- get_dim_ids_from_values(all_dim_values)
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
    geo_avail <- normalize_geo_availability(entry$geo_availability[[1]])

    if (is.null(geo_avail)) {
      # No geo_availability, skip this entry
      next
    }

    for (j in seq_len(nrow(geo_avail))) {
      dims <- geo_avail$dimensions[[j]]

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
