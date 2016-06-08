require(shiny)

shinyUI(navbarPage(
  title="MOLE MAPPER IMAGE CURATION", 
  inverse=TRUE,
  
  tabPanel(
    title="check the images",
    sidebarLayout(
      sidebarPanel(
        radioButtons('curVal', 'curation', choices=c('not reviewed'=-1, 'ok'=0, 'omit'=1, 'questionable'=2), selected = -1),
        actionButton("goPrev", "Previous"),
        actionButton("goNext", "Next"),
        br(),
        h3(textOutput('thisMessage')),
        br(),
        h4('PROGRESS:'),
        textOutput('progress'),
        br(),
        br(),
        actionButton('saveOutput', "I'm Done! Save me."),
        div(textOutput('endMessage'), style="color:blue"),
        br()
      ),
      
      mainPanel(
        wellPanel(
          h4('healthCode:'),
          textOutput("healthCode"),
          h4('recordId:'),
          textOutput("recordId")
        ),
        imageOutput("displayImage"),
        br()
      )
    )
  )
))

