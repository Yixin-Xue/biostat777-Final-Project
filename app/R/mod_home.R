mod_home_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h2("Home / Overview"),
    p("Project: Safety and Adverse Event Characterization of Type 2 Diabetes Treatments"),
    p("Use the tabs to explore global trends, mechanism comparisons, drug profiles, temporal signals, and methods."),
    tags$ul(
      tags$li("Data source: FAERS (cleaned 2019-2021)"),
      tags$li("Database: faers.sqlite (override with env var FAERS_DB_PATH)"),
      tags$li("Main table: cohort_analytic (case x drug x AE)")
    ),
    h4("Tabs"),
    tags$ul(
      tags$li("Global Trends: overall volume, serious vs non-serious, mechanism mix, top pseudo SOC"),
      tags$li("Mechanism Comparison: PT heatmap, top AEs, PRR/ROR by mechanism"),
      tags$li("Drug Profiles: per-drug trend, SOC mix, outcomes, top PT"),
      tags$li("Temporal Signals: quarterly forecasts (ARIMA, XGBoost, RF, ENet) for top drugs"),
      tags$li("Methods & Downloads: pipeline summary and field definitions")
    ),
    h4("Notes"),
    tags$ul(
      tags$li("Coverage: 2019-2021; extend to 2018-2024 by rerunning the pipeline."),
      tags$li("Required R packages: shiny, DBI, RSQLite, ggplot2, dplyr, tibble, tidyr, DT, scales; optional for forecasts: forecast, xgboost, randomForest, glmnet."),
      tags$li("Database size ~25GB; first load may take a moment.")
    )
  )
}

mod_home_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    # Static content only for now
  })
}
