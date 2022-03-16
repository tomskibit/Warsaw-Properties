#Projekt będzie pokazywał ceny mieszkań do zakupu w Warszawie, ilość ogłoszeń w serwisie olx
#projekt zostanie rozbudowany o ewentualne wyliczanie średniej ceny w m2

from bs4 import BeautifulSoup
from requests import get
import time
from datetime import date
import sqlite3
from sys import argv

#zmienna z adresem url do pobierania ofert
# url = 'https://www.olx.pl/nieruchomosci/mieszkania/sprzedaz/warszawa/'

url = 'https://gratka.pl/nieruchomosci/mieszkania/warszawa'


#łączenie z bazą daych
db = sqlite3.connect('dane.db')
cursor = db.cursor()
#po wlaczeniu po raz pierwszy python main.py setup tworzy sie baza danych
if len(argv) >1 and argv[1]=='setup':
    cursor.execute('''CREATE TABLE offers (district TEXT, price REAL, area REAL, pricem2 REAL, date TEXT)''')
    quit()


#pobranie zawartosci
page = get(url)
#wyswietlenie zawartosci
#print(page.content)
bs = BeautifulSoup(page.content, 'html.parser')

pages = int(bs.find('div', class_='pagination').get_text().split('z')[1].strip())
print(pages)

for i in  range(1, pages+1):

    urlSite = url+'?page='+str(i)
    print(urlSite)
    page =get(urlSite)
    bs = BeautifulSoup(page.content,'html.parser')
#Chce pobrać tytuł, Dzielnicę, cenę i m2, cena za m2, ilość pokoi

#funkcja get_text() oczyszcza mi tekst ze znacznikow html

    for offer in bs.find_all('article', class_="teaserUnified"):
        location = offer.find('span', class_= 'teaserUnified__location' ).get_text().strip()
        arrayLocation = location.split(',')
        city = arrayLocation[0]
        district = arrayLocation[1].strip()
        area = float(offer.find('li', class_='teaserUnified__listItem').get_text().split(' m')[0].replace(',','.'))
        #land = arrayLocation[2]
        #wchodzimhy do czesci z cena
        asideInfo = offer.find('div', class_ = "teaserUnified__aside" )
        priceArray = asideInfo.find('p', class_ = 'teaserUnified__price').get_text().split(' zł')
        #oczyszczamy ceny ze spacji i przerw w środku
        price = priceArray[0].strip().replace(" ", "")
        if(price== 'Zapytajocenę'):
            continue
        else:
            price=int(price)
        pricepm2= price/area
        today = date.today()
        print(district+' '+str(price)+ ' '+str(area) + ' '+str(round(pricepm2) ) +' '+ str(today))
        #do bazy sqllite musze przekazywać wartosci jako krotka gdzie ? to odpowiada elementowi krotki
        cursor.execute('INSERT INTO offers VALUES (?,?,?,?,?)',(district,price,area,round(pricepm2),str(today)))
        db.commit()
    print(f'zapisano strone numer {i}')
db.close()
