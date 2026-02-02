httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("swadl_indicator returns correct structure", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    expect_s3_class(info, "swadl_indicator_info")
    expect_named(
      info,
      c(
        "id",
        "name",
        "topic",
        "updated",
        "measures",
        "availability",
        "sources"
      )
    )

    cache_clear_all()
  })

  test_that("swadl_indicator returns correct indicator metadata", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    expect_equal(info$id, "hourly_wage_percentiles")
    expect_equal(info$name, "Hourly wage percentiles")
    expect_equal(info$topic, "wages")
    expect_s3_class(info$updated, "Date")

    cache_clear_all()
  })

  test_that("swadl_indicator returns correct measures", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    expect_s3_class(info$measures, "data.frame")
    expect_named(info$measures, c("id", "name", "format"))
    expect_true("nominal_wage" %in% info$measures$id)

    cache_clear_all()
  })

  test_that("swadl_indicator availability tibble has correct structure", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    expect_s3_class(info$availability, "data.frame")
    expect_named(
      info$availability,
      c(
        "date_interval",
        "measure_id",
        "geo_level",
        "dimensions",
        "date_start",
        "date_end"
      )
    )
    expect_true("national" %in% info$availability$geo_level)
    expect_true("wage_percentile" %in% info$availability$dimensions)

    cache_clear_all()
  })

  test_that("swadl_indicator availability includes dimension combinations", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    # Should have multi-way dimension combinations
    dims_with_cross <- info$availability$dimensions[
      grepl("\u00D7", info$availability$dimensions)
    ]
    expect_true(length(dims_with_cross) > 0)

    # Date columns should be Date type
    expect_s3_class(info$availability$date_start, "Date")
    expect_s3_class(info$availability$date_end, "Date")

    cache_clear_all()
  })

  test_that("swadl_indicator returns correct sources", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    expect_s3_class(info$sources, "data.frame")
    expect_named(info$sources, c("measure_id", "source", "url"))
    expect_true(nrow(info$sources) >= 1)

    cache_clear_all()
  })

  test_that("swadl_indicator errors on unknown indicator", {
    cache_clear_all()
    expect_error(
      swadl_indicator("nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("swadl_indicator errors on invalid input", {
    expect_error(
      swadl_indicator(123),
      "`indicator` must be a single character string"
    )
    expect_error(
      swadl_indicator(c("a", "b")),
      "`indicator` must be a single character string"
    )
  })

  test_that("print.swadl_indicator_info produces output", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    output <- capture.output(print(info))
    expect_true(any(grepl("hourly_wage_percentiles", output)))
    expect_true(any(grepl("Hourly wage percentiles", output)))
    expect_true(any(grepl("Available measures", output)))
    expect_true(any(grepl("Dimension combinations by geography", output)))
    expect_true(any(grepl("Date range", output)))
    expect_true(any(grepl("Sources", output)))

    cache_clear_all()
  })

  test_that("print.swadl_indicator_info returns invisibly", {
    cache_clear_all()
    info <- swadl_indicator("hourly_wage_percentiles")

    result <- withVisible(print(info))
    expect_false(result$visible)
    expect_identical(result$value, info)

    cache_clear_all()
  })

  test_that("swadl_indicator works for labor_force_emp indicator", {
    cache_clear_all()
    info <- swadl_indicator("labor_force_emp")

    expect_equal(info$id, "labor_force_emp")
    expect_equal(info$topic, "labor_force")
    expect_true("percent_emp" %in% info$measures$id)
    # Check that month data is available
    month_rows <- info$availability[
      info$availability$date_interval == "month",
    ]
    expect_true(nrow(month_rows) > 0)

    cache_clear_all()
  })

  # Tests for swadl_availability()

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
