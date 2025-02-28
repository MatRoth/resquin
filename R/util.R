#' Performs input check applicable to all data quality functions in the package
#' @noRd
input_check <- function(x,min_valid_responses){
  # Check if input is data frame
  if(!is.data.frame(x)) cli::cli_abort(
    c("!" = "x must be a data.frame or a tibble.",
      "x"  = "You have supplied a(n) {.cls {class(x)}}."))

  if(!is.numeric(min_valid_responses)) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be numeric.")
  )

  if(min_valid_responses >1|min_valid_responses<0) cli::cli_abort(
    c("!" = "Argument 'min_valid_responses' must be between or equal to 0 and 1.")
  )


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
  input_check(x,min_valid_responses)
  if(!is.numeric(scale_min)) cli::cli_abort(
    c("!" = "Argument 'scale_min' must be numeric.")
  )
  if(!is.numeric(scale_max)) cli::cli_abort(
    c("!" = "Argument 'scale_max' must be numeric.")
  )
  if(!is.logical(normalize)) cli::cli_abort(
    c("!" = "Argument 'normalize' must be logical.")
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

input_check_resp_patterns <- function(x,
                                      min_valid_responses,
                                      defined_patterns,
                                      arbitrary_patterns,
                                      min_repetitions){
  input_check(x,min_valid_responses)

  if(!missing(defined_patterns)){
    if(is.list(defined_patterns)){
      within_list_type_ok <- all(purrr::map_lgl(defined_patterns,\(cur_elem) all(is.quasi_integer(cur_elem))))
      if(!within_list_type_ok) cli::cli_abort(c(
        "!" = "Elements in the list supplied to `defined_patterns` are not numeric integers.",
        "i" = "Use numeric vectors with integer values of possible response options in the list supplied to `defined_patterns`"))
    } else {
      if(!is.quasi_integer(defined_patterns)){cli::cli_abort(c(
        "!" = "`defined_patterns` is not of type list or a vector not of numeric integers.",
        "i" = "`defined_patterns` requires a numeric vector of integer values representing response patterns (e.g. c(1,2,3)) or a list
        of vectors with integer values representing response options (e.g. list(c(1,2,3),c(3,2,1))."))
      }
    }
  }

  if(!missing(arbitrary_patterns)){
    if(!is.quasi_integer(arbitrary_patterns)){
      cli::cli_abort(c(
        "!" = "`arbitrary_patterns` is not of type list or of type numeric.",
        "i" = "`arbitrary_patterns` requires a numeric vector of integer values defining the length of patterns to search for."))
    } else {if(any(arbitrary_patterns < 2)){
      cli::cli_abort(c(
        "!" = "At least one element supplied to `arbitrary_patterns` is smaller than two.",
        "i" = "`arbitrary_patterns` requires a numeric integer value larger or equal two."))
      }
    }
  }

  if(!is.quasi_integer(min_repetitions)){
    cli::cli_abort(c(
      "!" = "`min_repitions` is not of type list or of type numeric.",
      "i" = "`min_repitions` requires a numeric integer value."))
  } else{
    if(min_repetitions < 2){
      cli::cli_abort(c(
        "!" = "`min_repitions` is smaller than two.",
        "i" = "`min_repitions` requires a numeric integer value larger or equal two."))
    }
  }
  return(NULL)
}



#' @noRd
#' Check if numeric vector can be coerced to integer without loss of precision
is.quasi_integer <- function(vec){
  tryCatch(is.integer(vctrs::vec_cast(vec,to = integer()))&is.numeric(vec),
           error = \(e) F)
}
