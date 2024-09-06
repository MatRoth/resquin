#' Compute response style indicators
#'
#' Calculates response style indicators for matrix questions or multi-item scales.
#'
#' @param x A data frame containing survey responses in wide format. For more information
#' see section "Data requirements" below.
#' @param scale_min numeric. Minimum of scale provided.
#' @param scale_max numeric. Maximum of scale provided.
#' @param min_valid_responses numeric between 0 and 1. Defines the share of valid responses
#' a respondent must have to calculate response style indicators.
#' @param normalize logical. If *TRUE*, counts of response style indicators will
#'  be divided by the number of non-missing responses per respondent. Default is
#'  *TRUE*.
#'
#' @details
#'
#' Response styles capture systematic shifts in respondents response behavior.
#' `resp_styles()` is aimed at multi-item scales or matrix questions which use the same number of
#' response options for many questions.
#'
#' #' The following response style indicators are calculated per respondent:
#' Middle response style (MRS), acquiescence response style (ARS), disacquiescence
#' response style (DARS), extreme response style (ERS) and
#' non-extreme response style (NERS).
#'
#' The response style indicators are calculated in the following way
#' \itemize{
#'    \item MRS: Sum of mid point responses.
#'    \item ARS: Sum of responses larger than midpoint.
#'    \item DARS: Sum of responses lower than midpoint.
#'    \item ERS: Sum of lowest or highest category responses.
#'    \item NERS: Sum of responses between lowest and highest respnose category.
#'    }
#'
#' Note that ARS and DRS assume that the polarity of the scale is positive. This
#' means that higher numerical values indicate agreement and lower numerical values
#' indicate disagreement. MRS can only be calculated if the scale has a numeric midpoint.
#'
#' Also note that the response style literature is fragmented (Bhaktha et al., 2024).
#' Response styles calculated with `resp_styles()` are based on van Vaerenbergh & Thomas (2024).
#' However, we used the name non-extreme response style (NERS) instead of mild response style,
#' to emphasize that NERS it the inverse of ERS. Both appear in the literature
#' (for a NERS example see Wetzel et al. (2013)). Consult literature in your field
#' of research to find appropriate names for the response style indicators calculated here.
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
#' @returns Returns a data frame with response style indicators
#'  per respondent.
#'  * Rows: Equal to number of rows in x.
#'  * Columns: Five, one for each response style indicator.
#'
#' @seealso [resp_distributions()] for calculating response distribution indicators.
#'
#' @author Matthias Roth, Matthias Bluemke & Clemens Lechner
#'
#' @references
#' Bhaktha, Nivedita, Henning Silber, and Clemens Lechner. 2024. „Characterizing response quality in surveys with multi-item scales: A unified framework“. OSF-preprtint: https://osf.io/9gs67/
#' van Vaerenbergh, Y., and T. D. Thomas. 2013. „Response Styles in Survey Research: A Literature Review of Antecedents, Consequences, and Remedies“. International Journal of Public Opinion Research 25(2):195–217. doi: 10.1093/ijpor/eds021.
#' Wetzel, Eunike, Claus H. Carstensen, und Jan R. Böhnke. 2013. „Consistency of Extreme Response Style and Non-Extreme Response Style across Traits“. Journal of Research in Personality 47(2):178–89. doi: 10.1016/j.jrp.2012.10.010.
#'
#' @examples
#' # A test data set with ten respondents
#' # and responses to three survey questions
#' # with response scales from 1 to 5.
#' testdata <- data.frame(
#'   var_a = c(1,4,3,5,3,2,3,1,3,NA),
#'   var_b = c(2,5,2,3,4,1,NA,2,NA,NA),
#'   var_c = c(1,2,3,NA,3,4,4,5,NA,NA))
#'
#' # Calculate response distribution indicators
#' resp_styles(testdata,
#'             scale_min = 1,
#'             scale_max = 5) |>
#'    round(2) # round to second decimal
#'
#' # Include respondents with NA values by decreasing the
#' # necessary number of valid responses per respondent.
#' resp_styles(testdata,
#'             scale_min = 1,
#'             scale_max = 5,
#'             min_valid_responses = 0.2) |>
#'    round(2) # round to second decimal
#'
#' # Get counts of responses attributable to response styles.
#' resp_styles(testdata,
#'             scale_min = 1,
#'             scale_max = 5,
#'             normalize = FALSE)
#'
#' @export
resp_styles <- function(x,
                   scale_min,
                   scale_max,
                   min_valid_responses = 1,
                   normalize = TRUE) {
  # Input check
  input_check_resp_styles(x,scale_min,scale_max,min_valid_responses,normalize)

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
    cli::cli_abort(c("!" = "No response style indicators were calculated as the proportion of missing data per respondent is larger than defined in {.var min_valid_responses}."))
    return(as.data.frame(output))}

  # Prepare and return output
  output <- list()

  scale_mid <- mean(c(scale_min, scale_max))
  if((scale_mid %% 1)> 0){
    cli::cli_alert_info(c("!" = "No scale midpoint found. Middle response style will not be calculated."))
    output$MRS[1:length(na_mask)] <- NA
    }
  else{
    output$MRS[!na_mask] <- rowSums(x[!na_mask,] == scale_mid, na.rm = T)
  }
  output$ARS[!na_mask] <- rowSums(x[!na_mask,] > scale_mid, na.rm = T)
  output$DRS[!na_mask] <- rowSums(x[!na_mask,] < scale_mid, na.rm = T)
  output$ERS[!na_mask] <- rowSums(x[!na_mask,] == scale_min|x[!na_mask,] == scale_max,na.rm=T)
  output$NERS[!na_mask]<- rowSums(x[!na_mask,] != scale_min & x[!na_mask,] != scale_max,na.rm=T)

  # Change type
  output <- as.data.frame(output)

  # Contiditional normalization
  if(normalize) output <- output/rowSums(!is.na(x))

  return(output)
}
