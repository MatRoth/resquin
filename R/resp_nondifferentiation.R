#' Compute response nondifferentiation indicators
#'
#' Compute response nondifferentiation indicators for responses to multi-item scales or matrix
#' questions.
#'
#' @param x A data frame containing survey responses in wide format. For more information
#' see section "Data requirements" below.
#' @param min_valid_responses Numeric between 0 and 1 of length 1. Defines the share of valid responses
#' a respondent must have to calculate response quality indicators. Default is 1.
#' @param id default is `True`. If the default value is supplied
#' a column named `id` with integer ids will be created. If `False` is supplied, no id column will be created. Alternatively, a numeric or character vector of unique values identifying
#' each respondent can be supplied. Needs to be of the same length as the number of rows of `x`.
#'
#' @details
#' Response nondifferentiation is the result of response behavior in which respondents deviate
#' from an ideal response process. Optimal response behavior is termed optimizing, while deviations from
#' optimal response behavior are termed satisficing (Krosnik, 1991). Optimizing describes a behavior in which
#' respondents go through all steps of comprehension, retrieval, judgment, and response selection. When satisficing,
#' respondents skip all or parts of the optimal response process. Satisficing can lead to non-response, "don't know"
#' responses, random responding or nondifferentiation. The later is targeted by the function `resp_nondifferentiation()`.
#'
#' Nondifferentiation is characterized by respondents choosing similar or even the same response options regardless of the
#' content of the question. Multiple indicators for response nondifferentiation have been developed.
#' For `resp_nondifferentiation()`, the following response nondifferentiation indicators described by Kim et al. (2017) are calculated per respondent:
#' \itemize{
#'    \item Simple Nondifferentiation: Respondents are assigned 1 or 0 depending on
#'    whether all responses have the same value (1) or not (0).
#'    \item Mean Root of Pairs Method: Mean of the root of the absolute differences between all pairs in a multi-item
#'    scale or matrix questions. It ranges from 0 (least straightlining) to 1 (most straightlining). The indicator is rescaled to be
#'    inbetween the minimum and maximum of all values. This means that including/excluding responses or respondents into the calculation
#'    changes the indicators values.
#'    \item Maximum Identical Rating Method: Proportion of the most commonly selected response option among all responses in a multi-item
#'    scale or matrix questions. It ranges from 0 (least straightlining) to 1 (most straightlining).
#'    \item Scale Point Variation Method: The probability of differentiation is defined as \eqn{1-\Sigma{p_i^2}},
#'     where \eqn{p_i} is the proportion of the values rated at each scale point on a rating scale and \eqn{i} indicates the number of scale points.
#'     The measure becomes larger if respondents use more scales points in a multi-item scale or matrix questions.
#' }
#'
#' It should be noted that Kim et al. (2017) average the response nondifferentiation indicators to obtain an aggregate
#' measure for response nondifferentiation. To do so, the `summary()` function can be called on the
#' results of `resp_nondifferentiation()`.
#'
#'
#' @section Data requirements:
#' `resp_nondifferentiationf()` assumes that the input data frame is structured in the following way:
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
#' @returns Returns a data frame with response nondifferentiation indicators per respondent.
#'  Dimensions:
#'  * Rows: Equal to number of rows in x.
#'  * Columns: Four response nondifferentiation indicator columns + id column (if specified).
#' @author Matthias Roth
#'
#' @seealso [resp_styles()] for calculating response style indicators.
#'  [resp_distributions()] for calculating response distribution indicators.
#'
#' @references Kim, Yujin, Jennifer Dykema, John Stevenson, Penny Black, and D. Paul Moberg. 2019.
#' “Straightlining: Overview of Measurement, Comparison of Indicators, and Effects in Mail–Web Mixed-Mode Surveys.”
#'  Social Science Computer Review 37(2):214–33. doi: 10.1177/0894439317752406.
#'
#'  Krosnick, Jon A. 1991. “Response Strategies for Coping with the Cognitive Demands
#'  of Attitude Measures in Surveys.”
#'  Applied Cognitive Psychology 5(3):213–36. doi: 10.1002/acp.2350050305.
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
#' # Calculate response nondifferentiation indicators
#' resp_nondifferentiation(x = testdata) |>
#'     round(2)
#'
#' # Include respondents with NA values by decreasing the
#' # necessary number of valid responses per respondent.
#'
#' resp_nondifferentiation(
#'       x = testdata,
#'       min_valid_responses = 0.2) |>
#'    round(2)
#'
#' resp_nondifferentiation(
#'      x = testdata,
#'      min_valid_responses = 0.2) |>
#'   summary() # To obtain aggregate measures of response nondifferentiation


#' @export
resp_nondifferentiation <- function(x, min_valid_responses = 1,id = T){
  # Input check
  input_check(x,min_valid_responses,id)

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
  if(isTRUE(id)) output$id <- 1:nrow(x) else output$id <- id
  # Simple non differentiation
  output$simple_nondifferentiation[!na_mask] <- apply(X = x[!na_mask,],
                                           MARGIN = 1,
                                           FUN = \(cur_row) as.numeric(length(unique(cur_row)) == 1))
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
  tibble::as_tibble(output)
}
