#³aduje bibliotkê do ³¹czenia siê z baz¹ danych SQLite
library(RSQLite)
library(ggplot2)

con <-
  dbConnect(
    RSQLite::SQLite(),
    "C:/Users/Tomek/Desktop/Robocze/WAT/VIsemestr/AWD/Projekt/dane.db"
  )
#pokazuje tabelê
dbListTables(con, "offers")

#pokazuje zawartoœæ tabeli
dane <- dbGetQuery(con, "select * from offers")


x <- dim(dane)[1]


wyniki <-
  data.frame(
    unlist(dane$price),
    unlist(dane$district),
    unlist(dane$area),
    unlist(dane$pricem2)
    
  )

names(wyniki) <- c("price", "district", "area", "pricem2")



dzielniceWarszawy <- c(
  "Wilanów",
  "Mokotów",
  "Bielany",
  "Œródmieœcie",
  "Wola",
  "Ochota",
  "Wawer",
  "Bemowo",
  "Praga-Po³udnie",
  "Praga-Pó³noc",
  "Bia³o³êka",
  "Ursus",
  "Ursynów",
  "¯oliborz"
)


dzielniceWarszawy <- sort(dzielniceWarszawy)


wynikiDzielnice <- wyniki[(
  wyniki$district == dzielniceWarszawy[1] |
    wyniki$district == dzielniceWarszawy[2] |
    wyniki$district == dzielniceWarszawy[3] |
    wyniki$district == dzielniceWarszawy[4] |
    wyniki$district == dzielniceWarszawy[5] |
    wyniki$district == dzielniceWarszawy[6] |
    wyniki$district == dzielniceWarszawy[7] |
    wyniki$district == dzielniceWarszawy[8] |
    wyniki$district == dzielniceWarszawy[9] |
    wyniki$district == dzielniceWarszawy[10] |
    wyniki$district == dzielniceWarszawy[11] |
    wyniki$district == dzielniceWarszawy[12] |
    wyniki$district == dzielniceWarszawy[13] |
    wyniki$district == dzielniceWarszawy[14]
) &
  wyniki$pricem2 < 50000, ]


#³adowanie pakietu shiny
library(shiny)
library(shinydashboard)
library(DT)
#pakiet shiny
ui <- dashboardPage(skin = "yellow",
  dashboardHeader(title = "Rynek nieruchomoœci w Warszawie"),
  
  #u³o¿enie w shiny
  dashboardSidebar(sidebarMenu(
    menuItem("Podsumowanie", tabName = "one", icon = icon("city")),
    menuItem(
      "Analizy dla dzielnicy",
      tabName = "two",
      icon = icon("chart-bar")
    ),
    menuItem(
      "Szczegó³y aplikacji",
      tabName = "three",
      icon = icon("info")
    )
  )),
  dashboardBody(tabItems(
    tabItem(
      "one",
      h1("Dane dotycz¹ce ca³ego rynku warszawskiego"),
      br(),
      h3("Podstawowe dane:"),
      h4("Œrednia cena mieszkania w Warszawie w z³:"),
      h4(round(mean(wynikiDzielnice$price))),
      h4("Œrednia wielkoœæ mieszkania w Warszawie w m2:"),
      h4(round(mean(wynikiDzielnice$area))),
      h4("Œrednia cena mieszkania w Warszawie w przeliczeniu na m2 w z³:"),
      h4(round(mean(wynikiDzielnice$pricem2))),
      plotOutput(outputId = "wyk3"),
   #   plotOutput(outputId = "wyk2"),
      
      plotOutput(outputId = "wyk4"),
      dataTableOutput("tabela1")
    )
    ,
    tabItem("two",
            fluidPage(
              
              selectInput(
                inputId = "disctrict1",
                label = "Wybierz dzielnicê do analizy",
                choices = dzielniceWarszawy,
                selected = "Bielany"
              ),
              plotOutput(outputId = "wyk1"),
              br(),
              h1("Podstawowe dane dla wybranej dzielnicy:"),
              h3("Œrednia cena mieszkania w wybranej dzielnicy w z³:"),
              h4(textOutput("text1")),
              h3("Œrednia wielkoœæ mieszkania w wybranej dzielnicy w m2:"),
              h4(textOutput("text2")),
              h3("Œrednia cena mieszkania w wybranej dzielnicy w przeliczeniu na m2 w z³:"),
              h4(textOutput("text3")),
              
            )),
    tabItem("three",
            h1("Szczegó³y"),
            p("Aplikacja pokazuje dane zbiorcze dotycz¹ce rynku nieruchomoœci w Warszawie, pozyskane 18-06-2021 "),
            br(),
            p("Dane dotycz¹ce rynku zosta³y pozyskane z serwisu Gratka.pl, z wykorzystaniem programu, który jest napisany w jêzyku Python. 
              Informacje by³y scrapowane crawlerem z biblioteki Beautifulsoup4 BS4 i nastêpnie zapisywane do bazy danych w SQLite."),
            p("W dalszej kolejnoœci obróbka danych odbywa³a siê ju¿ w jêzyku R. Program ³¹czy siê ze wskazan¹ na dysku baz¹, za pomoc¹ pakietu RSQlite3 pobiera dane, a nastêpnie wyœwietla 
              w formie wykresów i tabel. Do prezentacji zosta³ wykorzystany pakiet Shiny, GGplot2 (wykresy), DT (interaktywna tabela) ")
            )
   
  ))
)

server <- function(input, output) {
  output$wyk1 <- renderPlot({
    shinyWykres1 <- wynikiDzielnice[wynikiDzielnice$district == input$disctrict1, ]
    hist(shinyWykres1$price / 1000 , breaks = 20, xlim=range(0:3000),ylim=NULL, xlab ="Cena mieszkania",   main = paste("Ceny mieszkañ w dzielnicy w tysi¹cach z³."))
    
  })
  output$tabela1 <-renderDataTable(wynikiDzielnice)
  output$wyk2 <- renderPlot({
    barplot(
      table(wynikiDzielnice$district),
      col = "blue",
      xlab = "Dzielnice",
      ylab = "Liczba mieszkañ",
      main = "Liczba mieszkañ w podziale na dzielnice"
    )
  })
  output$wyk3 <- renderPlot({
    w2 <- ggplot(data = wynikiDzielnice, aes(x = wynikiDzielnice$district))
    w2 + geom_bar() + xlab("Dzielnice") + ylab("Liczba mieszkañ") + ggtitle("Liczba mieszkañ w podziale na dzielnice")
    
    
  })
  

  
  output$wyk4 <- renderPlot({
    plot(
      x = wyniki$area,
      y = wyniki$pricem2,
      xlab = "Powierzchnia nieruchomoœci w m2",
      ylab = "Cena za m2",
      main = " Zale¿noœæ wielkoœci od ceny m2"
    )
    
  })
  output$text1 <-renderText(
    {
      shinytext1 <- wynikiDzielnice[wynikiDzielnice$district == input$disctrict1, ]
      round(mean(shinytext1$price))
    }
  )
  
  output$text2 <-renderText(
    {
      shinytext2 <- wynikiDzielnice[wynikiDzielnice$district == input$disctrict1, ]
      round(mean(shinytext2$area))
    }
  )
  output$text3 <-renderText(
    {
      shinytext2 <- wynikiDzielnice[wynikiDzielnice$district == input$disctrict1, ]
      round(mean(shinytext2$pricem2))
    }
  )
  
  
}

shinyApp(ui, server)

#roz³¹czam siê z baz¹
dbDisconnect(con)
