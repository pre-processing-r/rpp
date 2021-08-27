#' @export
rpp_dev <- function() {
  roxygenize(roclets = "rpp_dev_roclet", load_code = "source")
}

#' @export
rpp_dev_roclet <- function() {
  roclet("rpp_dev")
}

#' @export
roclet_process.roclet_rpp_dev <- function(x, blocks, env, base_path, ...) {
  stopifnot(roxy_meta_get("load") %in% c("pkgload", "source"))

  plugins_text <- desc::desc_get("Config/rpp/plugins")
  plugins <- eval(parse(text = plugins_text), baseenv())
  stopifnot(rlang::is_bare_list(plugins))

  list(
    plugins = plugins,
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
