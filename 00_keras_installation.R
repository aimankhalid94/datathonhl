# BUSINESS SCIENCE LEARNING LABS ----
# LAB 56: TARGETS KERAS CHURN ----
# MODULE 00: KERAS SETUP ----
# **** ----

library(reticulate)

# PYTHON KERAS SETUP ----

## Installation ----
reticulate::conda_install(
    envname = "r-tf",
    packages = c("tensorflow", "keras", "h5py", "pyyaml")
)

## Select / Check python interpreter ----
#  - Tools > Project Options > Python > Select Interpreter ("r-tf")

reticulate::use_condaenv("r-tf", required = TRUE)

reticulate::py_config()

## Conda Environment YAML ----
#   - Open environment_r-tf.yml file to see specific python package versions


