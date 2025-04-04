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
