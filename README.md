
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rpp

<!-- badges: start -->
<!-- badges: end -->

An approach to preprocessing R code.

## Goals

The purpose of this project is to provide infrastructure that helps
generating the files in the `R/` directory in a package, either from
other sources, or inline. Applications include:

-   True zero-cost assertions
-   True zero-cost logging
-   Verbatim code inlining and expansion to simplify metaprogramming
-   Dynamic type checking
-   Static type annotations

## Location of the “source of truth”

### Inline

Works for assertions and logging.

Prerequisite: we don’t add or remove extra lines.

Pros: doesn’t need any extra files

Cons: transformation must be bidirectional (or at least work in the
reverse way)

### Parallel directory

Required for inlining/expansion and static type annotations.

Pros: Works for all cases

Cons: Entirely new infrastructure

## Constraints

1.  At any point in time, the code stored in version control should
    reflect the state most useful during *production*.
    -   Rationale: `devtools::install_github()` should “just work” and
        give you a package that you can already use.
2.  Ideally, the transformations occur during the following steps:
    -   `devtools::document()`: from parallel directory to `R/`, and
        also prepare the inline code for production
    -   `pkgload::load_all()`: this seems the most challenging part, do
        we need a hook into `load_all()` ?

    No transformation occurs during installation or execution time of
    the target package!
3.  A no-op transformation should be fast. When transforming the same
    code twice, the second transformation should be instant. This is
    important for rapid development cycles.
4.  Transformations should be pluggable, it should be easy to contribute
    plugins that add new transformations not considered yet
5.  Package developers/contributors should get a clear error message if
    e.g. rpp is not installed
6.  If files are generated, they should receive a “read-only” label
    that’s picked up (at least) by RStudio; maybe it’s worth marking the
    generated files as read-only too?

## Prototype

Three repositories in this organization:

-   rpp: Preprocessing framework
    -   New development, this repository
