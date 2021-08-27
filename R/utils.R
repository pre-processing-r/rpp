get_plugins <- function() {
  plugins_text <- desc::desc_get("Config/rpp/plugins")
  plugins <- eval(parse(text = plugins_text), baseenv())
  stopifnot(rlang::is_bare_list(plugins))
}

in_place_transform <- function(path, transforms) {
  text <- brio::read_lines(path)
  for (f in transforms) {
    text <- f(text)
  }
  brio::write_lines(text, path)
}
