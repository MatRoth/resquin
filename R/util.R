#' Performs input check applicable to all data quality functions in the package
#' @noRd
input_check <- function(x){
  # Check if input is data frame
  if(!is.data.frame(x)) cli::cli_abort(
    c("!" = "x must be a data.frame or a tibble.",
      "x"  = "You have supplied a(n) {.cls {class(x)}}."))

  # Check if input is convertible to integer without loss of precision
  int_errors <- purrr::imap(x,
                            purrr::safely(\(cur_col,col_name){
                              # Check if general conversion to numeric fails
                              vctrs::vec_cast(x = cur_col,
                                              to = integer(),
                                              x_arg = col_name)
                              # Additional check if cur_col is numeric
                              if(is.logical(cur_col[!is.na(cur_col)]) &
                                 length(cur_col[!is.na(cur_col)])) vctrs::stop_incompatible_cast(
                                x = cur_col,
                                to = integer(),
                                x_arg = col_name,
                                to_arg = integer())}
                              )) |>
    purrr::transpose()
  # Print error messages if any are found
  if(any(!purrr::map_lgl(int_errors$error,is.null))){
    cli::cli_abort(c("!" = "Non-integer data found in following columns:",
                     int_errors$error |>
                       purrr::discard(is.null) |>
                       purrr::map("message") |>
                       paste(collapse = "\n"),
                     "i" = "Please supply only integer values."))

  return(NULL)
  }
}

#' Performs input checks specific to resp_styles
#' @noRd
input_check_resp_styles <- function(x,
                               scale_min,
                               scale_max,
                               min_valid_responses,
                               normalize){
  input_check(x)
  if(!is.numeric(scale_min)) cli::cli_abort(
    c("!" = "Argument 'scale_min' must be numeric.")
  )
  if(!is.numeric(scale_max)) cli::cli_abort(
    c("!" = "Argument 'scale_max' must be numeric.")
  )
  if(!is.logical(normalize)) cli::cli_abort(
    c("!" = "Argument 'normalize' must be logical.")
  )
  if(!is.numeric(min_valid_responses)) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be numeric.")
  )
  if(min_valid_responses >1|min_valid_responses<0) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be between or equal to 0 and 1.")
  )

  unique_response_options <- x |>
    purrr::map(unique) |>
    purrr::map(\(cur_resp_opt){
      any(cur_resp_opt > stats::na.omit(scale_max) | cur_resp_opt < stats::na.omit(scale_min))}) |>
    purrr::keep(isTRUE)

  if(length(unique_response_options)>0) cli::cli_abort(c(
    "!" = "Response options outside of range defined by `scale_min` and `scale_max` were found.",
    "i" = "Following columns contain response options outside of `scale_min` and `scale_max`:",
    "{paste(names(unique_response_options),collapse = ' ')}")
  )
  return(NULL)
}
