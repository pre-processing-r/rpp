#' @export
declare_inline_plugin <- function(edit, clean) {
  structure(
    list(edit = edit, clean = clean),
    class = c("rpp_inline_plugin", "rpp_plugin")
  )
}
