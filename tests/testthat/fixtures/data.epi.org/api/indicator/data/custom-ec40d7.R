structure(
  list(
    method = "GET",
    url = "https://data.epi.org/api/indicator/data/custom?indicatorId=hourly_wage_percentiles&dateInterval=year&measureId=nominal_wage&datumns=%5B%7B%22geoId%22%3A%22national%22%2C%22dimensionValues%22%3A%22wage_p50%22%7D%5D",
    status_code = 500L,
    headers = structure(
      list(
        `content-type` = "application/json",
        `content-length` = "278",
        date = "Mon, 02 Feb 2026 18:17:33 GMT",
        `apigw-requestid` = "YKmJqggH4osEJNg=",
        `x-cache` = "Error from cloudfront",
        via = "1.1 312f8b716ad43246758aa8031a8e0342.cloudfront.net (CloudFront)",
        `x-amz-cf-pop` = "IAD55-P5",
        `x-amz-cf-id` = "51UsevD22uaDxe2_RDa1h1FLrtUa5rr86k2uZCIp96woSZ4r40F4Kg==",
        vary = "Origin"
      ),
      class = "httr2_headers"
    ),
    body = charToRaw(
      "{\"url\":\"/api/indicator/data/custom?dateInterval=year&datumns=%5B%7B%22geoId%22:%22national%22,%22dimensionValues%22:%22wage_p50%22%7D%5D&indicatorId=hourly_wage_percentiles&measureId=nominal_wage\",\"statusCode\":500,\"statusMessage\":\"\",\"message\":\"internal server error\",\"stack\":\"\"}"
    ),
    timing = c(
      redirect = 0,
      namelookup = 1.8e-05,
      connect = 0,
      pretransfer = 7.4e-05,
      starttransfer = 0.516489,
      total = 0.516505
    ),
    cache = new.env(parent = emptyenv())
  ),
  class = "httr2_response"
)
