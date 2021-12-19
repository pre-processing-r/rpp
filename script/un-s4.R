pkgload::load_all()

root <- "~/git/R/r-dbi/RSQLite"

if (!exists("parsed_full")) {
  parsed_full <- parse_package(root)
} else {
  message("Reusing parse data from ", dirname(dirname(parsed_full$filename[[1]])))
}

parsed_nested <-
  parsed_full %>%
  nest(data = -filename)

# If necessary, use a slice here
parsed <-
  parsed_nested[, ] %>%
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
  stopifnot(sum(set_method_idx) == 1)
  set_method_id <- parse_data$id[set_method_idx]
  set_method_children_idx <- (parse_data$parent == set_method_id)
  set_method_children_id <- parse_data$id[set_method_children_idx]

  stopifnot(grepl("^function", parse_data$text[set_method_children_idx][[7]]))

  # Assuming call by position in setMethod()
  new_method_name <- paste0(
    code[[2]], "_",
    paste0(eval(code[[3]]), collapse = "_")
  )
  code[[4]] <- rlang::sym(new_method_name)
  message(new_method_name)

  roxy_header <- parse_data$text[parse_data$parent < 0]
  new_function_header <- grep("@export", roxy_header, value = TRUE, invert = TRUE)
  has_export <- any(grepl("@export", roxy_header))
  name_header <- grep("@name |@rdname ", roxy_header, value = TRUE)

  if (length(name_header) == 0) {
    name_header <- paste0(
      "#' @rdname ",
      gsub("_", "-", new_method_name),
      "-method"
    )
    extra_header <- paste0(name_header, "\n")
  } else {
    extra_header <- ""
  }


  function_text <- paste0(
    gsub("^\n+", "", paste0(new_function_header, "\n", collapse = "")),
    "#' @usage NULL\n",
    extra_header,
    new_method_name, " <- ", parse_data$text[set_method_children_idx][[7]],
    "\n",
    "\n",
    name_header, "\n",
    if (has_export) "#' @export\n",
    deparse(code, 500)
  )

  styled_function_text <- styler::style_text(function_text, scope = "line_breaks")

  new_file_name <- file.path(dirname(filename), paste0(new_method_name, ".R"))
  writeLines(styled_function_text, new_file_name)
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
  code_list <- map_chr(parse_data_list, ~ paste(.x$text[.x$parent <= 0], collapse = "\n"))
  writeLines(paste(code_list, collapse = "\n\n"), filename)
})

Rcpp::compileAttributes(root)
devtools::document(root)
