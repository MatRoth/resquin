#' NEP-Scale GESIS Panel Campus File
#'
#' Responses on 15 items of the NEP scale (Dunlap et al., 2002) measuring attitudes towards
#' the environment. The data is from the GESIS Panel
#' Campus File (Bosnjak et al., 2017, GESIS Data Archive, 2025), which is a subset of the
#' full GESIS Panel. The GESIS Panel is a probability based general population
#' panel survey sampling from the German population.
#'
#' Responses are on a five point response scale, which has been inverted
#' from its original coding:
#' *  5 = Fully agree
#' *  4 = Agree
#' *  3 = Neither nor
#' *  2 = Don’t agree
#' *  1 = Fully disagree
#'
#' Note that some of the items are reverse coded, meaning that
#' higher agreement with the scale can either indicate more concern
#' for nature (e.g. bczd017a: Balance of nature is very sensitive),
#' while higher agreement to other items implies less concern for
#' nature (bczd005a: Approaching maximum number of humans).Thus,
#' straightling behavior is much less likely a result of valid
#' responding.
#'
#'
#' @format ## `nep`
#' A data frame with 1,222 rows and 15 columns:
#' * bczd005a: Approaching maximum number of humans
#' * bczd006a: The right to adapt environment to the needs
#' * bczd007a: Consequences of human intervention
#' * bczd008a: Human ingenuity
#' * bczd009a: Abuse of the environment by humans
#' * bczd010a: Sufficient natural resources
#' * bczd011a: Equal rights for plants and animals
#' * bczd012a: Balance of nature stable enough
#' * bczd013a: Humans are subjected to natural laws
#' * bczd014a: Environmental crisis greatly exaggerated
#' * bczd015a: Earth is like spaceship
#' * bczd016a: Humans were assigned to rule over nature
#' * bczd017a: Balance of nature is very sensitive
#' * bczd018a: Control nature
#' * bczd019a: Environmental disaster
#'
#'
#' @source Bosnjak, M.; Dannwolf, T.; Enderle, T.; Schauer, I.; Struminskaya, B.; Tanner, A. und Weyandt, Kai W. (2017): Establishing an open probability-based mixed-mode panel of the general population in Germany: The GESIS Panel. Social Science Computer Review, 36(1). https://doi.org/10.1177/0894439317697949
#' @source Dunlap, Riley E., Kent D. Van Liere, Angela G. Mertig, and Robert Emmet Jones (2002). “New Trends in Measuring Environmental Attitudes: Measuring Endorsement of the New Ecological Paradigm: A Revised NEP Scale.” Journal of Social Issues 56 (3): 425–42. https://doi.org/10.1111/0022-4537.00176.
#' @source GESIS Data Archive, Cologne (2025). ZA5666 Data file Version 1.0.0, https://doi.org/10.4232/1.12749
#'
"nep"
