
#' Plot one library service against Victoria over time
#'
#' Draws a line chart of library visits per resident for the chosen library
#' service (blue) and for Victoria as a whole (grey, dashed) from 2022-23 to
#' 2024-25. Years with no reported data are not drawn, so a service with
#' only one reported year appears as a single point.
#'
#' @inheritParams compare_visits
#'
#' @return A ggplot object.
#' @export
#'
#' @examples
#' plot_visits("Yarra")
plot_visits <- function(service) {
  comparison <- compare_visits(service)

  # One row per year for the service, and one per year for Victoria
  plot_data <- dplyr::bind_rows(
    comparison |>
      dplyr::select(financial_year, visits_per_person) |>
      dplyr::mutate(group = service),
    comparison |>
      dplyr::select(financial_year, visits_per_person = vic_visits_per_person) |>
      dplyr::mutate(group = "Victoria")
  )

  # Label each line at its last year, instead of using a legend
  end_labels <- plot_data |>
    dplyr::filter(!is.na(visits_per_person)) |>
    dplyr::group_by(group) |>
    dplyr::slice_max(financial_year, n = 1) |>
    dplyr::ungroup()

  line_colours <- c("#006DAE", "#8A8A8A")
  names(line_colours) <- c(service, "Victoria")

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(financial_year, visits_per_person, colour = group, group = group)
  ) +
    ggplot2::geom_line(ggplot2::aes(linetype = group), linewidth = 1.2, na.rm = TRUE) +
    ggplot2::geom_point(size = 3, na.rm = TRUE) +
    ggplot2::geom_text(
      data = end_labels,
      ggplot2::aes(label = paste0(group, ": ", sprintf("%.2f", visits_per_person))),
      hjust = 0, nudge_x = 0.08, size = 4.5, show.legend = FALSE
    ) +
    ggplot2::scale_colour_manual(values = line_colours, guide = "none") +
    ggplot2::scale_linetype_manual(
      values = c("solid", "dashed"),
      breaks = c(service, "Victoria"),
      guide = "none"
    ) +
    ggplot2::scale_x_discrete(expand = ggplot2::expansion(add = c(0.2, 1.2))) +
    ggplot2::scale_y_continuous(limits = c(0, NA)) +
    ggplot2::labs(
      title = paste("Library visits per resident:", service, "and Victoria"),
      x = "Financial year",
      y = "Library visits per resident",
      caption = "Source: Public Libraries Victoria Annual Statistical Survey"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title.position = "plot",
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      plot.caption = ggplot2::element_text(hjust = 0, colour = "#666666")
    )
}
