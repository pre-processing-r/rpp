#' Production State
#'
#' Switch a codebase to its production state.
#'
#' @details The production state of the code does
#' not include type checking or other checks, for
#' performance reasons. You may switch to the
#' development state of the code with [rpp_to_dev()],
#' but ensure you switch back to production when
#' pushing the code to online repositories or to CRAN.
#'
#' @name rpp_to_prod
#' @export
rpp_to_prod <- function() {
  roxygenize(roclets = "rpp::rpp_prod_roclet", load_code = "source")
}

#' @rdname roclets
#' @export
rpp_prod_roclet <- function() {
  roclet("rpp_prod")
}

#' @export
roclet_process.roclet_rpp_prod <- function(x, blocks, env, base_path, ...) {
  stopifnot(roxy_meta_get("load") %in% c("pkgload", "source"))

  list(
    plugins = get_plugins(),
    # FIXME: Add richer information from blocks
    files = rlang::set_names(dir("R", full.names = TRUE))
  )
}

#' @export
roclet_output.roclet_rpp_prod <- function(x, results, base_path, ...) {
  files <- names(results$files)
  plugins <- results$plugins
  prod <- compact(map(plugins, "prod"))

  walk(files, in_place_transform, prod)
}
