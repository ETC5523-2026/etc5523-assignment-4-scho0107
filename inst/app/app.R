library(shiny)
library(bslib)
library(vicvisits)

# Choices for the inputs come from the data in the package
services <- sort(unique(library_visits$library_service))
years <- sort(unique(library_visits$financial_year))

# ---- UI ----
ui <- page_sidebar(
  title = "Library visits per resident: how does your service compare with Victoria?",
  sidebar = sidebar(
    selectInput(
      "service", "1. Choose your library service",
      choices = services,
      selected = "Bayside"
    ),
    selectInput(
      "year", "2. Choose a financial year",
      choices = years,
      selected = "2024-25"
    )
  ),
  card(
    card_header("Has the gap with Victoria changed over time?"),
    plotOutput("trend_plot")
  )
)

# ---- Server ----
server <- function(input, output, session) {
  output$trend_plot <- renderPlot({
    plot_visits(input$service)
  })
}

shinyApp(ui, server)