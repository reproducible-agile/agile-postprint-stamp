# https://github.com/reproducible-agile/agile-postprint-stamp

library("shiny")
library("qpdf")
library("fs")
library("stringr")

button_text <- "Download and process PDF"

# Define UI for application that draws a histogram
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .shiny-output-error-validation {
        color: red;
      }
    "))
  ),
  
  shiny::img(src = "reproducible-AGILE-logo-square.png",
             title = "Reproducible AGILE Logo",
             style = "float: right; width: 200px; margin: 1em;"),
  titlePanel("AGILE Postprint PDF Processing"),
  
  p(
    "AGILE short papers in the past have only been published as ",
    shiny::a(shiny::em("bronze Open Access"), href = "https://en.wikipedia.org/wiki/Open_access#Bronze_OA"),
    "- they lack a clearly identifyable license.",
    "The AGILE council has decided to add a ",
    shiny::a("statement to the proceedings landing page",
             href = "https://agile-online.org/conference/proceedings"),
    "allowing authors to ",
    shiny::a("self-archive", href = "https://en.wikipedia.org/wiki/Self-archiving"),
    "their AGILE short papers as a ",
    shiny::a("postprint", href = "https://en.wikipedia.org/wiki/Postprint"),
    "which is a great step towards preserving the scientific contributions of AGILE short papers.",
    "This application helps authors to add a statement to their paper PDFs to document the origin of the paper.",
    "Such a statement is required by some repositories/preprint servers, such as ",
    shiny::a("EarthArXiv", href = "https://eartharxiv.org/"),
    "."
  ),
  
  p(
    "If you have any questions, please get in touch with Daniel Nüst of ",
    shiny::a("Reproducible AGILE", href = "https://reproducible-agile.github.io/"),
    ", who initiated to add the permissions statement to the AGILE website and also implemented this app (see ",
    shiny::a("source code on GitHub", href = "https://github.com/reproducible-agile/agile-postprint-stamp"),
    "- contributions welcome!):",
    shiny::code("daniel.nuest@uni-muenster.de")
  ),
  
  p(
    "Please report issues at ", shiny::a("https://github.com/reproducible-agile/agile-postprint-stamp/issues", href = "https://github.com/reproducible-agile/agile-postprint-stamp/issues"),
    "This tool is provided 'as-is'."
  ),
  
  shiny::hr(),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      textInput("paper_url",
                "URL to AGILE short paper"),
      actionButton("dl",
                   button_text),
      shiny::hr(),
      shiny::h4("Steps"),
      shiny::p("1. Enter the PDF to your preprint in the form above."),
      shiny::p("2. Click the ", button_text, "- Button."),
      shiny::p("3. Check the PDF in the main panel on the right, then save it to your computer."),
      shiny::p("4. Upload the PDF to a suitable repository, be sure to include a link to ",
               shiny::a("the main proceedings page", href = "https://agile-online.org/conference/proceedings"),
               "so that moderators or editors of the repository can easily find the permission statement."),
      shiny::p("5. Share the proper preprint citation with your professional network (including the DOI!) and include the DOI in future references to your article.")
    ),
    
    # Show the processed PDF
    mainPanel(
      htmlOutput("pdf_link"),
      uiOutput("pdf_viewer")
    )
  )
)

# https://community.rstudio.com/t/using-www-folder-save-and-display-pdf/6574/10
# https://agile-online.org/conference_paper/cds/agile_2016/shortpapers/109_Paper_in_PDF.pdf
server <- function(input, output) {
  output_file <- NULL
  
  observeEvent(input$dl, {
    req(input$paper_url)
    
    output$pdf_viewer <- renderUI({
      withProgress({
        shiny::setProgress(0.1, "Validating inputs")
        
        validate(
          # for testing: https://agile-online.org/test.pdf
          need(expr = startsWith(input$paper_url, "https://agile-online.org"),
               message = "Can only access the AGILE website using https."),
          need(expr = endsWith(input$paper_url, ".pdf"),
               message = "Can only download PDFs from the AGILE website.")
        )
      
        shiny::setProgress(0.2, "Downloading file")
        input_file <- get_agile_paper(url = input$paper_url)
        shiny::setProgress(0.4, paste0("Retrieved file from ", input$paper_url))
        
        # get overlay PDF
        paper_year <- get_agile_year(input$paper_url)
        overlay_pdf <- file.path("stamp", paste0(paper_year, ".pdf"))
        shiny::setProgress(0.6, paste0("Using overlay file ", overlay_pdf))
        
        output_file <- tempfile(pattern = paste0(
          stringr::str_replace_all(fs::path_ext_remove(fs::path_file(input$paper_url)), 
                                   pattern = "%20",
                                   replacement = "_"),
          "_overlay"),
          tmpdir = "www",
          fileext = ".pdf")
        qpdf_cli_overlay(overlay = overlay_pdf, base = input_file, output = output_file)
        shiny::setProgress(0.8, "Overlay done")
        
        shiny::setProgress(1, paste0("Done! Output PDF has ", qpdf::pdf_length(output_file), "pages"))
      })
      
      if (!is.null(output_file) && file.exists(output_file)) {
        download_url <- substr(output_file, 5, nchar(output_file)) # skip "www/" in the path
        
        output$pdf_link <- renderUI(
          tags$a("Download the PDF", href = download_url)
        )

        tags$object(
          data = download_url,
          type = "application/pdf",
          style= "height:80vh;",
          width = "100%",
          HTML("<h3>It appears that your browser does not support embedded PDFs.</h3>
              <p>To view this content, try another browser such as Chrome or Firefox</p>")
        )
      }
    })
  })
}

get_agile_paper <- function(url) {
  pdf_file <- tempfile(pattern = "short_paper", fileext = ".pdf")
  download.file(url, pdf_file)
  return(pdf_file)
}

# get_agile_year('https://agile-online.org/conference_paper/cds/agile_2010/PosterAbstracts_PDF/87_DOC.pdf')
# get_agile_year('https://agile-online.org/conference_paper/cds/agile_2017/shortpapers/59_ShortPaper_in_PDF.pdf')
get_agile_year <- function(url) {
  as.numeric(stringr::str_match(url, pattern = "/agile_([0-9]+)/")[,2])
}

qpdf_cli_overlay <- function(overlay, base, output) {
  system2("qpdf",
          args = c("--overlay", overlay, "--to=1", "--", base, output))
}
# qpdf_cli_overlay(overlay = overlay_pdf, base = paper_pdf, output = "test2.pdf")

# https://shiny.rstudio.com/reference/shiny/latest/onStop.html
onStop(function() {
  cat("Doing application cleanup\n")
  fs::file_delete(fs::dir_ls("www", regexp = "[.]pdf$"))
})

# Run the application
shinyApp(ui = ui, server = server)
