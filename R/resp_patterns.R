## Response pattern indicators
#n_transitions   <- length(rle_list$values) - 1
#mean_string_length   <- mean(rle_list$lengths) |> round(2)
#longest_string_length  <- max(rle_list$lengths)
#
#' Compute response pattern indicators
#'
#' Compute response pattern indicators for responses to multi-item scales or matrix
#' questions.
#'
#' @param x A data frame containing survey responses in wide format. For more information
#' see section "Data requirements" below.
#' @param min_valid_responses numeric between 0 and 1. Defines the share of valid responses
#' a respondent must have to calculate response quality indicators. Default is 1.
#' @details
#' The following response distribution indicators are calculated per respondent:
#' \itemize{
#'    \item n_na: number of intra-individual missing answers
#' }
#'

#'
#' @section Data requirements:
#' `resp_styles()` assumes that the input data frame is structured in the following way:
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
#'  * Columns:
#' @author Matthias Roth
#'
#' @seealso [resp_styles()] for calculating response style indicators.
#'
#' @references Dunn, Alexandra M., Eric D. Heggestad, Linda R. Shanock, and Nels Theilgard. 2018.
#' “Intra-Individual Response Variability as an Indicator of Insufficient Effort Responding:
#' Comparison to Other Indicators and Relationships with Individual Differences.”
#' Journal of Business and Psychology 33(1):105–21. doi: 10.1007/s10869-016-9479-0.
#'
#' Marjanovic, Zdravko, Ronald Holden, Ward Struthers, Robert Cribbie,
#' and Esther Greenglass. 2015. “The Inter-Item Standard Deviation (ISD):
#' An Index That Discriminates between Conscientious and Random Responders.”
#' Personality and Individual Differences 84:79–83.
#' doi: 10.1016/j.paid.2014.08.021.
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
#' # Calculate response distribution indicators
#' resp_distributions(x = testdata) |>
#'     round(2)
#'
#' # Include respondents with NA values by decreasing the
#' # necessary number of valid responses per respondent.
#'
#' resp_distributions(
#'       x = testdata,
#'       min_valid_responses = 0.2) |>
#'    round(2)


#' @export
resp_patterns <- function(x, min_valid_responses = 1) {
  # Set globally as min_valid_responses controls behavior on missing data
  na.rm <- T

  # General input checks
  input_check(x)

  # Function specif input checks
  if(!is.numeric(min_valid_responses)) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be numeric.")
  )
  if(min_valid_responses >1|min_valid_responses<0) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be between or equal to 0 and 1.")
  )

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
    return(as.data.frame(output))}

  # Calculate response quality indicators
  output <-list()

  # Missing numbers (for all respondents)
  output$n_na <- rowSums(is.na(x))
  output$prop_na <- (output$n_na/ncol(x))
  output$simple_non_differentiation[!na_mask] <- apply(x[!na_mask,],1,\(cur_row)  as.numeric((length(na.omit(unique(cur_row)))==1)))

  # Change type
  output <- as.data.frame(output)
  output
}

