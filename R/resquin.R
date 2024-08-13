# INFO -------------------------------------------------------------------------
# R Script for FUNCTION "resp_distributions"
# Compute, store, and inspect response distribution indicators

# This code was written
#  by Dr Clemens Lechner (clemens.lechner@gesis.org)
#  and extended by Dr Matthias Bluemke (matthias.bluemke@gesis.org)
#  and by Matthias Roth (matthias.roth@gesis.org)

#' Compute response distribution indices
#'
#' Calculates response distribution indicators for multi-item scales
#'
#' @param x A dataframe containing survey responses in wide format.
#' @param min_valid_responses numeric between 0 and 1. Defines the share of valid responses
#' a respondent must have to calculate response quality indicators.
#' @details
#' The functions assumes that the input data frame is structured in the following way:
#' * The data frame is in wide format, meaning each row represents one respondent, each
#' column represents one variable.
#' * The variables are in same the order as the questions respondents saw while taking the survey.
#' * Reverse keyed variables are in their original form. No items were recoded.
#' * All responses have integer values.
#' * Missing values are set to `NA`.
#'
#' The following response distribution indicators are calculated per respondent:
#' \itemize{
#'    \item n_valid: number of within person valid answers
#'    \item n_na: number of within person missing answers
#'    \item prop_na: proportion of missing responses within respondents
#'    \item ips_mean: within respondent mean over all items
#'    \item ips_median: within respondent median
#'    \item ips_median_abs_dev: within respondent median absolute deviation
#'    \item ips_sd:   within respondent standard deviation
#'    \item mahalanobis: Mahalanobis distance per respondent. Represents the distance
#'    of observations from the center of a multivariate normal distribution.
#' }
#' @returns Returns a data.frame with response quality indicators per respondent.
#'
#' @seealso [resp_styles()]
#' @export
resp_distributions <- function(x, min_valid_responses = 1) {
  # Set globally as min_valid_responses controls behavior on missing data
  na.rm <- T

  input_check(x)
  if(!is.numeric(min_valid_responses)) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be numeric.")
  )
  if(min_valid_responses >1|min_valid_responses<0) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be between or equal to 0 and 1.")
  )

  # Truncate response quality indices where n missing is > min_valid_responses
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

  # Calculate response quality indices
  output <- list()
  # Missing numbers (for all respondents)
  output$n_valid <- rowSums(!is.na(x))
  output$n_na <- rowSums(is.na(x))
  output$prop_na <- (output$n_na/ncol(x))

  # Response quality indicators for respondents with less missings than min_valid_responses
  output$ips_mean[!na_mask] <- rowMeans(x[!na_mask,],na.rm)
  output$ips_median[!na_mask] <- apply(x[!na_mask,],1,median,na.rm)
  output$ips_median_abs_dev[!na_mask] <- apply((abs(x[!na_mask,]-output$ips_median[!na_mask])),
                                               1,
                                               median,
                                               na.rm)
  output$ips_sd[!na_mask] <- sqrt(rowSums((x[!na_mask,]-output$ips_mean[!na_mask])^2,na.rm)/(rowSums(!is.na(x[!na_mask,]),na.rm)-1))

  # Mahalanobis distance can fail due to singular matrix
  tryCatch(
    expr = {output$mahalanobis[!na_mask] <- mahalanobis(
      x = x[!na_mask,],
      center = colMeans(x[!na_mask,],na.rm = T),
      cov = cov(x = x[!na_mask,],
                use = "pairwise.complete.obs"))},

    error = function(e){
      cli::cli_alert_warning(c(
        "!" = "Mahalanobis distance could not be calculated. Matrix may be singular."))
      return(output)},

    finally = {
      if(!("mahalanobis" %in% names(output))) output$mahalanobis <- NA
    }
  )


  # Change type
  output <- as.data.frame(output)
  output
  # return(as.data.frame(output))
}

