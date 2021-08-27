#' @export
rpp_prod <- function() {
  roxygenize(roclets = "rpp_prod_roclet", load_code = "source")
}

#' @export
rpp_prod_roclet <- function() {
  roclet("rpp_prod")
}

#' @export
roclet_process.roclet_rpp_prod <- function(x, blocks, env, base_path, ...) {
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
roclet_output.roclet_rpp_prod <- function(x, results, base_path, ...) {
  files <- names(results$files)
  plugins <- results$plugins
  prod <- compact(map(plugins, "prod"))

  walk(files, in_place_transform, prod)
}

in_place_transform <- function(path, transforms) {
  text <- brio::read_lines(path)
  for (f in transforms) {
    text <- f(text)
  }
  brio::write_lines(text, path)
}
