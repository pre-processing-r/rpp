# rpp

An approach to preprocessing R code.

## Goals

The purpose of this project is to provide infrastructure that helps generating the files in the `R/` directory in a package, either from other sources, or inline.
Applications include:

- True zero-cost assertions
- True zero-cost logging
- Verbatim code inlining and expansion to simplify metaprogramming
- Static type annotations

## Constraints

1. At any point in time, the code stored in version control should reflect the state most useful during *development*.
2. Ideally, the transformations occur during the following steps:
    - `R CMD build`: always
    - `pkgload::load_all()`: optionally, triggered through an environment variable, option, or configuration
    Specifically, the transformation must not require any dependencies during installation or execution time of the target package.
3. A no-op transformation should be fast.
    When transforming the same code twice, the second transformation should be instant.
    This is important for rapid development cycles.
4. Transformations should be pluggable, it should be easy to contribute plugins that add new transformations not considered yet
5. Package developers/contributors should get a clear error message if e.g. rpp is not installed
6. If files are generated, they should receive a "read-only" label that's picked up (at least) by RStudio; maybe it's worth marking the generated files as read-only too?

## Implementation options

This package would add/update infrastructure to the target package.
It also can provide code that is used during development, but not run time.

It seems that we need to hook into the package loading/building process.
I see two possible entry points

### `.Rprofile`

- What happens if users call `R CMD build --vanilla` ?
    Can we safeguard against this?
    
### `aaa.R`

- Safe with `--vanilla`
- Requires all `.R` files to be present in the directory
