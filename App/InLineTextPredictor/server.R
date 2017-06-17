#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
suppressPackageStartupMessages(library(shiny))

source("A-Functions.R")
complex.df <- readRDS(file="./data/complex.rds")
word.dict <- readRDS(file="./data/dictionary.rds")
list.pdf <- readRDS(file="./data/predictlist.rds")


# Define server logic required to make predictions
shinyServer(function(input, output) {

    # Conduct the prediction sequence   
    predict <- reactive({
        output$intext <- renderText({input$text}, quoted = TRUE)
          
        wordv <- unlist(text2word(input$text, complex.df))
        output$aliases <- renderPrint({wordv}, quoted = TRUE)
        
        if (wordv[length(wordv)] == ""){
            wordv <- wordv[1:(length(wordv)-1)]
        }
          
        codev <- word2code(wordv, word.dict)
        output$codes <- renderText({codev}, quoted = FALSE)
          
        p0.df <- calc.predict(codev, list.pdf, word.dict)

        alias2complex(code2word(p0.df$wp, word.dict),complex.df)
    })
    
    # Put the predicted words into the action buttons.
    output$pw1 <- renderText(predict()[1], quoted=FALSE)
    output$pw2 <- renderText(predict()[2], quoted=FALSE)
    output$pw3 <- renderText(predict()[3], quoted=FALSE)
    output$pw4 <- renderText(predict()[4], quoted=FALSE)
    output$pw5 <- renderText(predict()[5], quoted=FALSE)

})
