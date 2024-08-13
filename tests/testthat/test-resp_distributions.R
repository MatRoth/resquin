testdata <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 5,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,5,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,5,2,1,4))

test_that("resp_distributions input tests", {
  expect_no_error(resp_distributions(testdata))
  expect_error(resp_distributions(testdata,min_valid_responses = 5),
               regexp = "must be between or equal to 0 and 1")
  expect_error(resp_distributions(testdata,min_valid_responses = -1),
               regexp = "must be between or equal to 0 and 1")
  expect_error(resp_distributions(testdata,min_valid_responses = "a"),
               regexp = "Argument 'min_valid_responses' must be numeric.")
  expect_error(resp_distributions(testdata,min_valid_responses = T),
               regexp = "Argument 'min_valid_responses' must be numeric.")
  expect_error(resp_distributions(data.frame(var_a = c(NA,NA),
                                  var_b = c(NA,NA))),
               regexp = "No response quality indicators were calculated as the proportion of")
  expect_error(resp_distributions(as.matrix(testdata)),
               regexp = "x must be a data.frame or a tibble")
  expect_error(resp_distributions(T),
               regexp = "x must be a data.frame or a tibble")
  expect_error(resp_distributions(data.frame(var_a = c(1.5,2),
                                  var_b = c(2,3))),
               regexp = "Non-integer data found in following columns")
  expect_error(resp_distributions(data.frame(var_a = c("a","b"),
                                  var_b = c(2,3))),
               regexp = "Non-integer data found in following columns")
  expect_error(resp_distributions(data.frame(var_a = c(T,F),
                                  var_b = c(2,3))),
               regexp = "Non-integer data found in following columns")
})

test_that("resp_distributions output tests", {
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 0)$n_valid,
               c(0,1,2,2,1,1,1,3,3,3,3,3))
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 0)$n_na,
               c(3,2,1,1,2,2,2,0,0,0,0,0))
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 1)$prop_na,
               c(1,2/3,1/3,1/3,2/3,2/3,2/3,0,0,0,0,0))
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 0)$ips_mean,
               c(NA,2,(3+4)/2,(1+5)/2,2,3,5,
                 (2+5+3)/3,
                 (1+4+5)/3,
                 (4+3+2)/3,
                 (1+1+1)/3,
                 (3+3+4)/3))
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 0)$ips_median,
               c(NA,2,3.5,(1+5)/2,2,3,5,
                 median(c(2,5,3)),
                 median(c(1,4,5)),
                 median(c(4,3,2)),
                 median(c(1,1,1)),
                 median(c(3,3,4))))
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 0)$ips_median_abs_dev,
               c(NA,
                 median(abs(c(2,NA,NA))-2,na.rm=T),
                 median(abs(c(3,4,NA)-median(c(3,4,NA),  na.rm=T)),na.rm=T),
                 median(abs(c(1,NA,5)-median(c(1,NA,5),  na.rm=T)),na.rm=T),
                 median(abs(c(NA,2,NA)-median(c(NA,2,NA),na.rm=T)),na.rm=T),
                 median(abs(c(NA,NA,3)-median(c(NA,NA,3),na.rm=T)),na.rm=T),
                 median(abs(c(5,NA,NA)-median(c(5,NA,NA),na.rm=T)),na.rm=T),

                 median(abs(c(2,5,3)-median(c(2,5,3), na.rm=T)),na.rm=T),
                 median(abs(c(1,4,5)-median(c(1,4,5), na.rm=T)),na.rm=T),
                 median(abs(c(4,3,2)-median(c(4,3,2), na.rm=T)),na.rm=T),
                 median(abs(c(1,1,1)-median(c(1,1,1), na.rm=T)),na.rm=T),
                 median(abs(c(3,3,4)-median(c(3,3,4), na.rm=T)),na.rm=T)))
  expect_equal(resp_distributions(testdata,
               min_valid_responses = 0)$ips_sd,
               testdata |>
                 apply(1,sd,na.rm=T))
  #TODO Mahalanobis distance test
  expect_equal(resp_distributions(testdata,
                       min_valid_responses = 0)$mahal,
    mahalanobis(x = testdata,
                           center = colMeans(testdata,na.rm=T),
                           cov = cov(testdata,
                                     use = "pairwise.complete.obs")))
})


# Test for large data sets
#testdata_large <- purrr::map(1:50,
#                             \(cur_var){
#                               sample.int(5,size = 500000,replace = T)
#                             }) |>
#  as.data.frame()
#
#
#test_that("resp_distributions_output_test_large",{
#  skip_on_cran()
#  expect_no_error(resp_distributions(testdata_large))
#})
