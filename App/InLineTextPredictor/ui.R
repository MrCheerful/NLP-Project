#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny); library(shinythemes); library(markdown)

shinyUI(navbarPage("MrCheerful's NLP - Text Prediction Demo", 
    theme = shinytheme("simplex"),

    # Tab 1 - Prediction
    tabPanel("Next Word Prediction",
        fluidRow(
            column(1),
            column(6,
               tags$div(tags$hr(),
                    h3("Top five words:"),
                    actionButton("w1",textOutput("pw1")),
                    actionButton("w2",textOutput("pw2")),
                    actionButton("w3",textOutput("pw3")),
                    actionButton("w4",textOutput("pw4")),
                    actionButton("w5",textOutput("pw5")),

                    textInput("text", 
                              label = h3("Enter your text here:"),
                              value = ),
                    align="center")
            ),
            column(1)
        )
    ),
   
    # Tab 2 - Info 
    tabPanel("Demo Info",
        fluidRow(
            column(2, p("")),
            column(8, includeMarkdown("./about/about.md")),
            column(2, p(""))
        )
    ),
   
    # Footer
    tags$hr(),
    tags$br(),
    tags$span(style="color:grey", 
        tags$footer(("2017 - MrCheerful"), align = "left"), tags$br()
    )
))