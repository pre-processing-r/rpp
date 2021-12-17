#' Rich parse data
#'
#' Returns a tibble with one row per function/object in the string, file, or package.
#'
#' @param text The text to parse as string.
#'
#' @export
parse_text <- function(text, filename = NULL) {
  stopifnot(length(text) == 1)

  if (is.null(filename)) {
    filename <- "<text>"
  }

  expr <- parse(
    text = text,
    keep.source = TRUE,
    srcfile = srcfilecopy(filename, text, isFile = TRUE)
  )
  srcrefs <- attr(expr, "srcref")

  parsed <- as.list(expr)
  parse_data <- get_parse_data(expr)

  n_parsed <- length(parsed)
  n_parse_data <- length(parse_data)
  if (n_parsed < n_parse_data) {
    # Bind the last two parse data frames
    stopifnot(all(parse_data[[n_parse_data]]$token == "COMMENT"))
    n_parse_data_2 <- n_parse_data - rev(rlang::seq2(0, n_parse_data - n_parsed))
    parse_data <- c(parse_data[-n_parse_data_2], list(bind_rows(parse_data[n_parse_data_2])))
  }

  stopifnot(length(parsed) == length(srcrefs))
  stopifnot(length(parsed) == length(parse_data))

  tibble(filename, code = parsed, srcref = srcrefs, parse_data)
}


#' @rdname parse_text
#' @param file The file to parse, must be UTF-8 encoded.
#' @export
parse_file <- function(file) {
  message(file)
  text <- brio::read_file(file)
  parse_text(text, file)
}

#' @rdname parse_text
#' @param file The package to parse, must be UTF-8 encoded.
#' @export
parse_package <- function(path = ".") {
  file <- dir(file.path(path, "R"), full.names = TRUE)
  map_dfr(file, parse_file)
}

# FIXME: Reimplement for speed
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
