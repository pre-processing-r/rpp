test_that("snapshots", {
  expect_q_snapshot("?function(a = 0L) {}")
  expect_q_snapshot("?function(a = ?Integer()) {}")
  expect_q_snapshot("?function(a = 0L?Integer()) {}")
  expect_q_snapshot("Integer()? function(a = 0L?Integer()) {}")
  expect_q_snapshot("Integer()? x <- 0L")
})
