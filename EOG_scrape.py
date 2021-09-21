######################################################################################################
# EOG_scrape.py 
# Written by Juan Sebastian Lozano
# Dresciption: 
#   This script finds the download links of the VIIRS monthly composites produced by the Earth
#   Observation Group at UC Boulder
# INPUT:
# OUTPUT: ./links.csv
######################################################################################################

import requests #HTTP requests
import re #regex
from bs4 import BeautifulSoup #html/DOM parser
import os #file system

#set working directory to the current file's directory 
directory = "./"
os.chdir(directory)

#target url to be scraped
target_url = "https://eogdata.mines.edu/nighttime_light/monthly_notile/v10/"

#use requests and beautiful soup to get content 
target_response = requests.get(target_url)

target_content = BeautifulSoup(target_response.text, "html.parser")

#find all the link elements and iterate through them 
links = target_content.find_all("td", {"class":"indexcolname"}, "a")

#we're writing to a csv file
out_file = open("links.csv","w", newline='\n')

match_product = re.compile("avg_rade9h\\.tif\\.gz$")

for link in links: 
    link_url = target_url + link.a.get('href')
          
    link_response = BeautifulSoup(requests.get(link_url).text, "html.parser")
     
    links_monthly = link_response.find_all("td", {"class":"indexcolname"}, "a")
     
    for link_monthly in links_monthly: 
        link_products_in_month = link_url + link_monthly.a.get('href') + "vcmcfg/"
        response_products_in_month = BeautifulSoup(requests.get(link_products_in_month).text, "html.parser")
                 
        product_links = response_products_in_month.find_all("td", {"class":"indexcolname"}, "a")
        
        for product in product_links: 
            if match_product.search(product.text) is not None: 
                out_url = link_products_in_month + product.a.get('href')
                
                out_info = out_url.split('_')
                print(out_info)
                dates = out_info[4].split("-") #seperate date ranges into two dates in an array
                start_date = dates[0]
                end_date = dates[1]
                out_file.write(start_date[0:4] + "," + start_date[4:6] + "," + out_info[6] + "," + out_info[7] + "," + out_url)
                out_file.write("\n")

out_file.close()