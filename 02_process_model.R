# SETUP ----
library(reticulate)
library(targets)


# Setup ----
tar_script()

# Inspection ----

tar_manifest()

tar_glimpse()

tar_visnetwork()

tar_outdated()


# Workflow ----

tar_make()

tar_visnetwork()


# Tracking Functions ----

tar_read(sme_file)

tar_read(sme_data)

tar_read(sme_splits)

tar_read(sme_recipe)

tar_read(run_relu)
# tar_read(run_sigmoid)

tar_read(model_performance)

tar_read(best_run)

tar_read(production_model_keras)

tar_read(predictions)