-   [chk](https://github.com/Q-language/chk): Use case “True zero-cost
    assertions” and working example
    -   Private fork of
        [poissonconsulting/chk](https://github.com/poissonconsulting/chk)
-   [typed](https://github.com/Q-language/typed): Use case “Dynamic type
    checking”
    -   Private fork of
        [moodymudskipper/typed](https://github.com/moodymudskipper/typed)

Features:

-   Inline code transformation between “dev” and “prod” mode
-   Plugin concept
-   chk plugin
-   typed plugin
-   Integration with roxygen2

### Inline code transformation between “dev” and “prod” mode

For now, only manual inline transformations are supported. Code is
expected to reside in the `R/` directory and will be written to that
directory. Integration with pkgload may come at a later stage.

The “prod” mode is what should be committed to version control and
contain optimized code. In our example, all checks are elided in “prod”
mode, and maintained as comments on the same line so that they can be
brought back later.

The “dev” mode is what should be used when working on a package. All
checks are active.

A development workflow could look like this:

-   Clone the package
-   Run tests
-   Switch to “dev” mode: `rpp::rpp_to_dev()`
-   Run tests
-   Implement
-   Run tests
-   Switch to “prod” mode: `rpp::rpp_to_prod()`
-   Commit

``` r
library(rpp)

path <- file.path(tempdir(), "chk")
gert::git_clone("git@github.com:Q-language/chk", path = path)
oldwd <- setwd(path)
gert::git_status()
#> [1] file   status staged
#> <0 rows> (or 0-length row.names)

# First-time initialization is noisy
suppressMessages(rpp::rpp_to_dev())
gert::git_status()
#>                file   status staged
#> 1            R/cc.R modified  FALSE
#> 2    R/check-data.R modified  FALSE
#> 3     R/check-dim.R modified  FALSE
#> 4    R/check-dirs.R modified  FALSE
#> 5   R/check-files.R modified  FALSE
#> 6     R/check-key.R modified  FALSE
#> 7   R/check-names.R modified  FALSE
#> 8  R/check-values.R modified  FALSE
#> 9       R/chk-dir.R modified  FALSE
#> 10      R/chk-ext.R modified  FALSE
#> 11     R/chk-file.R modified  FALSE
#> 12 R/comment-chks.R modified  FALSE
#> 13   R/deprecated.R modified  FALSE

rpp::rpp_to_prod()
gert::git_status()
#> # A tibble: 0 × 3
#> # … with 3 variables: file <chr>, status <chr>, staged <lgl>

setwd(oldwd)
```

### Plugin concept

rpp responds to the `Config/rpp/plugins` configuration setting in
`DESCRIPTION`. This setting indicates which plugins to run. The setting
for chk looks like this:

    Config/rpp/plugins: list(typed::rpp_elide_types(), chk::rpp_elide_chk_calls())

A plugin is a function that returns an object obtained from
`rpp::inline_plugin()`. The plugin constructor expects two functions
that perform the transformation to “dev” and “prod” mode. Currently the
transformation functions expect a character vector that contains the
code, and return a character vector with modified code. Eventually these
functions will get access to roxygen2 tags, so that e.g. different
transformations can be applied to exported functions: the developer may
wish to keep all checks in place for exported functions, and elide them
only from private functions.

### chk plugin

The chk package provides a set of assertions, functions that start with
`chk_`.

``` r
chk::chk_atomic(1:3)
chk::chk_atomic(list())
#> Error: `list()` must be atomic.
```

The rpp plugin in this package elides calls to `chk_*()` functions and
replaces them with a comment: `chk_atomic(x)` becomes
`# !chk chk_atomic(x)` for production.

``` r
chk_plugin <- chk::rpp_elide_chk_calls()
prod_code <- chk_plugin$prod("chk_atomic(x)")
prod_code
#> [1] "# !chk chk_atomic(x)"
chk_plugin$dev(prod_code)
#> [1] "chk_atomic(x)"
```

The transformation is implemented with a search-replace operation based
on regular expressions.

### typed plugin

The typed package implements a framework for dynamic type assertions.
These assertions are evaluated at run time. Assertions are declared
using the `?` operator.

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

foo <- Character()? function(x = ?Character()) {
  Character()? out <- paste0("foo: x")
  out
}

foo(letters[1:3])
#> [1] "foo: x"
foo(1:3)
#> Error: In `foo(1:3)` at `check_arg(x, Character())`:
#> wrong argument to function, type mismatch
#> `typeof(value)`: "integer"  
#> `expected`:      "character"
foo
#> # typed function
#> function (x) 
#> {
#>     check_arg(x, Character())
#>     declare("out", Character(), value = paste0("foo: x"))
#>     check_output(out, Character())
#> }
#> <bytecode: 0x1387c0ae8>
#> # Return type: Character()
#> # Arg types:
#> # x: Character()
```

The rpp plugin implemented by {typed} elides the type declarations and
pastes the original code as a comment on the same line. It is
implemented by walking the parse data returned from
`utils::parseData()`, using an approach very similar to the {styler}
package.

``` r
code <- '
foo <- (Character()? function(x = ?Character()) {
  Character()? out <- paste0("foo: x")
  out
})
'
code <- strsplit(code, "\n")[[1]]

typed_plugin <- typed::rpp_elide_types()
prod <- typed_plugin$prod(code)
writeLines(prod)
#> 
#> foo <- (function(x               ) { # !q foo <- (Character()? function(x = ?Character()) {
#>   out <- paste0("foo: x") # !q   Character()? out <- paste0("foo: x")
#>   out
#> })
writeLines(typed_plugin$dev(prod))
#> 
#> foo <- (Character()? function(x = ?Character()) {
#>   Character()? out <- paste0("foo: x")
#>   out
#> })
```

### Integration with roxygen2

rpp implements a roclet, a plugin to the roxygen2 package. This offers
the following advantages:

-   Integration with established infrastructure
-   Conversion to “prod” mode as part of `devtools::document()`
-   Access to interpreted roxygen2 tags

To integrate this roclet into RStudio (Ctrl + Shift + D), a manual
change had to be performed in `chk.Rproj`:

    PackageRoxygenize: rd,collate,namespace,rpp::rpp_prod_roclet

## Project proposal

The prototype demonstrates the practical feasibility of enhancing R to
support static typing, without requiring much involvement from R core.
Below is a sketch of possible milestones for a project funded by the R
Consortium. The project is already split into three parts. It’s unlikely
that a big project is funded right away, smaller slices increase the
chance of success.

### Motivation

-   Static typing helps avoid errors early
-   General-purpose code transformation has many applications, no
    framework exists in R to date

### First slice: Minimum viable product

1.  Enhance {typed} towards a robust type system
    -   complex structures
    -   column specification for data frames
    -   size ranges for vectors?
    -   …
2.  Proposal and infrastructure for type inference
    -   Proof of concept: {dm}, other packages?
3.  Other applications for rpp
    -   Zero-cost logging
4.  Infrastructure wrapping
    -   rpp::load\_all(), rpp::test\_local(), rpp::build()
5.  Stabilization
    -   dogfood in {dm} and other packages

### Second slice: Useful product

1.  Integration into toolchain — pkgload, R CMD build
2.  Type annotations for base
3.  Infrastructure to derive type annotations for custom packages
4.  Sketch for static type checking
5.  Faster parser, custom syntax
6.  Request for user feedback

### Third slice: A new language

1.  Type annotations for recommended packages
2.  Type annotations for a choice of popular packages
3.  IDE integration
4.  GitHub integration
5.  Sourcegraph integration
6.  Better static type checking
7.  Adoption
