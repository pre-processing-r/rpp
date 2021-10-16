test_that("error handling for inline_plugin()", {
  expect_error(inline_plugin("dev", "prod"))
  expect_error(inline_plugin(function(dev) {}, function(prod) {}))
  expect_error(inline_plugin(function(lines, ...) {}, "prod"))
  expect_error(inline_plugin(function(lines, ...) {}, function(prod) {}))

  expect_s3_class(inline_plugin(function(lines, ...) {}, function(lines, ...) {}), "rpp_inline_plugin")
})
