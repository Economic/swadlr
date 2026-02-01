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
