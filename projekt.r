#�aduje bibliotk� do ��czenia si� z baz� danych SQLite
library(RSQLite)
library(ggplot2)

con <-
  dbConnect(
    RSQLite::SQLite(),
    "C:/Users/Tomek/Desktop/Robocze/WAT/VIsemestr/AWD/Projekt/dane.db"
  )
#pokazuje tabel�
dbListTables(con, "offers")

#pokazuje zawarto�� tabeli
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
  "Wilan�w",
  "Mokot�w",
  "Bielany",
  "�r�dmie�cie",
  "Wola",
  "Ochota",
  "Wawer",
  "Bemowo",
  "Praga-Po�udnie",
  "Praga-P�noc",
  "Bia�o��ka",
  "Ursus",
  "Ursyn�w",
  "�oliborz"
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


#�adowanie pakietu shiny
library(shiny)
library(shinydashboard)
library(DT)
#pakiet shiny
ui <- dashboardPage(skin = "yellow",
  dashboardHeader(title = "Rynek nieruchomo�ci w Warszawie"),
  
  #u�o�enie w shiny
  dashboardSidebar(sidebarMenu(
    menuItem("Podsumowanie", tabName = "one", icon = icon("city")),
    menuItem(
      "Analizy dla dzielnicy",
      tabName = "two",
      icon = icon("chart-bar")
    ),
    menuItem(
      "Szczeg�y aplikacji",
      tabName = "three",
      icon = icon("info")
    )
  )),
  dashboardBody(tabItems(
    tabItem(
      "one",
      h1("Dane dotycz�ce ca�ego rynku warszawskiego"),
      br(),
      h3("Podstawowe dane:"),
      h4("�rednia cena mieszkania w Warszawie w z�:"),
      h4(round(mean(wynikiDzielnice$price))),
      h4("�rednia wielko�� mieszkania w Warszawie w m2:"),
      h4(round(mean(wynikiDzielnice$area))),
      h4("�rednia cena mieszkania w Warszawie w przeliczeniu na m2 w z�:"),
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
                label = "Wybierz dzielnic� do analizy",
                choices = dzielniceWarszawy,
                selected = "Bielany"
              ),
              plotOutput(outputId = "wyk1"),
              br(),
              h1("Podstawowe dane dla wybranej dzielnicy:"),
              h3("�rednia cena mieszkania w wybranej dzielnicy w z�:"),
              h4(textOutput("text1")),
              h3("�rednia wielko�� mieszkania w wybranej dzielnicy w m2:"),
              h4(textOutput("text2")),
              h3("�rednia cena mieszkania w wybranej dzielnicy w przeliczeniu na m2 w z�:"),
              h4(textOutput("text3")),
              
            )),
    tabItem("three",
            h1("Szczeg�y"),
            p("Aplikacja pokazuje dane zbiorcze dotycz�ce rynku nieruchomo�ci w Warszawie, pozyskane 18-06-2021 "),
            br(),
            p("Dane dotycz�ce rynku zosta�y pozyskane z serwisu Gratka.pl, z wykorzystaniem programu, kt�ry jest napisany w j�zyku Python. 
              Informacje by�y scrapowane crawlerem z biblioteki Beautifulsoup4 BS4 i nast�pnie zapisywane do bazy danych w SQLite."),
            p("W dalszej kolejno�ci obr�bka danych odbywa�a si� ju� w j�zyku R. Program ��czy si� ze wskazan� na dysku baz�, za pomoc� pakietu RSQlite3 pobiera dane, a nast�pnie wy�wietla 
              w formie wykres�w i tabel. Do prezentacji zosta� wykorzystany pakiet Shiny, GGplot2 (wykresy), DT (interaktywna tabela) ")
            )
   
  ))
)

server <- function(input, output) {
  output$wyk1 <- renderPlot({
    shinyWykres1 <- wynikiDzielnice[wynikiDzielnice$district == input$disctrict1, ]
    hist(shinyWykres1$price / 1000 , breaks = 20, xlim=range(0:3000),ylim=NULL, xlab ="Cena mieszkania",   main = paste("Ceny mieszka� w dzielnicy w tysi�cach z�."))
    
  })
  output$tabela1 <-renderDataTable(wynikiDzielnice)
  output$wyk2 <- renderPlot({
    barplot(
      table(wynikiDzielnice$district),
      col = "blue",
      xlab = "Dzielnice",
      ylab = "Liczba mieszka�",
      main = "Liczba mieszka� w podziale na dzielnice"
    )
  })
  output$wyk3 <- renderPlot({
    w2 <- ggplot(data = wynikiDzielnice, aes(x = wynikiDzielnice$district))
    w2 + geom_bar() + xlab("Dzielnice") + ylab("Liczba mieszka�") + ggtitle("Liczba mieszka� w podziale na dzielnice")
    
    
  })
  

  
  output$wyk4 <- renderPlot({
    plot(
      x = wyniki$area,
      y = wyniki$pricem2,
      xlab = "Powierzchnia nieruchomo�ci w m2",
      ylab = "Cena za m2",
      main = " Zale�no�� wielko�ci od ceny m2"
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

#roz��czam si� z baz�
dbDisconnect(con)
