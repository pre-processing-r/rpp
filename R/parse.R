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

  tibble::lst(code)
}
