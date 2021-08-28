test_that("Argument types", {
  expect_q_snapshot("?function(a = 0L) {}")
  expect_q_snapshot("?function(a = ?Integer()) {}")
  expect_q_snapshot("?function(a = 0L ?Integer()) {}")
})

test_that("Return values", {
  expect_q_snapshot("Integer()? function(a = 0L ?Integer()) {}")
  expect_q_snapshot("fun <- (Integer()? function(a = 0L ?Integer()) {})")
  # FIXME: How to make this work?
  expect_q_snapshot("fun <- Integer()? function(a = 0L ?Integer()) {}")
})

test_that("Variable types", {
  expect_q_snapshot("Integer()? x <- 0L")
})
