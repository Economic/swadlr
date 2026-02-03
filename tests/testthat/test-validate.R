httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("validate_indicator accepts valid indicator", {
    cache_clear_all()
    expect_invisible(validate_indicator("hourly_wage_percentiles"))
    cache_clear_all()
  })

  test_that("validate_indicator rejects invalid indicator", {
    cache_clear_all()
    expect_error(
      validate_indicator("nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("validate_indicator rejects non-string input", {
    expect_error(
      validate_indicator(123),
      "`indicator` must be a single character string"
    )
    expect_error(
      validate_indicator(c("a", "b")),
      "`indicator` must be a single character string"
    )
  })

  test_that("validate_measure accepts valid measure", {
    cache_clear_all()
    expect_invisible(validate_measure(
      "hourly_wage_percentiles",
      "nominal_wage"
    ))
    cache_clear_all()
  })

  test_that("validate_measure rejects invalid measure", {
    cache_clear_all()
    expect_error(
      validate_measure("hourly_wage_percentiles", "fake_measure"),
      "Measure.*is not available for indicator"
    )
    cache_clear_all()
  })

  test_that("validate_measure rejects non-string input", {
    expect_error(
      validate_measure("hourly_wage_percentiles", 123),
      "`measure` must be a single character string"
    )
  })

  test_that("validate_date_interval accepts valid interval", {
    cache_clear_all()
    expect_invisible(
      validate_date_interval(
        "hourly_wage_percentiles",
        "nominal_wage",
        "year"
      )
    )
    cache_clear_all()
  })

  test_that("validate_date_interval rejects unavailable interval", {
    cache_clear_all()
    expect_error(
      validate_date_interval(
        "hourly_wage_percentiles",
        "nominal_wage",
        "month"
      ),
      "monthly data is not available for indicator"
    )
    cache_clear_all()
  })

  test_that("validate_date_interval rejects invalid input", {
    expect_error(
      validate_date_interval(
        "hourly_wage_percentiles",
        "nominal_wage",
        "daily"
      ),
      'must be either "year" or "month"'
    )
  })

  test_that("validate_geography returns geo_id for valid geography", {
    cache_clear_all()
    result <- validate_geography(
      "hourly_wage_percentiles",
      "nominal_wage",
      "year",
      "national"
    )
    expect_equal(result, "national")
    cache_clear_all()
  })

  test_that("get_geo_level returns correct levels", {
    expect_equal(get_geo_level("national"), "national")
    expect_equal(get_geo_level("regionMidwest"), "region")
    expect_equal(get_geo_level("division09"), "division")
    expect_equal(get_geo_level("state06"), "state")
  })

  test_that("get_geo_level errors on unknown format", {
    expect_error(get_geo_level("invalid_geo"), "Unknown geographic ID format")
    expect_error(get_geo_level("country01"), "Unknown geographic ID format")
  })

  test_that("validate_date accepts NULL", {
    expect_invisible(validate_date(NULL))
  })

  test_that("validate_date accepts valid dates", {
    expect_invisible(validate_date("2024-01-01"))
    expect_invisible(validate_date(c("2020-01-01", "2024-01-01")))
    expect_invisible(validate_date(as.Date("2024-01-01")))
  })

  test_that("validate_date rejects invalid dates", {
    expect_error(validate_date("not-a-date"), "Invalid date format")
    expect_error(validate_date(c("2020", "2021", "2022")), "at most 2 elements")
    expect_error(validate_date(123), "must be NULL")
  })

  test_that("get_available_dimension_values returns correct values", {
    cache_clear_all()
    vals <- get_available_dimension_values(
      "hourly_wage_percentiles",
      "nominal_wage",
      "year",
      "national"
    )
    expect_true("wage_p10" %in% vals)
    expect_true("wage_p50" %in% vals)
    expect_true("gender_female" %in% vals)
    cache_clear_all()
  })

  test_that("get_available_dimension_ids returns correct IDs", {
    cache_clear_all()
    ids <- get_available_dimension_ids(
      "hourly_wage_percentiles",
      "nominal_wage",
      "year",
      "national"
    )
    expect_true("wage_percentile" %in% ids)
    expect_true("gender" %in% ids)
    cache_clear_all()
  })

  test_that("map_dim_values_to_dim_ids maps correctly", {
    cache_clear_all()
    result <- map_dim_values_to_dim_ids(c("wage_p10", "gender_female"))
    expect_equal(result, c("wage_percentile", "gender"))
    cache_clear_all()
  })

  test_that("get_dim_value_lookup builds and caches lookup table", {
    cache_clear_all()
    lookup <- get_dim_value_lookup()
    expect_type(lookup, "list")
    expect_equal(lookup[["wage_p10"]], "wage_percentile")
    expect_equal(lookup[["gender_female"]], "gender")
    expect_true(cache_has("dim_value_lookup"))
    cache_clear_all()
  })

  test_that("map_dim_values_to_dim_ids returns NA for unknown values", {
    cache_clear_all()
    result <- map_dim_values_to_dim_ids(c("wage_p10", "unknown_value"))
    expect_equal(result, c("wage_percentile", NA_character_))
    cache_clear_all()
  })

  test_that("get_dim_value_ids_for_dim returns correct IDs", {
    cache_clear_all()
    vals <- get_dim_value_ids_for_dim("wage_percentile")
    expect_true("wage_p10" %in% vals)
    expect_true("wage_p50" %in% vals)
    cache_clear_all()
  })
})
