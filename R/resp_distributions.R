#' Compute response distribution indicators
#'
#' Calculates response distribution indicators for multi-item scales or matrix
#' questions which have the same number of response options for many questions.
#'
#' @param x A data frame containing survey responses in wide format.
#' @param min_valid_responses numeric between 0 and 1. Defines the share of valid responses
#' a respondent must have to calculate response quality indicators. Default is 1.
#'
#' @details
#' The functions assumes that the input data frame is structured in the following way:
#' * The data frame is in wide format, meaning each row represents one respondent, each
#' column represents one variable.
#' * The variables are in same the order as the questions respondents saw while taking the survey.
#' * All responses have integer values.
#' * Missing values are set to `NA`.
#'
#' The interpretation of the indicators calculated depends on the whether response
#' data of negatively worded questions are reversed or not:
#' * Do not reverse data of negatively worded questions if you want to assess
#' average response patterns (Dunn et al., 2018).
#' * Reverse data of negatively worded questions if you want to assess whether
#' responses are distributed randomly or not with respect to an assumed
#' latent variable (Marjanovic et al., 2015).
#'
#' The following response distribution indicators are calculated per respondent:
#' \itemize{
#'    \item n_valid: number of within person valid answers
#'    \item n_na: number of within person missing answers
#'    \item prop_na: proportion of missing responses within respondents
#'    \item ii_mean: intra-individual mean
#'    \item ii_median: intra-individual median
#'    \item ii_median_abs_dev: intra-individual median absolute deviation
#'    \item ii_sd:  intra-individual standard deviation
#'    \item ii_var: intra-individual variance
#'    \item mahal: Mahalanobis distance per respondent.
#' }
#'
#' Intra-individual response variability indicators (ii_sd, ii_var) have been
#' proposed to measure insufficient effort responding (Dunn et al., 2018) and to
#' distinguish between random and conscientious responding (Marjanovic et al, 2015).
#' ii_median_abs_dev is added as a robust alternative.
#'
#' Intra-individual location indicators can be used to asses the average location
#' of responses on a set of questions (ii_mean, ii_median).
#'
#' Mahalanobis distance is a outlier detection indicator. It represents the distance
#' of a participants responses from the center of a multivariate normal distribution
#' defined by the data of all respondents.
#'
#' Reponse distribution measures
#'
#' @returns Returns a data frame with response quality indicators per respondent.
#'  Dimensions:
#'  * Rows: Equal to number of rows in x.
#'  * Columns: 9, one for each response distribution indictator
#'
#' @author Matthias Roth, Matthias Bluemke & Clemens Lechner
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
#' resp_distributions(testdata) |>
#'     round(2)
#'
#' # Include respondents with NA values by decreasing the
#' # necessary number of valid responses per respondent.
#'
#' resp_distributions(testdata,
#'                    min_valid_responses = 0.2) |>
#'     round(2)
#'
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
  output$n_valid <- rowSums(!is.na(x))
  output$n_na <- rowSums(is.na(x))
  output$prop_na <- (output$n_na/ncol(x))

  # Response quality indicators for respondents with less missings than min_valid_responses
  output$wr_mean[!na_mask] <- rowMeans(x[!na_mask,],na.rm)
  output$wr_sd[!na_mask] <- sqrt(rowSums((x[!na_mask,]-output$wr_mean[!na_mask])^2,na.rm)/(rowSums(!is.na(x[!na_mask,]),na.rm)-1))
  output$wr_var <- output$wr_sd^2
  output$wr_median[!na_mask] <- apply(x[!na_mask,],1,stats::median,na.rm)
  output$wr_median_abs_dev[!na_mask] <- apply((abs(x[!na_mask,]-output$wr_median[!na_mask])),
                                               1,
                                               stats::median,
                                               na.rm)

  # Mahalanobis distance can fail due to singular matrix
  tryCatch(
    expr = {output$mahal[!na_mask] <- mahalanobis_na(
      x = x[!na_mask,],
      center = colMeans(x[!na_mask,],na.rm = T),
      cov = stats::cov(x = x[!na_mask,],
                use = "pairwise.complete.obs"))},

    error = function(e){
      cli::cli_alert_warning(c(
        "!" = "Mahalanobis distance could not be calculated. Matrix may be singular. Type '?resp_distribution' for more information."))
      return(output)},

    finally = {
      if(!("mahal" %in% names(output))) output$mahal <- NA
    }
  )


  # Change type
  output <- as.data.frame(output)
  output
}

#' Modified stats::mahalanobis function which allows for NA values
#' @noRd
mahalanobis_na<-\(x,center,cov){
  x <- as.matrix(x)
  x <- sweep(x, 2L, center)
  cov <- solve(cov)
  x[is.na(x)] <- 0 #set NA to 0 to propagate numerical value instead of NA
  sqrt(rowSums(x %*% cov * x))
}
