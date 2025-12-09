mod_home_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h2("Home / Overview"),
    p("Project: Safety and Adverse Event Characterization of Type 2 Diabetes Treatments"),
    p("Use the tabs to explore global trends, mechanism comparisons, drug profiles, temporal signals, and methods."),
    tags$ul(
      tags$li("Data source: FAERS (cleaned 2019-2021)"),
      tags$li("Database: faers.sqlite"),
      tags$li("Main table: cohort_analytic")
    )
  )
}

mod_home_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    # Static content only for now
  })
}
