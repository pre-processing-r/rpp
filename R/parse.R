#' Rich parse data for all source files in a package
#'
#' Returns a tibble with one row per function/object in the package.
#'
#' @export
parse_text <- function(text) {
  lines <- unlist(strsplit(text, "\n"))
  expr <- parse(text = text, keep.source = TRUE, srcfile = srcfilecopy("<text>", lines, isFile = TRUE))
  srcrefs <- attr(expr, "srcref")

  parsed <- as.list(expr)
  code <- get_parse_data(expr)

  n_parsed <- length(parsed)
  n_code <- length(code)
  if (n_parsed < n_code) {
    # Bind the last two parse data frames
    stopifnot(all(code[[n_code]]$token == "COMMENT"))
    n_code_2 <- n_code - rev(rlang::seq2(0, n_code - n_parsed))
    code <- c(code[-n_code_2], list(bind_rows(code[n_code_2])))
  }

  stopifnot(length(parsed) == length(srcrefs))
  stopifnot(length(parsed) == length(code))

  tibble(parsed, srcrefs, code)
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

  nested <- tibble(file, parsed = map(parsed, as.list), srcrefs, code = parse_data)

  stopifnot(lengths(nested$parsed) == lengths(nested$srcrefs))
  stopifnot(lengths(nested$parsed) == lengths(nested$parse_data))

  #unnest(nested, -file)
  nested
}

get_tree_root <- function(id, parent) {
  tree <- data.tree::FromDataFrameNetwork(data.frame(id, parent))
  list <- data.tree::ToListSimple(tree)
  trees <- map(list[-1], data.tree::FromListSimple)
  root_maps <- map(trees, data.tree::ToDataFrameNetwork)

  root_map <- imap_dfr(root_maps, ~ tibble(id = c(as.integer(.y), .x$to), root = as.integer(.y)))

  root_map$root[match(id, root_map$id)]
}

get_parse_data <- function(exprs) {
  pd <-
    getParseData(exprs, includeText = TRUE) %>%
    arrange(line1, col1, desc(line2), desc(col2), parent) %>%
    as_tibble()

  root <- get_tree_root(pd$id, abs(pd$parent))
  code <- unname(split(pd, root))

  # Special case: semicolon
  length_one <- map_int(code, nrow) == 1
  has_semicolon <- map_lgl(code, ~ .x$token[[1]] == "';'")
  code <- code[!length_one | !has_semicolon]

  code
}
