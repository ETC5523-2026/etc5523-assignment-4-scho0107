
#' Launch the library visits app
#'
#' Opens a Shiny app for comparing Victorian public library services
#' with the statewide visits per resident benchmark.
#'
#' The app uses the [library_visits] and [vic_visits] datasets included
#' in the package, so no separate data download is needed.
#'
#' @return No return value. Called to start the app.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function() {
  app_dir <- system.file("app", package = "vicvisits")

  if (app_dir == "") {
    stop("Could not find the app. Try re-installing `vicvisits`.", call. = FALSE)
  }

  shiny::runApp(app_dir, display.mode = "normal")
}
