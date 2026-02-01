test_that("cache_set and cache_get work", {
  cache_clear_all()

  cache_set("test_key", "test_value")
  expect_equal(cache_get("test_key"), "test_value")

  cache_set("test_key", "new_value")
  expect_equal(cache_get("test_key"), "new_value")

  cache_clear_all()
})

test_that("cache_get returns NULL for missing keys", {
  cache_clear_all()
  expect_null(cache_get("nonexistent"))
  cache_clear_all()
})

test_that("cache_has detects existing and missing keys", {
  cache_clear_all()

  expect_false(cache_has("test_key"))

  cache_set("test_key", "value")
  expect_true(cache_has("test_key"))

  cache_clear_all()
})

test_that("cache_clear_all removes all keys", {
  cache_clear_all()

  cache_set("key1", "value1")
  cache_set("key2", "value2")

  cache_clear_all()

  expect_null(cache_get("key1"))
  expect_null(cache_get("key2"))
})
