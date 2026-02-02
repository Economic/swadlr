httptest2::with_mock_dir(testthat::test_path("fixtures"), {
  test_that("swadl_id_names('topics') returns expected structure", {
    cache_clear_all()
    result <- swadl_id_names("topics")

    expect_s3_class(result, "data.frame")
    expect_named(result, c("id", "name"))
    expect_true(nrow(result) >= 1)
    expect_true("wages" %in% result$id)
    expect_true("labor_force" %in% result$id)

    cache_clear_all()
  })

  test_that("swadl_id_names('indicators') returns expected structure", {
    cache_clear_all()
    result <- swadl_id_names("indicators")

    expect_s3_class(result, "data.frame")
    expect_named(result, c("id", "name", "topic_id", "updated_date"))
    expect_true(nrow(result) >= 1)
    expect_true("hourly_wage_percentiles" %in% result$id)

    cache_clear_all()
  })

  test_that("swadl_id_names('indicators') filters by topic", {
    cache_clear_all()
    result <- swadl_id_names("indicators", topic = "wages")

    expect_true(nrow(result) >= 1)
    expect_true("hourly_wage_percentiles" %in% result$id)
    expect_true(all(result$topic_id == "wages"))

    cache_clear_all()
  })

  test_that("swadl_id_names('indicators') errors on unknown topic", {
    cache_clear_all()
    expect_error(
      swadl_id_names("indicators", topic = "nonexistent"),
      "Unknown topic"
    )
    cache_clear_all()
  })

  test_that("swadl_id_names('measures') returns expected structure", {
    cache_clear_all()
    result <- swadl_id_names("measures")

    expect_s3_class(result, "data.frame")
    expect_named(result, c("id", "name", "format"))
    expect_true(nrow(result) >= 1)
    expect_true("nominal_wage" %in% result$id)

    cache_clear_all()
  })

  test_that("swadl_id_names('measures') filters by indicator", {
    cache_clear_all()
    result <- swadl_id_names("measures", indicator = "hourly_wage_percentiles")

    expect_true(nrow(result) >= 1)
    expect_true("nominal_wage" %in% result$id)

    cache_clear_all()
  })

  test_that("swadl_id_names('measures') errors on unknown indicator", {
    cache_clear_all()
    expect_error(
      swadl_id_names("measures", indicator = "nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("swadl_id_names('dimensions') returns expected structure", {
    cache_clear_all()
    result <- swadl_id_names("dimensions")

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

  test_that("swadl_id_names('dimensions') filters by indicator", {
    cache_clear_all()
    result <- swadl_id_names(
      "dimensions",
      indicator = "hourly_wage_percentiles"
    )

    expect_true("wage_p10" %in% result$value_id)
    expect_true("gender_female" %in% result$value_id)
    # fpl200 dimension is not available for hourly_wage_percentiles
    expect_false("fpl200_below" %in% result$value_id)

    cache_clear_all()
  })

  test_that("swadl_id_names('dimensions') errors on unknown indicator", {
    cache_clear_all()
    expect_error(
      swadl_id_names("dimensions", indicator = "nonexistent"),
      "Unknown indicator"
    )
    cache_clear_all()
  })

  test_that("fetch functions cache results", {
    cache_clear_all()

    swadl_id_names("topics")
    expect_true(cache_has("topics"))

    swadl_id_names("indicators")
    expect_true(cache_has("indicators"))

    swadl_id_names("measures")
    expect_true(cache_has("measures"))

    swadl_id_names("dimensions")
    expect_true(cache_has("dimensions"))

    cache_clear_all()
  })
})

test_that("swadl_id_names('geographies') returns expected structure", {
  result <- swadl_id_names("geographies")

  expect_s3_class(result, "data.frame")
  expect_named(result, c("id", "level", "name", "abbr"))
  expect_equal(nrow(result), 65) # 1 national + 4 regions + 9 divisions + 51 states
  expect_true("national" %in% result$id)
  expect_true("state06" %in% result$id)
  expect_equal(result$name[result$id == "state06"], "California")
})

test_that("clear_swadlr_cache clears all cached data", {
  cache_set("test_key", "test_value")
  expect_true(cache_has("test_key"))

  clear_swadlr_cache()
  expect_false(cache_has("test_key"))
})
