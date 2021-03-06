#' ---
#' title: "Regression and Other Stories: Height and weight"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     theme: readable
#'     toc: true
#'     toc_depth: 2
#'     toc_float: true
#'     code_download: true
#' ---

#' Predict weight from height. See Chapters 3, 9 and 10 in Regression
#' and Other Stories.
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)

#' #### Load packages
library("rprojroot")
root<-has_file(".ROS-Examples-root")$make_fix_file()
library("rstanarm")

#' #### Load data
earnings <- read.csv(root("Earnings/data","earnings.csv"))
head(earnings)

#' ## Simulating uncertainty for linear predictors and predicted values

#' #### Predict weight (in pounds) from height (in inches)
#'
#' The option `refresh = 0` supresses the default Stan sampling
#' progress output. This is useful for small data with fast
#' computation. For more complex models and bigger data, it can be
#' useful to see the progress.
fit_1 <- stan_glm(weight ~ height, data=earnings, refresh = 0)
print(fit_1)

#' **Predict weight for 66 inches person
coefs_1 <- coef(fit_1)
predicted_1 <- coefs_1[1] + coefs_1[2]*66
round(predicted_1, 1)
#' or
new <- data.frame(height=66)
pred <- posterior_predict(fit_1, newdata=new)
#'
cat("Predicted weight for a 66-inch-tall person is", round(mean(pred)),
"pounds with a sd of", round(sd(pred)), "\n")

#' #### Center heights
earnings$c_height <- earnings$height - 66
fit_2 <- stan_glm(weight ~ c_height, data=earnings, refresh = 0)
print(fit_2)

#' #### Point prediction
new <- data.frame(c_height=4.0)
point_pred_2 <- predict(fit_2, newdata=new)
round(point_pred_2, 1)

#' #### Posterior simulations
#' 
#' variation coming from posterior uncertainty in the coefficients
linpred_2 <- posterior_linpred(fit_2, newdata=new)
hist(linpred_2)

#' #### Posterior predictive simulations
#' 
#' variation coming from posterior uncertainty in the coefficients and
#' predictive uncertainty
postpred_2 <- posterior_predict(fit_2, newdata=new)
hist(postpred_2)

#' ## Indicator variables

#' #### Predict weight (in pounds) from height (in inches)
new <- data.frame(height=66)
pred <- posterior_predict(fit_1, newdata=new)
cat("Predicted weight for a 66-inch-tall person is", round(mean(pred)), "pounds with a sd of", round(sd(pred)), "\n")

#' #### Including a binary variable in a regression
fit_3 <- stan_glm(weight ~ c_height + male, data=earnings, refresh = 0)
print(fit_3)
new <- data.frame(c_height=4, male=0)
pred <- posterior_predict(fit_3, newdata=new)
cat("Predicted weight for a 70-inch-tall female is", round(mean(pred)), "pounds with a sd of", round(sd(pred)), "\n")

#' #### Using indicator variables for multiple levels of a categorical predictor<br/>
#' Include ethnicity in the regression as a factor
fit_4 <- stan_glm(weight ~ c_height + male + factor(ethnicity),
                  data=earnings, refresh = 0)
print(fit_4)

#' #### Choose the baseline category by setting the levels
earnings$eth <- factor(earnings$ethnicity,
  levels=c("White", "Black", "Hispanic", "Other"))
fit_5 <- stan_glm(weight ~ c_height + male + ethnicity, data=earnings, refresh = 0)
print(fit_5)

#' #### Alternatively create indicators for the four ethnic groups directly:
earnings$eth_white <- ifelse(earnings$ethnicity=="White", 1, 0)
earnings$eth_black <- ifelse(earnings$ethnicity=="Black", 1, 0)
earnings$eth_hispanic <- ifelse(earnings$ethnicity=="Hispanic", 1, 0)
earnings$eth_other <- ifelse(earnings$ethnicity=="Other", 1, 0)
fit_6 <- stan_glm(weight ~ c_height + male + eth_black + eth_hispanic + eth_other,
                  data=earnings, refresh = 0)
print(fit_6)
