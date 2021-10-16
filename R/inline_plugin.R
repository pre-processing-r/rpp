#' Create Plugin
#'
#' Create an inline plugin.
#'
#' @param dev,prod Development and production
#' functions to run when in either state. These
#' callback function should accept a single argument
#' `lines`, a vector of character strings: the source code where
#' each character string is a line of code.
#' They also should accept an ellipsis `...` for future extensibility.
#'
#' @examples
#' chg_magrittr_to_native <- function(lines) {
#'   gsub("\\%>\\%", "|>", lines)
#' }
#'
#' code <- 'function(x) {
#'   x %>%
#'     sum()
#' }'
#'
#' chg_magrittr_to_native(code)
#' @export
inline_plugin <- function(dev, prod) {
  if (!is.function(dev)) {
    stop("`dev` must be a function.")
  }

  if (!all(c("lines", "...") %in% names(formals(dev)))) {
    stop("`dev` must accept `lines` and `...` as arguments.")
  }

  if (!is.function(prod)) {
    stop("`prod` must be a function.")
  }

  if (!all(c("lines", "...") %in% names(formals(prod)))) {
    stop("`prod` must accept `lines` and `...` as arguments.")
  }

  structure(
    list(dev = dev, prod = prod),
    class = c("rpp_inline_plugin", "rpp_plugin")
  )
}
