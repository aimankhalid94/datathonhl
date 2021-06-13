# BUSINESS SCIENCE LEARNING LABS ----
# LAB 56: TARGETS KERAS sme ----
# TAR FILE ----
# **** ----

library(targets)
library(tidyverse)

source("R/function.R")

tar_option_set(packages = c("keras", "tidymodels", "tidyverse", "tidyquant"))

# TARGETS WORKFLOW ----

list(
    ## Identify Data Location ----
    tar_target(
        name    = sme_file,
        command = "data/sme_data.xlsx",
        format  = "file"
    )
    ,
    ## Read Data ----
    tar_target(
        name    = sme_data,
        command = read_data(sme_file)
    )
    ,
    ## Split Train / Test ----
    tar_target(
        name    = sme_splits,
        command = split_data(sme_data, prop = 0.8)
    )
    ,
    ## Make Recipe ----
    tar_target(
        name    = sme_recipe,
        command = prepare_recipe(sme_splits)
    )
    ,
    ## Try: Relu ----
    tar_target(
        name    = run_relu,
        command = test_model(act1 = "relu", sme_splits, sme_recipe)
    )
    ,
    # ## Try: Sigmoid ----
    # tar_target(
    #     name    = run_sigmoid,
    #     command = test_model(act1 = "sigmoid", sme_splits, sme_recipe)
    # )
    # ,
    # ## Try: Softmax ----
    # tar_target(
    #     name    = run_softmax,
    #     command = test_model(act1 = "softmax", sme_splits, sme_recipe)
    # )
    # ,
    ## Try: Softmax units 1: 32 ----
    # tar_target(
    #     name    = run_softmax_units1_32,
    #     command = test_model(act1 = "softmax", units1 = 32, sme_splits, sme_recipe)
    # )
    # ,
    ## Get Model Performance ----
    tar_target(
        name    = model_performance,
        command = bind_rows(run_relu)
        # command = bind_rows(run_relu, run_sigmoid, run_softmax, run_softmax_units1_32)
    )
    ,
    ## Get Best Run ----
    tar_target(
        name    = best_run,
        command = model_performance %>%
            slice_max(auc)
    )
    ,
    ## Retrain Model on Full Dataset ----
    tar_target(
        name    = production_model_keras,
        command = refit_run(best_run, sme_data, sme_recipe),
        format  = "keras"
    )
    ,
    ## Final Predictions ----
    tar_target(
        name    = predictions,
        command = predict_new_data(sme_data, sme_recipe, production_model_keras)
    )
)

