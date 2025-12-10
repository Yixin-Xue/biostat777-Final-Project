library(shiny)

# Source helpers and modules
source(file.path("R", "db_utils.R"))
source(file.path("R", "plot_utils.R"))
source(file.path("R", "mod_home.R"))
source(file.path("R", "mod_global_trends.R"))
source(file.path("R", "mod_mech_compare.R"))
source(file.path("R", "mod_drug_profiles.R"))
source(file.path("R", "mod_temporal_signals.R"))
source(file.path("R", "mod_methods.R"))

# Database connection (override via env var FAERS_DB_PATH)
db_path <- Sys.getenv("FAERS_DB_PATH", unset = file.path("..", "data", "faers.sqlite"))
con <- connect_faers(db_path)

navbar_style <- "
.navbar-default {
  background-color: #002D72;
  border-color: #001f52;
}
.navbar-default .navbar-brand,
.navbar-default .navbar-nav > li > a {
  color: #ffffff;
}
.navbar-default .navbar-brand:hover,
.navbar-default .navbar-nav > li > a:hover {
  color: #cbd6e6;
}
.navbar-default .navbar-nav > .active > a,
.navbar-default .navbar-nav > .active > a:focus,
.navbar-default .navbar-nav > .active > a:hover {
  color: #ffffff;
  background-color: #001f52;
}
.navbar-default .navbar-toggle .icon-bar {
  background-color: #ffffff;
}
"

ui <- tagList(
  tags$head(tags$style(HTML(navbar_style))),
  navbarPage(
    title = "T2DM Safety Dashboard",
    tabPanel("Home", mod_home_ui("home")),
    tabPanel("Global Trends", mod_global_trends_ui("global")),
    tabPanel("Mechanism Comparison", mod_mech_compare_ui("mech")),
    tabPanel("Drug Profiles", mod_drug_profiles_ui("drug")),
    tabPanel("Temporal Signals", mod_temporal_signals_ui("ts")),
    tabPanel("Methods & Downloads", mod_methods_ui("methods"))
  )
)

server <- function(input, output, session) {
  mod_home_server("home", con)
  mod_global_trends_server("global", con)
  mod_mech_compare_server("mech", con)
  mod_drug_profiles_server("drug", con)
  mod_temporal_signals_server("ts", con)
  mod_methods_server("methods", con)
}

onStop(function() {
  disconnect_faers(con)
})

shinyApp(ui, server)
