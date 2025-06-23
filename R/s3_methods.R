#' Constructor for resp_indicator object to control print and summary methods
#' while preserving tibble behavior for data wrangling
#' @noRd
new_resp_indicator <- function(resp_indicator_list,
                               min_valid_responses,
                               na_mask,
                               id){
  new_resp_indicator_obj <- vctrs::new_data_frame(
    x = resp_indicator_list,
    class = c("resp_indicator","tbl"),
    "min_valid_responses" = min_valid_responses,
    "na_mask" = na_mask,
    "id" = id)
  new_resp_indicator_obj
}

#' Custom print function
#' @noRd
#' @exportS3Method pillar::tbl_sum
tbl_sum.resp_indicator <- function(x,...) {
  default_header <- NextMethod()

  header_prefix <- paste("Number of missings due to min_valid_responses equal to",
                         attr(x,"min_valid_responses"))
  c(stats::setNames(object = sum(attr(x,"na_mask")),
             nm = header_prefix),
    default_header)
}

#' Summary function for resp_indicator objects
#'
#' Summarizes results of resp_* functions.
#'
#' @param object An object of type resp_indicator created with a resp_* function.
#' @param quantiles A numeric vector with values raning from 0 to 1. Determines the
#' quantiles which are calculated. Default is `c(0,0.25,0.5,0.75,1)`.
#' @param ... Additional arguments (currently not supported).
#'
#' @returns A resp_indicator summary object. Works like a list with two elements:
#' * quantile_estimates. A dataframe of estimated quantiles for the response quality indicators
#' calculated.
#' * mean_estimates. A named vector with means of response quality indicators calculated.
#' @exportS3Method base::summary
summary.resp_indicator <- function(object,quantiles,...){
  object$id <- NULL
  object$arbitrary_patterns <- NULL
  object$defined_patterns <- NULL
  mean_estimates <- colMeans(object,na.rm=T)
  if(!missing(quantiles)){
    if(!is.numeric(quantiles) |
       !(all(quantiles >=0 & quantiles <=1))|
       !(length(quantiles) >= 1)){
      cli::cli_abort(c("!" = "Quantiles need to be a numeric vector with values ranging from 0 to 1."))
    } else {
      probs_quantiles <- quantiles}
    }
  else{
    probs_quantiles <- c(0,0.25,0.5,0.75,1)
  }

  quantile_estimates <- apply(
    X = object,
    MARGIN = 2,
    FUN = \(cur_indicator){
      stats::quantile(x = cur_indicator,
                      probs = probs_quantiles,
                      na.rm = T,
                      names = F)
    },
    simplify = F)

  quantile_estimates <- quantile_estimates|>
    tibble::as_tibble()|>
    tibble::add_column(
      tibble::tibble(
        "quantiles" = paste0(probs_quantiles*100,"%")),
        .before = 1)


  results <- list(
    mean_estimates = mean_estimates,
    quantile_estimates = quantile_estimates)
  class(results) <- "summary_response_indicators"
  results
}

#' Custom summary function
#' @noRd
#' @exportS3Method base::print
print.summary_response_indicators <- function(x,...){
  cli::cli_h3("Averages of response quality indicators")
  print(x$mean_estimates |> round(2))
  cli::cli_h3("Quantiles of response quality indicators ")
  print(x$quantile_estimates |> purrr::modify_if(is.numeric,round,2))
}

#' Custom plot function
#' @noRd
#' @exportS3Method base::plot
plot.resp_indicator <- function(x,y,...){
  x$id <- NULL
  x$arbitrary_patterns <- NULL
  x$defined_patterns <- NULL
  graphics::par(mfrow = c(ncol(x),1),mar = c(2,1,1.5,2))
  purrr::walk2(.x = x,
               .y = names(x),
               .f = \(cur_vals,cur_name){
                 graphics::boxplot(x = cur_vals,
                                   main = cur_name,
                                   horizontal = T)
               })
  graphics::par(mfrow = c(1,1))
}

