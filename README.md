
<!-- README.md is generated from README.Rmd. Please edit that file -->

# resquin

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/resquin)](https://CRAN.R-project.org/package=resquin)

<!-- badges: end -->

## About

`resquin` (**res**ponse **qu**ality **in**dicators) provides functions
to calculate survey data quality indicators to help identifying
low-quality responses Vaerenbergh and Thomas (2013). `resp_styles()`,
`resp_distributions()` and `resp_patterns()` (not yet implemented)
provide response quality indicators geared towards matrix questions.
Matrix questions present survey respondents with multiple questions
which have the same response format, meaning the same number and
labeling of response options.

At the moment, `resquin` provides two functions:

- `resp_styles()` - Calculates response style indicators (e.g. extreme
  response style or middle response style).
- `resp_distributions()` - Calculates response distribution indicators
  (e.g. within person mean and standard deviation over a set of survey
  questions).

Two more functions are planned:

- `resp_patterns` - Calculates response pattern indicators (e.g.
  straightlining)
- `resp_times` - Calculates response time indicators (e.g. median item
  response time)

## Installation

`resquin` is available via github. To install `resquin` from github, you
can use one of the following commands:

``` r
# Installing resquin with devtools
devtools::install_github("https://github.com/MatRoth/resquin")

# Installing resquin with pak
pak::pak("https://github.com/MatRoth/resquin")
```

## Getting started

Functions in `resquin` calculate response quality indicators for survey
data stored in a data frame or tibble. The functions assume that the
input data frame is structured in the following way:

- The data frame is in wide format, meaning each row represents one
  respondent, each column represents one variable.
- All variables have the same number of response options.
- The variables are in same the order as the questions respondents saw
  while taking the survey.
- Reverse keyed variables are in their original form. No items were
  recoded.
- All responses have integer values.
- Missing values are set to `NA`.

### Example dataset of survey responses

Consider the following (fake) data set of survey responses.

``` r
# A small test data set with three items and ten respondents
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
```

The data set contains responses to three survey questions (var_a,var_b
and var_c) from ten respondents. All three survey question allow
responses on a scale from 1 to 5. Some respondents have missing values,
which are set to `NA`.

Lets use this data set to calculate response quality indicators.

### `resp_styles()`: Response style indicators

Response styles capture systematic shifts in respondents response
behavior. For example, respondents with an extreme response style may
only choose the lowest and highest categories (in our example 1 and 5)
while mid-point responder only choose the midpoint of a scale (in our
example 3).

To calculate response styles we can use the `resp_styles()` function.
First, we need to specify our data argument `x`. Then, we need to
specify the minimum and maximum of the scales used in our questionnaire
(`scale_min` and `scale_max` respectively). Remember that all questions
included must have the same number of response options. We will discuss
the arguments `min_valid_responses` and `normalize` later.

``` r
library(resquin)
# Calculating response style indicators for all respondents with no missing values
results_response_styles <- resp_styles(
  x = testdata,
  scale_min = 1,
  scale_max = 5,
  min_valid_responses = 1, # Excludes respondents with less than 100% valid responses
  normalize = T)  # Presents results in percent of all responses

round(results_response_styles,2)
#>     MRS  ARS  DRS  ERS NERS
#> 1  0.00 0.00 1.00 0.67 0.33
#> 2  0.00 0.67 0.33 0.33 0.67
#> 3  0.67 0.00 0.33 0.00 1.00
#> 4    NA   NA   NA   NA   NA
#> 5  0.67 0.33 0.00 0.00 1.00
#> 6  0.00 0.33 0.67 0.33 0.67
#> 7    NA   NA   NA   NA   NA
#> 8  0.00 0.33 0.67 0.67 0.33
#> 9    NA   NA   NA   NA   NA
#> 10   NA   NA   NA   NA   NA
```

The resulting data frame contains five columns corresponding to the
middle response style (MRS), acquiescence response style (ARS),
disaquiescence response style (DRS), extreme response style (ERS), and
non-extreme response style (NERS) - you can learn more about the
response styles in the help file of the function using `?resp_styles`.

Each respondent receives one value for each indicator, given that they
can be calculated. Because `normalize` is set to `TRUE`the values are
expressed as the share of responses of a respondent that can be
attributed to a response style. For example, respondent one has an ERS
value of 0.67 meaning that two out of three responses can be identified
as extreme responses. On the other hand, respondent one does not have
any mid-point response, leading to a value of 0 in the MRS column.

Instead of calculating proportions, we can extract the counts of
responses that can be attributed to a response option by setting
`normalize` to `FALSE`.

Finally, we can decide to include or exclude respondents from receiving
response style values by setting `min_valid_responses`, which can take
values from 0 to 1. `min_valid_responses` sets the share of valid
responses (i.e. non-missing responses) a respondent must have to receive
response style values. A value of 0 indicates that response style values
should be calculated for all respondents, regardless of whether or not
they have missing values. A value of 1 indicates that response styles
should only be calculated for respondents who have valid responses on
all variables. Values between 0 and 1 indicate the share of responses
that need to be valid to be included in the response style calculations.

### `resp_distributions()`: Within respondent response distribution indices

`resp_distributions()` calculates indices which reflect the location and
variability of responses within a respondent. `resp_distributions()`
works similar to `resp_styles()`: We need to specify the data argument
and we can include or exclude respondents from the calculations based on
amount of missing data they exhibit (for an explanation see paragraph
above).

``` r
# Calulating response distribution indicators for all respondents with no missing values
results_resp_distributions <- resp_distributions(
  x = testdata,
  min_valid_responses = 0) # Excludes respondents with less than 100% valid responses

round(results_resp_distributions,2)
#>    n_valid n_na prop_na wr_mean wr_sd wr_var wr_median wr_median_abs_dev mahal
#> 1        3    0    0.00    1.33  0.58   0.33       1.0               0.0  2.27
#> 2        3    0    0.00    3.67  1.53   2.33       4.0               1.0  1.68
#> 3        3    0    0.00    2.67  0.58   0.33       3.0               0.0  1.05
#> 4        2    1    0.33    4.00  1.41   2.00       4.0               1.0  2.21
#> 5        3    0    0.00    3.33  0.58   0.33       3.0               0.0  1.24
#> 6        3    0    0.00    2.33  1.53   2.33       2.0               1.0  1.29
#> 7        2    1    0.33    3.50  0.71   0.50       3.5               0.5  0.71
#> 8        3    0    0.00    2.67  2.08   4.33       2.0               1.0  2.24
#> 9        1    2    0.67    3.00   NaN    NaN       3.0               0.0  0.24
#> 10       0    3    1.00      NA    NA     NA        NA                NA    NA
```

The resulting data frame contains eight columns:

- n_valid: the number of valid responses
- n_na: the number of missing responses
- prop_na: the proportion of missing responses of all responses
- ips_mean: the ipsatized (within respondent) mean over all responses
- ips_median: the ipsatized (within respondent) median over all
  responses
- ips_median_abs_dev: the ipsatized (within respondent) median deviation
  from the ipsaized median
- ips_sd: the ipsatized (within respondent) standard deviation over all
  responses
- mahal: the mahalanobis distance of the respondent across all responses

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-bhaktha" class="csl-entry">

Bhaktha, Nivedita, Henning Silber, and Clemens Lechner. n.d.
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
