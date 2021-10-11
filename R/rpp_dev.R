#' Development State
#' 
#' Switch to codebase to the development state.
#' 
#' @details The development state of the codebase
#' may include type checking and more but cannot
#' be submitted to CRAN and impacts performances
#' of runtime code, ensure you switch back to 
#' the production version with [rpp_to_prod()]
#' after development work is done.
#' 
#' @export
rpp_to_dev <- function() {
  roxygenize(roclets = "rpp::rpp_dev_roclet", load_code = "source")
}

#' @export
rpp_dev_roclet <- function() {
  roclet("rpp_dev")
}

#' @export
roclet_process.roclet_rpp_dev <- function(x, blocks, env, base_path, ...) {
  stopifnot(roxy_meta_get("load") %in% c("pkgload", "source"))

  list(
    plugins = get_plugins(),
    # FIXME: Add richer information from blocks
    files = rlang::set_names(dir("R", full.names = TRUE))
  )
}

#' @export
roclet_output.roclet_rpp_dev <- function(x, results, base_path, ...) {
  files <- names(results$files)
  plugins <- results$plugins
  dev <- compact(map(plugins, "dev"))

  walk(files, in_place_transform, dev)
}
