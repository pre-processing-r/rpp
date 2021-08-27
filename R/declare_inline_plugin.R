#' @export
declare_inline_plugin <- function(dev, prod) {
  structure(
    list(dev = dev, prod = prod),
    class = c("rpp_inline_plugin", "rpp_plugin")
  )
}
