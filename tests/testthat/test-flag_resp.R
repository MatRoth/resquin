testdata <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 5,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,5,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,5,2,1,4))

indicators_test <- resp_distributions(testdata)
indicators_nep <- resp_distributions(nep)

test_that("flag_resp input tests",{
  expect_no_error(indicators_nep |> flag_resp(ii_mean > 2, ii_sd <2, ii_mean > 2 & ii_sd < 2))
  expect_no_error(indicators_test|> flag_resp(ii_mean > 2, ii_sd <2, ii_mean > 2 & ii_sd < 2))
  expect_error(indicators_test |> flag_resp(ii_mean > 2,ERS == 1),
               regexp = "The following column names were not found in the supplied data frame: ERS")
})

test_that ("flag_resp output test",{
  expect_equal(flag_resp(indicators_test,ii_mean>2)[["ii_mean > 2"]],
               c(rep(NA,7),T,T,T,F,T))
  expect_equal(flag_resp(indicators_test,mahal > 1.6,ii_sd <2),
               {res <- tibble::tibble(
                 "id" = 1:nrow(testdata),
                 "mahal > 1.6" = c(rep(NA,7),T,F,F,T,F),
                 "ii_sd < 2" = c(rep(NA,7),T,F,T,T,T))
               class(res) <- c("flag_resp","tbl","data.frame")
               res})
})
