# BUSINESS SCIENCE LEARNING LABS ----
# LAB 56: TARGETS KERAS CHURN ----
# TAR FILE ----
# **** ----

library(targets)
library(tidyverse)

source("R/functions.R")

tar_option_set(packages = c("keras", "tidymodels", "tidyverse", "tidyquant"))

# TARGETS WORKFLOW ----

list(
    ## Identify Data Location ----
    tar_target(
        name    = churn_file,
        command = "data/churn.csv",
        format  = "file"
    )
    ,
    ## Read Data ----
    tar_target(
        name    = churn_data,
        command = read_data(churn_file)
    )
    ,
    ## Split Train / Test ----
    tar_target(
        name    = churn_splits,
        command = split_data(churn_data, prop = 0.7)
    )
    # ,
    # ## Make Recipe ----
    # tar_target(
    #     name    = churn_recipe,
    #     command = prepare_recipe(churn_splits)
    # )
    # ,
    # ## Try: Relu ----
    # tar_target(
    #     name    = run_relu,
    #     command = test_model(act1 = "relu", churn_splits, churn_recipe)
    # )
    # ,
    # ## Try: Sigmoid ----
    # tar_target(
    #     name    = run_sigmoid,
    #     command = test_model(act1 = "sigmoid", churn_splits, churn_recipe)
    # )
    # ,
    # ## Try: Softmax ----
    # tar_target(
    #     name    = run_softmax,
    #     command = test_model(act1 = "softmax", churn_splits, churn_recipe)
    # )
    # ,
    # ## Get Model Performance ----
    # tar_target(
    #     name    = model_performance,
    #     command = bind_rows(run_relu, run_sigmoid, run_softmax)
    # )
    # ,
    # ## Get Best Run ----
    # tar_target(
    #     name    = best_run,
    #     command = model_performance %>%
    #         slice_max(auc)
    # )
    # ,
    # ## Retrain Model on Full Dataset ----
    # tar_target(
    #     name    = production_model_keras,
    #     command = refit_run(best_run, churn_data, churn_recipe),
    #     format  = "keras"
    # )
    # ,
    # ## Final Predictions ----
    # tar_target(
    #     name    = predictions,
    #     command = predict_new_data(churn_data, churn_recipe, production_model_keras)
    # )
)

