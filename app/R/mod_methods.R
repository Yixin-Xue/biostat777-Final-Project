mod_methods_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(HTML("
        h2.methods-title { font-size: 30px; font-weight: 800; margin-bottom: 8px; color: #002D72; }
        .methods-lead { font-size: 16px; margin-bottom: 18px; }
        .methods-section { margin-bottom: 12px; padding: 8px 0; border-bottom: 1px solid #e5e5e5; }
        summary { font-weight: 700; font-size: 17px; cursor: pointer; }
      "))
    ),
    h2("Methods & Downloads", class = "methods-title"),
    p("This page documents the data pipeline, analytical design, and reproducibility of the FAERS T2DM safety analysis.", class = "methods-lead"),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("📦 Data Collection & Cleaning Pipeline"),
      tags$ul(
        tags$li("Automated FAERS download across quarters (DEMO/DRUG/REAC/OUTC/THER)."),
        tags$li("Structured cleaning: column normalization, content cleaning, de-dup by case version, outlier filters."),
        tags$li("Drug name normalization via RxNorm API; PT → pseudo SOC mapping."),
        tags$li("SQLite as processing store for large-scale joins and aggregation.")
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("📊 Dashboard Structure"),
      tags$ul(
        tags$li("Home: context, data snapshot, team."),
        tags$li("Global Trends: quarterly volume and serious vs non-serious."),
        tags$li("Mechanism Comparison: PT/SOC patterns and PRR/ROR."),
        tags$li("Drug Profiles: per-drug trends, SOC mix, outcomes, top PT."),
        tags$li("Temporal Signals: quarterly forecasts (ARIMA, XGBoost, RF, ENet).")
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("💻 Programming Paradigms"),
      tags$table(
        class = "table table-striped",
        tags$thead(tags$tr(tags$th("Paradigm"), tags$th("Where used"), tags$th("Purpose"))),
        tags$tbody(
          tags$tr(tags$td("Command line"), tags$td("Rscript step1–step11"), tags$td("Batch ETL and cleaning")),
          tags$tr(tags$td("Functional (dplyr/purrr)"), tags$td("Pipeline scripts, cohort assembly"), tags$td("Composable data transforms")),
          tags$tr(tags$td("Database (DBI + SQLite)"), tags$td("cohort_analytic and staging tables"), tags$td("Large joins, aggregation")),
          tags$tr(tags$td("ML / Time series"), tags$td("Page 5: ARIMA, XGBoost, RF, ENet"), tags$td("Emerging signal forecasts"))
        )
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("⚠️ Data Scope & Limitations"),
      tags$ul(
        tags$li("Scope: FAERS 2019–2021 cleaned cohort."),
        tags$li("Spontaneous reporting; no causality or incidence rates."),
        tags$li("Subject to reporting bias, media effects, market size, duplicate reports.")
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("🔁 Reproducibility & Extensibility"),
      tags$ul(
        tags$li("End-to-end scripted (step1–step11)."),
        tags$li("Can extend to 2018–2024 by rerunning pipeline without code changes."),
        tags$li("Shiny decoupled from DB path via FAERS_DB_PATH.")
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("⬇️ Downloads (placeholders)"),
      p("Add downloadable summaries as needed:"),
      tags$ul(
        tags$li(downloadButton(ns("dl_mech"), "Mechanism summaries (CSV)")),
        tags$li(downloadButton(ns("dl_drug"), "Drug-level AE summaries (CSV)")),
        tags$li(downloadButton(ns("dl_prr"), "PRR/ROR results (CSV)"))
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("👥 Team & Repo"),
      tags$ul(
        tags$li("Team: Jet 2 Holiday — Jiayi Chu, Yixin Xue, Shuya Guo, Runjiu Chen"),
        tags$li("GitHub: add repo link if published"),
        tags$li("Data not redistributed here (FAERS size and terms); use faers.sqlite")
      )
    )
  )
}

mod_methods_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    # Placeholder download handlers; wire to real data if/when available
    output$dl_mech <- downloadHandler(
      filename = function() "mechanism_summaries.csv",
      content = function(file) write.csv(data.frame(message = "Add data"), file, row.names = FALSE)
    )
    output$dl_drug <- downloadHandler(
      filename = function() "drug_summaries.csv",
      content = function(file) write.csv(data.frame(message = "Add data"), file, row.names = FALSE)
    )
    output$dl_prr <- downloadHandler(
      filename = function() "prr_ror.csv",
      content = function(file) write.csv(data.frame(message = "Add data"), file, row.names = FALSE)
    )
  })
}
