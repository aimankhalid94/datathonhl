# BUSINESS SCIENCE LEARNING LABS ----
# LAB 56: TARGETS KERAS CHURN ----
# MODULE 02: TARGETS PROCESS MODEL ----
# **** ----

# SETUP ----
library(tidyverse)
library(tidymodels)
library(keras)
library(targets)

source("R/functions.R")

best_model   <- tar_read(production_model_keras)

set.seed(123)
new_data_tbl <- read_csv("data/churn.csv") %>% slice_sample(n = 500)

predict_new_data(
    new_data     = new_data_tbl,
    churn_recipe = tar_read(churn_recipe),
    churn_model  = tar_read(best_model)
)
