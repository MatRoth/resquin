# checking consistency of print, summary and plot methods

    Code
      summary(resp_distributions(testdata))
    Message
      
      -- Averages of response quality indicators 
    Output
           n_na   prop_na   ii_mean     ii_sd ii_median     mahal 
           1.08      0.36      2.80      1.04      2.80      1.54 
    Message
      
      -- Quantiles of response quality indicators  
    Output
      # A tibble: 5 x 7
        quantiles  n_na prop_na ii_mean ii_sd ii_median mahal
        <chr>     <dbl>   <dbl>   <dbl> <dbl>     <dbl> <dbl>
      1 0%            0    0       1     0            1  1.3 
      2 25%           0    0       3     0.58         3  1.46
      3 50%           1    0.33    3.33  1            3  1.49
      4 75%           2    0.67    3.33  1.53         3  1.67
      5 100%          3    1       3.33  2.08         4  1.78

---

    Code
      resp_distributions(testdata)
    Output
      # Number of missings due to min_valid_responses equal to 1: 7
      # A data frame:                                             12 x 7
            id  n_na prop_na ii_mean  ii_sd ii_median mahal
         <int> <dbl>   <dbl>   <dbl>  <dbl>     <dbl> <dbl>
       1     1     3   1       NA    NA            NA NA   
       2     2     2   0.667   NA    NA            NA NA   
       3     3     1   0.333   NA    NA            NA NA   
       4     4     1   0.333   NA    NA            NA NA   
       5     5     2   0.667   NA    NA            NA NA   
       6     6     2   0.667   NA    NA            NA NA   
       7     7     2   0.667   NA    NA            NA NA   
       8     8     0   0        3.33  1.53          3  1.67
       9     9     0   0        3.33  2.08          4  1.49
      10    10     0   0        3     1             3  1.46
      11    11     0   0        1     0             1  1.78
      12    12     0   0        3.33  0.577         3  1.30

---

    Code
      print(summary(flag_resp(resp_distributions(testdata), ii_mean > 2)))
    Message
      
      -- Number of respondents flagged (Total N: 12) 
    Output
      ii_mean > 2 
                4 
      NULL

