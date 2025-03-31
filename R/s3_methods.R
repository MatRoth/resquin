#' Constructor for resp_indicator object to control print and summary methods
#' while preserving tibble behavior for data wrangling
#' @noRd
new_resp_indicator <- function(resp_indicator_list,
                               min_valid_responses,
                               na_mask){
  new_resp_indicator_obj <- vctrs::new_data_frame(
    x = resp_indicator_list,
    class = c("resp_indicator","tbl"),
    "min_valid_responses" = min_valid_responses,
    "na_mask" = na_mask)
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

#' Custom summary function
#' @noRd
#' @exportS3Method base::summary
summary.resp_indicator <- function(object,...){
  object$id <- NULL
  object$arbitrary_patterns <- NULL
  object$defined_patterns <- NULL
  mean_estimates <- colMeans(object,na.rm=T)

  dots <- list(...)
  if("quantiles" %in% names(dots)){
    if(!is.numeric(dots$quantiles) |
       !(all(dots$quantiles >=0)|
       all(dots$quantiles <=1)) &
       !(length(dots$quantiles) >= 1)){
      cli::cli_abort(c("!" = "Quantiles need to be a numeric vector with values ranging from 0 to 1."))
    } else {
      probs_quantiles <- dots$quantiles}
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
  class(results) <- "summary_response_styles"
  results
}

#' Custom summary function
#' @noRd
#' @exportS3Method base::print
print.summary_response_styles <- function(x,...){
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
