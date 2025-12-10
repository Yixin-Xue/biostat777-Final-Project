mod_methods_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h2("Methods & Downloads"),
    p("Document pipeline, key definitions, and provide download links (fill as needed)."),
    h4("Pipeline summary"),
    verbatimTextOutput(ns("methods_text")),
    h4("Field hints (cohort_analytic)"),
    verbatimTextOutput(ns("fields_text"))
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

    output$fields_text <- renderText({
      paste(
        "Key fields in cohort_analytic:",
        "- target_generic: standardized drug name (16 T2DM drugs)",
        "- mech_class_final: mechanism class (GLP1, SGLT2, DPP4, Biguanide, BasalInsulin, GIP_GLP1)",
        "- source_quarter: source period (e.g., 2019Q1)",
        "- pt / pseudo_soc: preferred term and mapped pseudo SOC",
        "- Outcomes: death, hosp, lifethreat, disability, congenital, required_intervention",
        "- Demographics: age, sex, country",
        sep = "\n"
      )
    })
  })
}
