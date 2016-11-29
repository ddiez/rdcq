###
library(shiny)
library(readr)
library(dplyr)
library(reshape2)
library(glmnet)
library(limma)
source("DCQ.R")

ui <- shinyUI({
  pageWithSidebar(
    headerPanel(title = "DCQ: Digital Cell Quantifier"),
    sidebarPanel(
      fileInput("file",
                "file:"
      ),
      sliderInput("alpha",
                  "alpha:",
                  min = 0,
                  max = 1,
                  value = 0.05,
                  step = 0.01
      ),
      sliderInput("lambda.min.ratio",
                  "lambda.min.ratio:",
                  min = 0,
                  max = 1,
                  value = 0.2,
                  step = 0.01
      ),
      textInput("nlambda",
                "nlambda",
                value = 100
                )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(title = "Cell quantification",
          textInput("filter",
                    label = "Filter:",
                    value = ""
          ),
          plotOutput("cells",
                     dblclick = "cells_dblclick",
                     brush = brushOpts(
                       id = "cells_brush",
                       resetOnNew = TRUE
                     ))
        ),
        tabPanel(title = "Markers",
          dataTableOutput("markers")
        ),
        tabPanel(title = "Expression",
                 plotOutput("expression",
                            dblclick = "expression_dblclick",
                            brush = brushOpts(
                              id = "expression_brush",
                              resetOnNew = TRUE
                            )
                            )
                 )
      )
    )
  )
})
server <- shinyServer(function(input, output, server) {
  dbd <- melt(db, varnames = c("marker", "celltype"))

  file <- reactive({
    if (!is.null(input$file$name)) {
      #x <- read.delim(input$file$datapath, check.names = FALSE)
      x <- read_delim(file = input$file$datapath, delim = "\t", escape_double = FALSE)
      x <- avereps(x[, -1], ID = x[, 1] %>% unlist)
      x <- x[rownames(x) %in% markers[, 2], ]
      rownames(x) <- markers[rownames(x), 1]
      return(x)
    }
  })
  
  dcq <- reactive({
    x <- file()
    if (!is.null(x)) {
      tmp <-
        DCQ(
          x,
          db = db,
          alpha = input$alpha,
          lambda.min.ratio = input$lambda.min.ratio,
          nlambda = input$nlambda
        )
      return(melt(tmp, varnames = c("sample", "celltype")))
    }
  })
  
  filter <- reactive({
    d <- dcq()
    if(!is.null(d))
      d %>% dplyr::filter(grepl(input$filter, celltype, ignore.case = TRUE))
  })
  
  ranges_cells <- reactiveValues(x = NULL, y = NULL)
  output$cells <- renderPlot({
    d <- filter()
    if(!is.null(d))
      ggplot(d,aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5), axis.text.y = element_text(size = 10)) + coord_cartesian(xlim = ranges_cells$x, ylim = ranges_cells$y)
  }, width = 500, height = 500)
  
  observeEvent(input$cells_dblclick, {
    brush <- input$cells_brush
    if (!is.null(brush)) {
      ranges_cells$x <- c(brush$xmin, brush$xmax)
      ranges_cells$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges_cells$x <- NULL
      ranges_cells$y <- NULL
    }
  })
  
  output$markers <- renderDataTable(markers)
  
  ranges_expression <- reactiveValues(x = NULL, y = NULL)
  output$expression <- renderPlot({
    ggplot(dbd,aes(x=celltype,y=marker,fill=value)) + geom_tile() + scale_fill_gradientn(colors = .jet.colors(128)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) + coord_cartesian(xlim = ranges_expression$x, ylim = ranges_expression$y)
  })
  
  observeEvent(input$expression_dblclick, {
    brush <- input$expression_brush
    if (!is.null(brush)) {
      ranges_expression$x <- c(brush$xmin, brush$xmax)
      ranges_expression$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges_expression$x <- NULL
      ranges_expression$y <- NULL
    }
  })
})
shinyApp(ui = ui, server = server)
