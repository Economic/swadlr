httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("parse_dimension handles 'overall'", {
    cache_clear_all()
    result <- parse_dimension(
      "overall",
      "hourly_wage_percentiles",
      "real_wage_2024",
      "year",
      "national",
      "national"
    )

    expect_equal(result$endpoint, "list")
    expect_equal(result$params$dimensionValueIds, "overall")
    expect_equal(result$dim_ids, "overall")
    cache_clear_all()
  })

  test_that("parse_dimension handles single dimension ID", {
    cache_clear_all()
    result <- parse_dimension(
      "wage_percentile",
      "hourly_wage_percentiles",
      "real_wage_2024",
      "year",
      "national",
      "national"
    )

    expect_equal(result$endpoint, "list")
    expect_equal(result$params$dimensionId, "wage_percentile")
    expect_equal(result$dim_ids, "wage_percentile")
    cache_clear_all()
  })

  test_that("parse_dimension handles list with single dimension", {
    cache_clear_all()
    result <- parse_dimension(
      list("wage_percentile"),
      "hourly_wage_percentiles",
      "real_wage_2024",
      "year",
      "national",
      "national"
    )

    expect_equal(result$endpoint, "list")
    expect_equal(result$params$dimensionId, "wage_percentile")
    cache_clear_all()
  })

  test_that("parse_dimension handles list with specific value", {
    cache_clear_all()
    result <- parse_dimension(
      list("wage_percentile" = "wage_p50"),
      "hourly_wage_percentiles",
      "real_wage_2024",
      "year",
      "national",
      "national"
    )

    expect_equal(result$endpoint, "list")
    expect_equal(result$params$dimensionValueIds, "wage_p50")
    expect_equal(result$dim_value_filter$wage_percentile, "wage_p50")
    cache_clear_all()
  })

  test_that("parse_dimension handles list with multiple values", {
    cache_clear_all()
    result <- parse_dimension(
      list("wage_percentile" = c("wage_p10", "wage_p50")),
      "hourly_wage_percentiles",
      "real_wage_2024",
      "year",
      "national",
      "national"
    )

    expect_equal(result$endpoint, "list")
    expect_equal(result$params$dimensionId, "wage_percentile")
    expect_equal(
      result$dim_value_filter$wage_percentile,
      c("wage_p10", "wage_p50")
    )
    cache_clear_all()
  })

  test_that("parse_dimension handles cross-dimensional queries", {
    cache_clear_all()
    result <- parse_dimension(
      list("gender" = "gender_male", "age_group"),
      "labor_force_emp",
      "percent_emp",
      "month",
      "national",
      "national"
    )

    expect_equal(result$endpoint, "custom")
    expect_true("datumns" %in% names(result$params))
    expect_true("gender" %in% result$dim_ids)
    expect_true("age_group" %in% result$dim_ids)
    cache_clear_all()
  })

  test_that("parse_dimension rejects invalid dimension", {
    cache_clear_all()
    expect_error(
      parse_dimension(
        "nonexistent",
        "hourly_wage_percentiles",
        "real_wage_2024",
        "year",
        "national",
        "national"
      ),
      "Dimension.*is not available for this indicator"
    )
    cache_clear_all()
  })

  test_that("parse_dimension rejects invalid dimension value", {
    cache_clear_all()
    expect_error(
      parse_dimension(
        list("wage_percentile" = "wage_p99"),
        "hourly_wage_percentiles",
        "real_wage_2024",
        "year",
        "national",
        "national"
      ),
      "Dimension value\\(s\\) not available"
    )
    cache_clear_all()
  })

  test_that("parse_dimension rejects empty list", {
    expect_error(
      parse_dimension(
        list(),
        "hourly_wage_percentiles",
        "real_wage_2024",
        "year",
        "national",
        "national"
      ),
      "cannot be empty"
    )
  })

  test_that("parse_dimension rejects invalid input types", {
    expect_error(
      parse_dimension(
        123,
        "hourly_wage_percentiles",
        "real_wage_2024",
        "year",
        "national",
        "national"
      ),
      "must be"
    )
  })

  test_that("build_datumns creates correct structure", {
    cache_clear_all()
    datumns <- build_datumns(
      c("gender", "age_group"),
      list(gender = "gender_male", age_group = NULL),
      "national",
      c("gender_male", "gender_female", "age_16_24", "age_25_54")
    )

    expect_type(datumns, "list")
    expect_true(length(datumns) > 0)
    expect_true(all(sapply(datumns, \(x) x$geoId == "national")))
    expect_true(all(sapply(datumns, \(x) "dimensionValues" %in% names(x))))
    cache_clear_all()
  })
})
