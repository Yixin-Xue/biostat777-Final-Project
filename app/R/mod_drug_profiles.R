mod_drug_profiles_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h2("Individual Drug Profiles"),
    selectInput(ns("drug"), "Select drug", choices = NULL),
    plotOutput(ns("drug_trend")),
    tableOutput(ns("drug_top_events"))
  )
}

mod_drug_profiles_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    observe({
      if (is.null(con)) return()
      drugs <- db_safe_query(con, "SELECT DISTINCT target_generic FROM cohort_analytic ORDER BY target_generic")
      updateSelectInput(session, "drug", choices = drugs$target_generic)
    })

    output$drug_trend <- renderPlot({
      plot_placeholder("Drug trend placeholder")
    })

    output$drug_top_events <- renderTable({
      data.frame(message = "Top PT/pseudo_soc for selected drug")
    })
  })
}
