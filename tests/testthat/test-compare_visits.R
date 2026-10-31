test_that("compare_visits() returns one row per year", {
  result <- compare_visits("Yarra")
  expect_equal(nrow(result), 3)
  expect_equal(result$financial_year, c("2022-23", "2023-24", "2024-25"))
})

test_that("the Victorian figure matches the PLV Benchmarking Report", {
  result <- compare_visits("Yarra")
  expect_equal(round(result$vic_visits_per_person, 2), c(3.05, 3.37, 3.48))
})

test_that("years with no reported data are NA", {
  result <- compare_visits("Towong")
  expect_equal(result$reported, c(FALSE, FALSE, TRUE))
  expect_true(all(is.na(result$visits_per_person[1:2])))
})

test_that("a wrong service name gives an error", {
  expect_error(compare_visits("Yara"), "must be one library service name")
})