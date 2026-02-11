## R package development

Follow these instructions when writing R code:

### Key commands

```
# To run code
Rscript -e "devtools::load_all(); code"

# To run all tests
Rscript -e "devtools::test()"

# To run all tests for files starting with {name}
Rscript -e "devtools::test(filter = '^{name}')"

# To run all tests for R/{name}.R
Rscript -e "devtools::test_active_file('R/{name}.R')"

# To run a single test "blah" for R/{name}.R
Rscript -e "devtools::test_active_file('R/{name}.R', desc = 'blah')"

# To redocument the package
Rscript -e "devtools::document()"

# To rebuild README.md from README.Rmd
Rscript -e "devtools::build_readme()"

# To check pkgdown documentation
Rscript -e "pkgdown::check_pkgdown()"

# To rebuild the pkgdown site
Rscript -e "pkgdown::build_site()"

# To check the package with R CMD check
Rscript -e "devtools::check()"

# To format code
air format .
```

### Coding

* Always run `air format .` after generating code
* Use the base pipe operator (`|>`) not the magrittr pipe (`%>%`)
* Don't use `_$x` or `_$[["x"]]` since this package must work on R 4.1.
* Use `\() ...` for single-line anonymous functions. For all other cases, use `function() {...}` 

### Testing

- Tests for `R/{name}.R` go in `tests/testthat/test-{name}.R`.
- All new code should have an accompanying test.
- If there are existing tests, place new tests next to similar existing tests.
- Strive to keep your tests minimal with few comments.

### Test conventions

#### httptest2 fixtures

Tests use httptest2 to mock API responses with fixtures in `tests/testthat/fixtures/`, organized by URL path (e.g., `fixtures/data.epi.org/api/topic/list.json`). This avoids hitting the live API during tests.

Key points:
- httptest2 intercepts httr2 requests at `req_perform()` and returns fixture data
- The throttle (`throttle_if_needed()`) runs before the request, so it would still delay even with mocked responses
- `tests/testthat/setup.R` sets `options(swadlr.throttle_interval = 0)` to disable throttling during tests
- Use `testthat::test_path("fixtures")` in `with_mock_dir()` calls to ensure correct path resolution with `devtools::test()`

To update fixtures when the live API changes:

```r
httptest2::.mockPaths("tests/testthat/fixtures")
httptest2::start_capturing()
devtools::test()
httptest2::stop_capturing()
```

**Warning:** httptest2's `with_mock_dir()` auto-prepends `tests/testthat/` to relative paths when `tests/testthat/` exists in the working directory. Never call `with_mock_dir("tests/testthat/fixtures", ...)` from the package root — it will resolve to `tests/testthat/tests/testthat/fixtures/`. In test files, always use `testthat::test_path("fixtures")` which returns just `"fixtures"` (relative to the test directory where `devtools::test()` sets the working directory), bypassing the prepend logic. Outside of test files, use `.mockPaths()` directly as shown above.

#### When to use `with_mock_dir()` vs direct unit tests

- Use `with_mock_dir()` for tests that call functions making HTTP requests (`fetch_*` functions, `get_swadl()`, etc.):
  ```r
  httptest2::with_mock_dir(testthat::test_path("fixtures"), {
    test_that("...", { ... })
  })
  ```
- Use direct unit tests (no mocking) for pure functions that transform data in memory, like `apply_date_filter()`, `transform_response()`, or cache functions.

#### Cache clearing

Call `cache_clear_all()` at the start and end of each test that interacts with cached data. This ensures test isolation:

```r
test_that("...", {
  cache_clear_all()
  # test code
  cache_clear_all()
})
```

#### Test naming

- Use descriptive test names that state what is being tested and the expected outcome.
- Group related tests together within a file.
- Validation tests should verify both the success case and the error message for invalid input.

### Documentation

- Every user-facing function should be exported and have roxygen2 documentation.
- Wrap roxygen comments at 80 characters.
- Internal functions should not have roxygen documentation.
- Whenever you add a new (non-internal) documentation topic, also add the topic to `_pkgdown.yml`. 
- Always re-document the package after changing a roxygen2 comment.
- Use `pkgdown::check_pkgdown()` to check that all topics are included in the reference index.

### `NEWS.md`

- Every user-facing change should be given a bullet in `NEWS.md`. Do not add bullets for small documentation changes or internal refactorings.
- Each bullet should briefly describe the change to the end user and mention the related issue in parentheses.
- A bullet can consist of multiple sentences but should not contain any new lines (i.e. DO NOT line wrap).
- If the change is related to a function, put the name of the function early in the bullet.
- Order bullets alphabetically by function name. Put all bullets that don't mention function names at the beginning.

### GitHub

- If you use `gh` to retrieve information about an issue, always use `--comments` to read all the comments.

### Writing

- Use sentence case for headings.
- Use US English.

### Proofreading

If the user asks you to proofread a file, act as an expert proofreader and editor with a deep understanding of clear, engaging, and well-structured writing. 

Work paragraph by paragraph, always starting by making a TODO list that includes individual items for each top-level heading. 

Fix spelling, grammar, and other minor problems without asking the user. Label any unclear, confusing, or ambiguous sentences with a FIXME comment.

Only report what you have changed.
