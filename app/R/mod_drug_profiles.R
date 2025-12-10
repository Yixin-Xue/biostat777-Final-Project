mod_drug_profiles_ui <- function(id) {
  ns <- NS(id)
    tabPanel(
    title = "Drug Profiles",
    sidebarLayout(
      sidebarPanel(
        width = 3,
        tags$head(tags$style(HTML("
          /* Narrow sidebar styling for Drug Profiles */
          #", ns("sidebar"), " { padding:8px 10px; background:#fafafa; border:1px solid #ddd; border-radius:6px; }
          #", ns("sidebar"), " .form-group { margin-bottom:8px; }
          #", ns("sidebar"), " label { font-size:12px; font-weight:600; margin-bottom:2px; }
          #", ns("sidebar"), " select { font-size:12px; padding:2px 6px; height:30px; }
        "))),
        div(
          id = ns("sidebar"),
          selectInput(ns("drug"), "Select drug", choices = NULL, width = "100%"),
          selectInput(ns("time_level"), "Time scale", choices = c("Quarter" = "quarter", "Year" = "year"), selected = "quarter", width = "100%")
        )
      ),
      mainPanel(
        fluidRow(
          column(4, uiOutput(ns("kpi_total_cases"))),
          column(4, uiOutput(ns("kpi_serious_prop"))),
          column(4, uiOutput(ns("kpi_soc_count")))
        ),
        fluidRow(
          column(12, plotOutput(ns("plot_time"), height = "320px"))
        ),
        fluidRow(
          column(6, plotOutput(ns("plot_soc"), height = "260px")),
          column(6, plotOutput(ns("plot_outcome"), height = "260px"))
        ),
        fluidRow(
          column(12, DT::dataTableOutput(ns("tbl_pt")))
        )
      )
    )
  )
}

mod_drug_profiles_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Initialize drug choices
    observe({
      drugs <- get_available_drugs(con)
      if (length(drugs)) {
        updateSelectInput(session, "drug", choices = drugs, selected = drugs[1])
      }
    })

    # Reactive data pulls
    ts_data <- reactive({
      req(input$drug, input$time_level)
      get_drug_time_series(con, input$drug, level = input$time_level)
    })

    soc_data <- reactive({
      req(input$drug)
      get_drug_soc_dist(con, input$drug, top_n = 10)
    })

    pt_data <- reactive({
      req(input$drug)
      get_drug_top_pt(con, input$drug, n = 15)
    })

    outcome_data <- reactive({
      req(input$drug)
      get_drug_outcomes(con, input$drug)
    })

    # KPI: total cases
    output$kpi_total_cases <- renderUI({
      d <- outcome_data()
      total <- if (nrow(d) && !is.na(d$total_cases)) d$total_cases else 0
      div(class = "well", style = "padding:8px 10px; font-size:12px;",
          div(style = "display:flex; justify-content:space-between; align-items:center;",
              span("Total cases", style = "font-weight:600;"),
              span(format(total, big.mark = ","), style = "font-size:16px; font-weight:700;")
          )
      )
    })

    # KPI: serious proportion (any serious outcome per case)
    output$kpi_serious_prop <- renderUI({
      d <- outcome_data()
      if (!nrow(d)) return(div(class = "well", h4("Serious proportion"), strong("N/A")))
      serious_cases <- ifelse(!is.na(d$serious_cases), d$serious_cases, 0)
      prop <- ifelse(d$total_cases > 0, serious_cases / d$total_cases, NA_real_)
      div(class = "well", style = "padding:8px 10px; font-size:12px;",
          div(style = "display:flex; justify-content:space-between; align-items:center;",
              span("Serious cases", style = "font-weight:600;"),
              span(ifelse(is.na(prop), "N/A", scales::percent(prop, accuracy = 0.1)), style = "font-size:16px; font-weight:700;")
          )
      )
    })

    # KPI: number of SOC categories
    output$kpi_soc_count <- renderUI({
      soc <- soc_data()
      div(class = "well", style = "padding:8px 10px; font-size:12px;",
          div(style = "display:flex; justify-content:space-between; align-items:center;",
              span("SOC count", style = "font-weight:600;"),
              span(nrow(soc), style = "font-size:16px; font-weight:700;")
          )
      )
    })

    # Time trend
    output$plot_time <- renderPlot({
      df <- ts_data()
      req(nrow(df) > 0)
      ggplot(df, aes(x = period, y = n_cases, group = 1)) +
        geom_line(color = "#2C3E50") +
        geom_point(color = "#18BC9C") +
        labs(x = "Period", y = "Cases", title = paste("Reporting trend -", input$drug), subtitle = "FAERS 2019–2021") +
        theme_minimal() + center_titles
    })

    # SOC distribution (Top 10)
    output$plot_soc <- renderPlot({
      df <- soc_data()
      req(nrow(df) > 0)
      ggplot(df, aes(x = reorder(pseudo_soc, n_events), y = n_events)) +
        geom_col(fill = "#3498DB") +
        coord_flip() +
        labs(x = "Pseudo SOC", y = "Events", title = "Top SOCs", subtitle = paste("Top 10 for", input$drug)) +
        theme_minimal() + center_titles
    })

    # Serious outcomes breakdown
    output$plot_outcome <- renderPlot({
      d <- outcome_data()
      req(nrow(d) > 0)
      df <- tibble::tibble(
        outcome = c("Death", "Hospitalization", "Life-threatening", "Disability",
                    "Congenital", "Required intervention"),
        n = c(d$death, d$hosp, d$lifethreat, d$disability, d$congenital, d$required_intervention)
      )
      ggplot(df, aes(x = outcome, y = n)) +
        geom_col(fill = "#E67E22") +
        coord_flip() +
        labs(x = NULL, y = "Cases", title = "Serious outcomes", subtitle = paste("Any serious flag for", input$drug)) +
        theme_minimal() + center_titles
    })

    # Top Preferred Terms table
    output$tbl_pt <- DT::renderDataTable({
      df <- pt_data()
      if (!nrow(df)) return(df)
      df <- df |>
        dplyr::mutate(
          proportion = ifelse(sum(n_events) > 0, n_events / sum(n_events), NA_real_)
        )
      DT::datatable(
        df,
        options = list(pageLength = 10),
        rownames = FALSE
      )
    })
  })
}
