# Validation helpers for get_swadl()

# Filter availability by measure, date_interval, geo_level
filter_availability <- function(
  availability,
  measure = NULL,
  date_interval = NULL,
  geo_level = NULL
) {
  result <- availability
  if (!is.null(measure)) {
    result <- result[result$measure_id == measure, ]
  }
  if (!is.null(date_interval)) {
    result <- result[result$date_interval == date_interval, ]
  }
  if (!is.null(geo_level)) {
    result <- result[result$geo_level == geo_level, ]
  }
  result
}

# Validate a single string value against available options
validate_single_string <- function(
  value,
  param_name,
  available,
  error_suffix = NULL
) {
  if (!is.character(value) || length(value) != 1) {
    stop("`", param_name, "` must be a single character string.", call. = FALSE)
  }

  if (!(value %in% available)) {
    msg <- paste0("Unknown ", param_name, ": \"", value, "\"")
    if (!is.null(error_suffix)) {
      msg <- paste0(msg, "\n", error_suffix)
    }
    stop(msg, call. = FALSE)
  }

  invisible(TRUE)
}

# Validate indicator exists
validate_indicator <- function(indicator) {
  indicators_raw <- fetch_indicators()
  available_ids <- indicators_raw$indicator$id

  validate_single_string(
    indicator,
    "indicator",
    available_ids,
    'Use swadl_id_names("indicators") to see available indicators.'
  )
}

# Validate measure is available for indicator
validate_measure <- function(indicator, measure, availability = NULL) {
  if (is.null(availability)) {
    availability <- get_indicator_availability(indicator)
  }
  available_measures <- unique(availability$availability$measure_id)

  validate_single_string(
    measure,
    "measure",
    available_measures,
    paste0(
      "Measure is not available for indicator \"",
      indicator,
      "\".\n",
      "Available measures: ",
      paste(available_measures, collapse = ", ")
    )
  )
}

# Validate date_interval is available for indicator/measure
validate_date_interval <- function(
  indicator,
  measure,
  date_interval,
  availability = NULL
) {
  # First check it's a valid date_interval value
  validate_single_string(
    date_interval,
    "date_interval",
    c("year", "month"),
    '`date_interval` must be either "year" or "month".'
  )

  # Then check it's available for this indicator/measure
  if (is.null(availability)) {
    availability <- get_indicator_availability(indicator)
  }
  avail_data <- availability$availability

  # Filter to this measure
  measure_rows <- filter_availability(avail_data, measure = measure)
  available_intervals <- unique(measure_rows$date_interval)

  if (!(date_interval %in% available_intervals)) {
    stop(
      date_interval,
      "ly data is not available for indicator \"",
      indicator,
      "\" with measure \"",
      measure,
      "\".\n",
      "Available intervals: ",
      paste(available_intervals, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

# Validate geography is available for indicator/measure/interval
validate_geography <- function(
  indicator,
  measure,
  date_interval,
  geography,
  availability = NULL
) {
  # First resolve geography to API ID
  geo_id <- resolve_geography(geography)

  # Get geo level from the ID
  geo_level <- get_geo_level(geo_id)

  if (is.null(availability)) {
    availability <- get_indicator_availability(indicator)
  }
  avail_data <- availability$availability

  # Filter to this measure and interval
  filtered <- filter_availability(
    avail_data,
    measure = measure,
    date_interval = date_interval
  )
  available_geo_levels <- unique(filtered$geo_level)

  if (!(geo_level %in% available_geo_levels)) {
    stop(
      "Geographic level \"",
      geo_level,
      "\" is not available for indicator \"",
      indicator,
      "\" with measure \"",
      measure,
      "\" (",
      date_interval,
      "ly).\n",
      "Available geographic levels: ",
      paste(available_geo_levels, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(geo_id)
}

# Get the geographic level from a geo ID
get_geo_level <- function(geo_id) {
  if (geo_id == "national") {
    return("national")
  }
  if (startsWith(geo_id, "region")) {
    return("region")
  }
  if (startsWith(geo_id, "division")) {
    return("division")
  }
  if (startsWith(geo_id, "state")) {
    return("state")
  }
  stop("Unknown geographic ID format: ", geo_id, call. = FALSE)
}

# Get availability rows for indicator/measure/interval/geo_level
get_availability_rows <- function(
  indicator,
  measure,
  date_interval,
  geo_level
) {
  ind_data <- get_indicator_availability(indicator)
  availability <- ind_data$availability

  filter_availability(
    availability,
    measure = measure,
    date_interval = date_interval,
    geo_level = geo_level
  )
}

# Get available dimension values for an indicator/measure/interval/geo_level
get_available_dimension_values <- function(
  indicator,
  measure,
  date_interval,
  geo_level
) {
  avail <- get_availability_rows(indicator, measure, date_interval, geo_level)
  unique(unlist(avail$dimension_values))
}

# Get available dimension IDs for an indicator/measure/interval/geo_level
get_available_dimension_ids <- function(
  indicator,
  measure,
  date_interval,
  geo_level
) {
  dim_values <- get_available_dimension_values(
    indicator,
    measure,
    date_interval,
    geo_level
  )

  get_dim_ids_from_values(dim_values)
}

# Get or build cached lookup table mapping dim_value_id -> dim_id
get_dim_value_lookup <- function() {
  if (cache_has("dim_value_lookup")) {
    return(cache_get("dim_value_lookup"))
  }

  dims_raw <- fetch_dimensions()
  lookup <- list()

  iterate_dimension_values(
    dims_raw,
    function(dim_id, dim_name, val_id, val_name) {
      lookup[[val_id]] <<- dim_id
    }
  )

  cache_set("dim_value_lookup", lookup)
  lookup
}

# Map dimension value IDs to their dimension IDs
map_dim_values_to_dim_ids <- function(dim_value_ids) {
  lookup <- get_dim_value_lookup()

  unname(vapply(
    dim_value_ids,
    function(val_id) {
      if (val_id %in% names(lookup)) {
        lookup[[val_id]]
      } else {
        NA_character_
      }
    },
    character(1)
  ))
}

# Get all dimension value IDs for a dimension ID
get_dim_value_ids_for_dim <- function(dimension_id) {
  dims_raw <- fetch_dimensions()

  dim_idx <- which(dims_raw$dimension$id == dimension_id)
  if (length(dim_idx) == 0) {
    return(character(0))
  }

  dims_raw$dimension_values[[dim_idx]]$dimension_value$id
}

# Validate date argument
validate_date <- function(date) {
  if (is.null(date)) {
    return(invisible(TRUE))
  }

  if (inherits(date, "Date")) {
    date <- as.character(date)
  }

  if (!is.character(date)) {
    stop(
      "`date` must be NULL, a character string, or a Date object.",
      call. = FALSE
    )
  }

  if (length(date) > 2) {
    stop(
      "`date` must have at most 2 elements (start and end).",
      call. = FALSE
    )
  }

  # Try to parse dates
  parsed <- tryCatch(
    as.Date(date),
    error = function(e) {
      stop(
        "Invalid date format. Use ISO format (YYYY-MM-DD).",
        call. = FALSE
      )
    }
  )

  if (any(is.na(parsed))) {
    stop(
      "Invalid date format. Use ISO format (YYYY-MM-DD).",
      call. = FALSE
    )
  }

  invisible(TRUE)
}
