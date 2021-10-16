<!-- README.md is generated from README.Rmd. Please edit that file -->

# [rpp](https://rpp.q-lang.org/)

<!-- badges: start -->

[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

The goal of rpp is to provide a framework for preprocessing R code. Ultimately, this package aims at supporting static type checking for R, among other applications. At this time, dynamic type checking and zero-cost assertions are supported with the help of two other packages, {typed} and {chk}.

## Motivation

R is a weakly-typed interpreted language: variables can hold objects of any time, there is no explicit compilation stage, and no checks are carried out during run time. This is great for interactive ad-hoc analysis, but can make complex projects more difficult to maintain and debug. In contrast, in strongly-typed languages, the type of each variable is declared beforehand. Adding a static type checking layer to R would make it easier to improve stability in complex projects. With preprocessing, this can be done with no cost at runtime.

## Development vs. production

This package operates on the notion of different source code “modes”:

-   **Development** (or dev): the code the developer of the package works on
-   **Production** (or prod): the code that is run by typical users

Expensive checks can be enabled in development mode, while production code is kept lean and fast. In production mode, all checks are completely removed (elided) from the source code. Only production code ends up in version control, this ensures compatibility with existing tooling. Code can be quickly and losslessly converted between development and production modes with [`rpp::rpp_to_dev()`](https://rpp.q-lang.org/reference/rpp_to_dev.html) and [`rpp::rpp_to_prod()`](https://rpp.q-lang.org/reference/rpp_to_prod.html).

## Plugins

The rpp package does not implement any code transformations. Rather, it provides the infrastructure for plugins which are responsible for converting development code to production code and back. Currently, two plugins exist (in forks of existing packages in this GitHub organization):

-   {[typed](https://github.com/Q-language/typed)} provides dynamic type checking via the `typed::rpp_elide_types()` plugin
-   {[chk](https://github.com/Q-language/chk)} provides zero-cost assertions via the [`chk::rpp_elide_chk_calls()`](https://rdrr.io/pkg/chk/man/rpp_elide_chk_calls.html) plugin

Plugins are configured in the `DESCRIPTION` file.

## Installation

Install the development version of rpp and the associated packages from [GitHub](https://github.com/) with:

<pre class='chroma'>
<span class='c'># install.packages("devtools")</span>
<span class='nf'>devtools</span><span class='nf'>::</span><span class='nf'><a href='https://devtools.r-lib.org//reference/remote-reexports.html'>install_github</a></span><span class='o'>(</span><span class='s'>"Q-language/rpp"</span><span class='o'>)</span>
<span class='nf'>devtools</span><span class='nf'>::</span><span class='nf'><a href='https://devtools.r-lib.org//reference/remote-reexports.html'>install_github</a></span><span class='o'>(</span><span class='s'>"Q-language/typed"</span><span class='o'>)</span>
<span class='nf'>devtools</span><span class='nf'>::</span><span class='nf'><a href='https://devtools.r-lib.org//reference/remote-reexports.html'>install_github</a></span><span class='o'>(</span><span class='s'>"Q-language/chk"</span><span class='o'>)</span></pre>

Once on [CRAN](https://CRAN.R-project.org), you can also install the released version of rpp with:

<pre class='chroma'>
<span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"rpp"</span><span class='o'>)</span></pre>

## Example

<pre class='chroma'>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/moodymudskipper/typed'>typed</a></span><span class='o'>)</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Attaching package: 'typed'</span>
<span class='c'>#&gt; The following object is masked from 'devtools_shims':</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;     ?</span>
<span class='c'>#&gt; The following object is masked from 'package:utils':</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt;     ?</span></pre>

The following function makes use of dynamic type assertions provided by the {typed} package:

<pre class='chroma'>
<span class='nv'>foo</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/typed/man/assertion_factories.html'>Character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>?</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>=</span> <span class='o'>?</span><span class='nf'><a href='https://rdrr.io/pkg/typed/man/assertion_factories.html'>Character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>{</span>
  <span class='nf'><a href='https://rdrr.io/pkg/typed/man/assertion_factories.html'>Character</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>?</span> <span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"foo:"</span>, <span class='nv'>x</span><span class='o'>)</span>
  <span class='nv'>out</span>
<span class='o'>}</span></pre>

This is still valid R code, because {typed} overloads the `?` operator. The function can only be called with a character vector, other types give an error:

<pre class='chroma'>
<span class='nf'>foo</span><span class='o'>(</span><span class='s'>"bar"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "foo: bar"</span>
<span class='nf'>foo</span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>
<span class='c'>#&gt; Error: In `foo(1)` at `check_arg(x, Character())`:</span>
<span class='c'>#&gt; wrong argument to function, type mismatch</span>
<span class='c'>#&gt; `typeof(value)`: <span style='color: #00BB00;'>"double"</span>   </span>
<span class='c'>#&gt; `expected`:      <span style='color: #00BB00;'>"character"</span></span>
<span class='nf'>foo</span><span class='o'>(</span><span class='nv'>mean</span><span class='o'>)</span>
<span class='c'>#&gt; Error: In `foo(mean)` at `check_arg(x, Character())`:</span>
<span class='c'>#&gt; wrong argument to function, type mismatch</span>
<span class='c'>#&gt; `typeof(value)`: <span style='color: #00BB00;'>"closure"</span>  </span>
<span class='c'>#&gt; `expected`:      <span style='color: #00BB00;'>"character"</span></span></pre>

These checks are useful, but slow down the code. If this function lives in a package that is configured with the `typed::rpp_elide_types()` plugin, running [`rpp::rpp_to_prod()`](https://rpp.q-lang.org/reference/rpp_to_prod.html) results in the following code:

<pre class='chroma'>
<span class='nv'>foo</span> <span class='o'>&lt;-</span>              <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>               <span class='o'>)</span> <span class='o'>{</span> <span class='c'># !q foo &lt;- Character()? function(x = ?Character()) {</span>
  <span class='nv'>out</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste</a></span><span class='o'>(</span><span class='s'>"foo:"</span>, <span class='nv'>x</span><span class='o'>)</span>                        <span class='c'># !q   Character()? out &lt;- paste("foo:", x)</span>
  <span class='nv'>out</span>
<span class='o'>}</span></pre>

Running [`rpp::rpp_to_dev()`](https://rpp.q-lang.org/reference/rpp_to_dev.html) brings back the original code with the checks. The production version is not particularly pretty, but does the job.

The fork of the {[chk](https://github.com/Q-language/chk)} package in this organization is configured for use with rpp. Clone the repository, start an R session, and run [`rpp::rpp_to_dev()`](https://rpp.q-lang.org/reference/rpp_to_dev.html) and [`rpp::rpp_to_prod()`](https://rpp.q-lang.org/reference/rpp_to_prod.html) to see rpp in action.

## Further reading

-   To set up rpp for an existing or new project, and to learn about the existing plugins in more detail, see `vignette("rpp", package = "rpp")`
-   The creation of a new plugin and the integration with roxygen2 is described in [`vignette("plugins", package = "rpp")`](https://rpp.q-lang.org/articles/plugins.html)
-   An outlook on future development is presented in `vignette("roadmap", package = "rpp")`
