library(targets)

source("R/functions.R")

tar_option_set(packages = c("keras", "tidymodels", "tidyverse", "tidyquant"))

# SIMPLE WORKFLOW ----

list(
    tar_target(
        name    = churn_file,
        command = "data/churn.csv",
        format  = "file"
    ),
    tar_target(
        name    = churn_data,
        command = split_data(churn_file)
    ),
    tar_target(
        name    = churn_recipe,
        command = prepare_recipe(churn_data)
    )
)

