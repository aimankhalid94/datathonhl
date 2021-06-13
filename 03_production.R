# SETUP ----
library(tidyverse)
library(tidymodels)
library(keras)
library(targets)

source("R/function.R")

best_model   <- tar_read(production_model_keras)

set.seed(123)
new_data_tbl <- readxl::read_excel("data/sme_data.xlsx") %>% slice_sample(n = 500)

test <- predict_new_data(
    new_data     = new_data_tbl,
    sme_recipe = tar_read(sme_recipe),
    sme_model  = tar_read(production_model_keras)
)
test$.pred_class=='yes'
# new_data_tbl_2 = new_data_tbl
prediction_tbl <- test %>%
    select(.pred_prob) %>%
    bind_cols(new_data_tbl %>% head(495))

prediction_tbl %>%
    ggplot(aes(interest_rate, .pred_prob, color = .pred_prob)) +
    geom_point() +
    geom_smooth(se = F)

prediction_tbl <- prediction_tbl %>%
    mutate(text = str_glue("Customer ID: {ID}
                            Prob (No Default): {scales::percent(.pred_prob, accuracy = 0.1)}
                           "))
prediction_tbl$text
color_primary = "#78c2ad"

g <- prediction_tbl %>%
    ggplot(aes(interest_rate, .pred_prob, color = .pred_prob)) +
    geom_point(aes(text = text), size = 4) +
    geom_smooth(se = F, color = 'black') +
    theme_minimal() +
    scale_color_gradient(low = color_primary, high = 'black') +
    labs(x = "Interest Rate", y = "Default Score (Larger = Worse)")

ggplotly(g, tooltip = "text") %>%
    highlight()
