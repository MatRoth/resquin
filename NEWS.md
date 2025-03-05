# resquin (development version)
* Added `resp_nondifferentiation()` as a new function for calculating 
straightlining indicators.
* Added `resp_nondifferentiation()` to readme and getting started vignette.
* Added `resp_patterns()` as a new function.
* Added `id` column to all outputs to make it easier to identify respondents or
merge function outputs to data frames. `id` is either `True` for an integer id,
`False` for no `id` column, or a vector of unique integer or character values
identifying each respondent.

# resquin 0.0.2
* Changes in response to CRAN team. Changed license description in DESCRIPTION
and removed License.md
* Removed warning on development version at the start of the readme.md

# resquin 0.0.1
* Initial cran submission.

# resquin 0.0.0.9000
* Preparation for intial CRAN submission.
* Contains two functions 'resp_styles' and 'resp_distributions'
