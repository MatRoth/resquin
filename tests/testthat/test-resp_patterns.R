testdata <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 5,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,5,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,5,2,1,4))

test_that("resp_patterns input tests", {
  expect_error(resp_patterns(testdata,
                             arbitrary_patterns = 1),
               regexp = "At least one element supplied to")
  expect_error(resp_patterns(testdata,
                             arbitrary_patterns = "a"),
               regexp = "is not of type list or of type numeric.")
  expect_error(resp_patterns(testdata,
                             defined_patterns = "a"),
               regexp = "is not of type list or a vector not of numeric integers")
  expect_error(resp_patterns(testdata,min_repetitions = "a"),
               regexp = "is not of type list or of type numeric")
  expect_error(resp_patterns(testdata,min_repetitions = 1),
               regexp = "is smaller than two.")
})

test_that("resp_patterns output tests", {
  expect_no_error(resp_patterns(testdata))
  expect_equal(resp_patterns(testdata)$n_transitions,
                  c(NA,NA,NA,NA,NA,NA,NA,2,2,2,0,1))
  expect_equal(resp_patterns(testdata)$n_transitions,
               c(NA,NA,NA,NA,NA,NA,NA,2,2,2,0,1))
  expect_equal(resp_patterns(testdata)$mean_string_length,
               c(NA,NA,NA,NA,NA,NA,NA,1,1,1,3,1.5))
  expect_equal(resp_patterns(testdata,defined_patterns = c(4,3,2))$defined_patterns,
               list(NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                    c("4_3_2" = 0),
                    c("4_3_2" = 0),
                    c("4_3_2" = 1),
                    c("4_3_2" = 0),
                    c("4_3_2" = 0)))
})

