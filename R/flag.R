#' Flag respondents based on response quality indicators
#'
#' @param x A data frame containing survey responses in wide format. For more information
#' see section "Data requirements" below.
#' @param min_valid_responses Numeric between 0 and 1 of length 1. Defines the share of valid responses
#' a respondent must have to calculate response pattern indicators. Default is 1.
#' @param defined_patterns An optional vector of integer values with patterns to search for or a list of integer vectors.
#'  Will not be computed if not specified or if an empty vector is supplied.
#' @param arbitrary_patterns An optional vector of integer values or a list containing vectors of
#' integer values. The values determine the pattern that should be searched for.
#' Will not be computed if not specified or if 0 is supplied.
#' @param min_repetitions: Defines number of times an arbitrary pattern
#'    has to be repeated to be retained in the results. Must be larger or equal to 2.
#' @param id default is `True`. If the default value is supplied
#' a column named `id` with integer ids will be created. If `False` is supplied, no id column will be created. Alternatively, a numeric or character vector of unique values identifying
#' each respondent can be supplied. Needs to be of the same length as the number of rows of `x`.
#'
