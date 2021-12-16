#' Rich parse data for all source files in a package
#'
#' Returns a tibble with one row per function/object in the package.
#'
#' @export
parse_text <- function(text) {
  lines <- unlist(strsplit(text, "\n"))
  expr <- parse(text = text, keep.source = TRUE, srcfile = srcfilecopy("<text>", lines, isFile = TRUE))
  srcref <- attr(expr, "srcref")

  parse_data <- get_parse_data(expr)

  nested <- rlang::list2(parsed = as.list(expr), srcrefs = srcref, !!!parse_data)

  # stopifnot(lengths(nested$parsed) == lengths(nested$srcrefs))
  # stopifnot(lengths(nested$parsed) == lengths(nested$parse_data))

  # unnest(nested, everything())
  nested
}

#' Rich parse data for all source files in a package
#'
#' Returns a tibble with one row per function/object in the package.
#'
#' @export
parse_package <- function(path = ".") {
  file <- dir(file.path(path, "R"), full.names = TRUE)
  parsed <- map(file, parse, keep.source = TRUE)
  srcrefs <- map(parsed, attr, "srcref")

  parse_data <- map(parsed, get_parse_data)

  nested <- tibble(file, parsed = map(parsed, as.list), srcrefs, parse_data)

  stopifnot(lengths(nested$parsed) == lengths(nested$srcrefs))
  stopifnot(lengths(nested$parsed) == lengths(nested$parse_data))

  #unnest(nested, -file)
  nested
}

get_parse_data <- function(exprs) {
  pd <-
    getParseData(exprs, includeText = TRUE) %>%
    arrange(line1, col1, desc(line2), desc(col2), parent) %>%
    as_tibble()

  is_pre_comment <- pd$parent < 0
  is_pre_comment_rle <- rle(is_pre_comment | (pd$token != "COMMENT" & pd$parent == 0))

  pre_comment_end <- cumsum(is_pre_comment_rle$lengths)
  pre_comment_start <- lag(pre_comment_end, default = 0L) + 1L
  pre_comment_idx <- map2(pre_comment_start[is_pre_comment_rle$values], pre_comment_end[is_pre_comment_rle$values], rlang::seq2)
  pre_comments <- map(pre_comment_idx, ~ pd[.x, ])

  pd_code <- pd[!is_pre_comment, ]

  stopifnot(pd_code$parent[[1]] == 0)
  split <- cumsum(pd_code$parent == 0)
  code <- unname(split(pd_code, split))

  # stopifnot(length(pre_comments) == length(code))

  tibble::lst(pre_comments, code)
}
