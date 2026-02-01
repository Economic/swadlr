test_that("resolve_geography handles national", {
  expect_equal(resolve_geography("national"), "national")
  expect_equal(resolve_geography("United States"), "national")
  expect_equal(resolve_geography("US"), "national")
  expect_equal(resolve_geography("us"), "national")
})

test_that("resolve_geography handles regions", {
  expect_equal(resolve_geography("regionMidwest"), "regionMidwest")
  expect_equal(resolve_geography("Midwest"), "regionMidwest")
  expect_equal(resolve_geography("midwest"), "regionMidwest")
  expect_equal(resolve_geography("Northeast"), "regionNortheast")
  expect_equal(resolve_geography("South"), "regionSouth")
  expect_equal(resolve_geography("West"), "regionWest")
})

test_that("resolve_geography handles divisions", {
  expect_equal(resolve_geography("division09"), "division09")
  expect_equal(resolve_geography("Pacific"), "division09")
  expect_equal(resolve_geography("New England"), "division01")
  expect_equal(resolve_geography("Mountain"), "division08")
})
test_that("resolve_geography handles states by name", {
  expect_equal(resolve_geography("California"), "state06")
  expect_equal(resolve_geography("california"), "state06")
  expect_equal(resolve_geography("New York"), "state36")
  expect_equal(resolve_geography("District of Columbia"), "state11")
})

test_that("resolve_geography handles states by abbreviation", {
  expect_equal(resolve_geography("CA"), "state06")
  expect_equal(resolve_geography("ca"), "state06")
  expect_equal(resolve_geography("NY"), "state36")
  expect_equal(resolve_geography("DC"), "state11")
})

test_that("resolve_geography handles states by API ID", {
  expect_equal(resolve_geography("state06"), "state06")
  expect_equal(resolve_geography("state36"), "state36")
  expect_equal(resolve_geography("state11"), "state11")
})

test_that("resolve_geography errors on invalid input", {
  expect_error(resolve_geography("invalid"), "Unknown geography")
  expect_error(resolve_geography("XY"), "Unknown geography")
})

test_that("resolve_geography errors on non-character input", {
  expect_error(resolve_geography(123), "must be a non-empty character string")
  expect_error(
    resolve_geography(c("CA", "NY")),
    "must be a non-empty character string"
  )
  expect_error(resolve_geography(NULL), "must be a non-empty character string")
  expect_error(resolve_geography(""), "must be a non-empty character string")
})

test_that("resolve_geography provides suggestions for typos", {
  expect_error(resolve_geography("Califronia"), "Did you mean")
  expect_error(resolve_geography("Califronia"), "California")
})
