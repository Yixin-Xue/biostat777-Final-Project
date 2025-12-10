mod_global_trends_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    title = "Global Trends",
    fluidPage(
      fluidRow(
        column(
          width = 6,
          h4("1) Quarterly reporting trend (all cases)"),
          plotOutput(ns("trend_plot"), height = "260px")
        ),
        column(
          width = 6,
          h4("2) Quarterly serious vs non-serious"),
          plotOutput(ns("serious_plot"), height = "260px")
        )
      ),
      fluidRow(
        column(
          width = 6,
          h4("3) Event counts by mechanism class"),
          plotOutput(ns("mech_plot"), height = "260px")
        ),
        column(
          width = 6,
          h4("4) Top 15 pseudo SOC"),
          plotOutput(ns("soc_plot"), height = "260px")
        )
      )
    )
  )
}

mod_global_trends_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    # Fetch quarter-level data once
    trend_quarter <- reactive({
      df <- get_global_trend_quarter(con)
      if (!nrow(df)) return(df)
      df |>
        dplyr::mutate(period = factor(period, levels = period))
    })

    output$trend_plot <- renderPlot({
      df <- trend_quarter()
      req(nrow(df) > 0)
      ggplot2::ggplot(df, ggplot2::aes(x = period, y = n_cases, group = 1)) +
        ggplot2::geom_line(color = "#2C3E50") +
        ggplot2::geom_point(color = "#2C3E50") +
        ggplot2::labs(x = "Quarter", y = "Cases", title = "Quarterly AE reports", subtitle = "FAERS 2019–2021") +
        ggplot2::theme_minimal() + center_titles +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
    })

    # Serious vs non-serious by quarter
    output$serious_plot <- renderPlot({
      df <- trend_quarter()
      req(nrow(df) > 0)
      df <- df |>
        dplyr::mutate(
          non_serious = pmax(n_cases - n_serious, 0)
        )
      ggplot2::ggplot(df, ggplot2::aes(x = period)) +
        ggplot2::geom_line(ggplot2::aes(y = n_serious, color = "Serious"), group = 1) +
        ggplot2::geom_point(ggplot2::aes(y = n_serious, color = "Serious")) +
        ggplot2::geom_line(ggplot2::aes(y = non_serious, color = "Non-serious"), group = 1) +
        ggplot2::geom_point(ggplot2::aes(y = non_serious, color = "Non-serious")) +
        ggplot2::scale_color_manual(values = c("Serious" = "#e74c3c", "Non-serious" = "#3498db")) +
        ggplot2::labs(x = "Quarter", y = "Cases", color = NULL, title = "Serious vs non-serious by quarter", subtitle = "FAERS 2019–2021") +
        ggplot2::theme_minimal() + center_titles +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                       legend.position = "top")
    })

    # Mechanism event counts
    output$mech_plot <- renderPlot({
      df <- get_mech_event_counts(con)
      req(nrow(df) > 0)
      ggplot2::ggplot(df, ggplot2::aes(x = n_events, y = reorder(mech_class, n_events))) +
        ggplot2::geom_col(fill = "#2980b9") +
        ggplot2::labs(x = "Number of events", y = "Mechanism", title = "Event counts by mechanism", subtitle = "FAERS 2019–2021") +
        ggplot2::theme_minimal() + center_titles
    })

    # Top pseudo SOC
    output$soc_plot <- renderPlot({
      df <- get_top_pseudo_soc(con, top_n = 15)
      req(nrow(df) > 0)
      ggplot2::ggplot(df, ggplot2::aes(x = n_events, y = reorder(pseudo_soc, n_events))) +
        ggplot2::geom_col(fill = "#16a085") +
        ggplot2::labs(x = "Number of events", y = "Pseudo SOC", title = "Top 15 pseudo SOC", subtitle = "FAERS 2019–2021") +
        ggplot2::theme_minimal() + center_titles
    })
  })
}
