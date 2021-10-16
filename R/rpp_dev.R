#' Development State
#'
#' Switch a codebase to the development state.
#'
#' @details The development state of the codebase
#' may include type checking and more but cannot
#' be submitted to CRAN and impacts performance
#' of runtime code.
#' Also, currently this state is not meant to be committed to version control;
#' this may change in further versions.
#' Ensure you switch back to
#' the production version with [rpp_to_prod()]
#' after development work is done.
#'
#' @name rpp_to_dev
#' @export
rpp_to_dev <- function() {
  roxygenize(roclets = "rpp::rpp_dev_roclet", load_code = "source")
}

#' Roclets
#'
#' These functions implement [roxygen2::roclet()]s for integration
#' with the roxygen2 package.
#'
#' @rdname roclets
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
