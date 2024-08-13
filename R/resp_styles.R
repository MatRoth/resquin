# INFO -------------------------------------------------------------------------
# R Script for FUNCTION "resp_styles"
# Compute, store, and inspect response style indicators (resp_styles)

# This code was written
# by Dr Matthias Bluemke (matthias.bluemke@gesis.org)
# and modified & documented by Matthias Roth (matthias.roth@gesis.org)
#  and by Matthais Roth (matthias.roth@gesis.org)

#' Compute response style indicators
#'
#' Calculates response style indicators for multi-item scales
#'
#' @param x A data frame containing survey responses in wide format.
#' @param scale_min numeric. Minimum of scale provided.
#' @param scale_max numeric. Maximum of scale provided.
#' @param min_valid_responses numeric between 0 and 1. Defines the share of valid responses
#' a respondent must have to calculate response style indicators.
#' @param normalize logical. If true, counts of response style indicators will
#'  be divided by the number of non-missing responses per respondent.
#'
#' @details
#'
#' Response styles capture systematic shifts in respondents response behavior.
#' `resp_styles` is aimed at multi-item scales which use the same number of
#' response options for many questions.
#'
#' The functions assumes that the input data frame is structured in the following way:
#' * The data frame is in wide format, meaning each row represents one respondent,
#' each column represents one variable.
#' * The variables are in same the order as the questions respondents
#' saw while taking the survey.
#' * Reverse keyed variables are in their original form. No items were recoded.
#' * All responses have integer values.
#' * Questions have the same number of response options.
#' * Missing values are set to `NA`.
#'
#' The following response style indicators are calculated per respondent:
#' \itemize{
#'    \item MRS: Middle response style (only if scale has a numeric midpoint)
#'    \item ARS: Acquiescence response style
#'    \item DRS: Disacquiescence response style
#'    \item ERS: Extreme response style
#'    \item NERS: Non-extreme response style
#'    }
#' @returns Returns a data frame with response quality indicators per respondent.
#' @seealso [resp_distributions()]
#' @export
resp_styles <- function(x,
                   scale_min,
                   scale_max,
                   min_valid_responses = 1,
                   normalize = TRUE) {
  # Input check
  input_check_resp_styles(x,scale_min,scale_max,min_valid_responses,normalize)

  # Truncate response quality indices where number of valid responses is not >= min_valid_responses
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
  scale_mid <- mean(c(scale_min, scale_max))

  output <- list()
  if((scale_mid %% 1)> 0){
    cli::cli_alert_info(c("!" = "No scale midpoint found. Middle response style will not be calculated."))}
  else{
    output$MRS[!na_mask] <- rowSums(x[!na_mask,] == scale_mid, na.rm = T)
  }
  output$ARS[!na_mask] <- rowSums(x[!na_mask,] > scale_mid, na.rm = T)
  output$DRS[!na_mask] <- rowSums(x[!na_mask,] < scale_mid, na.rm = T)
  output$ERS[!na_mask] <- rowSums(x[!na_mask,] == scale_min|x[!na_mask,] == scale_max,na.rm=T)
  output$NERS[!na_mask]<- rowSums(x[!na_mask,] != scale_min & x[!na_mask,] != scale_max,na.rm=T)

  output <- as.data.frame(output)

  if(normalize) output <- output/rowSums(!is.na(x))

  return(output)
}
