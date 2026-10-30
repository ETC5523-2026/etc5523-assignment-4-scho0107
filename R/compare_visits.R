
#' Compare one library service with Victoria
#'
#' Compares a library service's visits per resident with the Victorian
#' statewide rate for each financial year from 2022-23 to 2024-25.
#' It also calculates the difference and the service's rank each year.
#'
#' The statewide rate is total Victorian visits divided by total population,
#' not the average of individual service rates.
#'
#' Only services that reported data are ranked. Missing years have
#' `NA` for visits per resident, difference and rank.
#'
#' @param service Name of a library service in `library_visits`,
#'   for example `"Yarra"`.
#'
#' @return A data frame with one row per financial year and the columns
#'   `library_service`, `financial_year`, `visits_per_person`,
#'   `vic_visits_per_person` (statewide rate), `difference` (service minus
#'   Victoria), `rank` (1 = highest visits per resident), `n_services`
#'   (number of ranked services) and `reported`.
#' @export
#'
#' @examples
#' compare_visits("Yarra")
#'
#' # Towong did not report in 2022-23 or 2023-24
#' compare_visits("Towong")
compare_visits <- function(service) {

  # Check the service name
  if (length(service) != 1 || !service %in% library_visits$library_service) {
    stop(
      "`service` must be one library service name from ",
      "`library_visits$library_service`, for example \"Yarra\".",
      call. = FALSE
    )
  }

  # Rank reported services by year
  service_ranks <- library_visits |>
    dplyr::filter(reported) |>
    dplyr::group_by(financial_year) |>
    dplyr::mutate(
      rank = dplyr::min_rank(dplyr::desc(visits_per_person)),
      n_services = dplyr::n()
    ) |>
    dplyr::ungroup() |>
    dplyr::select(library_service, financial_year, rank, n_services)

  vic_rates <- vic_visits |>
    dplyr::select(financial_year, vic_visits_per_person = visits_per_person)

  library_visits |>
    dplyr::filter(library_service == service) |>
    dplyr::left_join(vic_rates, by = "financial_year") |>
    dplyr::left_join(service_ranks, by = c("library_service", "financial_year")) |>
    dplyr::mutate(difference = visits_per_person - vic_visits_per_person) |>
    dplyr::select(
      library_service, financial_year, visits_per_person,
      vic_visits_per_person, difference, rank, n_services, reported
    )
}
