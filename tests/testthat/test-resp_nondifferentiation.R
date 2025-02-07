testdata <- data.frame( # NA block and pattern block
  var_a = c(NA, 2, 3, 1,NA,NA, 5,2,1,4,1,3),
  var_b = c(NA,NA, 4,NA, 2,NA,NA,5,4,3,1,3),
  var_c = c(NA,NA,NA, 5,NA, 3,NA,3,5,2,1,4))

testdata_kim_et_al <- data.frame(
  var_1 = c(5,5),
  var_2 = c(5,5),
  var_3 = c(5,5),
  var_4 = c(5,1))

test_that("resp_nondif output test Kim et al. 2017",{
  expect_equal(round(mean(resp_nondifferentiation(testdata_kim_et_al)$simple_nondifferentiation),2),0.5)
  expect_equal(round(mean(resp_nondifferentiation(testdata_kim_et_al)$mean_root_pairs),2),0.5)
  expect_equal(round(mean(resp_nondifferentiation(testdata_kim_et_al)$max_identical_rating),2),0.88)
  expect_equal(round(mean(resp_nondifferentiation(testdata_kim_et_al)$scale_point_variation),2),0.19)
  })
