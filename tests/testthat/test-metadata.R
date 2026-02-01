httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("swadlr_topics returns expected structure", {
    cache_clear_all()
    result <- swadlr_topics()

    expect_s3_class(result, "data.frame")
    expect_named(result, c("id", "name"))
    expect_equal(nrow(result), 2)
    expect_equal(result$id, c("wages", "labor_force"))
    expect_equal(result$name, c("Wages", "Employment"))

    cache_clear_all()
  })

  test_that("swadlr_indicators returns expected structure", {
    cache_clear_all()
    result <- swadlr_indicators()

    expect_s3_class(result, "data.frame")
    expect_named(result, c("id", "name", "topic_id", "updated_date"))
    expect_equal(nrow(result), 2)
    expect_equal(result$id[1], "hourly_wage_percentiles")
    expect_equal(result$topic_id[1], "wages")

    cache_clear_all()
  })

  test_that("swadlr_indicators filters by topic", {
    cache_clear_all()
    result <- swadlr_indicators(topic = "wages")

    expect_equal(nrow(result), 1)
    expect_equal(result$id, "hourly_wage_percentiles")

    cache_clear_all()
  })

  test_that("swadlr_indicators errors on unknown topic", {
    cache_clear_all()
    expect_error(
      swadlr_indicators(topic = "nonexistent"),
      "Unknown topic"
    )
    cache_clear_all()
  })

  test_that("swadlr_measures returns expected structure", {
    cache_clear_all()
    result <- swadlr_measures()

    expect_s3_class(result, "data.frame")
    expect_named(result, c("id", "name", "format"))
    expect_equal(nrow(result), 3)
    expect_true("real_wage_2024" %in% result$id)

    cache_clear_all()
  })

  test_that("swadlr_measures filters by indicator", {
    cache_clear_all()
    result <- swadlr_measures(indicator = "hourly_wage_percentiles")

    expect_equal(nrow(result), 1)
    expect_equal(result$id, "real_wage_2024")

    cache_clear_all()
  })

  test_that("swadlr_measures errors on unknown indicator", {
    cache_clear_all()
    expect_error(
      swadlr_measures(indicator = "nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("swadlr_dimensions returns expected structure", {
    cache_clear_all()
    result <- swadlr_dimensions()

    expect_s3_class(result, "data.frame")
    expect_named(
      result,
      c("dimension_id", "dimension_name", "value_id", "value_name")
    )
    expect_true(nrow(result) >= 5)
    expect_true("wage_p10" %in% result$value_id)
    expect_true("gender_female" %in% result$value_id)

    cache_clear_all()
  })

  test_that("swadlr_dimensions filters by indicator", {
    cache_clear_all()
    result <- swadlr_dimensions(indicator = "hourly_wage_percentiles")

    expect_true("wage_p10" %in% result$value_id)
    expect_true("gender_female" %in% result$value_id)
    expect_false("age_16_24" %in% result$value_id)

    cache_clear_all()
  })

  test_that("swadlr_dimensions errors on unknown indicator", {
    cache_clear_all()
    expect_error(
      swadlr_dimensions(indicator = "nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("fetch functions cache results", {
    cache_clear_all()

    swadlr_topics()
    expect_true(cache_has("topics"))

    swadlr_indicators()
    expect_true(cache_has("indicators"))

    swadlr_measures()
    expect_true(cache_has("measures"))

    swadlr_dimensions()
    expect_true(cache_has("dimensions"))

    cache_clear_all()
  })
})

test_that("swadlr_geographies returns expected structure", {
  result <- swadlr_geographies()

  expect_s3_class(result, "data.frame")
  expect_named(result, c("id", "level", "name", "abbr"))
  expect_equal(nrow(result), 65) # 1 national + 4 regions + 9 divisions + 51 states
  expect_true("national" %in% result$id)
  expect_true("state06" %in% result$id)
  expect_equal(result$name[result$id == "state06"], "California")
})

test_that("swadlr_clear_cache clears all cached data", {
  cache_set("test_key", "test_value")
  expect_true(cache_has("test_key"))

  swadlr_clear_cache()
  expect_false(cache_has("test_key"))
})
