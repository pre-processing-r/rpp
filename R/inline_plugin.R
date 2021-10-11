#' Create Plugin
#' 
#' Create an inline plugin.
#' 
#' @param dev,prod Development and production
#' functions to run when in either state. This
#' callback function should accept a single argument
#' a vector of character strings: the source code where
#' each character string is a line of code.
#' 
#' @examples
#' chg_magrittr_to_native <- function(lines){
#'   gsub("\\%>\\%", "|>", lines)
#' }
#' 
#' code <- 'function(x){
#'   x %>% 
#'     sum()
#' }'
#' 
#' chg_magrittr_to_native(code)
#' @export
inline_plugin <- function(dev, prod) {
  structure(
    list(dev = dev, prod = prod),
    class = c("rpp_inline_plugin", "rpp_plugin")
  )
}
