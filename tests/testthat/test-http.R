test_that("swadlr_base_url returns correct URL", {
  expect_equal(swadlr_base_url(), "https://data.epi.org")
})

test_that("throttle_if_needed delays when called rapidly", {
  # Temporarily enable throttling with a short interval for this test
  withr::local_options(swadlr.throttle_interval = 0.5)
  cache_clear_all()

  # First call should not delay
  start1 <- Sys.time()
  throttle_if_needed()
  elapsed1 <- as.numeric(difftime(Sys.time(), start1, units = "secs"))
  expect_lt(elapsed1, 0.2)

  # Immediate second call should delay ~0.5 seconds
  start2 <- Sys.time()
  throttle_if_needed()
  elapsed2 <- as.numeric(difftime(Sys.time(), start2, units = "secs"))
  expect_gte(elapsed2, 0.3)

  cache_clear_all()
})

test_that("throttle_if_needed does not delay after interval passes", {
  # Temporarily enable throttling with a short interval for this test
  withr::local_options(swadlr.throttle_interval = 0.3)
  cache_clear_all()

  throttle_if_needed()
  Sys.sleep(0.4)

  # Should not delay since interval has passed
  start <- Sys.time()
  throttle_if_needed()
  elapsed <- as.numeric(difftime(Sys.time(), start, units = "secs"))
  expect_lt(elapsed, 0.2)

  cache_clear_all()
})

test_that("swadlr_request builds correct URL with query params", {
  skip_if_offline()
  skip_on_cran()

  cache_clear_all()

  # Make a simple request to the topic list endpoint
  result <- swadlr_request("/api/topic/list")

  expect_type(result, "list")
  expect_true(length(result) > 0)

  cache_clear_all()
})

test_that("swadlr_request handles connection errors gracefully", {
  # This tests the error handling for invalid URLs
  # We temporarily override the base URL function
  old_fn <- swadlr_base_url
  assignInNamespace(
    "swadlr_base_url",
    function() "https://invalid.domain.test",
    "swadlr"
  )

  cache_clear_all()
  expect_error(swadlr_request("/api/test"), "Failed to connect")

  # Restore original function
  assignInNamespace("swadlr_base_url", old_fn, "swadlr")
  cache_clear_all()
})

httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("swadlr_request handles API error responses", {
    cache_clear_all()
    expect_error(
      swadlr_request("/api/test/error"),
      "HTTP 500"
    )
    cache_clear_all()
  })
})
