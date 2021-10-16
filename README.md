
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rpp

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/rpp)](https://CRAN.R-project.org/package=rpp)
<!-- badges: end -->

The goal of rpp is to provide a framework for preprocessing R code.
Ultimately, this package aims at supporting static type checking for R,
among other applications. Currently, two plugins exist: dynamic type
checking, and zero-cost assertions.

## Overview

### Development vs. production

This package operates on the notion of different source code “modes”:

-   **Development** (or dev): what the developer of the package edits
-   **Production** (or prod): the code that is run by typical users

Expensive checks can be enabled in development mode, while production
code is kept lean and fast. In production mode, all checks are
completely removed (elided) from the source code. Only production code
ends up in version control, this ensures compatibility with existing
tooling. Code can be quickly and losslessly converted between
development and production modes with `rpp::rpp_to_dev()` and
`rpp::rpp_to_prod()`.

### Plugins

The rpp package does not implement any code transformations. Rather, it
provides the infrastructure for plugins which are responsible for
converting development code to production code and back. Currently, two
plugins exist (in forks of existing packages in this GitHub
organization):

-   {[typed](https://github.com/Q-language/typed)} provides dynamic type
    checking via the `typed::rpp_elide_types()` plugin
-   {[chk](https://github.com/Q-language/chk)} provides zero-cost
    assertions via the `chk::rpp_elide_chk_calls()` plugin

Plugins are configured in the `DESCRIPTION` file.

## Installation

Install the development version of rpp and the associated packages from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Q-language/rpp")
devtools::install_github("Q-language/typed")
devtools::install_github("Q-language/chk")
```

Once on [CRAN](https://CRAN.R-project.org), you can also install the
released version of rpp with:

``` r
install.packages("rpp")
```

## Example

``` r
library(typed)
#> 
#> Attaching package: 'typed'
#> The following object is masked from 'devtools_shims':
#> 
#>     ?
#> The following object is masked from 'package:utils':
#> 
#>     ?
```

The following function makes use of dynamic type assertions provided by
the {typed} package:

``` r
foo <- Character()? function(x = ?Character()) {
  Character()? out <- paste("foo:", x)
  out
}
```

This is still valid R code, because {typed} overloads the `?` operator.
The function can only be called with a character vector, other types
give an error:

``` r
foo("bar")
#> [1] "foo: bar"
foo(1)
#> Error: In `foo(1)` at `check_arg(x, Character())`:
#> wrong argument to function, type mismatch
#> `typeof(value)`: "double"   
#> `expected`:      "character"
foo(mean)
#> Error: In `foo(mean)` at `check_arg(x, Character())`:
#> wrong argument to function, type mismatch
#> `typeof(value)`: "closure"  
#> `expected`:      "character"
```

These checks are useful, but slow down the code. If this function lives
in a package that is configured with the `typed::rpp_elide_types()`
plugin, running `rpp::rpp_to_prod()` results in the following code:

``` r
foo <-              function(x               ) { # !q foo <- Character()? function(x = ?Character()) {
  out <- paste("foo:", x)                        # !q   Character()? out <- paste("foo:", x)
  out
}
```

Running `rpp::rpp_to_dev()` brings back the original code with the
checks. The production version is not particularly pretty, but does the
job.

The fork of the {[chk](https://github.com/Q-language/chk)} package in
this organization is configured for use with rpp. Clone the repository,
start an R session, and run `rpp:rpp_to_dev()` and `rpp::rpp_to_prod()`
to see rpp in action.

## Further reading

-   To set up rpp for an existing or new project, and to learn about the
    existing plugins in more detail, see `vignette("rpp")`
-   The creation of a new plugin and the integration with roxygen2 is
    described in `vignette("plugins")`
-   An outlook on future development is presented in
    `vignette("roadmap")`
