httptest2::with_mock_dir("fixtures", {
  test_that("get_swadl_series returns correct structure", {
    cache_clear_all()
    df <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = "overall"
    )

    expect_s3_class(df, "data.frame")
    expect_true("date" %in% names(df))
    expect_true("value" %in% names(df))
    expect_true("geography" %in% names(df))
    expect_true("overall" %in% names(df))
    cache_clear_all()
  })

  test_that("get_swadl_series with overall dimension", {
    cache_clear_all()
    df <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = "overall"
    )

    expect_s3_class(df$date, "Date")
    expect_type(df$value, "double")
    expect_equal(df$geography, rep("national", nrow(df)))
    expect_equal(df$overall, rep("overall", nrow(df)))
    cache_clear_all()
  })

  test_that("get_swadl_series with single dimension", {
    cache_clear_all()
    df <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = "wage_percentile"
    )

    expect_true("wage_percentile" %in% names(df))
    expect_true("wage_p10" %in% df$wage_percentile)
    expect_true("wage_p50" %in% df$wage_percentile)
    cache_clear_all()
  })

  test_that("get_swadl_series with specific dimension value", {
    cache_clear_all()
    df <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = list("wage_percentile" = "wage_p50")
    )

    expect_true("wage_percentile" %in% names(df))
    expect_equal(unique(df$wage_percentile), "wage_p50")
    cache_clear_all()
  })

  test_that("get_swadl_series with cross-dimensional query", {
    cache_clear_all()
    df <- get_swadl_series(
      "labor_force_emp",
      "percent_emp",
      date_interval = "month",
      dimension = list("gender" = "gender_male", "age_group")
    )

    expect_true("gender" %in% names(df))
    expect_true("age_group" %in% names(df))
    expect_equal(unique(df$gender), "gender_male")
    expect_true("age_16_24" %in% df$age_group)
    expect_true("age_25_54" %in% df$age_group)
    cache_clear_all()
  })

  test_that("get_swadl_series date filtering with single date", {
    cache_clear_all()
    df_all <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = "overall"
    )
    df_filtered <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = "overall",
      date = "2024-01-01"
    )

    expect_true(nrow(df_filtered) <= nrow(df_all))
    expect_true(all(df_filtered$date == as.Date("2024-01-01")))
    cache_clear_all()
  })

  test_that("get_swadl_series date filtering with range", {
    cache_clear_all()
    df <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      dimension = "overall",
      date = c("2020-01-01", "2024-01-01")
    )

    expect_true(all(df$date >= as.Date("2020-01-01")))
    expect_true(all(df$date <= as.Date("2024-01-01")))
    cache_clear_all()
  })

  test_that("get_swadl_series accepts geography as name", {
    cache_clear_all()
    df <- get_swadl_series(
      "hourly_wage_percentiles",
      "real_wage_2024",
      geography = "national",
      dimension = "overall"
    )

    expect_equal(unique(df$geography), "national")
    cache_clear_all()
  })

  test_that("get_swadl_series validates indicator", {
    expect_error(
      get_swadl_series(
        "nonexistent",
        "real_wage_2024",
        dimension = "overall"
      ),
      "Unknown indicator"
    )
  })

  test_that("get_swadl_series validates measure", {
    cache_clear_all()
    expect_error(
      get_swadl_series(
        "hourly_wage_percentiles",
        "fake_measure",
        dimension = "overall"
      ),
      "not available"
    )
    cache_clear_all()
  })

  test_that("get_swadl_series validates date_interval", {
    cache_clear_all()
    expect_error(
      get_swadl_series(
        "hourly_wage_percentiles",
        "real_wage_2024",
        date_interval = "month",
        dimension = "overall"
      ),
      "not available"
    )
    cache_clear_all()
  })

  test_that("get_swadl_series validates dimension", {
    cache_clear_all()
    expect_error(
      get_swadl_series(
        "hourly_wage_percentiles",
        "real_wage_2024",
        dimension = "nonexistent"
      ),
      "not available"
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
})
