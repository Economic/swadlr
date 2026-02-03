structure(
  list(
    method = "GET",
    url = "https://data.epi.org/api/test/error",
    status_code = 500L,
    headers = structure(
      list(
        `content-type` = "application/json"
      ),
      class = "httr2_headers"
    ),
    body = charToRaw("{\"message\":\"internal server error\"}"),
    cache = new.env(parent = emptyenv())
  ),
  class = "httr2_response"
)
