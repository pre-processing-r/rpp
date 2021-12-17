pkgload::load_all()

if (!exists("parsed_full")) {
  parsed_full <- parse_package("~/git/R/r-dbi/DBI")
}

parsed_nested <-
  parsed_full %>%
  nest(data = -filename)

parsed <-
  parsed_nested[2, ] %>%
  unnest(data)

method_idx <- map_lgl(parsed$code, ~ {
  list <- as.list(.x)
  if (length(list) >= 4) {
    identical(list[[1]], rlang::sym("setMethod")) &&
      is.call(list[[4]]) &&
      identical(list[[4]][[1]], rlang::sym("function"))
  } else {
    FALSE
  }
})

pwalk(parsed[method_idx, ], function(filename, code, srcref, parse_data) {
  set_method_idx <- (parse_data$parent == 0)
  set_method_id <- parse_data$id[set_method_idx]
  set_method_children_idx <- (parse_data$parent == set_method_id)
  set_method_children_id <- parse_data$id[set_method_children_idx]

  stopifnot(grepl("^function", parse_data$text[set_method_children_idx][[7]]))

  # Assuming call by position in setMethod()
  new_method_name <- paste0(c(code[[2]], eval(code[[3]])), collapse = "_")
  code[[4]] <- rlang::sym(new_method_name)
  message(new_method_name)

  roxy_header <- parse_data$text[parse_data$parent < 0]
  new_function_header <- grep("@export", roxy_header, value = TRUE, invert = TRUE)
  has_export <- any(grepl("@export", roxy_header))
  name_header <- grep("@name |@rdname ", roxy_header, value = TRUE)

  function_text <- paste0(
    gsub("^\n+", "", paste0(new_function_header, "\n", collapse = "")),
    "#' @usage NULL\n",
    new_method_name, " <- ", parse_data$text[set_method_children_idx][[7]],
    "\n",
    name_header, "\n",
    if (has_export) "#' @export\n",
    deparse(code, 500)
  )

  new_file_name <- file.path(dirname(filename), paste0(new_method_name, ".R"))
  writeLines(function_text, new_file_name)
})

generic_idx <- map_lgl(parsed$code, ~ {
  list <- as.list(.x)
  if (length(list) >= 1) {
    identical(list[[1]], rlang::sym("setGeneric"))
  } else {
    FALSE
  }
})

pwalk(parsed[generic_idx, ], function(filename, code, srcref, parse_data) {
  set_generic_idx <- (parse_data$parent == 0)
  set_generic_id <- parse_data$id[set_generic_idx]

  # Assuming call by position in setMethod()
  new_generic_name <- as.character(code[[2]])
  message(new_generic_name)

  function_text <- parse_data$text[parse_data$parent <= 0]
  new_file_name <- file.path(dirname(filename), paste0(new_generic_name, ".R"))
  writeLines(function_text, new_file_name)
})

rest <-
  parsed[!method_idx & !generic_idx, ] %>%
  group_by(filename) %>%
  summarize(parse_data_list = list(parse_data)) %>%
  ungroup()

pwalk(rest, function(filename, parse_data_list) {
  code_list <- map(parse_data_list, ~ c(.x$text[.x$parent <= 0], ""))
  writeLines(unlist(code_list), filename)
})
