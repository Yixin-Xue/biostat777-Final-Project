# Placeholder for shared plotting utilities
library(ggplot2)

plot_placeholder <- function(title = "Coming soon") {
  ggplot() +
    geom_blank() +
    ggtitle(title) +
    theme_minimal()
}

# Common theme to center titles/subtitles
center_titles <- theme(
  plot.title = element_text(hjust = 0.5, face = "bold"),
  plot.subtitle = element_text(hjust = 0.5)
)
