
#' Library visits per resident for Victorian public library services
#'
#' Annual visits per resident for 50 Victorian public library services
#' from 2022-23 to 2024-25, with one row per service and financial year.
#'
#' Visits per resident are calculated as branch and mobile library visits
#' divided by the municipal population, following PLV definitions.
#'
#' Indigo did not report in 2022-23, and Towong did not report in 2022-23
#' or 2023-24. These observations have `reported = FALSE` and
#' `visits_per_person = NA` rather than using PLV estimates.
#'
#' Library service names use the 2024-25 names in all years: Connected
#' Libraries (formerly Connected Libraries (Casey)), Your Library (formerly
#' Your Library (Eastern)) and Hyphen (formerly Wodonga). Vision Australia
#' is excluded because no municipal population is available.
#'
#' Only the calculated rates are stored, not the original visit counts
#' or population figures. See `data-raw/library_visits.R` for the
#' preparation steps.
#'
#' @format A data frame with 150 rows and 4 columns:
#' \describe{
#'   \item{library_service}{Name of the library service.}
#'   \item{financial_year}{Financial year, from 2022-23 to 2024-25.}
#'   \item{visits_per_person}{Library visits divided by municipal population.}
#'   \item{reported}{Whether the library service submitted data for that year.}
#' }
#' @source Public Libraries Victoria, 2024-25 Annual Statistical Survey,
#'   Final Datasets 2022-23 to 2024-25.
#'   <https://www.plv.org.au/resources/earlier-reports-and-surveys/>
#'   Data © Public Libraries Victoria.
#' @seealso [vic_visits]
#' @examples
#' head(library_visits)
"library_visits"


#' Statewide library visits per resident in Victoria
#'
#' Annual library visits per resident for Victoria from 2022-23 to 2024-25.
#' These figures provide the statewide benchmark for comparing library
#' services.
#'
#' The statewide rate uses total Victorian library visits divided by total
#' population, rather than the average of individual service rates.
#' PLV's statewide totals include estimates for services that did not report.
#'
#' @format A data frame with 3 rows and 2 columns:
#' \describe{
#'   \item{financial_year}{Financial year, from 2022-23 to 2024-25.}
#'   \item{visits_per_person}{Total Victorian library visits divided by
#'     the Victorian population.}
#' }
#' @source Public Libraries Victoria, 2024-25 Annual Statistical Survey,
#'   Final Datasets 2022-23 to 2024-25.
#'   <https://www.plv.org.au/resources/earlier-reports-and-surveys/>
#'   Data © Public Libraries Victoria.
#' @examples
#' vic_visits
"vic_visits"
