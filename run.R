# https://github.com/reproducible-agile/agile-postprint-stamp

# based on https://github.com/virtualstaticvoid/heroku-buildpack-r#shiny-applications
library("shiny")

port <- Sys.getenv("PORT")

shiny::runApp(
  appDir = getwd(),
  host = "0.0.0.0",
  port = as.numeric(port)
)
