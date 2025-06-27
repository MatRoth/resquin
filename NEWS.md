# resquion 0.1.1
* Changed the way the mahalanobis distance is calculcated in `resp_distributions()`,
if missing values are allowed. Now within respondent mean imputation is used.
Before missing values were turned to a value of 0, which is wrong in almost any
case and would have skewed the results of respondents with missing values.
Mean imputation is not an ideal solution, but it allows the observed data
to influence the value of the mahalanobis distance value under missing data. 
Because within respondent mean imputation is not ideal, a new section
in the description is added to call for caution when interpreting the mahalanobis
distance values produced by `resp_distributions()` if `min_valid_responses` is
smaller than 1.
* Polished documentation (fixing typos etc.)
* Added vignette on flagging respondents with `flag_resp()`.
* Added a disclaimer for handling of missing data in `resp_nondifferentiation`.
* Added documentation on s3 methods.
* Fixed bug in s3 print function which would crash if `resp_styles()` was used
on even numbered response scales.
* Added tests for functions added since 0.0.2.
* Now depends on R version being >= to R version 4.1.


# resquin 0.1.0
* Added `resp_patterns()` and `resp_nondifferentiation()` as a new function.
* Added `id` column to all outputs to make it easier to identify respondents or
merge function outputs to data frames. `id` is either `True` for an integer id,
`False` for no `id` column, or a vector of unique integer or character values
identifying each respondent.
* Added `flag_resp()` function to quickly create and compare different flagging
strategies based on response quality indicators.
* Added s3 types to outputs of `resp_*()` and `flag_resp()` functions.
* Added s3 print, summary and plot methods for outputs of `resp_*()` functions.
* Added s3 summary method for `flag_resp()` output.

# resquin 0.0.2
* Changes in response to CRAN team. Changed license description in DESCRIPTION
and removed License.md
* Removed warning on development version at the start of the readme.md

# resquin 0.0.1
* Initial cran submission.

# resquin 0.0.0.9000
* Preparation for intial CRAN submission.
* Contains two functions 'resp_styles' and 'resp_distributions'
