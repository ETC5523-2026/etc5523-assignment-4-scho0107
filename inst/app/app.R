library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(vicvisits)

# Choices for the inputs come from the data in the package
services <- sort(unique(library_visits$library_service))
years <- sort(unique(library_visits$financial_year))

# ---- UI ----
ui <- page_sidebar(
  # Let the page scroll instead of squeezing every card onto one screen
  fillable = FALSE,
  title = "Library visits per resident: how does your service compare with Victoria?",
  theme = bs_theme(
    version = 5,
    primary = "#006DAE",
    base_font = "Arial",
    font_scale = 1.05
  ),
  tags$head(tags$link(rel = "stylesheet", href = "styles.css")),

  sidebar = sidebar(
    width = 320,
    selectInput(
      "service", "1. Choose your library service",
      choices = c("Type or pick a service" = "", services),
      selected = "Bayside"
    ),
    selectInput(
      "year", "2. Choose a financial year",
      choices = years,
      selected = "2024-25"
    ),
    div(
      class = "help-text",
      h5("How to use this app"),
      p(
        strong("Library service"), " changes every output: the summary,",
        " the trend chart and the highlighted bar in the ranking chart."
      ),
      p(
        strong("Financial year"), " changes the summary numbers and the",
        " ranking chart. The trend chart always shows all three years."
      ),
      h5("What the fields mean"),
      p(
        strong("Visits per resident"), " = branch visits + mobile library",
        " visits, divided by the council population."
      ),
      p(
        strong("Victoria"), " = all library visits in Victoria divided by",
        " the Victorian population. It is not an average of the 50 services."
      ),
      p(strong("Rank"), " = position among services that reported data (1 = highest).")
    )
  ),

  # Who the app is for and what it answers
  div(
    class = "app-question",
    p(
      strong("For: "), "council library service managers in Victoria."
    ),
    p(
      strong("Question: "), "How do my service's library visits per resident",
      " compare with the Victorian figure, and has the gap changed from",
      " 2022-23 to 2024-25?"
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
    class = "summary-card",
    card_header("What this means"),
    uiOutput("summary_text")
  ),

  card(
    full_screen = TRUE,
    card_header("Has the gap with Victoria changed over time?"),
    plotOutput("trend_plot", height = "380px"),
    p(
      class = "how-to-read",
      "How to read: the blue line is your service and the grey dashed line is",
      " Victoria. If the blue line sits above the grey line, your service had",
      " more visits per resident than the state. If the gap gets wider over",
      " time, your service is moving further from the statewide figure.",
      " A missing point means the service did not report data that year."
    )
  ),

  card(
    full_screen = TRUE,
    card_header(textOutput("rank_header")),
    plotOutput("rank_plot", height = "820px"),
    p(
      class = "how-to-read",
      "How to read: each bar is one library service, sorted from most to",
      " fewest visits per resident. Your service is blue and the dashed line",
      " is the Victorian figure. Services to the right of the line are above",
      " the statewide figure."
    )
  ),

  card(
    card_header("Before you use these numbers"),
    tags$ul(
      tags$li(
        "Visits count entries to a library, not different people. One",
        " person who visits every week counts many times."
      ),
      tags$li(
        "Councils with many workers, students or tourists (such as Melbourne",
        " or Yarra) can have high visits per resident because people who live",
        " elsewhere also use their libraries."
      ),
      tags$li(
        "Indigo (2022-23) and Towong (2022-23 and 2023-24) did not report",
        " data. PLV used estimates for these, which this app does not show."
      ),
      tags$li(
        "Cardinia Shire moved from Casey-Cardinia Libraries to Myli in",
        " December 2022. Comparisons involving 2022-23 for these services",
        " should be treated with caution."
      ),
      tags$li(
        "Data are reported by each library service. Source: Public Libraries",
        " Victoria Annual Statistical Survey, Final Datasets 2022-23 to",
        " 2024-25 (data \u00a9 Public Libraries Victoria)."
      )
    )
  )
)

# ---- Server ----
server <- function(input, output, session) {

  # Comparison table for the chosen service (all three years).
  # compare_visits() is the exported function from the vicvisits package.
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

    # Extra warning for the two services affected by the 2022 change
    split_note <- NULL
    if (input$service %in% c("Connected Libraries", "Myli")) {
      split_note <- p(
        class = "caution",
        "Note: Cardinia Shire moved from Casey-Cardinia Libraries to Myli",
        " on 1 December 2022. This changed the areas served, so comparisons",
        " involving 2022-23 should be treated with caution."
      )
    }

    tagList(p(first_sentence), p(second_sentence), split_note)
  })

  # ---- Trend chart ----
  output$trend_plot <- renderPlot({
    req(comparison())
    # plot_visits() is the exported plotting function from vicvisits
    plot_visits(input$service) +
      labs(title = NULL)
  }, res = 96)

  # ---- Ranking chart ----
  output$rank_header <- renderText({
    req(input$service)
    paste0("Where does ", input$service, " sit among all services in ", input$year, "?")
  })

  output$rank_plot <- renderPlot({
    validate(need(
      input$service != "",
      "Choose a library service in the sidebar to see where it ranks."
    ))

    # All services that reported data in the chosen year
    year_data <- library_visits |>
      filter(financial_year == input$year, reported) |>
      mutate(
        focus = if_else(library_service == input$service, "Your service", "Other services"),
        library_service = reorder(library_service, visits_per_person)
      )

    vic_rate <- vic_visits |>
      filter(financial_year == input$year) |>
      pull(visits_per_person)

    rank_subtitle <- paste0(
      "Dashed line: Victoria (", sprintf("%.2f", vic_rate), " visits per resident)"
    )
    if (!input$service %in% year_data$library_service) {
      rank_subtitle <- paste0(
        rank_subtitle, ". ", input$service, " is not shown because it did not",
        " report data for ", input$year, "."
      )
    }

    ggplot(year_data, aes(visits_per_person, library_service, fill = focus)) +
      geom_col() +
      geom_vline(xintercept = vic_rate, linetype = "dashed", colour = "#333333") +
      scale_fill_manual(
        values = c("Your service" = "#006DAE", "Other services" = "#C8C8C8"),
        guide = "none"
      ) +
      scale_x_continuous(expand = expansion(mult = c(0, 0.05))) +
      labs(
        # Wrap long subtitles so they fit the chart width
        subtitle = paste(strwrap(rank_subtitle, width = 85), collapse = "\n"),
        x = "Library visits per resident",
        y = NULL
      ) +
      theme_minimal(base_size = 14) +
      theme(
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        plot.subtitle = element_text(colour = "#444444")
      )
  }, res = 96)
}

shinyApp(ui, server)