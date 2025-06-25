testdata <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 5,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,5,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,5,2,1,4))

test_that("s3 type assertion",{
  expect_s3_class(resp_styles(testdata,scale_min = 1,scale_max = 5),class = c("resp_indicator","tbl","data.frame"))
  expect_s3_class(resp_distributions(testdata),class = c("resp_indicator","tbl","data.frame"))
  expect_s3_class(resp_patterns(testdata),class = c("resp_indicator","tbl","data.frame"))
  expect_s3_class(resp_nondifferentiation(testdata),class = c("resp_indicator","tbl","data.frame"))
  expect_s3_class(summary(resp_distributions(testdata)),class = "summary_response_indicators")
  }
)

test_that("summary quantile input test",{
  expect_error(summary(resp_distributions(testdata),quantiles = "a"),
               regexp = "Quantiles need to be a numeric vector")
  expect_error(summary(resp_distributions(testdata),quantiles = -1),
               regexp = "Quantiles need to be a numeric vector")
  expect_error(summary(resp_distributions(testdata),quantiles = c(-1,2)),
               regexp = "Quantiles need to be a numeric vector")
  expect_no_error(summary(resp_distributions(testdata),quantiles = c(0,1)))
  }
)

test_that("checking consistency of print, summary and plot methods",{
  expect_snapshot(summary(resp_distributions(testdata)))
  expect_snapshot(resp_distributions(testdata))
  expect_snapshot(print(resp_distributions(testdata) |>
                    flag_resp(ii_mean > 2) |>
                    summary()))
})

test_that("checking consistency of flag_resp summary output",{
  expect_equal({
    out <- resp_distributions(testdata) |>
      flag_resp(ii_mean > 2) |>
      summary()
    c(out$n_flagged,
      out$n,
      out$normalized)},
    c("ii_mean > 2" = 4,
      12,
      F))
})

testdata2 <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 6,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,6,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,6,2,1,4))

test_that("check that resp_styles works with plot and even numbered scales",{
  expect_no_error(
    resp_styles(testdata2,scale_min = 1,scale_max = 6) |> plot()
  )
})
