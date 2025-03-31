## Response pattern indicators (under development)
#
#' Compute response pattern indicators (under development)
#'
#' Compute response pattern indicators for responses to multi-item scales or matrix
#' questions.
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
#' @param min_repetitions Defines number of times an arbitrary pattern
#'    has to be repeated to be retained in the results. Must be larger or equal to 2.
#' @param id default is `True`. If the default value is supplied
#' a column named `id` with integer ids will be created. If `False` is supplied, no id column will be created. Alternatively, a numeric or character vector of unique values identifying
#' each respondent can be supplied. Needs to be of the same length as the number of rows of `x`.
#'
#' @details
#' The following response distribution indicators are calculated per respondent:
#' \itemize{
#'    \item n_transitions: Number of times two consecutive response options differ.
#'    \item mean_string_length: Mean length of strings of identical answers.
#'    \item longest_string_length: Longest length of string of identical answers.
#'    \item (optional) defined_pattern: A list column that contains one named vector
#'    per respondent. The names of the vector are repeating patterns found in the
#'    responses of a respondent. The values of the vector are how often the pattern
#'    specified in the argument "defined_patterns" occurs. See section "Defined patterns" for
#'    more information.
#'    \item (optional) arbitrary_patterns: A list column that contains one named vector
#'    per respondent. The names of the vector are repeating patterns found in the
#'    responses of a respondent. The values of the vector are how often the pattern
#'    occurred. See "Arbitrary patterns" for more information.
#' }
#'
#' # Defined and arbitrary pattern indicators
#' Responses of an individual respondent can follow patterns, such as zig-zagging
#' across the response scale over multiple items. There might be a-priori knowledge
#' which response patterns could occur and might be indicative of low quality
#' responding. For this case the defined_patterns argument can be used to specify
#' one or more patterns whose presence will be checked for each respondent. If
#' no a-priori knowledge exists, it is possible to check for all patterns of a
#' specified length.
#'
#' ## Defined patterns
#' A pattern is defined by providing one ore more patterns in a character vector.
#' A few examples: `resp_patterns(x,defined_patterns = c(1,2,3)` checks how
#' often the response pattern 1,2,3 occurs in the responses of a single respondent.
#' `list(c(1,2,3),c(3,2,1))` checks how often
#' the two patterns 1,2,3 and 3,2,1 occur individually in the responses of a single
#' respondent. There is no limit to the number of patterns.
#'
#' ## Arbitrary patterns
#' Checks for arbitrary patterns are defined by providing one ore more integer values
#' in a numeric vector. The integers must be larger or equal to two. A few examples:
#' `resp_patterns(x,arbitrary_patterns = 2)` will check for sequences of responses
#' of length two which repeat at least two times.
#' `resp_patterns(x,arbitrary_patterns = c(2,3,4,5))` will check for sequences of responses
#' of length two, three, four and five that repeat at least two times.
#'
#'
#' # Data requirements
#' `resp_patterns()` assumes that the input data frame is structured in the following way:
#' * The data frame is in wide format, meaning each row represents one respondent,
#' each column represents one variable.
#' * The variables are in same the order as the questions respondents
#' saw while taking the survey.
#' * Reverse keyed variables are in their original form. No items were recoded.
#' * All responses have integer values.
#' * Questions have the same number of response options.
#' * Missing values are set to `NA`.
#'
#'
#' @returns Returns a data frame with response quality indicators per respondent.
#'  Dimensions:
#'  * Rows: Equal to number of rows in x.
#'  * Columns: Three response pattern indicators + one column for defined patterns
#'   (if specified) + one column for arbitrary patterns (if specified) + one id column (if specified).
#' @author Matthias Roth, Thomas Knopf
#'
#' @seealso [resp_styles()] for calculating response style indicators.
#' [resp_distributions()] for calculating response distribution indicators.
#' [resp_nondifferentiation()] for calculating response nondifferentiation indicators.
#'
#' @references  Curran, P. G. (2016). Methods for the detection of carelessly
#'  invalid responses in survey data.
#'  Journal of Experimental Social Psychology, 66, 4–19. https://doi.org/10.1016/j.jesp.2015.07.006
#'
#'
#' @examples
#' # A small test data set with ten respondents
#' # and responses to three survey questions
#' # with response scales from 1 to 5.
#' testdata <- data.frame(
#'   var_a = c(1,4,3,5,3,2,3,1,3,NA),
#'   var_b = c(2,5,2,3,4,1,NA,2,NA,NA),
#'   var_c = c(1,2,3,NA,3,4,4,5,NA,NA))
#'
#' # Calculate response pattern indicators
#' resp_patterns(x = testdata) |>
#'     round(2)
#'
#' # Include respondents with NA values by decreasing the
#' # necessary number of valid responses per respondent.
#'
#' resp_patterns(
#'       x = testdata,
#'       min_valid_responses = 0.2) |>
#'    round(2)

