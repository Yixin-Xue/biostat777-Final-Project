mod_temporal_signals_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    title = "Temporal & Emerging Signals",
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("drug"), "Select a drug (top by reports)", choices = NULL)
      ),
      mainPanel(
        h4("Time series and multi-model forecasts"),
        plotOutput(ns("ts_plot"), height = "420px"),
        h4("Forecast values for next 4 quarters"),
        tableOutput(ns("ts_table"))
      )
    )
  )
}

mod_temporal_signals_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    # Optional packages
    has_forecast <- requireNamespace("forecast", quietly = TRUE)
    has_xgb      <- requireNamespace("xgboost", quietly = TRUE)
    has_rf       <- requireNamespace("randomForest", quietly = TRUE)
    has_en       <- requireNamespace("glmnet", quietly = TRUE)

    col_obs   <- "#1d4ed8"
    col_arima <- "#0ea5e9"
    col_xgb   <- "#f97316"
    col_rf    <- "#22c55e"
    col_en    <- "#a855f7"

    # Helpers --------------------------------------------------------------
    get_top10_drugs <- function(con) {
      sql <- "
        SELECT target_generic, COUNT(*) AS n
        FROM cohort_analytic
        GROUP BY target_generic
        ORDER BY n DESC
        LIMIT 10
      "
      df <- DBI::dbGetQuery(con, sql)
      if (nrow(df) == 0) return(character(0))
      df$target_generic
    }

    next_yq <- function(last_year, last_quarter, h = 4) {
      steps <- seq_len(h)
      tibble::tibble(
        year    = last_year + (last_quarter + steps - 1) %/% 4,
        quarter = ((last_quarter + steps - 1) %% 4) + 1
      ) |>
        dplyr::mutate(year_quarter = paste0(year, "Q", quarter))
    }

    is_flat <- function(x, tol = 1e-6) {
      x <- as.numeric(x)
      if (length(x) <= 1 || any(!is.finite(x))) return(FALSE)
      rng <- max(x) - min(x)
      mean_abs <- mean(abs(x), na.rm = TRUE)
      rng < tol * max(1, mean_abs)
    }

    build_ts_and_forecasts <- function(drug_name, con, h = 4) {
      sql <- "
        SELECT source_quarter, COUNT(*) AS n
        FROM cohort_analytic
        WHERE target_generic = ?
        GROUP BY source_quarter
        ORDER BY source_quarter
      "
      df <- DBI::dbGetQuery(con, sql, params = list(drug_name))
      if (nrow(df) < 4) {
        return(list(ok = FALSE, reason = "Not enough quarters for modeling", observed = df, combined = NULL, fc_table = NULL))
      }

      df <- df |>
        dplyr::mutate(
          year    = as.integer(substr(source_quarter, 1, 4)),
          quarter = as.integer(substr(source_quarter, 6, 6))
        ) |>
        dplyr::arrange(year, quarter)

      y <- df$n
      # future periods
      yq_fc <- next_yq(tail(df$year, 1), tail(df$quarter, 1), h = h) |>
        dplyr::mutate(
          t        = max(seq_len(nrow(df))) + dplyr::row_number(),
          q_factor = as.integer(factor(quarter, levels = 1:4))
        )

      df_feats <- df |>
        dplyr::mutate(
          t        = dplyr::row_number(),
          q_factor = as.integer(factor(quarter, levels = 1:4))
        )
      X_train <- as.matrix(df_feats[, c("t", "q_factor")])
      y_train <- df_feats$n
      X_future <- as.matrix(yq_fc[, c("t", "q_factor")])

      df_obs <- df |>
        dplyr::transmute(
          year, quarter,
          year_quarter = source_quarter,
          kind = "Observed",
          model = "Observed",
          value = n
        )

      df_fc_arima <- df_fc_xgb <- df_fc_rf <- df_fc_en <- NULL

      # ARIMA (log1p)
      if (has_forecast) {
        ts_y <- stats::ts(log1p(y), frequency = 4)
        fit_arima <- try(forecast::auto.arima(ts_y, stepwise = FALSE, approximation = FALSE), silent = TRUE)
        if (!inherits(fit_arima, "try-error")) {
          fc <- forecast::forecast(fit_arima, h = h)
          pred <- pmax(0, expm1(as.numeric(fc$mean)))
          if (!is_flat(pred)) {
            df_fc_arima <- tibble::tibble(
              year         = yq_fc$year,
              quarter      = yq_fc$quarter,
              year_quarter = yq_fc$year_quarter,
              kind         = "Forecast",
              model        = "ARIMA",
              value        = pred
            )
          }
        }
      }

      # XGBoost
      if (has_xgb) {
        dtrain <- xgboost::xgb.DMatrix(data = X_train, label = y_train)
        params <- list(objective = "reg:squarederror", max_depth = 3, eta = 0.2, subsample = 0.8, nthread = 1)
        fit_xgb <- try(
          xgboost::xgb.train(params = params, data = dtrain, nrounds = 80, verbose = 0),
          silent = TRUE
        )
        if (!inherits(fit_xgb, "try-error")) {
          pred_xgb <- try(predict(fit_xgb, newdata = X_future), silent = TRUE)
          if (!inherits(pred_xgb, "try-error") && !is_flat(pred_xgb)) {
            df_fc_xgb <- tibble::tibble(
              year         = yq_fc$year,
              quarter      = yq_fc$quarter,
              year_quarter = yq_fc$year_quarter,
              kind         = "Forecast",
              model        = "XGBoost",
              value        = as.numeric(pred_xgb)
            )
          }
        }
      }

      # Random Forest
      if (has_rf) {
        df_rf_train <- data.frame(y = y_train, t = df_feats$t, q_factor = factor(df_feats$q_factor))
        fit_rf <- try(randomForest::randomForest(y ~ t + q_factor, data = df_rf_train), silent = TRUE)
        if (!inherits(fit_rf, "try-error")) {
          df_rf_future <- data.frame(t = yq_fc$t, q_factor = factor(yq_fc$q_factor, levels = levels(df_rf_train$q_factor)))
          pred_rf <- try(predict(fit_rf, newdata = df_rf_future), silent = TRUE)
          if (!inherits(pred_rf, "try-error") && !is_flat(pred_rf)) {
            df_fc_rf <- tibble::tibble(
              year         = yq_fc$year,
              quarter      = yq_fc$quarter,
              year_quarter = yq_fc$year_quarter,
              kind         = "Forecast",
              model        = "RF",
              value        = as.numeric(pred_rf)
            )
          }
        }
      }

      # Elastic Net
      if (has_en) {
        fit_en <- try(glmnet::cv.glmnet(X_train, y_train, alpha = 0.5), silent = TRUE)
        if (!inherits(fit_en, "try-error")) {
          pred_en <- try(as.numeric(stats::predict(fit_en, newx = X_future, s = "lambda.min")), silent = TRUE)
          if (!inherits(pred_en, "try-error") && !is_flat(pred_en)) {
            df_fc_en <- tibble::tibble(
              year         = yq_fc$year,
              quarter      = yq_fc$quarter,
              year_quarter = yq_fc$year_quarter,
              kind         = "Forecast",
              model        = "ENet",
              value        = pred_en
            )
          }
        }
      }

      df_fc_all <- dplyr::bind_rows(df_fc_arima, df_fc_xgb, df_fc_rf, df_fc_en)
      df_all    <- dplyr::bind_rows(df_obs, df_fc_all)

      fc_table <- NULL
      if (!is.null(df_fc_all) && nrow(df_fc_all) > 0) {
        fc_table <- df_fc_all |>
          dplyr::select(year_quarter, model, value) |>
          tidyr::pivot_wider(names_from = model, values_from = value) |>
          dplyr::arrange(year_quarter)
      }

      list(ok = TRUE, observed = df, combined = df_all, fc_table = fc_table)
    }

    # Populate drug choices
    observe({
      choices <- get_top10_drugs(con)
      if (length(choices)) {
        updateSelectInput(session, "drug", choices = choices, selected = choices[1])
      }
    })

    # Plot output
    output$ts_plot <- renderPlot({
      drug <- input$drug
      if (is.null(drug) || !nzchar(drug)) {
        return(
          ggplot2::ggplot() +
            ggplot2::annotate("text", x = 0.5, y = 0.5, label = "Please select a drug.", size = 6) +
            ggplot2::theme_void()
        )
      }

      res <- build_ts_and_forecasts(drug, con, h = 4)
      df_all <- res$combined
      if (is.null(df_all) || nrow(df_all) == 0) {
        return(
          ggplot2::ggplot() +
            ggplot2::annotate("text", x = 0.5, y = 0.5, label = "No data available for this drug.", size = 6) +
            ggplot2::theme_void()
        )
      }

      df_all <- df_all |>
        dplyr::arrange(year, quarter) |>
        dplyr::mutate(year_quarter = factor(year_quarter, levels = unique(year_quarter)))

      p <- ggplot2::ggplot()
      # Observed
      df_obs <- dplyr::filter(df_all, kind == "Observed")
      p <- p +
        ggplot2::geom_line(data = df_obs, ggplot2::aes(x = year_quarter, y = value, group = 1),
                           color = col_obs, linewidth = 1.8) +
        ggplot2::geom_point(data = df_obs, ggplot2::aes(x = year_quarter, y = value),
                            color = col_obs, size = 3)

      add_model <- function(df, col, linetype) {
        if (nrow(df) > 0) {
          p <<- p +
            ggplot2::geom_line(data = df, ggplot2::aes(x = year_quarter, y = value, group = 1),
                               color = col, linewidth = 1.6, linetype = linetype) +
            ggplot2::geom_point(data = df, ggplot2::aes(x = year_quarter, y = value),
                                color = col, size = 3)
        }
      }

      add_model(dplyr::filter(df_all, kind == "Forecast", model == "ARIMA"), col_arima, "dashed")
      add_model(dplyr::filter(df_all, kind == "Forecast", model == "XGBoost"), col_xgb, "dotdash")
      add_model(dplyr::filter(df_all, kind == "Forecast", model == "RF"), col_rf, "longdash")
      add_model(dplyr::filter(df_all, kind == "Forecast", model == "ENet"), col_en, "dotted")

      p +
        ggplot2::labs(
          x = "Year-Quarter",
          y = "Number of reports",
          title = paste("Quarterly AE reports for", drug)
        ) +
        ggplot2::theme_minimal(base_size = 13) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    })

    # Forecast table
    output$ts_table <- renderTable({
      drug <- input$drug
      if (is.null(drug) || !nzchar(drug)) return(NULL)
      res <- build_ts_and_forecasts(drug, con, h = 4)
      tbl <- res$fc_table
      if (is.null(tbl) || nrow(tbl) == 0) return(NULL)
      tbl <- as.data.frame(tbl)
      num_cols <- setdiff(names(tbl), "year_quarter")
      for (nm in num_cols) {
        if (is.numeric(tbl[[nm]])) tbl[[nm]] <- round(tbl[[nm]], 1)
      }
      names(tbl)[names(tbl) == "year_quarter"] <- "YearQuarter"
      tbl
    })
  })
}
