mod_mech_compare_ui <- function(id) {
  ns <- NS(id)
  tabPanel(
    title = "Mechanism Comparison",
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("mech"), "Select mechanism class", choices = NULL),
        sliderInput(ns("top_n_pt"), "Number of PTs in heatmap", min = 20, max = 80, value = 50, step = 10)
      ),
      mainPanel(
      tabsetPanel(
        tabPanel("Heatmap", plotOutput(ns("heatmap_plot"), height = "600px")),
        tabPanel("Top AE", plotOutput(ns("top_ae_plot"), height = "600px")),
        tabPanel("PRR / ROR",
                 tableOutput(ns("prr_table")),
                 br(),
                 h4("PRR/ROR 2x2 table definition"),
                 tags$p("a = reports in the selected mechanism class that include this PT"),
                 tags$p("b = reports in the selected mechanism class that do not include this PT"),
                 tags$p("c = reports in all other mechanism classes that include this PT"),
                 tags$p("d = reports in all other mechanism classes that do not include this PT"),
                 tags$table(
                   class = "table table-bordered table-condensed",
                   tags$thead(
                     tags$tr(
                       tags$th(""),
                       tags$th("PT reported"),
                       tags$th("PT not reported")
                     )
                   ),
                   tags$tbody(
                     tags$tr(
                       tags$td("Selected mechanism class"),
                       tags$td("a"),
                       tags$td("b")
                     ),
                     tags$tr(
                       tags$td("All other classes"),
                       tags$td("c"),
                       tags$td("d")
                     )
                   )
                 )
        )
        )
      )
    )
  )
}

mod_mech_compare_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Initialize mechanism choices
    observe({
      mech_choices <- get_mechanism_classes(con)
      if (length(mech_choices)) {
        updateSelectInput(session, "mech", choices = mech_choices, selected = mech_choices[1])
      }
    })

    # Heatmap data (restricted to top PT overall)
    pt_heat_data <- reactive({
      req(input$top_n_pt)
      get_pt_heatmap_data(con, top_n = input$top_n_pt)
    })

    # Heatmap: mechanism x PT proportion
    output$heatmap_plot <- renderPlot({
      res <- pt_heat_data()
      req(length(res) == 2)
      top_pt <- res$top_pt
      counts <- res$counts
      req(nrow(counts) > 0)

      mech_totals <- counts |>
        dplyr::group_by(mech_class) |>
        dplyr::summarise(total = sum(n_events), .groups = "drop")

      df <- counts |>
        dplyr::left_join(mech_totals, by = "mech_class") |>
        dplyr::mutate(
          prop = ifelse(total > 0, n_events / total, NA_real_),
          pt = factor(pt, levels = rev(top_pt$pt)) # keep overall top order
        )

      ggplot2::ggplot(df, ggplot2::aes(x = mech_class, y = pt, fill = prop)) +
        ggplot2::geom_tile() +
        ggplot2::scale_fill_gradient(low = "white", high = "red", na.value = "grey90") +
        ggplot2::labs(x = "Mechanism class", y = "Preferred Term (PT)", fill = "Proportion", title = "PT heatmap by mechanism", subtitle = "Scaled within mechanism") +
        ggplot2::theme_minimal() + center_titles +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                       axis.text.y = ggplot2::element_text(size = 7))
    })

    # Top AE bar chart (selected mechanism)
    output$top_ae_plot <- renderPlot({
      req(input$mech)
      df <- get_top_pt_by_mech(con, input$mech, top_n = 20)
      req(nrow(df) > 0)
      ggplot2::ggplot(df, ggplot2::aes(x = reorder(pt, n_events), y = n_events)) +
        ggplot2::geom_col(fill = "#0ABAB5") +
        ggplot2::coord_flip() +
        ggplot2::labs(x = "Preferred Term (PT)", y = "Count", title = paste("Top 20 AEs for", input$mech), subtitle = "Counts within selected mechanism") +
        ggplot2::theme_minimal() + center_titles
    })

    # PRR / ROR table
    output$prr_table <- renderTable({
      req(input$mech)
      df <- get_prr_counts(con, input$mech, top_n = 30)
      if (!nrow(df)) return(data.frame())
      # Haldane-Anscombe correction to avoid div-by-zero
      df <- df |>
        dplyr::mutate(
          prr = ((a + 0.5) / (a + b + 1)) / ((c + 0.5) / (c + d + 1)),
          ror = ((a + 0.5) / (b + 0.5)) / ((c + 0.5) / (d + 0.5))
        ) |>
        dplyr::select(pt, a, b, c, d, prr, ror) |>
        dplyr::arrange(dplyr::desc(prr))
      df
    })
  })
}
