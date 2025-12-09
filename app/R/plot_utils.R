# Placeholder for shared plotting utilities
library(ggplot2)

plot_placeholder <- function(title = "Coming soon") {
  ggplot() +
    geom_blank() +
    ggtitle(title) +
    theme_minimal()
}
