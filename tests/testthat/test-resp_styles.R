testdata <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 5,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,5,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,5,2,1,4))

test_that("resp_styles input tests", {
  expect_no_error(resp_styles(testdata,scale_min = 1, scale_max = 5))
  expect_error(resp_styles(testdata,scale_min = T, scale_max = 5, min_valid_responses = 0.5),
               regexp = "Argument 'scale_min' must be numeric.")
  expect_error(resp_styles(testdata,scale_min = 1, scale_max = "a", min_valid_responses = 0.5),
               regexp = "Argument 'scale_max' must be numeric.")
  expect_error(resp_styles(testdata,scale_min = T, scale_max = 5, min_valid_responses = 0.5),
               regexp = "Argument 'scale_min' must be numeric.")
  expect_error(resp_styles(testdata,scale_min = 1, scale_max = 5, min_valid_responses = 5,
                      normalize = "test"),
               regexp = "Argument 'normalize' must be logical.")
  expect_error(resp_styles(testdata,scale_min = 1, scale_max = 5,min_valid_responses = -1),
               regexp = "must be between or equal to 0 and 1")
  expect_error(resp_styles(testdata,scale_min = 1, scale_max = 5,min_valid_responses = "a"),
               regexp = "Argument 'min_valid_responses' must be numeric.")
  expect_error(resp_styles(testdata,scale_min = 1, scale_max = 5,min_valid_responses = T),
               regexp = "Argument 'min_valid_responses' must be numeric.")
  expect_error(resp_styles(as.matrix(testdata),scale_min = 1, scale_max = 5,),
               regexp = "x must be a data.frame or a tibble")
  expect_error(resp_styles(T),
               regexp = "x must be a data.frame or a tibble")
  expect_error(resp_styles(data.frame(var_a = c(1.5,2),
                                  var_b = c(2,3)),
                      scale_min = 1, scale_max = 5),
               regexp = "Non-integer data found in following columns")
  expect_error(resp_styles(data.frame(var_a = c("a","b"),
                                  var_b = c(2,3)),
                      scale_min = 1, scale_max = 5),
               regexp = "Non-integer data found in following columns")
  expect_error(resp_styles(data.frame(var_a = c(T,F),
                                  var_b = c(2,3)),
                      scale_min = 1, scale_max = 5),
               regexp = "Non-integer data found in following columns")
  expect_error(resp_styles(data.frame(var_a = c(1,3),
                                 var_b = c(3,6)),
                      scale_min = 1,
                      scale_max = 5),
               regexp = "var_b")
})


test_that("resp_styles output tests", {
  expect_equal(resp_styles(testdata,1,5,min_valid_responses = 0,normalize = F)$MRS,
               c(NA,0,1,0,0,1,0,1,0,1,0,2))
  expect_equal(resp_styles(testdata,1,5,min_valid_responses = 0,normalize = F)$ARS,
               c(NA,0,1,1,0,0,1,1,2,1,0,1))
  expect_equal(resp_styles(testdata,1,5,min_valid_responses = 0,normalize = F)$DRS,
               c(NA,1,0,1,1,0,0,1,1,1,3,0))
  expect_equal(resp_styles(testdata,1,5,min_valid_responses = 0,normalize = F)$ERS,
               c(NA,0,0,2,0,0,1,1,2,0,3,0))
  expect_equal(resp_styles(testdata,1,5,min_valid_responses = 0,normalize = F)$NERS,
               c(NA,1,2,0,1,1,0,2,1,3,0,3))
})