#' Summary function for flag_resp() output
#'
#' Calculates the number of respondents flagged with a flagging strategy. Also
#' calculates the agreement between flagging strategies.
#'
#' @param object An object of type `flag_resp` which is created using the `flag_resp()`
#' function.
#' @param normalize A logical value indicating, whether to normalize the agreement
#' estimates between flagging strategies. See details for more information.
#' @param ... Other arguments for summary functions (currently not supported).
#' @returns An object of class "summary_flag_resp". The object works like a list
#' with four elements.
#' * n_flagged: a named vector of the number of cases a flagging strategy flagged as positive.
#' * agreement: a data frame which counts the number of cases two flagging strategies flagged
#' as positive. If `normalized`, the values are the percentage agreement in flagged respondents.
#' * normalized: Indicator if agreement values were normalized.
#' * n: number of rows in `object`.
#' @details
#' The agreement is either the count of respondents which two flagging strategies
#' flag (`normalize = T`) or the number of respondents that is flagged positive by
#' at least one flagging strategy.
#'
#' In logical terms, the normalized agreement is `sum(fs1 & fs2) / sum(fs1 | fs2)`.
#'
#' @exportS3Method base::summary
summary.flag_resp <- function(object,normalize = F,...){
  # Filter out id if present
  if("id" %in% names(object)) object$id <- NULL

  n_flagged <- colSums(object,na.rm=T)

  # Case for only one flagging strategy
  if(length(names(object)) == 1){
    results <- list(
      n_flagged = n_flagged,
      agreement = data.frame(),
      n = nrow(object),
      normalized = normalize)
    class(results) <- "summary_flag_resp"
    return(results)
  }

  # Create correlation matrix style agreement matrix
  identical_combinations <- data.frame(V1 = names(object),V2 = names(object))
  distinct_combinations <- utils::combn(x = names(object),m =2) |>
    t() |>
    as.data.frame()

  all_combinations <- rbind(identical_combinations,
                            distinct_combinations)

  agreement <- all_combinations |> # a & b
    apply(1,\(cur_row) rowSums(object[,c(cur_row[1],cur_row[2])]) == 2) |>
    colSums(na.rm=T)

  overall <- all_combinations |> # a OR b
    apply(1,\(cur_row) rowSums(object[,c(cur_row[1],cur_row[2])]) >= 1) |>
    colSums(na.rm=T)

  # Normalize if T
  if(normalize) agreement <- agreement/overall # sum(a & b) / sum(a OR b)

  # Reshape for printing and saving
  agreement_df <- cbind(all_combinations,agreement) |>
    stats::reshape(direction = "wide",idvar = "V1",timevar = "V2")

  agreement_df <- cbind(agreement_df$V1,rev(agreement_df[,2:ncol(agreement_df)])) |>
    purrr::map(rev) |>
    tibble::as_tibble()

  agreement_df <- stats::setNames(agreement_df,
                                  stringi::stri_replace(names(agreement_df),
                                                        replacement = "",
                                                        regex = c("agreement\\.|agreement_df\\$")))
  names(agreement_df) <- c("Flag",names(agreement_df[2:ncol(agreement_df)]))

  # Creating results object and adding type
  results <- list(
    n_flagged = n_flagged,
    agreement = agreement_df,
    n = nrow(object),
    normalized = normalize)
  class(results) <- "summary_flag_resp"
  results
}

#' @noRd
#' @exportS3Method base::print
print.summary_flag_resp <- function(x,...){
  cli::cli_h3(paste0("Number of respondents flagged (Total N: ",x$n,")"))
  print(x$n_flagged)

  if(nrow(x$agreement) == 0 & ncol(x$agreement) == 0) return()

  cli::cli_h3("Agreement between flagging strategies")
    print_agreement <- x$agreement |>
    purrr::modify_if(is.numeric,round,2) |>
    purrr::modify(as.character)
  print_agreement[is.na(print_agreement)] <- ""
  names(print_agreement) <- c("Flag",names(print_agreement[2:ncol(print_agreement)]))
  knitr::kable(print_agreement,format = "simple") |> print()

  if(x$normalized) cli::cli_text("(Normalized: Respondents flagged by both flagging strategies divided by all flagged respondents.)")
}
