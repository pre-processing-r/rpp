#' @export
declare_inline_plugin <- function(edit, clean) {
  structure(
    list(dev = edit, prod = clean),
    class = c("rpp_inline_plugin", "rpp_plugin")
  )
}
