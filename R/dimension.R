# Dimension argument parsing and expansion

# Parse the dimension argument and return query parameters
#
# Returns a list with:
#   - endpoint: "list" or "custom"
#   - params: list of query parameters for the endpoint
#   - dim_ids: character vector of dimension IDs being queried
#   - dim_value_ids: list of dimension value IDs to filter on (NULL = all)
parse_dimension <- function(
  dimension,
  indicator,
  measure,
  date_interval,
  geo_level,
  geo_id
) {
  # Get available dimension values
  avail_dim_values <- get_available_dimension_values(
    indicator,
    measure,
    date_interval,
    geo_level
  )
  avail_dim_ids <- get_available_dimension_ids(
    indicator,
    measure,
    date_interval,
    geo_level
  )

  # Case 1: dimension = "overall"
  if (is.character(dimension) && length(dimension) == 1) {
    if (dimension == "overall") {
      return(parse_dimension_overall(geo_id, avail_dim_values))
    }

    # Case 2: dimension = "dimension_id" (single dimension, all values)
    return(parse_dimension_single(
      dimension,
      geo_id,
      avail_dim_ids,
      avail_dim_values
    ))
  }

  # Case 3: dimension = list(...)
  if (is.list(dimension)) {
    return(parse_dimension_list(
      dimension,
      geo_id,
      avail_dim_ids,
      avail_dim_values
    ))
  }

  stop(
    "`dimension` must be \"overall\", a dimension ID, or a list.",
    call. = FALSE
  )
}

# Parse dimension = "overall"
parse_dimension_overall <- function(geo_id, avail_dim_values) {
  # Check if "overall" is available
  if (!("overall" %in% avail_dim_values)) {
    stop(
      "\"overall\" dimension value is not available for this indicator.\n",
      "Use a specific dimension instead.",
      call. = FALSE
    )
  }

  list(
    endpoint = "list",
    params = list(dimensionValueIds = "overall"),
    dim_ids = "overall",
    dim_value_filter = list(overall = "overall")
  )
}

# Parse dimension = "dimension_id" (single dimension, all values)
parse_dimension_single <- function(
  dimension,
  geo_id,
  avail_dim_ids,
  avail_dim_values
) {
  if (!(dimension %in% avail_dim_ids)) {
    stop(
      "Dimension \"",
      dimension,
      "\" is not available for this indicator.\n",
      "Available dimensions: ",
      paste(avail_dim_ids, collapse = ", "),
      call. = FALSE
    )
  }

  list(
    endpoint = "list",
    params = list(dimensionId = dimension),
    dim_ids = dimension,
    dim_value_filter = NULL
  )
}

# Parse dimension = list(...)
parse_dimension_list <- function(
  dimension,
  geo_id,
  avail_dim_ids,
  avail_dim_values
) {
  if (length(dimension) == 0) {
    stop("`dimension` list cannot be empty.", call. = FALSE)
  }

  dim_names <- names(dimension)
  if (is.null(dim_names)) {
    dim_names <- rep("", length(dimension))
  }

  # Collect dimension IDs and values
  dim_ids <- character(0)
  dim_value_filter <- list()
  needs_custom <- FALSE

  for (i in seq_along(dimension)) {
    elem <- dimension[[i]]
    name <- dim_names[i]

    if (name == "" || is.null(name)) {
      # Unnamed element: dimension ID, all values
      if (!is.character(elem) || length(elem) != 1) {
        stop(
          "Unnamed list elements must be single dimension ID strings.",
          call. = FALSE
        )
      }
      if (!(elem %in% avail_dim_ids)) {
        stop(
          "Dimension \"",
          elem,
          "\" is not available for this indicator.\n",
          "Available dimensions: ",
          paste(avail_dim_ids, collapse = ", "),
          call. = FALSE
        )
      }
      dim_ids <- c(dim_ids, elem)
      dim_value_filter[[elem]] <- NULL
    } else {
      # Named element: filter to specific value(s)
      if (!(name %in% avail_dim_ids)) {
        stop(
          "Dimension \"",
          name,
          "\" is not available for this indicator.\n",
          "Available dimensions: ",
          paste(avail_dim_ids, collapse = ", "),
          call. = FALSE
        )
      }
      if (!is.character(elem)) {
        stop("Dimension values must be character strings.", call. = FALSE)
      }

      # Validate dimension values
      dim_vals_available <- get_dim_value_ids_for_dim(name)
      dim_vals_in_indicator <- intersect(dim_vals_available, avail_dim_values)
      invalid <- setdiff(elem, dim_vals_in_indicator)
      if (length(invalid) > 0) {
        stop(
          "Dimension value(s) not available: ",
          paste(invalid, collapse = ", "),
          "\n",
          "Available values for \"",
          name,
          "\": ",
          paste(dim_vals_in_indicator, collapse = ", "),
          call. = FALSE
        )
      }

      dim_ids <- c(dim_ids, name)
      dim_value_filter[[name]] <- elem
    }
  }

  dim_ids <- unique(dim_ids)

  # Determine endpoint
  if (length(dim_ids) > 1) {
    needs_custom <- TRUE
  }

  if (needs_custom) {
    # Cross-dimensional: use custom endpoint
    datumns <- build_datumns(
      dim_ids,
      dim_value_filter,
      geo_id,
      avail_dim_values
    )
    return(list(
      endpoint = "custom",
      params = list(datumns = datumns),
      dim_ids = dim_ids,
      dim_value_filter = dim_value_filter
    ))
  }

  # Single dimension
  dim_id <- dim_ids[1]
  filter <- dim_value_filter[[dim_id]]

  if (is.null(filter)) {
    # All values for single dimension
    return(list(
      endpoint = "list",
      params = list(dimensionId = dim_id),
      dim_ids = dim_id,
      dim_value_filter = NULL
    ))
  }

  if (length(filter) == 1) {
    # Single value
    return(list(
      endpoint = "list",
      params = list(dimensionValueIds = filter),
      dim_ids = dim_id,
      dim_value_filter = dim_value_filter
    ))
  }

  # Multiple values for single dimension: query all, filter client-side
  # Or we can use custom endpoint with explicit values
  return(list(
    endpoint = "list",
    params = list(dimensionId = dim_id),
    dim_ids = dim_id,
    dim_value_filter = dim_value_filter
  ))
}

# Build datumns array for custom endpoint
build_datumns <- function(dim_ids, dim_value_filter, geo_id, avail_dim_values) {
  # Get all dimension value combinations from availability
  # that match the requested dimensions

  # Get the available dimension value combinations
  # These are stored as arrays in avail_dim_values
  # We need to expand the dimension IDs to dimension value IDs

  # First, get all possible values for each dimension
  dim_values_by_dim <- list()
  for (dim_id in dim_ids) {
    filter <- dim_value_filter[[dim_id]]
    if (is.null(filter)) {
      # All values for this dimension that are available
      all_vals <- get_dim_value_ids_for_dim(dim_id)
      available_vals <- intersect(all_vals, avail_dim_values)
      dim_values_by_dim[[dim_id]] <- available_vals
    } else {
      dim_values_by_dim[[dim_id]] <- filter
    }
  }

  # Generate all combinations
  combinations <- expand.grid(dim_values_by_dim, stringsAsFactors = FALSE)

  # Filter to only combinations that exist in availability
  # (This may need refinement based on actual availability structure)

  # Build datumns array
  datumns <- lapply(seq_len(nrow(combinations)), function(i) {
    row <- combinations[i, ]
    list(
      geoId = geo_id,
      dimensionValues = unname(as.character(row))
    )
  })

  datumns
}