#' @export
resp_patterns <- function(x,
                          min_valid_responses = 1,
                          defined_patterns,
                          arbitrary_patterns,
                          min_repetitions = 2,
                          id = T) {
  # Set globally as min_valid_responses controls behavior on missing data
  na.rm <- T

  # General input checks

  # Create call
  check_call <- list()
  check_call[["x"]] <- x
  if(!missing(defined_patterns)) check_call[["defined_patterns"]] <- defined_patterns
  if(!missing(arbitrary_patterns)) check_call[["arbitrary_patterns"]] <- arbitrary_patterns
  check_call[["min_valid_responses"]] <- min_valid_responses
  check_call[["min_repetitions"]] <- min_repetitions
  check_call[["id"]] <- id
  do.call(what = input_check_resp_patterns,
          args = check_call)

  # Truncate response quality indicators where n valid responses is < min_valid_responses
  na_mask <- if(min_valid_responses== 0){
    rowSums(is.na(x)) == ncol(x)}else{ #include all rows
      if(min_valid_responses == 1){
        (rowSums(is.na(x)))>0 #only include rows with no NA
      }else{
        (rowSums(!is.na(x))/ncol(x)) <= min_valid_responses #include rows where number of valid responses >= min_valid responses
      }
    }

  # Break if na_mask is equal to number of respondents
  if(all(na_mask)){
    cli::cli_abort(c("!" = "No response quality indicators were calculated as the proportion of missing data per respondent is larger than defined in {.var min_valid_responses}."))
    return(tibble::as_tibble(output))}

  # Calculate response quality indicators
  output <- list()
  if(isTRUE(id)){
    output$id <- 1:nrow(x)
  } else {
    if(!isFALSE(id)){
      output$id <- id
    }
  }

  # Missing numbers (for all respondents)
  output$n_transitions[!na_mask] <- apply(x[!na_mask,],1,\(cur_row) length(rle(cur_row)$values)-1)
  output$mean_string_length[!na_mask] <- apply(x[!na_mask,],1,\(cur_row) mean(rle(cur_row)$lengths,na.rm=T))
  output$longest_string_length[!na_mask] <- apply(x[!na_mask,],1,\(cur_row) max(rle(cur_row)$lengths,na.rm=T))

  # Conditional execution of defined and arbitrary patterns
  if(!missing(defined_patterns)){
    # Change defined pattern to list if it is not
    if(!is.list(defined_patterns)) defined_patterns <- list(defined_patterns)

    output$defined_patterns[!na_mask] <- apply(x[!na_mask,],
                                               1,
                                               simplify = F,
                                               \(cur_row){
      purrr::map(defined_patterns, # Iterate over defined patterns list
                 \(pat) detect_pattern(cur_row,pat)) |>
                                                   unlist()})}

  if(!missing(arbitrary_patterns)){
    output$arbitrary_patterns[!na_mask] <- apply(x[!na_mask,],
                                                 1,
                                                 simplify = F,
                                                 \(cur_row){
      # Create all patterns of specified length(s)
      patterns <- purrr::map(arbitrary_patterns,\(n){
        slider::slide(.x = cur_row,
                      .after = n-1,
                      .f = \(cur_pattern) cur_pattern)
      }) |>
        purrr::flatten() |>
        purrr::keep(\(pat) length(pat) %in% arbitrary_patterns)

      patterns <- purrr::map(patterns,
                             as.character) |>
        purrr::map_chr(paste,collapse = "_")

      # Calculate number of times patterns are found
      found_patterns <- purrr::map(patterns,
                 \(pat) detect_pattern(cur_row,pat)) |>
        purrr::flatten_int() |>
        purrr::keep(\(pat) pat >= min_repetitions) |>
        sort(decreasing = T)
      found_patterns[unique(names(found_patterns))]
    })}

  # Change type and return
  new_resp_indicator(output,min_valid_responses,na_mask)
}


# Detects individual patterns in a response string
#' @noRd
detect_pattern <- function(response_vector,pattern){
  # Response string is the vector of responses
  # pattern is the vector representing the pattern to investigate
  response_string <- paste(response_vector,collapse = "_")
  pattern_string <- paste(pattern,collapse = "_")
  setNames(object = stringi::stri_count_fixed(response_string,pattern_string),
           nm = pattern_string)
}


