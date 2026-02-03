# Shared internal utility functions

# Normalize geo_availability to consistent data frame format
#
# The API can return geo_availability in two formats:
# 1. Data frame with dimensions and geo_ids list columns
# 2. List of objects, each with dimensions and geo_ids fields
#
# This function normalizes both formats to a data frame with:
# - dimensions: list column of dimension ID vectors
# - geo_ids: list column of geography ID vectors
#
# @param geo_avail The geo_availability element from an availability entry
# @return A data frame with dimensions and geo_ids list columns, or NULL if empty
normalize_geo_availability <- function(geo_avail) {
  if (is.null(geo_avail) || length(geo_avail) == 0) {
    return(NULL)
  }

  # Already a data frame - return as-is

  if (is.data.frame(geo_avail)) {
    return(geo_avail)
  }

  # Convert list format to data frame
  n <- length(geo_avail)
  dimensions <- vector("list", n)
  geo_ids <- vector("list", n)

  for (i in seq_len(n)) {
    dimensions[[i]] <- geo_avail[[i]]$dimensions
    geo_ids[[i]] <- geo_avail[[i]]$geo_ids
  }

  data.frame(
    dimensions = I(dimensions),
    geo_ids = I(geo_ids)
  )
}


# Iterate over all dimension values, calling a callback for each
#
# This helper encapsulates the common pattern of iterating over the nested
# structure returned by fetch_dimensions(). For each dimension value, it calls
# the callback function with dim_id, dim_name, val_id, and val_name.
#
# @param dims_raw The result of fetch_dimensions()
# @param callback A function with parameters (dim_id, dim_name, val_id, val_name)
iterate_dimension_values <- function(dims_raw, callback) {
  n_dims <- length(dims_raw$dimension$id)
  for (i in seq_len(n_dims)) {
    dim_id <- dims_raw$dimension$id[i]
    dim_name <- dims_raw$dimension$name[i]
    dim_vals <- dims_raw$dimension_values[[i]]
    n_vals <- length(dim_vals$dimension_value$id)
    for (j in seq_len(n_vals)) {
      callback(
        dim_id = dim_id,
        dim_name = dim_name,
        val_id = dim_vals$dimension_value$id[j],
        val_name = dim_vals$dimension_value$name[j]
      )
    }
  }
}


# Get unique dimension IDs that have values in the given set
#
# Given a set of dimension value IDs, returns the unique dimension IDs
# that contain at least one of those values.
#
# @param dim_value_ids Character vector of dimension value IDs
# @return Character vector of unique dimension IDs
get_dim_ids_from_values <- function(dim_value_ids) {
  if (length(dim_value_ids) == 0) {
    return(character(0))
  }

  dims_raw <- fetch_dimensions()
  dim_ids <- character(0)

  iterate_dimension_values(
    dims_raw,
    function(dim_id, dim_name, val_id, val_name) {
      if (val_id %in% dim_value_ids) {
        dim_ids <<- c(dim_ids, dim_id)
      }
    }
  )

  unique(dim_ids)
}
