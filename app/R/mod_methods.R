mod_methods_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(HTML("
        h2.methods-title { font-size: 30px; font-weight: 800; margin-bottom: 8px; color: #002D72; }
        .methods-lead { font-size: 16px; margin-bottom: 18px; }
        .methods-section { margin-bottom: 12px; padding: 8px 0; border-bottom: 1px solid #e5e5e5; }
        summary { font-weight: 700; font-size: 17px; cursor: pointer; }
        /* Arrow icons for collapsible sections */
        summary::before { content: '▸'; display: inline-block; margin-right: 6px; transition: transform 0.2s; }
        details[open] > summary::before { content: '▾'; }
      "))
    ),
    h2("Methods & Limitations", class = "methods-title"),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("👥 Dashboard Ownership"),
      tags$ul(
        tags$li("Home / Overview — Together"),
        tags$li("Global Trends — Shuya Guo"),
        tags$li("Mechanism Comparison — Jiayi Chu"),
        tags$li("Individual Drug Profiles — Yixin Xue"),
        tags$li("Temporal & Emerging Signals — Runjiu Chen"),
        tags$li("Methods & Downloads — Together")
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
          tags$tr(tags$td("Machine learning / Time series"), tags$td("Page 5: ARIMA, XGBoost, RF, ENet"), tags$td("Emerging signal forecasts"))
        )
      )
    ),
    tags$details(
      open = TRUE,
      class = "methods-section",
      tags$summary("⚠️ Data Scope & Limitations"),
      tags$ul(
        tags$li("Scope: FAERS reports (2019–2021) for a cleaned, case-level cohort of selected T2DM drugs."),
        tags$li("Spontaneous reporting: Results reflect reporting patterns, not incidence or absolute risk."),
        tags$li("No causality: Associations do not imply causal relationships."),
        tags$li("Reporting bias: Influenced by media attention, regulation, market exposure, and prescribing patterns."),
        tags$li("Data quality: Reports may contain missing, incomplete, or duplicate information despite de-duplication.")
      )
    ),
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
