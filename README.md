
<!-- README.md is generated from README.Rmd. Please edit that file -->

# resquin

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/resquin)](https://CRAN.R-project.org/package=resquin)
[![R-CMD-check](https://github.com/MatRoth/resquin/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MatRoth/resquin/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/MatRoth/resquin/graph/badge.svg)](https://app.codecov.io/gh/MatRoth/resquin)
<!-- badges: end -->

## About

`resquin` (**res**ponse **qu**ality **in**dicators) provides functions
to calculate survey data quality indicators to help identifying
low-quality responses ([Bhaktha, Silber, and Lechner
2024](#ref-bhaktha); [Curran 2016](#ref-curran2016); [Vaerenbergh and
Thomas 2013](#ref-vanvaerenbergh2013)). `resp_styles()`,
`resp_distributions()`, `resp_nondifferentiation()` and `resp_patters()`
provide response quality indicators geared towards multi-item scales or
matrix questions. Both multi-item scales and matrix questions present
survey respondents with multiple questions which have the same response
format, meaning the same number and labeling of response options.

At the moment, `resquin` provides four functions:

- `resp_styles()` - Calculates response style indicators (e.g. extreme
  response style or middle response style).
- `resp_distributions()` - Calculates response distribution indicators
  (e.g. intra-individual mean and standard deviation over a set of
  survey questions).
- `resp_nondifferentiation()` - Calculates response nondifferentiation
  indicators. Nondifferentiation indicators primarily measure
  straightlining. The indicators differ in how straightlining is
  operationalized. Currently under development.
- `resp_patterns()` - Calculates response pattern indicators (e.g. long
  string analysis). Currently under development.

(A function on response times was also planed but may require its own
package. Data wrangling of response times is more complicated.)

For information on how to use `resquin` see the vignettes [Getting
started with
resquin](https://matroth.github.io/resquin/articles/getting_started_with_resquin.html)
and [resquin in
practice](https://matroth.github.io/resquin/articles/resquin_in_practice.html).

`resquin` is still under active development. Please use github
[issues](https://github.com/MatRoth/resquin/issues) to file questions
and bug reports or send them directly to <matthias.roth@gesis.org>. We
are happy to receive feedback!

## Installation

`resquin` is available via CRAN and github. To install `resquin` from
CRAN or github, you can use one of the following commands:

``` r
# Install resquin via CRAN
install.packages("resquin")

# Install development version of resquin with devtools
devtools::install_github("https://github.com/MatRoth/resquin")

# Install development version of resquin with pak
pak::pak("https://github.com/MatRoth/resquin")
```

## Getting started

To use `resquin`, supply a data frame containing survey responses in
wide format to either `resp_styles()`, `resp_distributions()`,
`resp_nondifferentiation()`, `resp_patterns()`.

``` r
# load resquin
library(resquin)

# A test data set with three items and ten respondents
testdata <- data.frame(
  var_a = c(1,4,3,5,3,2,3,1,3,NA),
  var_b = c(2,5,2,3,4,1,NA,2,NA,NA),
  var_c = c(1,2,3,NA,3,4,4,5,NA,NA))

testdata
#>    var_a var_b var_c
#> 1      1     2     1
#> 2      4     5     2
#> 3      3     2     3
#> 4      5     3    NA
#> 5      3     4     3
#> 6      2     1     4
#> 7      3    NA     4
#> 8      1     2     5
#> 9      3    NA    NA
#> 10    NA    NA    NA

# Calculate response style indicators per respondent
resp_styles(x = testdata,
            scale_min = 1,
            scale_max = 5) |> # Specify scale minimum and maximum
  round(2)
#> # Number of missings due to min_valid_responses equal to 1: 4
#> # A data frame:                                             10 × 6
#>       id   MRS   ARS   DRS   ERS  NERS
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1     1  0     0     1     0.67  0.33
#>  2     2  0     0.67  0.33  0.33  0.67
#>  3     3  0.67  0     0.33  0     1   
#>  4     4 NA    NA    NA    NA    NA   
#>  5     5  0.67  0.33  0     0     1   
#>  6     6  0     0.33  0.67  0.33  0.67
#>  7     7 NA    NA    NA    NA    NA   
#>  8     8  0     0.33  0.67  0.67  0.33
#>  9     9 NA    NA    NA    NA    NA   
#> 10    10 NA    NA    NA    NA    NA

# Calculate response distribution indicators per respondent
resp_distributions(x = testdata) |>
  round(2)
#> # Number of missings due to min_valid_responses equal to 1: 4
#> # A data frame:                                             10 × 7
#>       id  n_na prop_na ii_mean ii_sd ii_median mahal
#>    <dbl> <dbl>   <dbl>   <dbl> <dbl>     <dbl> <dbl>
#>  1     1     0    0       1.33  0.58         1  2.04
#>  2     2     0    0       3.67  1.53         4  1.6 
#>  3     3     0    0       2.67  0.58         3  1.38
#>  4     4     1    0.33   NA    NA           NA NA   
#>  5     5     0    0       3.33  0.58         3  0.97
#>  6     6     0    0       2.33  1.53         2  1.38
#>  7     7     1    0.33   NA    NA           NA NA   
#>  8     8     0    0       2.67  2.08         2  1.88
#>  9     9     2    0.67   NA    NA           NA NA   
#> 10    10     3    1      NA    NA           NA NA

# Calculate response nondifferentiation indicator per respondent
resp_nondifferentiation(x = testdata) |> 
  round(2)
#> # Number of missings due to min_valid_responses equal to 1: 4
#> # A data frame:                                             10 × 5
#>       id simple_nondifferentiation mean_root_pairs max_identical_rating
#>    <dbl>                     <dbl>           <dbl>                <dbl>
#>  1     1                         0            1                    0.67
#>  2     2                         0            0.21                 0.33
#>  3     3                         0            1                    0.67
#>  4     4                        NA           NA                   NA   
#>  5     5                         0            1                    0.67
#>  6     6                         0            0.21                 0.33
#>  7     7                        NA           NA                   NA   
#>  8     8                         0            0                    0.33
#>  9     9                        NA           NA                   NA   
#> 10    10                        NA           NA                   NA   
#> # ℹ 1 more variable: scale_point_variation <dbl>

# Calculate response pattern indicators
resp_patterns(x = testdata) |> 
  round(2)
#> # Number of missings due to min_valid_responses equal to 1: 4
#> # A data frame:                                             10 × 4
#>       id n_transitions mean_string_length longest_string_length
#>    <dbl>         <dbl>              <dbl>                 <dbl>
#>  1     1             2                  1                     1
#>  2     2             2                  1                     1
#>  3     3             2                  1                     1
#>  4     4            NA                 NA                    NA
#>  5     5             2                  1                     1
#>  6     6             2                  1                     1
#>  7     7            NA                 NA                    NA
#>  8     8             2                  1                     1
#>  9     9            NA                 NA                    NA
#> 10    10            NA                 NA                    NA
```

For a more information on how to use `resquin` see the vignettes
[Getting started with
resquin](https://matroth.github.io/resquin/articles/getting_started_with_resquin.html)
and [resquin in
practice](https://matroth.github.io/resquin/articles/resquin_in_practice.html).

# References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-bhaktha" class="csl-entry">

Bhaktha, Nivedita, Henning Silber, and Clemens Lechner. 2024.
“Characterizing Response Quality in Surveys with Multi-Item Scales: A
Unified Framework.” <https://osf.io/9gs67/>.

</div>

<div id="ref-curran2016" class="csl-entry">

Curran, Paul G. 2016. “Methods for the Detection of Carelessly Invalid
Responses in Survey Data.” *Journal of Experimental Social Psychology*
66 (September): 4–19. <https://doi.org/10.1016/j.jesp.2015.07.006>.

</div>

<div id="ref-vanvaerenbergh2013" class="csl-entry">

Vaerenbergh, Y. van, and T. D. Thomas. 2013. “Response Styles in Survey
Research: A Literature Review of Antecedents, Consequences, and
Remedies.” *International Journal of Public Opinion Research* 25 (2):
195–217. <https://doi.org/10.1093/ijpor/eds021>.

</div>

</div>
