
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
among other applications.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Q-language/rpp")
```

Once on [CRAN](https://CRAN.R-project.org), you can also install the
released version of rpp with:

``` r
install.packages("rpp")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(rpp)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/master/examples>.
