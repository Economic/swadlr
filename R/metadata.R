# Internal functions for fetching and caching API metadata

# Fetch topics from the API (with caching)
fetch_topics <- function() {
  if (cache_has("topics")) {
    return(cache_get("topics"))
  }

  result <- swadlr_request("/api/topic/list")
  cache_set("topics", result)
  result
}

# Fetch indicators from the API (with caching)
fetch_indicators <- function() {
  if (cache_has("indicators")) {
    return(cache_get("indicators"))
  }

  result <- swadlr_request("/api/indicator/list")
  cache_set("indicators", result)
  result
}

# Fetch measures from the API (with caching)
fetch_measures <- function() {
  if (cache_has("measures")) {
    return(cache_get("measures"))
  }

  result <- swadlr_request("/api/measure/list")
  cache_set("measures", result)
  result
}

# Fetch dimensions from the API (with caching)
fetch_dimensions <- function() {
  if (cache_has("dimensions")) {
    return(cache_get("dimensions"))
  }

  result <- swadlr_request("/api/dimension/list")
  cache_set("dimensions", result)
  result
}

# Fetch sources from the API (with caching)
fetch_sources <- function() {
  if (cache_has("sources")) {
    return(cache_get("sources"))
  }

  result <- swadlr_request("/api/source/list")
  cache_set("sources", result)
  result
}

# Get availability data for a specific indicator
# Returns list(indicator = data.frame row, availability = list)
# Stops with error if indicator not found
get_indicator_availability <- function(indicator) {
  indicators_raw <- fetch_indicators()
  indicator_idx <- which(indicators_raw$indicator$id == indicator)

  if (length(indicator_idx) == 0) {
    stop(
      "Unknown indicator: \"",
      indicator,
      "\"\n",
      'Use swadl_id_names("indicators") to see available indicators.',
      call. = FALSE
    )
  }

  list(
    indicator = indicators_raw$indicator[indicator_idx, ],
    availability = indicators_raw$availability[[indicator_idx]]
  )
}
