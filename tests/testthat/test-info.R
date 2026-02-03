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

    # cli output needs special capture - use cli's built-in capture
    output <- cli::cli_fmt(print(info))
    expect_true(any(grepl("Hourly wage percentiles", output)))
    expect_true(any(grepl("Indicator", output)))
    expect_true(any(grepl("Measures", output)))
    expect_true(any(grepl("Dimensions by geography", output)))
    expect_true(any(grepl("Dates", output)))
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
})
