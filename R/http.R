# HTTP utilities for making API requests

# Base URL for the EPI SWADL API
swadlr_base_url <- function() {
  "https://data.epi.org"
}

# Throttle requests to avoid overwhelming the API
# Delays if less than 2 seconds since last request
throttle_if_needed <- function() {
  last_request <- cache_get("last_request")
  if (!is.null(last_request)) {
    elapsed <- as.numeric(difftime(Sys.time(), last_request, units = "secs"))
    if (elapsed < 2) {
      Sys.sleep(2 - elapsed)
    }
  }
  cache_set("last_request", Sys.time())
}

# Make a request to the SWADL API
#
# @param endpoint API endpoint (e.g., "/api/topic/list")
# @param query Named list of query parameters
# @return Parsed JSON response
swadlr_request <- function(endpoint, query = list()) {
  throttle_if_needed()

  url <- paste0(swadlr_base_url(), endpoint)

  req <- httr2::request(url)
  req <- httr2::req_url_query(req, !!!query)
  req <- httr2::req_user_agent(req, "swadlr R package")

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) {
      stop(
        "Failed to connect to SWADL API at ",
        url,
        "\n",
        "Error: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  if (httr2::resp_status(resp) != 200) {
    stop(
      "SWADL API request failed with status ",
      httr2::resp_status(resp),
      "\n",
      "URL: ",
      url,
      call. = FALSE
    )
  }

  body <- httr2::resp_body_string(resp)
  jsonlite::fromJSON(body, simplifyVector = TRUE)
}
