test_that("snapshots", {
  expect_q_snapshot("?function(a = 0L) {}")
  expect_q_snapshot("?function(a = ?Integer()) {}")
  expect_q_snapshot("?function(a = 0L?Integer()) {}")
})
