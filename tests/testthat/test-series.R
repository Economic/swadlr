httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("get_swadl returns correct structure", {
    cache_clear_all()
    df <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      dimension = list("wage_percentile" = "wage_p50")
    )

    expect_s3_class(df, "data.frame")
    expect_true("date" %in% names(df))
    expect_true("value" %in% names(df))
    expect_true("geography" %in% names(df))
    expect_true("wage_percentile" %in% names(df))
    cache_clear_all()
  })

  test_that("get_swadl with specific dimension value", {
    cache_clear_all()
    df <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      dimension = list("wage_percentile" = "wage_p50")
    )

    expect_s3_class(df$date, "Date")
    expect_type(df$value, "double")
    expect_equal(unique(df$geography), "national")
    expect_equal(unique(df$wage_percentile), "wage_p50")
    cache_clear_all()
  })

  test_that("get_swadl with single dimension", {
    cache_clear_all()
    df <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      dimension = "wage_percentile"
    )

    expect_true("wage_percentile" %in% names(df))
    expect_true("wage_p10" %in% df$wage_percentile)
    expect_true("wage_p50" %in% df$wage_percentile)
    cache_clear_all()
  })

  test_that("get_swadl with cross-dimensional query", {
    cache_clear_all()
    df <- get_swadl(
      "labor_force_emp",
      "percent_emp",
      date_interval = "year",
      dimension = list("gender" = "gender_male", "age_group")
    )

    expect_true("gender" %in% names(df))
    expect_true("age_group" %in% names(df))
    expect_equal(unique(df$gender), "gender_male")
    expect_true("age_16_24" %in% df$age_group)
    expect_true("age_25_54" %in% df$age_group)
    cache_clear_all()
  })

  test_that("get_swadl date filtering with single date", {
    cache_clear_all()
    df_all <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      dimension = list("wage_percentile" = "wage_p50")
    )
    df_filtered <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      dimension = list("wage_percentile" = "wage_p50"),
      date = "2024-01-01"
    )

    expect_true(nrow(df_filtered) <= nrow(df_all))
    expect_true(all(df_filtered$date == as.Date("2024-01-01")))
    cache_clear_all()
  })

  test_that("get_swadl date filtering with range", {
    cache_clear_all()
    df <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      dimension = list("wage_percentile" = "wage_p50"),
      date = c("2020-01-01", "2024-01-01")
    )

    expect_true(all(df$date >= as.Date("2020-01-01")))
    expect_true(all(df$date <= as.Date("2024-01-01")))
    cache_clear_all()
  })

  test_that("get_swadl accepts geography as name", {
    cache_clear_all()
    df <- get_swadl(
      "hourly_wage_percentiles",
      "nominal_wage",
      geography = "national",
      dimension = list("wage_percentile" = "wage_p50")
    )

    expect_equal(unique(df$geography), "national")
    cache_clear_all()
  })

  test_that("get_swadl validates indicator", {
    expect_error(
      get_swadl(
        "nonexistent",
        "nominal_wage",
        dimension = list("wage_percentile" = "wage_p50")
      ),
      "Unknown indicator"
    )
  })

  test_that("get_swadl validates measure", {
    cache_clear_all()
    expect_error(
      get_swadl(
        "hourly_wage_percentiles",
        "fake_measure",
        dimension = list("wage_percentile" = "wage_p50")
      ),
      "Measure.*is not available for indicator"
    )
    cache_clear_all()
  })

  test_that("get_swadl validates date_interval", {
    cache_clear_all()
    expect_error(
      get_swadl(
        "hourly_wage_percentiles",
        "nominal_wage",
        date_interval = "month",
        dimension = list("wage_percentile" = "wage_p50")
      ),
      "monthly data is not available for indicator"
    )
    cache_clear_all()
  })

  test_that("get_swadl validates dimension", {
    cache_clear_all()
    expect_error(
      get_swadl(
        "hourly_wage_percentiles",
        "nominal_wage",
        dimension = "nonexistent"
      ),
      "Dimension.*is not available for this indicator"
    )
    cache_clear_all()
  })

  test_that("transform_response handles single row", {
    data <- list(
      fkDimensionValueIds = list("wage_p10"),
      geoLevel = "national",
      geoId = "national",
      date = "2024-01-01",
      value = 15.25
    )

    result <- transform_response(data, "wage_percentile")
    expect_s3_class(result, "data.frame")
    expect_equal(nrow(result), 1)
  })

  test_that("empty_series_df creates correct structure", {
    df <- empty_series_df(c("wage_percentile", "gender"))

    expect_s3_class(df, "data.frame")
    expect_equal(nrow(df), 0)
    expect_true(all(
      c("date", "value", "geography", "wage_percentile", "gender") %in%
        names(df)
    ))
  })

  test_that("apply_dim_filter filters correctly", {
    df <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-01")),
      value = c(10, 20),
      geography = c("national", "national"),
      wage_percentile = c("wage_p10", "wage_p50"),
      stringsAsFactors = FALSE
    )

    result <- apply_dim_filter(df, list(wage_percentile = "wage_p50"))
    expect_equal(nrow(result), 1)
    expect_equal(result$wage_percentile, "wage_p50")
  })

  test_that("apply_date_filter with single date", {
    df <- data.frame(
      date = as.Date(c("2023-01-01", "2024-01-01")),
      value = c(10, 20),
      stringsAsFactors = FALSE
    )

    result <- apply_date_filter(df, "2024-01-01")
    expect_equal(nrow(result), 1)
    expect_equal(result$date, as.Date("2024-01-01"))
  })

  test_that("apply_date_filter with range", {
    df <- data.frame(
      date = as.Date(c("2022-01-01", "2023-01-01", "2024-01-01")),
      value = c(10, 15, 20),
      stringsAsFactors = FALSE
    )

    result <- apply_date_filter(df, c("2023-01-01", "2024-01-01"))
    expect_equal(nrow(result), 2)
    expect_true(all(result$date >= as.Date("2023-01-01")))
  })

  test_that("apply_date_filter with NULL returns unchanged", {
    df <- data.frame(
      date = as.Date(c("2023-01-01", "2024-01-01")),
      value = c(10, 20),
      stringsAsFactors = FALSE
    )

    result <- apply_date_filter(df, NULL)
    expect_equal(nrow(result), 2)
  })

  test_that("apply_dim_filter returns empty when filter matches nothing", {
    df <- data.frame(
      date = as.Date(c("2024-01-01", "2024-01-01")),
      value = c(10, 20),
      geography = c("national", "national"),
      wage_percentile = c("wage_p10", "wage_p50"),
      stringsAsFactors = FALSE
    )

    result <- apply_dim_filter(df, list(wage_percentile = "wage_p99"))
    expect_equal(nrow(result), 0)
  })

  test_that("apply_date_filter returns empty when date matches nothing", {
    df <- data.frame(
      date = as.Date(c("2023-01-01", "2024-01-01")),
      value = c(10, 20),
      stringsAsFactors = FALSE
    )

    result <- apply_date_filter(df, "1900-01-01")
    expect_equal(nrow(result), 0)
  })

  test_that("apply_date_filter returns empty when range matches nothing", {
    df <- data.frame(
      date = as.Date(c("2023-01-01", "2024-01-01")),
      value = c(10, 20),
      stringsAsFactors = FALSE
    )

    result <- apply_date_filter(df, c("1900-01-01", "1901-01-01"))
    expect_equal(nrow(result), 0)
  })

  test_that("get_swadl with default overall dimension", {
    cache_clear_all()
    df <- get_swadl("hourly_wage_median", "real_wage_median_2025")

    expect_true(nrow(df) > 0)
    expect_true(all(c("date", "value", "geography", "overall") %in% names(df)))
    expect_s3_class(df$date, "Date")
    expect_type(df$value, "double")
    expect_equal(unique(df$geography), "national")
    expect_true("overall" %in% df$overall)
    cache_clear_all()
  })

  test_that("parse_dimension_overall uses list endpoint", {
    cache_clear_all()
    result <- parse_dimension_overall(
      c("overall", "gender_male", "gender_female")
    )

    expect_equal(result$endpoint, "list")
    expect_equal(result$params, list(dimensionId = "overall"))
    expect_equal(result$dim_ids, "overall")
    cache_clear_all()
  })
})
