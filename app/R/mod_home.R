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
        h4("A comparative pharmacovigilance analysis of FAERS (2019–2021) across 15 T2DM drugs in 5 mechanisms", class = "hero-subtitle"),
        p("Type 2 diabetes requires long-term treatment with multiple drug classes, each with distinct mechanisms and adverse event profiles. The FDA’s FAERS database contains millions of real-world safety reports linking patient demographics, drug exposures, and MedDRA-coded clinical events. As newer agents (e.g., GLP-1 receptor agonists, SGLT2 inhibitors) are used alongside older therapies such as metformin, DPP-4 inhibitors, and basal insulin, the safety landscape has become increasingly complex. This dashboard provides a unified view of FAERS data to help clinicians and researchers explore and compare adverse event patterns across commonly used T2DM treatments.", class = "hero-body"),
        h4("Team", class = "hero-subtitle"),
        p("Team name: Jet 2 Holiday"),
        p("Members: Jiayi Chu, Yixin Xue, Shuya Guo, Runjiu Chen"),
        h4("Research questions", class = "hero-subtitle"),
        tags$ul(
          tags$li("Global Trends: How do quarterly report volumes and serious outcomes change over time?"),
          tags$li("Mechanism Comparison: Which PTs/SOCs dominate each mechanism, and where are disproportional signals (PRR/ROR)?"),
          tags$li("Drug Profiles: For each drug, what are the top events, SOC mix, and serious outcome patterns?"),
          tags$li("Temporal Signals: Do time-series models flag emerging signals for top drugs?")
        ),
        tags$details(
          class = "methods-section",
          tags$summary("Glossary of Terms & Abbreviations", style = "color:#002D72; font-weight:700;"),
          tags$table(
            class = "table table-striped table-condensed",
            style = "table-layout: fixed; width: 100%;",
            tags$colgroup(
              tags$col(style = "width:15%;"),
              tags$col(style = "width:25%;"),
              tags$col(style = "width:60%;")
            ),
            tags$thead(
              tags$tr(
                tags$th("Abbreviation"),
                tags$th("Full Term"),
                tags$th("Description")
              )
            ),
            tags$tbody(
              tags$tr(tags$td("FAERS"), tags$td("FDA Adverse Event Reporting System"), tags$td("U.S. post-marketing surveillance database collecting spontaneous adverse drug event reports.")),
              tags$tr(tags$td("T2DM"), tags$td("Type 2 Diabetes Mellitus"), tags$td("A chronic metabolic disease characterized by impaired glucose regulation due to insulin resistance and/or insufficient insulin secretion.")),
              tags$tr(tags$td("AE"), tags$td("Adverse Event"), tags$td("Any unfavorable or unintended medical occurrence reported after drug exposure.")),
              tags$tr(tags$td("PT"), tags$td("Preferred Term"), tags$td("Standardized MedDRA term describing a specific adverse event (e.g., nausea, headache).")),
              tags$tr(tags$td("SOC"), tags$td("System Organ Class"), tags$td("High-level MedDRA category grouping adverse events by affected organ system.")),
              tags$tr(tags$td("MedDRA"), tags$td("Medical Dictionary for Regulatory Activities"), tags$td("International terminology used to code adverse events in FAERS.")),
              tags$tr(tags$td("RxNorm"), tags$td("RxNorm Drug Vocabulary"), tags$td("Standardized drug nomenclature used for drug name normalization.")),
              tags$tr(tags$td("ATC"), tags$td("Anatomical Therapeutic Chemical Classification"), tags$td("WHO system organizing drugs by therapeutic use and mechanism.")),
              tags$tr(tags$td("PRR"), tags$td("Proportional Reporting Ratio"), tags$td("Disproportionality metric comparing AE reporting frequency for a drug vs all others.")),
              tags$tr(tags$td("ROR"), tags$td("Reporting Odds Ratio"), tags$td("Disproportionality measure of odds of reporting a specific AE for a drug relative to others.")),
              tags$tr(tags$td("ARIMA"), tags$td("AutoRegressive Integrated Moving Average"), tags$td("Classical time-series model for analyzing and forecasting counts.")),
              tags$tr(tags$td("XGBoost"), tags$td("Extreme Gradient Boosting"), tags$td("Gradient-boosted decision tree algorithm for predictive modeling.")),
              tags$tr(tags$td("RF"), tags$td("Random Forest"), tags$td("Ensemble of decision trees for robust prediction.")),
              tags$tr(tags$td("ENet"), tags$td("Elastic Net Regression"), tags$td("Regularized regression combining L1 and L2 penalties for correlated predictors."))
            )
          )
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
      column(3, div(class = "metric-card", p(class = "metric-title", "Target drugs"), p(class = "metric-value", "15"))),
      column(3, div(class = "metric-card", p(class = "metric-title", "Mechanism classes"), p(class = "metric-value", "5"))),
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
          tags$li("SGLT2: Empagliflozin, Dapagliflozin, Canagliflozin, Ertugliflozin")
        )
      )
    ),
    hr(),
    fluidRow(
      column(
        6,
        h4("Data Cleaning Pipeline"),
        tags$ul(
          tags$li("FAERS raw data download (2019–2021)"),
          tags$li("Data cleaning and case de-duplication"),
          tags$li("Drug name normalization using RxNorm"),
          tags$li("Adverse event PT → pre-defined SOC mapping"),
          tags$li("ATC code and mechanistic class classification"),
          tags$li("Case-level cohort construction"),
          tags$li("Analysis-ready dataset (cohort_analytic)")
        )
      ),
      column(
        6,
        h4("Dashboard Overview"),
        tags$ul(style = "padding-left:18px;",
          tags$li("Home / Overview: background, data source, workflow summary, team"),
          tags$li("Global Trends: overall AE volume and serious vs non-serious distributions"),
          tags$li("Mechanism Comparison: cross-mechanism AE patterns (PT/SOC) and PRR/ROR signals"),
          tags$li("Individual Drug Profiles: per-drug trends, SOC mix, serious outcomes, top PT"),
          tags$li("Temporal & Emerging Signals: quarterly trends with ARIMA/XGBoost/RF/ENet forecasts"),
          tags$li("Methods & Limitations: pipeline documentation, paradigms, scope/limits")
        )
      )
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
