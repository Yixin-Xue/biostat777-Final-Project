mod_methods_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h2("Methods & Downloads"),
    p("Document pipeline, definitions (PRR/ROR), and provide download links."),
    verbatimTextOutput(ns("methods_text"))
  )
}

mod_methods_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    output$methods_text <- renderText({
      paste(
        "Data source: FAERS (cleaned 2019-2021)",
        "Main table: cohort_analytic (cohort_drug_final, cohort_reac, cohort_outc, cohort_demo as inputs)",
        "Pseudo SOC mapping from data/pseudo_soc_map_top.csv + heuristics",
        "Use scripts step9-11 for cohort assembly and analytic table",
        sep = "\n"
      )
    })
  })
}
