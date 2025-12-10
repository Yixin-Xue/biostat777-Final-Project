mod_home_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(HTML("
        :root { --jhu-blue: #002D72; --jhu-light: #e6eef8; }
        .metric-card { background: var(--jhu-light); padding:14px 16px; border-radius:8px; margin-bottom:10px; border:1px solid #cbd6e6; }
        .metric-title { font-size:13px; text-transform:uppercase; color:#3a4a70; margin:0; letter-spacing:0.5px; }
        .metric-value { font-size:20px; font-weight:700; margin:2px 0 0 0; color: var(--jhu-blue); }
        .hero-title { font-size: 28px; font-weight: 800; color: var(--jhu-blue); }
        .hero-subtitle { font-size: 18px; font-weight: 700; color: #0f3f8c; }
        .hero-body { font-size: 15px; line-height: 1.5; color: #1f2f4f; }
      "))
    ),
    fluidRow(
      column(
        width = 7,
        h2("Safety and Adverse Event Characterization of Type 2 Diabetes Treatments", class = "hero-title"),
        h4("A comparative pharmacovigilance analysis of FAERS (2019–2021) across 16 T2DM drugs in 6 mechanisms", class = "hero-subtitle"),
        p("Type 2 diabetes requires long-term treatment with multiple drug classes, each with distinct mechanisms and adverse event profiles. The FDA’s FAERS database contains millions of real-world safety reports linking patient demographics, drug exposures, and MedDRA-coded clinical events. As newer agents (e.g., GLP-1 receptor agonists, SGLT2 inhibitors, GIP/GLP-1 agonists) are used alongside older therapies such as metformin, DPP-4 inhibitors, and basal insulin, the safety landscape has become increasingly complex. This dashboard provides a unified view of FAERS data to help clinicians and researchers explore and compare adverse event patterns across commonly used T2DM treatments.", class = "hero-body"),
        h4("Team", class = "hero-subtitle"),
        p("Team name: Jet 2 Holiday"),
        p("Members: Jiayi Chu, Yixin Xue, Shuya Guo, Runjiu Chen"),
        h4("Research questions", class = "hero-subtitle"),
        tags$ul(
          tags$li("Global Trends: How do quarterly report volumes and serious outcomes change over time?"),
          tags$li("Mechanism Comparison: Which PTs/SOCs dominate each mechanism, and where are disproportional signals (PRR/ROR)?"),
          tags$li("Drug Profiles: For each drug, what are the top events, SOC mix, and serious outcome patterns?"),
          tags$li("Temporal Signals: Do time-series models flag emerging signals for top drugs?")
        )
      ),
      column(
        width = 5,
        tags$img(src = "index-picture.jpg", alt = "Dashboard illustration", style = "max-width:90%; border-radius:8px; display:block; margin-left:auto;")
      )
    ),
    hr(),
    h4("Data snapshot"),
    fluidRow(
      column(3, div(class = "metric-card", p(class = "metric-title", "Data source"), p(class = "metric-value", "FAERS"))),
      column(3, div(class = "metric-card", p(class = "metric-title", "Time window"), p(class = "metric-value", "2019–2021"))),
      column(3, div(class = "metric-card", p(class = "metric-title", "Total cases"), p(class = "metric-value", "203,237"))),
      column(3, div(class = "metric-card", p(class = "metric-title", "Drug–event records"), p(class = "metric-value", "≈17.6M")))
    ),
    fluidRow(
      column(3, div(class = "metric-card", p(class = "metric-title", "Target drugs"), p(class = "metric-value", "16"))),
      column(3, div(class = "metric-card", p(class = "metric-title", "Mechanism classes"), p(class = "metric-value", "6"))),
      column(6, div(class = "metric-card", p(class = "metric-title", "Database"), p(class = "metric-value", "faers.sqlite")))
    ),
    hr(),
    h4("Target drugs and mechanisms"),
    fluidRow(
      column(
        6,
        tags$strong("Biguanide / DPP-4 / Basal insulin"),
        tags$ul(
          tags$li("Biguanide: Metformin"),
          tags$li("DPP-4: Sitagliptin, Saxagliptin, Linagliptin, Alogliptin"),
          tags$li("Basal insulin: Insulin glargine, Insulin degludec")
        )
      ),
      column(
        6,
        tags$strong("Incretins / SGLT2"),
        tags$ul(
          tags$li("GLP-1 RA: Semaglutide, Liraglutide, Dulaglutide, Exenatide"),
          tags$li("GIP/GLP-1: Tirzepatide"),
          tags$li("SGLT2: Empagliflozin, Dapagliflozin, Canagliflozin, Ertugliflozin")
        )
      )
    ),
    hr(),
    h4("Pipeline overview"),
    tags$ol(
      tags$li("FAERS raw data download (2019–2021)"),
      tags$li("Cleaning & de-duplication"),
      tags$li("Drug name normalization (RxNorm)"),
      tags$li("PT → pseudo SOC mapping"),
      tags$li("ATC & mechanism classification"),
      tags$li("Case-level cohort construction"),
      tags$li("Analysis-ready dataset (cohort_analytic)")
    ),
    hr(),
    h4("Notes"),
    tags$ul(
      tags$li("Key tables: cohort_analytic (case x drug x AE), cohort_drug_final, cohort_reac, cohort_outc."),
      tags$li("Database size ~25GB; first load may take a moment.")
    ),
    hr(),
    h4("Compliance disclaimer"),
    p("FAERS is a spontaneous reporting system and does not establish causality. Reporting frequencies may be influenced by reporting bias, media attention, and market size. Results should be interpreted as exploratory safety signals rather than incidence estimates.")
  )
}

mod_home_server <- function(id, con) {
  moduleServer(id, function(input, output, session) {
    # Static content
  })
}
