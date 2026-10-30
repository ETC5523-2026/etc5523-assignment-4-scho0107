library(shiny)
library(bslib)
library(vicvisits)
library(dplyr)

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
  layout_columns(
    fill = FALSE,
    value_box(
      title = textOutput("service_title"),
      value = textOutput("service_value"),
      p("library visits per resident"),
      theme = "primary"
    ),
    value_box(
      title = textOutput("vic_title"),
      value = textOutput("vic_value"),
      p("library visits per resident (statewide)"),
      theme = "light"
    ),
    value_box(
      title = textOutput("rank_title"),
      value = textOutput("rank_value"),
      p("among Victorian library services (1 = highest)"),
      theme = "light"
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


  # Comparison table for the chosen service (all three years)
  comparison <- reactive({
    compare_visits(input$service)
  })

  # The row for the chosen year only
  selected_year <- reactive({
    comparison() |>
      filter(financial_year == input$year)
  })

  output$service_title <- renderText({
    paste(input$service, "in", input$year)
  })

  output$service_value <- renderText({
    if (selected_year()$reported) {
      sprintf("%.2f", selected_year()$visits_per_person)
    } else {
      "No data"
    }
  })

  output$vic_title <- renderText({
    paste("Victoria in", input$year)
  })

  output$vic_value <- renderText({
    sprintf("%.2f", selected_year()$vic_visits_per_person)
  })

  output$rank_title <- renderText({
    paste("Rank in", input$year)
  })

  output$rank_value <- renderText({
    if (selected_year()$reported) {
      paste(selected_year()$rank, "of", selected_year()$n_services)
    } else {
      "Not ranked"
    }
  })
}

shinyApp(ui, server)