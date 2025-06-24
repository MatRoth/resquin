#' Flag respondents based on response quality indicators
#'
#' Flag respondents with one or more flagging expression.
#'
#' @param x A data frame containing response quality indicators. Each column
#' should be one response quality indicator. Each row should be the
#' value of the response quality indicator of a respondent.
#' @param ... Flagging expressions. See details.
#' @returns A data frame containing one column per flagging strategy and
#' the same number of rows as`x`. Each column contains `T` and `F` flags per respondents.
#' An additional `id` column is added as the first column if a column named `id`
#' is present in `x`.
#' @details
#' `flag_resp()` works very similar to the popular `dplyr::filter()` function. However,
#' instead of filtering data, `flag_resp()` returns a data frame of `T` and `F` values,
#' representing which respondents are flagged.
#'
#' As the first argument, you provide a data frame of response quality indicators,
#' where each column represents one response quality indicator and each row represents
#' one respondent.
#' As the second argument you provide one ore more logical statements to flag respondents.
#' For example:
#' * `flag_resp(x,ERS > 0.5)` returns a data frame with one column named `ERS > 0.5`. Each
#' row represents one respondent and shows whether the statement "is the extreme response style
#' indicator larger than 0.5" is true (`T`) or false (`F`).
#' * `flag_resp(x,ERS > 0.5,ii_mean < 3)` returns a data frame with two columns indicating
#' for which respondents the two flagging expressions are true or false.
#'
#' Note that `flag_resp()` is not restricted to functions from the `resquin` package.
#' You can supply any numerical column in the data frame `x`. This opens the possibility
#' to compare flagging strategies based on response quality indicators across
#' packages and functions.
#'
#' Use the `summary()` function on the results to compare flagging strategies.
#'
#' For more details see the vignette:
#' \code{vignette("Flagging respondents", package = "resquin")}
#'
#' @examples
#' res_dist_indicators <- resp_distributions(nep) # Create indicator data frame
#'
#' flagged_respondents <- flag_resp(res_dist_indicators,
#'                                  ii_mean > 3, # Flagging strategy 1
#'                                  ii_sd < 2, # Flagging strategy 2
#'                                  ii_mean > 3 & ii_sd > 2) # Flagging strategy 3
#' flagged_respondents # A data frame with three columns, each corresponding to one flagging strategy
#' summary(flagged_respondents) # quickly compare flagging strategies
#'
#' @export
flag_resp <- function(x,...){
  # Extract expressions & names
  flag_expr <- rlang::exprs(...)
  flag_names <- purrr::map(flag_expr,rlang::as_label)

  # Check whether supplied indicator names are in data
  supplied_indicators <- purrr::map(flag_expr,all.vars) |>
    purrr::map(utils::head,1) |> #only extract lhs of the logical expression
    purrr::flatten_chr()

  not_found_indicators <- supplied_indicators[!supplied_indicators %in% names(x)]
  if(length(not_found_indicators) > 0){
    msg<- "The following column names were not found in the supplied data frame:"
    indi_not_found <- not_found_indicators |>
      paste(collapse = ", ")
    cli::cli_abort(c("!" = paste(msg,indi_not_found,collapse = "")))
  }

  # Perform flagging
  flag_results <- purrr::map(flag_expr,
                             rlang::eval_tidy,
                             data = x)
  flag_results <- stats::setNames(flag_results,
                                  flag_names)

  # Set type and return
  flag_results <- tibble::as_tibble(flag_results)
  # Add id if supplied
  if("id" %in% names(x)) cbind(
    tibble::tibble(id = x$id),
    flag_results) -> flag_results

  new_flag_resp_results <- vctrs::new_data_frame(
    x = flag_results,
    class = c("flag_resp","tbl"))
  new_flag_resp_results
}
