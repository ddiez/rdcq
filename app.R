###
library(shiny)
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
          plotOutput("cells")
        ),
        tabPanel(title = "Markers",
          dataTableOutput("markers")
        ),
        tabPanel(title = "Expression",
                 plotOutput("expression")
                 )
      )
    )
  )
})
server <- shinyServer(function(input, output, server) {
  source("DCQ.R")
  library(limma)

    file <- reactive({
    if(! is.null(input$file$name)) {
      x <- read.delim(input$file$datapath, check.names = FALSE)
      x <- avereps(x[,-1], ID = x[,1])
      x <- x[rownames(x) %in% markers[,2],]
      rownames(x) <- markers[rownames(x),1]
      return(x)
    }
  })
  
  dcq <- reactive({
    x <- file()
    if(!is.null(x)) {
      tmp <- DCQ(x, db = db, alpha = input$alpha, lambda.min.ratio = input$lambda.min.ratio, nlambda = input$nlambda)
      return(melt(tmp, varnames = c("sample", "celltype")))
    }
  })
  
  filter <- reactive({
    d <- dcq()
    if(!is.null(d))
      d %>% dplyr::filter(grepl(input$filter, celltype, ignore.case = TRUE))
  })
  output$cells <- renderPlot({
    d <- filter()
    if(!is.null(d))
      ggplot(d,aes(x = sample, y = celltype,fill = value)) + geom_tile() + scale_fill_gradient2(low = "seagreen", mid = "white", high = "purple4", midpoint = 0, limit = c(-.12,.12)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5), axis.text.y = element_text(size = 10))
    else
      print("ready.")
  }, width = 500, height = 500)
  
  output$markers <- renderDataTable(markers)
  
  output$expression <- renderPlot({
    d <- melt(db, varnames = c("marker", "celltype"))
    ggplot(d,aes(x=celltype,y=marker,fill=value)) + geom_tile() + scale_fill_gradientn(colors = .jet.colors(128)) + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5))
  })
})
shinyApp(ui = ui, server = server)
