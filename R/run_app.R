#' run_app
#'
#' run_app function
#'
#' @export

run_app <- function() {

  shiny::shinyApp(ui = app_ui, server = app_server
                  # options = list(launch.browser = TRUE)
                  )

}
