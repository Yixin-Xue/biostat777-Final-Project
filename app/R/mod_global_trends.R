mod_global_trends_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    h2("Global Trends"),
    p("Aggregate reporting trends, serious vs non-serious, by quarter."),
    plotOutput(ns("trend_plot")),
    tableOutput(ns("trend_table"))
  )
}

mod_global_trends_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    output$trend_plot <- renderPlot({
      plot_placeholder("Global trend placeholder")
    })
    output$trend_table <- renderTable({
      data.frame(message = "Populate with cohort_analytic grouped by source_quarter")
    })
  })
}
