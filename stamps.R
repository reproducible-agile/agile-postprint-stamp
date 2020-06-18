# https://github.com/reproducible-agile/agile-postprint-stamp
library("rmarkdown")

years <- c(2003:2019)

generate_overlay_pdf <- function(year) {
  rmarkdown::render(input = "stamp/stamp.Rmd",
                    output_file = paste0(year, ".pdf"),
                    params = list("year" = year))
}

for (y in years) {
  generate_overlay_pdf(y)
}

file.remove(file.path("stamp", list.files("stamp", patter = "tex$")))
