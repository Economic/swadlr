# Core data retrieval functions

#' Get time series data from SWADL
#'
#' Retrieves time series data from the EPI State of Working America Data
#' Library API.
#'
#' @param indicator Indicator ID (e.g., `"hourly_wage_percentiles"`). Use
#'   [swadl_id_names()] to see available indicators.
#' @param measure Measure ID (e.g., `"nominal_wage"`). Use
#'   [swadl_id_names()] or [swadl_indicator()] to see available measures.
#' @param date_interval Either `"year"` or `"month"`. Defaults to `"year"`.
#' @param geography A geography specification. Accepts state names (e.g.,
#'   `"California"`), abbreviations (e.g., `"CA"`), region names (e.g.,
#'   `"Midwest"`), division names (e.g., `"Pacific"`), or API IDs (e.g.,
#'   `"state06"`). Defaults to `"national"`.
#' @param dimension Dimension specification. Can be:
#'   - `"overall"`: Returns aggregate data without demographic breakdown
#'   - A dimension ID (e.g., `"wage_percentile"`): Returns all values for that
#'     dimension
#'   - A list with named and/or unnamed elements:
#'     - Named elements filter to specific values:
#'       `list("wage_percentile" = "wage_p50")`
#'     - Unnamed elements return all values:
#'       `list("wage_percentile")`
#'     - Multiple dimensions can be cross-tabulated, but only one dimension
#'       can return all values; the others must specify values:
#'       `list("gender" = "gender_male", "age_group")`
#' @param date Optional date filter. Can be:
#'   - `NULL` (default): All available dates
#'   - A single date (character or Date): Returns only that date
#'   - A vector of two dates: Returns dates in that range (inclusive)
#'
#' @return A tibble with columns:
#'   - `date`: Observation date
#'   - `value`: The observed value
#'   - `geography`: Geography ID
#'   - One column per dimension in the request, containing dimension value IDs
#'
#' @seealso [swadl_indicator()] for indicator details, [swadl_id_names()] to
#'   list indicators, measures, and dimensions.
#'
#' @export
#' @examples
#' \donttest{
#' # Median hourly wage over time
#' get_swadl(
#'   "hourly_wage_percentiles",
#'   "nominal_wage",
#'   dimension = list("wage_percentile" = "wage_p50")
#' )
#'
#' # All wage percentiles
#' get_swadl(
#'   "hourly_wage_percentiles",
#'   "nominal_wage",
#'   dimension = "wage_percentile"
#' )
#'
#' # Employment rate for males by age group
#' get_swadl(
#'   "labor_force_emp",
#'   "percent_emp",
#'   dimension = list("gender" = "gender_male", "age_group")
#' )
#'
#' # Filter to specific date range
#' get_swadl(
#'   "hourly_wage_percentiles",
#'   "nominal_wage",
#'   dimension = "wage_percentile",
#'   date = c("2000-01-01", "2024-01-01")
#' )
#' }
get_swadl <- function(
  indicator,
  measure,
  date_interval = c("year", "month"),
  geography = "national",
  dimension = "overall",
  date = NULL
) {
  # Match date_interval argument
  date_interval <- match.arg(date_interval)

  # Validate inputs
  validate_indicator(indicator)
  availability <- get_indicator_availability(indicator)
  validate_measure(indicator, measure, availability)
  validate_date_interval(indicator, measure, date_interval, availability)
  geo_id <- validate_geography(
    indicator,
    measure,
    date_interval,
    geography,
    availability
  )
  geo_level <- get_geo_level(geo_id)
  validate_date(date)

  # Parse dimension argument
  dim_parsed <- parse_dimension(
    dimension,
    indicator,
    measure,
    date_interval,
    geo_level,
    geo_id
  )

  # Fetch data from custom endpoint
  data <- fetch_data_custom(
    indicator,
    date_interval,
    measure,
    dim_parsed$params$datumns
  )

  # Handle empty response
  if (length(data) == 0 || (is.data.frame(data) && nrow(data) == 0)) {
    warning("No data returned from API.", call. = FALSE)
    return(empty_series_df(dim_parsed$dim_ids))
  }

  # Transform to long-format data frame
  result <- transform_response(data, dim_parsed$dim_ids)

  # Apply dimension value filter (if needed)
  result <- apply_dim_filter(result, dim_parsed$dim_value_filter)

  # Apply date filter
  result <- apply_date_filter(result, date)

  result
}

# Fetch data from /api/indicator/data/custom endpoint
fetch_data_custom <- function(indicator, date_interval, measure, datumns) {
  query <- list(
    indicatorId = indicator,
    dateInterval = date_interval,
    measureId = measure,
    datumns = jsonlite::toJSON(datumns, auto_unbox = TRUE)
  )

  swadlr_request("/api/indicator/data/custom", query)
}

# Transform API response to long-format data frame
transform_response <- function(data, dim_ids) {
  # Handle vector response (single row)
  if (!is.data.frame(data)) {
    data <- as.data.frame(t(unlist(data)), stringsAsFactors = FALSE)
  }

  # API returns: fkDimensionValueIds, geoLevel, geoId, date, value
  # We need: date, value, geography, {dimension columns}

  n_rows <- nrow(data)

  # Extract dimension values
  dim_values_list <- data$fkDimensionValueIds

  # Create dimension columns
  dim_cols <- list()
  for (dim_id in dim_ids) {
    dim_cols[[dim_id]] <- character(n_rows)
  }

  for (i in seq_len(n_rows)) {
    dim_vals <- dim_values_list[[i]]
    if (is.null(dim_vals) || length(dim_vals) == 0) {
      next
    }

    # Map dimension values to dimension IDs
    val_dim_ids <- map_dim_values_to_dim_ids(dim_vals)

    for (j in seq_along(dim_vals)) {
      val <- dim_vals[j]
      val_dim_id <- val_dim_ids[j]
      if (!is.na(val_dim_id) && val_dim_id %in% names(dim_cols)) {
        dim_cols[[val_dim_id]][i] <- val
      }
    }
  }

  # Build result tibble
  result <- tibble::tibble(
    date = as.Date(data$date),
    value = as.numeric(data$value),
    geography = as.character(data$geoId)
  )

  # Add dimension columns
  for (dim_id in dim_ids) {
    result[[dim_id]] <- dim_cols[[dim_id]]
  }

  result
}

# Create empty tibble with correct structure
empty_series_df <- function(dim_ids) {
  result <- tibble::tibble(
    date = as.Date(character(0)),
    value = numeric(0),
    geography = character(0)
  )

  for (dim_id in dim_ids) {
    result[[dim_id]] <- character(0)
  }

  result
}

# Apply dimension value filter to results
apply_dim_filter <- function(result, dim_value_filter) {
  if (is.null(dim_value_filter) || length(dim_value_filter) == 0) {
    return(result)
  }

  for (dim_id in names(dim_value_filter)) {
    filter_vals <- dim_value_filter[[dim_id]]
    if (!is.null(filter_vals) && dim_id %in% names(result)) {
      result <- result[result[[dim_id]] %in% filter_vals, ]
    }
  }

  result
}

# Apply date filter to results
apply_date_filter <- function(result, date) {
  if (is.null(date) || nrow(result) == 0) {
    return(result)
  }

  # Convert to Date
  date <- as.Date(date)

  if (length(date) == 1) {
    # Single date
    result <- result[result$date == date, ]
  } else {
    # Date range
    start_date <- min(date)
    end_date <- max(date)
    result <- result[result$date >= start_date & result$date <= end_date, ]
  }

  result
}
