#' Compute response nondifferentiation indicators
#'
#' Compute response nondifferentiation indicators for responses to multi-item scales or matrix
#' questions.
#'
#' @param x A data frame containing survey responses in wide format. For more information
#' see section "Data requirements" below.
#' @param min_valid_responses numeric between 0 and 1. Defines the share of valid responses
#' a respondent must have to calculate response quality indicators. Default is 1.
#' @details
#' The following response nondifferentiation indicators are calculated per respondent:
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
#' @references Kim, Yujin, Jennifer Dykema, John Stevenson, Penny Black, and D. Paul Moberg. 2019.
#' “Straightlining: Overview of Measurement, Comparison of Indicators, and Effects in Mail–Web Mixed-Mode Surveys.”
#'  Social Science Computer Review 37(2):214–33. doi: 10.1177/0894439317752406.
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
resp_nondif <- function(x, min_valid_responses = 1){
  # Input check
  input_check(x,min_valid_responses)

  # Truncate response quality indicators where number of valid responses is not >= min_valid_responses
  na_mask <- if(min_valid_responses== 0){
    rowSums(is.na(x)) == ncol(x)}else{ #include all rows, except where this is only NA
      if(min_valid_responses == 1){
        (rowSums(is.na(x)))>0 #only include rows with no NA
      }else{
        (rowSums(!is.na(x))/ncol(x)) <= min_valid_responses #include rows where number of valid responses >= min_valid responses
      }
    }

  # Break if na_mask is equal to number of respondents
  if(all(na_mask)){
    cli::cli_abort(c("!" = "No response nondifferentiation indicators were calculated as the proportion of missing data per respondent is larger than defined in {.var min_valid_responses}."))
    return(as.data.frame(output))}

  # Prepare and return output
  output <- list()
  # Simple non differentiation
  output$simple_nondifferentiation[!na_mask] <- apply(X = x[!na_mask,],
                                           MARGIN = 1,
                                           FUN = \(cur_row) length(unique(cur_row)) == 1)
  # Mean root of pairs method
  output$mean_root_pairs[!na_mask] <- apply(X = x[!na_mask,],
                                            MARGIN = 1,
                                            FUN = \(cur_row){
    combinations <- combn(cur_row,2)
    root_pairs<- combinations |>
      t() |>
      apply(MARGIN = 1,
            FUN = \(cur_row) sqrt(abs(cur_row[1]-cur_row[2]))) |>
      sum(na.rm=T)
    mean_root_pairs <- root_pairs/nrow(combinations)
    mean_root_pairs})
  # Rescale mean root of pairs
  output$mean_root_pairs <- (output$mean_root_pairs-max(output$mean_root_pairs,na.rm=T))/(min(output$mean_root_pairs,na.rm=T)-max(output$mean_root_pairs,na.rm=T))
  # Maximum identical rating method
  output$max_identical_rating[!na_mask] <- apply(X = x[!na_mask,],
                                             MARGIN = 1,
                                             FUN = \(cur_row){
    max_identical_rating <- cur_row |> table() |> sort() |> tail(1) |> unname()
    max_identical_rating/length(cur_row) #rescale
    })
  # Scale point variation method
  output$scale_point_variation[!na_mask] <- apply(
    X = x[!na_mask,],
    MARGIN = 1,
    FUN = \(cur_row) 1-sum((table(cur_row)/length(cur_row))^2,na.rm=T))

  #Return output
  as.data.frame(output)
}
