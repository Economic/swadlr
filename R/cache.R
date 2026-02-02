# Internal cache environment for storing metadata and rate limiting
.swadlr_cache <- new.env(parent = emptyenv())

# Get a value from the cache
cache_get <- function(key) {
  .swadlr_cache[[key]]
}

# Set a value in the cache
cache_set <- function(key, value) {
  .swadlr_cache[[key]] <- value
  invisible(value)
}

# Check if a key exists in the cache
cache_has <- function(key) {
  exists(key, envir = .swadlr_cache, inherits = FALSE)
}

# Clear all cached data (internal helper)
cache_clear_all <- function() {
  rm(list = ls(envir = .swadlr_cache), envir = .swadlr_cache)
  invisible()
}

#' Clear the swadlr cache
#'
#' Clears all cached metadata from the current R session. This includes cached
#' topics, indicators, measures, dimensions, and sources. Use this function if
#' you want to refresh metadata from the API.
#'
#' @return Invisible `NULL`.
#'
#' @export
#' @examples
#' \donttest{
#' clear_swadlr_cache()
#' }
clear_swadlr_cache <- function() {
  cache_clear_all()
  invisible()
}
