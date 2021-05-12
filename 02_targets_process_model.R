# BUSINESS SCIENCE LEARNING LABS ----
# LAB 56: TARGETS KERAS CHURN ----
# MODULE 02: TARGETS PROCESS MODEL ----
# **** ----

# SETUP ----
library(reticulate)
library(targets)

reticulate::use_condaenv("r-tf", required = TRUE)

# TARGETS DATA ANALYSIS ----

# Setup ----

# tar_script()

# Inspection ----

tar_manifest()

tar_glimpse()

tar_visnetwork()

tar_outdated()


# Workflow ----

tar_make()

tar_visnetwork()


# Tracking Functions ----

tar_read(churn_file)

tar_read(churn_data)

tar_read(churn_splits)

tar_read(churn_recipe)

tar_read(run_relu)
tar_read(run_sigmoid)

tar_read(model_performance)

tar_read(best_run)

tar_read(production_model_keras)

tar_read(predictions)




