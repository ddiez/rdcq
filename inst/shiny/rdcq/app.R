library(shiny)
library(readr)
library(dplyr)
library(reshape2)
library(limma)
library(ggplot2)
library(plotly)
library(rdcq)

ui <- shinyUI({
  pageWithSidebar(
    headerPanel(title = "DCQ: Digital Cell Quantifier"),
    sidebarPanel(
      fileInput("file",
                "file:"),
      sliderInput(
        "alpha",
        "alpha:",
        min = 0,
        max = 1,
        value = 0.05,
        step = 0.01
      ),
      sliderInput(
        "lambda.min.ratio",
        "lambda.min.ratio:",
        min = 0,
        max = 1,
        value = 0.2,
        step = 0.01
      ),
      textInput("nlambda", "nlambda", value = 100)
    ),
    mainPanel(tabsetPanel(
      tabPanel(title = "Cell quantification",
               textInput("filter", label = "Filter:", value = ""),
               plotlyOutput("cells", height = "800px")),
      tabPanel(title = "Markers",
               dataTableOutput("markers")),
      tabPanel(title = "Expression",
               plotlyOutput("expression", height = "800px"))
    ))
  )
})
server <- shinyServer(function(input, output, server) {
  values <- reactiveValues(data = NULL, dcq = NULL)

  observeEvent(input$file$datapath, {
    f <- input$file$datapath

    if (tools::file_ext(f) == "rds") {
      x <- read_rds(f)
      x <- exprs(x)
    } else {
      x <- readr::read_delim(
        file = f,
        delim = "\t",
        escape_double = FALSE
      )
      x <- limma::avereps(x[, -1], ID = x[, 1] %>% unlist)
    }

    x <- x[rownames(x) %in% markers[, 2], ]
    rownames(x) <- markers[rownames(x), 1]
    values$data <- x
  })

  observeEvent(values$data, {
    tmp <- dcq(
      values$data,
      db = db,
      alpha = input$alpha,
      lambda.min.ratio = input$lambda.min.ratio,
      nlambda = input$nlambda
    )
    values$dcq <- reshape2::melt(tmp, varnames = c("sample", "celltype"))
  })

  filter <- reactive({
    if (!is.null(values$dcq))
      values$dcq %>% dplyr::filter(grepl(input$filter, celltype, ignore.case = TRUE))
  })

  output$cells <- renderPlotly({
    d <- filter()

    validate(
      need(!is.null(d), "Load some dataset"),
      need(nrow(d) > 0, "Change filter")
    )

    ggplot(d, aes(x = sample, y = celltype, fill = value)) +
        geom_tile() +
        scale_fill_gradient2(
          low = "seagreen",
          mid = "white",
          high = "purple4",
          midpoint = 0
        ) +
        theme(axis.text.x = element_text(
          angle = 90,
          hjust = 1,
          vjust = .5
        ))
  })

  output$markers <- renderDataTable(markers)

  output$expression <- renderPlotly({
    ggplot(db_tidy, aes(x = celltype, y = marker, fill = expression)) +
      geom_tile() +
      scale_fill_gradient(
        low = "white",
        high = "red"
      ) +
      theme(axis.text.x = element_text(
        angle = 90,
        hjust = 1,
        vjust = .5
      ))
  })
})

shinyApp(ui = ui, server = server)
