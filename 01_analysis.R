# BUSINESS OBJECTIVE ----
# - Predict SME Credit Default

# LIBRARIES ----

library(keras)
library(tidymodels)
library(tidyquant)
library(tidyverse)
library(reticulate)


# KERAS SETUP ----
# 1.0 DATA ----

## Read Data -----
sme_data_raw <- readxl::read_excel("data/sme_data.xlsx")

sme_data_raw %>% glimpse()

## Remove unnecessary data ----
sme_data_tbl <- sme_data_raw %>%
    select(-ID) %>%
    drop_na() %>%
    select(Default_Flag, everything())

glimpse(sme_data_tbl)


# 2.0 TRAIN / TEST ----

## Split test/training sets ----
set.seed(100)
train_test_split <- initial_split(sme_data_tbl, prop = 0.8)
train_test_split

## Retrieve train and test sets ----
train_tbl <- training(train_test_split)
test_tbl  <- testing(train_test_split)

# 3.0 RECIPE ----

## Create recipe ----
rec_obj <- recipe(Default_Flag ~ ., data = train_tbl) %>%
    # step_discretize(tenure, options = list(cuts = 6)) %>%
    # step_log(TotalCharges) %>%
    step_dummy(all_nominal(), -all_outcomes()) %>%
    step_center(all_predictors(), -all_outcomes()) %>%
    step_scale(all_predictors(), -all_outcomes())

rec_prepped <- rec_obj %>% prep(data = train_tbl)


## Bake Predictors ----
x_train_tbl <- bake(rec_prepped, new_data = train_tbl) %>% select(-Default_Flag)
x_test_tbl  <- bake(rec_prepped, new_data = test_tbl) %>% select(-Default_Flag)

glimpse(x_train_tbl)


## Response variables for training and testing sets ----
y_train_vec <- ifelse(pull(train_tbl, Default_Flag) == 1, 1, 0)
y_test_vec  <- ifelse(pull(test_tbl, Default_Flag) == 1, 1, 0)


# 4.0 MODELING ----

## Building our Artificial Neural Network ----
model_keras <- keras_model_sequential()

model_keras %>%

    # First hidden layer
    layer_dense(
        units              = 16,
        kernel_initializer = "uniform",
        activation         = "relu",
        input_shape        = ncol(x_train_tbl)) %>%

    # Dropout to prevent overfitting
    layer_dropout(rate = 0.1) %>%

    # Second hidden layer
    layer_dense(
        units              = 16,
        kernel_initializer = "uniform",
        activation         = "relu") %>%

    # Dropout to prevent overfitting
    layer_dropout(rate = 0.1) %>%

    # Output layer
    layer_dense(
        units              = 1,
        kernel_initializer = "uniform",
        activation         = "sigmoid") %>%

    # Compile ANN
    compile(
        optimizer = 'adam',
        loss      = 'binary_crossentropy',
        metrics   = c('accuracy')
    )

model_keras

## Fit the keras model to the training data ----
history <- fit(
    object           = model_keras,
    x                = as.matrix(x_train_tbl),
    y                = y_train_vec,
    batch_size       = 50,
    epochs           = 35,
    validation_split = 0.30
)

## Model Diagnostics -----
print(history)

plot(history) +
    theme_tq() +
    scale_color_tq() +
    scale_fill_tq()


# 5.0 PREDICTIONS ----

## Predicted Class ----
yhat_keras_class_vec <- predict_classes(object = model_keras, x = as.matrix(x_test_tbl)) %>%
    as.vector()

## Predicted Class Probability ----
yhat_keras_prob_vec  <- predict_proba(object = model_keras, x = as.matrix(x_test_tbl)) %>%
    as.vector()


y_test_vec
## Format test data and predictions for yardstick metrics ----
estimates_keras_tbl <- tibble(
    truth      = as.factor(y_test_vec) %>% fct_recode(yes = "1", no = "0"),
    estimate   = as.factor(yhat_keras_class_vec) %>% fct_recode(yes = "1", no = "0"),
    class_prob = yhat_keras_prob_vec
)

estimates_keras_tbl

## Confusion Table ----
estimates_keras_tbl %>% conf_mat(truth, estimate)

## AUC ----
estimates_keras_tbl %>% roc_auc(truth, class_prob, event_level = 'second')

## Accuracy ----
estimates_keras_tbl %>% accuracy(truth, estimate)
