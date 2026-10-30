library(shiny)
library(bslib)
library(vicvisits)
library(dplyr)

# Choices for the inputs come from the data in the package
services <- sort(unique(library_visits$library_service))
years <- sort(unique(library_visits$financial_year))

# ---- UI ----
ui <- page_sidebar(
  fillable = FALSE,
  title = "Library visits per resident: how does your service compare with Victoria?",
  sidebar = sidebar(
    selectInput(
      "service", "1. Choose your library service",
      choices = c("Type or pick a service" = "", services),
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
    card_header("What this means"),
    uiOutput("summary_text")
  ),
  card(
    card_header("Has the gap with Victoria changed over time?"),
    plotOutput("trend_plot")
  )
)

# ---- Server ----
server <- function(input, output, session) {

  # Comparison table for the chosen service (all three years)
  comparison <- reactive({
    validate(need(
      input$service != "",
      "Choose a library service in the sidebar to see the comparison."
    ))
    compare_visits(input$service)
  })

  # The row for the chosen year only
  selected_year <- reactive({
    comparison() |>
      filter(financial_year == input$year)
  })

  # ---- Summary numbers ----
  # req() keeps the boxes blank until a service is chosen
  output$service_title <- renderText({
    req(input$service)
    paste(input$service, "in", input$year)
  })

  output$service_value <- renderText({
    req(input$service)
    if (selected_year()$reported) {
      sprintf("%.2f", selected_year()$visits_per_person)
    } else {
      "No data"
    }
  })

  output$vic_title <- renderText({
    req(input$service)
    paste("Victoria in", input$year)
  })

  output$vic_value <- renderText({
    req(input$service)
    sprintf("%.2f", selected_year()$vic_visits_per_person)
  })

  output$rank_title <- renderText({
    req(input$service)
    paste("Rank in", input$year)
  })

  output$rank_value <- renderText({
    req(input$service)
    if (selected_year()$reported) {
      paste(selected_year()$rank, "of", selected_year()$n_services)
    } else {
      "Not ranked"
    }
  })

  # ---- Written interpretation ----
  output$summary_text <- renderUI({
    row <- selected_year()

    # Weak state: the service did not report data for this year
    validate(need(
      row$reported,
      paste0(
        input$service, " did not report visit data to Public Libraries",
        " Victoria for ", input$year, ". PLV used an estimate for this year,",
        " which is not shown because it is not reported data. Choose another",
        " financial year to see this service's figures."
      )
    ))

    if (abs(row$difference) < 0.1) {
      compare_words <- "about the same as"
    } else if (row$difference > 0) {
      compare_words <- paste(sprintf("%.2f", row$difference), "visits higher than")
    } else {
      compare_words <- paste(sprintf("%.2f", abs(row$difference)), "visits lower than")
    }

    first_sentence <- paste0(
      "In ", input$year, ", ", input$service, " recorded ",
      sprintf("%.2f", row$visits_per_person), " library visits per resident. ",
      "This is ", compare_words, " the Victorian figure of ",
      sprintf("%.2f", row$vic_visits_per_person), ", and ranks ", row$rank,
      " out of ", row$n_services, " library services."
    )

    # How the gap changed between the first and last years with data
    reported_years <- comparison() |>
      filter(reported)

    if (nrow(reported_years) >= 2) {
      first_gap <- reported_years$difference[1]
      last_gap <- reported_years$difference[nrow(reported_years)]
      change <- last_gap - first_gap

      if (abs(change) < 0.1) {
        change_words <- "stayed about the same compared with Victoria"
      } else if (change > 0) {
        change_words <- "rose compared with Victoria"
      } else {
        change_words <- "fell compared with Victoria"
      }

      second_sentence <- paste0(
        "Between ", reported_years$financial_year[1], " and ",
        reported_years$financial_year[nrow(reported_years)],
        ", ", input$service, " ", change_words, ": the gap went from ",
        sprintf("%+.2f", first_gap), " to ", sprintf("%+.2f", last_gap),
        " visits per resident."
      )
    } else {
      second_sentence <- paste(
        "There is only one year of reported data for this service, so the",
        "change over time cannot be described."
      )
    }

    tagList(p(first_sentence), p(second_sentence))
  })

  # ---- Trend chart ----
  output$trend_plot <- renderPlot({
    req(comparison())
    plot_visits(input$service)
  })
}

shinyApp(ui, server)