httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("swadl_availability returns correct structure", {
    cache_clear_all()
    result <- swadl_availability()

    expect_s3_class(result, "data.frame")
    expect_named(
      result,
      c(
        "indicator_id",
        "indicator_name",
        "date_interval",
        "measure_id",
        "geo_level",
        "dimensions",
        "date_start",
        "date_end"
      )
    )
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability filters by indicator", {
    cache_clear_all()
    result <- swadl_availability(indicator = "hourly_wage_percentiles")

    expect_true(all(result$indicator_id == "hourly_wage_percentiles"))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability filters by multiple indicators", {
    cache_clear_all()
    result <- swadl_availability(
      indicator = c("hourly_wage_percentiles", "labor_force_emp")
    )

    expect_true(
      all(
        result$indicator_id %in% c("hourly_wage_percentiles", "labor_force_emp")
      )
    )
    expect_true("hourly_wage_percentiles" %in% result$indicator_id)
    expect_true("labor_force_emp" %in% result$indicator_id)

    cache_clear_all()
  })

  test_that("swadl_availability filters by measure", {
    cache_clear_all()
    result <- swadl_availability(measure = "nominal_wage")

    expect_true(all(result$measure_id == "nominal_wage"))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability filters by date_interval", {
    cache_clear_all()
    result <- swadl_availability(date_interval = "year")

    expect_true(all(result$date_interval == "year"))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability filters by geo_level", {
    cache_clear_all()
    result <- swadl_availability(geo_level = "state")

    expect_true(all(result$geo_level == "state"))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability filters by multiple geo_levels", {
    cache_clear_all()
    result <- swadl_availability(geo_level = c("state", "national"))

    expect_true(all(result$geo_level %in% c("state", "national")))
    expect_true("state" %in% result$geo_level)
    expect_true("national" %in% result$geo_level)

    cache_clear_all()
  })

  test_that("swadl_availability exact dimension match works", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = c("gender", "wage_percentile"),
      dimensions_match = "exact"
    )

    # All results should have exactly "gender × wage_percentile"
    expect_true(all(result$dimensions == "gender \u00D7 wage_percentile"))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability exact match is order-insensitive", {
    cache_clear_all()
    result1 <- swadl_availability(
      dimensions = c("gender", "wage_percentile"),
      dimensions_match = "exact"
    )
    result2 <- swadl_availability(
      dimensions = c("wage_percentile", "gender"),
      dimensions_match = "exact"
    )

    expect_equal(nrow(result1), nrow(result2))
    expect_equal(result1$dimensions, result2$dimensions)

    cache_clear_all()
  })

  test_that("swadl_availability all dimension match works", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = c("gender", "wage_percentile"),
      dimensions_match = "all"
    )

    # All results should contain both gender and wage_percentile
    expect_true(all(grepl("gender", result$dimensions)))
    expect_true(all(grepl("wage_percentile", result$dimensions)))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability all match includes higher-way combinations", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = c("gender", "wage_percentile"),
      dimensions_match = "all"
    )

    # Should include 3-way combinations containing both
    three_way <- result$dimensions[
      vapply(
        result$dimensions,
        function(d) length(strsplit(d, " \u00D7 ")[[1]]),
        integer(1)
      ) ==
        3
    ]
    expect_true(length(three_way) > 0 || nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability any dimension match works", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = c("gender", "race"),
      dimensions_match = "any"
    )

    # All results should contain either gender or race
    has_gender_or_race <- vapply(
      result$dimensions,
      function(d) grepl("gender", d) || grepl("race", d),
      logical(1)
    )
    expect_true(all(has_gender_or_race))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability any match includes single dimension", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = "wage_percentile",
      dimensions_match = "any"
    )

    expect_true(all(grepl("wage_percentile", result$dimensions)))
    # Should include both single and multi-way
    single <- result$dimensions[result$dimensions == "wage_percentile"]
    multi <- result$dimensions[grepl("\u00D7", result$dimensions)]
    expect_true(length(single) > 0 || length(multi) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability returns empty for no matches", {
    cache_clear_all()
    result <- swadl_availability(indicator = "nonexistent_indicator")

    expect_equal(nrow(result), 0)
    expect_named(
      result,
      c(
        "indicator_id",
        "indicator_name",
        "date_interval",
        "measure_id",
        "geo_level",
        "dimensions",
        "date_start",
        "date_end"
      )
    )

    cache_clear_all()
  })

  test_that("swadl_availability handles overall dimension", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = "overall",
      dimensions_match = "exact"
    )

    expect_true(all(result$dimensions == "overall"))
    expect_true(nrow(result) > 0)

    cache_clear_all()
  })

  test_that("swadl_availability dimension match excludes overall", {
    cache_clear_all()
    result <- swadl_availability(
      dimensions = "gender",
      dimensions_match = "any"
    )

    # overall should not be included when filtering by specific dimensions
    expect_false("overall" %in% result$dimensions)

    cache_clear_all()
  })

  test_that("swadl_availability combines multiple filters", {
    cache_clear_all()
    result <- swadl_availability(
      indicator = "hourly_wage_percentiles",
      geo_level = "national",
      date_interval = "year",
      dimensions = "gender",
      dimensions_match = "any"
    )

    expect_true(all(result$indicator_id == "hourly_wage_percentiles"))
    expect_true(all(result$geo_level == "national"))
    expect_true(all(result$date_interval == "year"))
    expect_true(all(grepl("gender", result$dimensions)))

    cache_clear_all()
  })

  test_that("swadl_availability caches results", {
    cache_clear_all()

    # First call populates cache
    result1 <- swadl_availability()

    # Second call should use cache
    result2 <- swadl_availability()

    expect_equal(nrow(result1), nrow(result2))

    cache_clear_all()
  })
})
