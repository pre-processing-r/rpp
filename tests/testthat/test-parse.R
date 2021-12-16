test_that("parse_text() snapshots", {
  expect_snapshot({
    as.list(parse_text("a <- 1"))
  })

  expect_snapshot({
    as.list(parse_text("#' roxygen2 block\na <- 1"))
  })

  expect_snapshot({
    as.list(parse_text("a <- 1 # inline comment"))
  })

  expect_snapshot({
    as.list(parse_text("a <- 1\na <- 2"))
  })

  expect_snapshot({
    as.list(parse_text("a <- 1; a <- 2"))
  })
})
