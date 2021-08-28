if (require(testthat)) {
  library(rpp)
  test_check("rpp")
} else {
  message("testthat not available.")
}
