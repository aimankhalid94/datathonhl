
# DATA LOAD & PREPROCESS ----

# Reads data from sme file
read_data <- function(sme_file) {
    readxl::read_excel(sme_file) %>%
        drop_na()
}

# Split Data
split_data <- function(sme_data, prop = 0.8, seed = 123) {
    set.seed(seed)
    ret <- sme_data %>%
        rsample::initial_split(prop = prop)
    return(ret)
}

# Takes output of read_and_split_data()
# Returns recipe
prepare_recipe <- function(sme_splits) {
    ret <- sme_splits %>%
        rsample::training() %>%
        recipes::recipe(Default_Flag ~ .) %>%
        recipes::step_rm(ID) %>%
        recipes::step_naomit(recipes::all_outcomes(), recipes::all_predictors()) %>%
        recipes::step_dummy(recipes::all_nominal(), -recipes::all_outcomes()) %>%
        recipes::step_center(recipes::all_predictors(), -recipes::all_outcomes()) %>%
        recipes::step_scale(recipes::all_predictors(), -recipes::all_outcomes()) %>%
        recipes::prep()
    return(ret)
}

# MODELING ----

# Defines the main tuning parameters of the model
define_model <- function(sme_data, sme_recipe, units1, units2, act1, act2, act3) {
    input_shape <- ncol(
        recipes::bake(sme_recipe, sme_data, recipes::all_predictors(), composition = "matrix")
    )
    ret <- keras::keras_model_sequential() %>%
        keras::layer_dense(
            units = units1,
            kernel_initializer = "uniform",
            activation = act1,
            input_shape = input_shape
        ) %>%
        keras::layer_dropout(rate = 0.1) %>%
        keras::layer_dense(
            units = units2,
            kernel_initializer = "uniform",
            activation = act2
        ) %>%
        keras::layer_dropout(rate = 0.1) %>%
        keras::layer_dense(
            units = 1,
            kernel_initializer = "uniform",
            activation = act3
        )
    return(ret)
}

# Tunes the model using define_model()
# Returns a fitted Keras Model
fit_model <- function(
    sme_data,
    sme_recipe,
    units1 = 16,
    units2 = 16,
    act1 = "relu",
    act2 = "relu",
    act3 = "sigmoid"
) {

    model <- define_model(sme_data, sme_recipe, units1, units2, act1, act2, act3)

    keras::compile(
        model,
        optimizer = "adam",
        loss = "binary_crossentropy",
        metrics = c("accuracy")
    )

    x_train_tbl <- recipes::bake(
        sme_recipe,
        sme_data,
        recipes::all_predictors(),
        composition = "matrix"
    )

    y_train_vec <- recipes::bake(
        sme_recipe,
        sme_data,
        recipes::all_outcomes()
    ) %>%
        dplyr::pull()

    keras::fit(
        object           = model,
        x                = x_train_tbl,
        y                = y_train_vec,
        batch_size       = 32,
        epochs           = 32,
        validation_split = 0.3,
        verbose          = 0
    )
    return(model)
}


test_estimates <- function(sme_splits, sme_recipe, sme_model) {

    testing_data <- recipes::bake(sme_recipe, testing(sme_splits))

    x_test_tbl <- testing_data %>%
        dplyr::select(-Default_Flag) %>%
        as.matrix()

    y_test_vec <- testing_data %>%
        dplyr::select(Default_Flag) %>%
        pull()

    yhat_keras_class_vec <- sme_model %>%
        keras::predict_classes(x_test_tbl) %>%
        as.factor() %>%
        forcats::fct_recode(yes = "1", no = "0")

    yhat_keras_prob_vec <- sme_model %>%
        keras::predict_proba(x_test_tbl) %>%
        as.vector()

    test_truth <- y_test_vec %>%
        as.factor() %>%
        forcats::fct_recode(yes = "1", no = "0")

    estimates_keras_tbl <- tibble(
        truth      = test_truth,
        estimate   = yhat_keras_class_vec,
        class_prob = yhat_keras_prob_vec
    )

    return(estimates_keras_tbl)
}

# Reports test accuracy
test_accuracy <- function(sme_splits, sme_recipe, sme_model) {

    test_estimates(sme_splits, sme_recipe, sme_model) %>%
        yardstick::accuracy(truth, estimate) %>%
        dplyr::pull(.estimate)

}

test_auc <- function(sme_splits, sme_recipe, sme_model) {

    test_estimates(sme_splits, sme_recipe, sme_model) %>%
        yardstick::roc_auc(truth, class_prob, event_level = 'second') %>%
        dplyr::pull(.estimate)
}

# Follows several steps:
# 1. Trains model with fit_model()
# 2. Gets accuracy: test_accuracy()
# 3. Gets auc: test_auc()
# 4. Summarizes results
test_model <- function(
    sme_splits,
    sme_recipe,
    units1 = 16,
    units2 = 16,
    act1 = "relu",
    act2 = "relu",
    act3 = "sigmoid"
) {
    sme_model <- fit_model(
        rsample::training(sme_splits),
        sme_recipe,
        units1, units2, act1, act2, act3
    )
    accuracy <- test_accuracy(sme_splits, sme_recipe, sme_model)
    auc      <- test_auc(sme_splits, sme_recipe, sme_model)
    tibble::tibble(
        accuracy = accuracy,
        auc      = auc,
        units1   = units1,
        units2   = units2,
        act1     = act1,
        act2     = act2,
        act3     = act3
    )
}

# Retrains a final model using parameters from a single run
refit_run <- function(sme_run, sme_data, sme_recipe) {
    fit_model(
        sme_data,
        sme_recipe,
        sme_run$units1,
        sme_run$units2,
        sme_run$act1,
        sme_run$act2,
        sme_run$act3
    )
}

# PREDICTION ----

predict_new_data <- function(new_data, sme_recipe, sme_model) {
    testing_data <- bake(sme_recipe, new_data)
    x_test_tbl <- testing_data %>%
        select(-Default_Flag) %>%
        as.matrix()
    yhat_keras_class_vec <- sme_model %>%
        predict_classes(x_test_tbl) %>%
        as.factor() %>%
        fct_recode(yes = "1", no = "0")
    yhat_keras_prob_vec <-
        sme_model %>%
        predict_proba(x_test_tbl) %>%
        as.vector()

    tibble(
        .pred_class = yhat_keras_class_vec,
        .pred_prob  = yhat_keras_prob_vec
    )

}
