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
      return(parse_dimension_overall(avail_dim_values))
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
parse_dimension_overall <- function(avail_dim_values) {
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
    params = list(dimensionId = "overall"),
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

  # Get all values for this dimension that are available for the indicator
  all_vals <- get_dim_value_ids_for_dim(dimension)
  available_vals <- intersect(all_vals, avail_dim_values)

  # Build datumns array with one entry per dimension value
  datumns <- lapply(available_vals, function(val) {
    list(geoId = geo_id, dimensionValues = list(val))
  })

  list(
    endpoint = "custom",
    params = list(datumns = datumns),
    dim_ids = dimension,
    dim_value_filter = NULL
  )
}

# Validate and process an unnamed list element
# Returns the dimension ID if valid
validate_unnamed_dimension_element <- function(elem, avail_dim_ids) {
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
  elem
}

# Validate and process a named list element
# Returns the validated dimension values
validate_named_dimension_element <- function(
  name,
  values,
  avail_dim_ids,
  avail_dim_values
) {
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
  if (!is.character(values)) {
    stop("Dimension values must be character strings.", call. = FALSE)
  }

  dim_vals_available <- get_dim_value_ids_for_dim(name)
  dim_vals_in_indicator <- intersect(dim_vals_available, avail_dim_values)
  invalid <- setdiff(values, dim_vals_in_indicator)

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
  values
}

# Validate that at most one dimension requests all values
validate_all_values_constraint <- function(dim_value_filter) {
  all_values_dims <- names(which(vapply(
    dim_value_filter,
    is.null,
    logical(1)
  )))

  if (length(all_values_dims) > 1) {
    stop(
      "Only one dimension can request all values. ",
      "The following dimensions are requesting all values: ",
      paste(all_values_dims, collapse = ", "),
      "\n",
      "Specify values for all but one dimension, e.g.:\n",
      "  dimension = list(\"",
      all_values_dims[1],
      "\" = \"value\", \"",
      all_values_dims[2],
      "\")",
      call. = FALSE
    )
  }
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

  for (i in seq_along(dimension)) {
    elem <- dimension[[i]]
    name <- dim_names[i]

    if (name == "" || is.null(name)) {
      dim_id <- validate_unnamed_dimension_element(elem, avail_dim_ids)
      dim_ids <- c(dim_ids, dim_id)
      dim_value_filter[dim_id] <- list(NULL)
    } else {
      values <- validate_named_dimension_element(
        name,
        elem,
        avail_dim_ids,
        avail_dim_values
      )
      dim_ids <- c(dim_ids, name)
      dim_value_filter[[name]] <- values
    }
  }

  dim_ids <- unique(dim_ids)
  validate_all_values_constraint(dim_value_filter)

  datumns <- build_datumns(
    dim_ids,
    dim_value_filter,
    geo_id,
    avail_dim_values
  )

  list(
    endpoint = "custom",
    params = list(datumns = datumns),
    dim_ids = dim_ids,
    dim_value_filter = dim_value_filter
  )
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
    # dimensionValues must be a list so it serializes as a JSON array
    list(
      geoId = geo_id,
      dimensionValues = as.list(unname(as.character(row)))
    )
  })

  datumns
}
