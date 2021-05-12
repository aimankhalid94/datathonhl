
# Check python interpreter
# - Tools > Project Options > Python > Select Interpreter ("r-tf")
reticulate::py_config()
reticulate::use_condaenv("r-tf", required = TRUE)

library(targets)

# Setup ----

# tar_script()


# Workflow ----

tar_make()

tar_manifest()

tar_glimpse()

tar_visnetwork()

tar_outdated()


# Tracking Functions ----

tar_read(churn_file)

tar_read(churn_data)

tar_read(best_run)

best_run_tbl <- tar_read(best_run)

best_model   <- tar_read(best_model)

tar_meta() %>% View()
