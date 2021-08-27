#' @export
rpp_roclet <- function() {
  roclet("rpp")
}

#' @export
roclet_process.roclet_rpp <- function(x, blocks, env, base_path, ...) {
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
roclet_output.roclet_rpp <- function(x, results, base_path, ...) {
  files <- names(results$files)
  plugins <- results$plugins
  clean <- compact(map(plugins, "clean"))

  walk(files, in_place_transform, clean)
}

in_place_transform <- function(path, transforms) {
  text <- brio::read_lines(path)
  for (f in transforms) {
    text <- f(text)
  }
  brio::write_lines(text, path)
}
