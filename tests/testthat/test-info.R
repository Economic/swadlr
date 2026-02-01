httptest2::with_mock_dir("fixtures", {
  test_that("get_swadl_info returns correct structure", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    expect_s3_class(info, "swadlr_indicator_info")
    expect_named(
      info,
      c(
        "id",
        "name",
        "topic",
        "updated",
        "measures",
        "dimensions",
        "availability",
        "sources"
      )
    )

    cache_clear_all()
  })

  test_that("get_swadl_info returns correct indicator metadata", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    expect_equal(info$id, "hourly_wage_percentiles")
    expect_equal(info$name, "Hourly wage percentiles")
    expect_equal(info$topic, "wages")
    expect_s3_class(info$updated, "Date")

    cache_clear_all()
  })

  test_that("get_swadl_info returns correct measures", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    expect_s3_class(info$measures, "data.frame")
    expect_named(info$measures, c("id", "name", "format"))
    expect_true("real_wage_2024" %in% info$measures$id)

    cache_clear_all()
  })

  test_that("get_swadl_info returns correct dimensions", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    expect_s3_class(info$dimensions, "data.frame")
    expect_named(
      info$dimensions,
      c(
        "dimension_id",
        "dimension_name",
        "value_id",
        "value_name"
      )
    )
    expect_true("wage_p10" %in% info$dimensions$value_id)
    expect_true("gender_female" %in% info$dimensions$value_id)

    cache_clear_all()
  })

  test_that("get_swadl_info returns correct availability", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    expect_type(info$availability, "list")
    expect_named(
      info$availability,
      c("date_range", "geo_levels", "geo_availability")
    )

    expect_type(info$availability$date_range, "list")
    expect_true("national" %in% info$availability$geo_levels)

    cache_clear_all()
  })

  test_that("get_swadl_info returns correct sources", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    expect_s3_class(info$sources, "data.frame")
    expect_named(info$sources, c("measure_id", "source", "url"))
    expect_true(nrow(info$sources) >= 1)

    cache_clear_all()
  })

  test_that("get_swadl_info errors on unknown indicator", {
    cache_clear_all()
    expect_error(
      get_swadl_info("nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("get_swadl_info errors on invalid input", {
    expect_error(
      get_swadl_info(123),
      "`indicator` must be a single character string"
    )
    expect_error(
      get_swadl_info(c("a", "b")),
      "`indicator` must be a single character string"
    )
  })

  test_that("print.swadlr_indicator_info produces output", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    output <- capture.output(print(info))
    expect_true(any(grepl("hourly_wage_percentiles", output)))
    expect_true(any(grepl("Hourly wage percentiles", output)))
    expect_true(any(grepl("Available measures", output)))
    expect_true(any(grepl("Available dimensions", output)))
    expect_true(any(grepl("Date range", output)))
    expect_true(any(grepl("Geographic availability", output)))
    expect_true(any(grepl("Sources", output)))

    cache_clear_all()
  })

  test_that("print.swadlr_indicator_info returns invisibly", {
    cache_clear_all()
    info <- get_swadl_info("hourly_wage_percentiles")

    result <- withVisible(print(info))
    expect_false(result$visible)
    expect_identical(result$value, info)

    cache_clear_all()
  })

  test_that("get_swadl_info works for labor_force_emp indicator", {
    cache_clear_all()
    info <- get_swadl_info("labor_force_emp")

    expect_equal(info$id, "labor_force_emp")
    expect_equal(info$topic, "labor_force")
    expect_true("percent_emp" %in% info$measures$id)
    expect_true(!is.null(info$availability$date_range$month))

    cache_clear_all()
  })
})
