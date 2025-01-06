import requests
from bs4 import BeautifulSoup
import json
import time
import logging
import os
import unicodedata
from urllib.parse import urljoin

# URL of the FANDOM wiki page
url = "https://terraria.wiki.gg/es/wiki/Armas"
categoriesToScrape = ["Armas cuerpo a cuerpo", "Armas a distancia", "Armas mágicas", "Armas de invocación"]
interval = 1
test = False
testAmount = 20
scriptPath = os.path.dirname(os.path.abspath(__file__))

def sanitize_string(input_string):
    # Normalize the string to decomposed form and then filter out non-ASCII characters
    normalized_string = unicodedata.normalize('NFD', input_string)
    sanitized_string = ''.join([char for char in normalized_string if unicodedata.category(char) != 'Mn'])
    return sanitized_string

def get_value_of_stat(id,label,statText):
    statText = statText.split(" ")[0]
    if is_decial(statText):
        return(int(round(float(statText))))
    try:
        return int(statText)
    except ValueError:
        pass
    try:
        #contains () ex '5 ()7 ()'
        return int(statText.split("(")[0].strip())
    except ValueError:
        pass
    try:
        #contains %
        return int(statText.split("%")[0].strip())
    except ValueError:
        pass
    logging.error(f"Could not get value for {label} for item {id}, found: {statText}")
    return 0

def is_decial(value):
    try:
        float(value)  # Try converting to float
        return True
    except ValueError:
        return False

def get_velocidad(id,text):
    frames = 1
    if is_decial(text):
        return int(round(float(text)))
    text = text.lower()
    if "velocidad de vértigo" in text:
        frames = 10
    elif "Muy Rápida" in text or "Muy Rápido" in text: 
        frames = 12
    elif "gran velocidad" in text or "deprisa" in text:
        frames = 17
    elif "rápido" in text or "veloz" in text or "rápida" in text:
        frames = 22 
    elif "velocidad normal" in text or "normal" in text or "medio" in text:
        frames = 27
    elif "lento" in text:
        frames = 35
    elif "muy lento" in text:
        frames = 42
    elif text == "extremadamente lento":
        frames = 45
    else:
        logging.error(f"Could not get speed for {text} for item {id}")
    return frames

def get_category_name(category):
    if category == "Armas cuerpo a cuerpo":
        return "Melee"
    elif category == "Armas a distancia":
        return "Ranged"
    elif category == "Armas mágicas":
        return "Magic"
    elif category == "Armas de invocación":
        return "Summon"

def get_money_value(id,pi_data_value):
    multipliers = []
    for a_tag in pi_data_value.find_all('a', href=True):
        href = a_tag['href']
        if 'mc' in href or 'Mc' in href:
            multipliers.append(1)
        elif 'mp' in href or 'Mp' in href:
            multipliers.append(1000000)
        elif 'mo' in href or 'Mo' in href:
            multipliers.append(10000)
    for span in pi_data_value.find_all("span"):
        if span.has_attr("title"):
            title = span["title"]
            if "Moneda de plata" in title:
                multipliers.append(100)
            elif "Moneda de oro" in title:
                multipliers.append(10000)
            elif "Moneda de platino" in title:
                multipliers.append(1000000)
            elif "Moneda de cobre" in title:
                multipliers.append(1)
            else:
                logging.error(f"Incomoatible title on {id} {title}")
                multipliers.append(1)
    if len(multipliers) == 0:
        logging.error(f"No multipliers found on {id}")
        return 0
    numbers = pi_data_value.stripped_strings
    #remove empty strings
    numbers = list(filter(lambda x: x != '', numbers))
    numbers = list(filter(lambda x: x != '()', numbers))
    numbers = list(filter(lambda x: x != '(', numbers))
    numbers = list(filter(lambda x: x != ')', numbers))
    total = 0
    if len(numbers) != len(multipliers):
        logging.error(f"Numbers and multipliers don't match) on {id} {numbers} {multipliers}")
        return 0
    for i,number in enumerate(numbers):
        total += get_value_of_stat(id,"money",number)*multipliers[i]
    return total

def get_image(id,json_template,soup):
    fileName = sanitize_string(json_template["name"]).replace(" ","-") + ".png"
    json_template["image"] = "assets/images/" + fileName 
    images = soup.findAll("img", class_="pi-image-thumbnail")
    if len(images) == 0:
        logging.error(f"could not found the image for item {id}")
        return
    if len(images) > 1:
        logging.error(f"found more than one image for item {id}")

    img_url = images[0]['src']
    img_url = urljoin(url, img_url)
    if not img_url.startswith('http'):
        img_url = os.path.join(url, img_url)

    # Send a GET request to download the image
    img_data = requests.get(img_url).content

    # Define the path to save the image
    image_folder = "images"
    if not os.path.exists(os.path.join(scriptPath,image_folder)):
        os.makedirs(os.path.join(scriptPath,image_folder))
    image_path = os.path.join(scriptPath,image_folder, fileName)

    # Save the image to a file
    with open(image_path, 'wb') as f:
        f.write(img_data)
    
def get_name(id,json_template,soup):
    name = soup.find("h1", class_="firstHeading")
    if name:
        nameSpan = name.find("span")
        if nameSpan:
            json_template["name"] = nameSpan.text.strip()
        else:
            logging.error(f"No name found for item {id}")
    else:
        logging.error(f"No name found for item {id}")

def get_description(id,json_template,soup):
    descriptionDiv = soup.find("div", class_="mw-parser-output")
    if not descriptionDiv:
        logging.error(f"No descriptionDiv found for item {id}")
    else:
        description = descriptionDiv.findAll("p")
        if len(description) > 1:
            json_template["description"] = description[1].text.strip()
        else:
            logging.error(f"No description found for item {id}")

def get_stats(id,json_template,soup,category):
    sideBar = soup.find("aside", class_="portable-infobox")
    damageFound, knockbackFound, useTimeFound = False, False, False
    velocidad = None
    if (category == "Summon"):
        knockbackFound, useTimeFound = True, True,
    if not sideBar:
        logging.error(f"No sideBar found for item {id}")
    else:
        sections = sideBar.findAll("section")
        if len(sections) > 1:
            for section in sections:
                stats = section.findAll("div", class_="pi-item")
                for stat in stats:
                    if stat.attrs["data-source"].lower() == "daño":
                        json_template["damage"] = get_value_of_stat(id, "damage", stat.find("div", class_="pi-data-value").text.strip())
                        damageFound = True
                    elif stat.attrs["data-source"].lower() == "automático":
                        b = stat.find("b")
                        if b:
                            json_template["autoAttack"] = False
                        else:
                            json_template["autoAttack"] = True
                    elif stat.attrs["data-source"].lower() == "retroceso":
                        json_template["knockback"] = get_value_of_stat(id, "knockback", stat.find("div", class_="pi-data-value").text.strip())
                        knockbackFound = True
                    elif stat.attrs["data-source"].lower() == "crítico":
                        json_template["critChance"] = get_value_of_stat(id, "critChance", stat.find("div", class_="pi-data-value").text.strip())
                    elif stat.attrs["data-source"].lower() == "uso":
                        json_template["useTime"] = get_value_of_stat(id, "useTime", stat.find("div", class_="pi-data-value").text.strip())
                        useTimeFound = True
                    elif stat.attrs["data-source"].lower() == "velocidad":
                            velocidad = get_velocidad(id, stat.find("div", class_="pi-data-value").text.strip())
                            useTimeFound = True    
                    elif stat.attrs["data-source"].lower() == "dejado por":
                        json_template["obtainedBy"] = "dejado por: " + stat.find("div", class_="pi-data-value").text.strip()
                    elif stat.attrs["data-source"].lower() == "encontrado en":
                        json_template["obtainedBy"] = "encontrado en: " + stat.find("div", class_="pi-data-value").text.strip()
                    elif stat.attrs["data-source"].lower() == "comprado a":
                        json_template["obtainedBy"] = "comprado a: " + stat.find("div", class_="pi-data-value").text.strip()
                    label = stat.findNext("h3", class_="pi-data-label")
                    if (label):
                        if label.text.lower() == "daño":
                            json_template["damage"] = get_value_of_stat(id, "damage", stat.find("div", class_="pi-data-value").text.strip())
                            damageFound = True
                        elif label.text.lower() == "automático":
                            b = stat.find("b")
                            if b:
                                json_template["autoAttack"] = False
                            else:
                                json_template["autoAttack"] = True
                        elif label.text.lower() == "retroceso":
                            json_template["knockback"] = get_value_of_stat(id, "knockback", stat.find("div", class_="pi-data-value").text.strip())
                            knockbackFound = True
                        elif label.text.lower() == "crítico":
                            json_template["critChance"] = get_value_of_stat(id, "critChance", stat.find("div", class_="pi-data-value").text.strip())
                        elif label.text.lower() == "uso":
                            json_template["useTime"] = get_value_of_stat(id, "useTime", stat.find("div", class_="pi-data-value").text.strip())
                            useTimeFound = True
                        elif label.text.lower() == "velocidad":
                            velocidad = get_velocidad(id, stat.find("div", class_="pi-data-value").text.strip())
                            useTimeFound = True
                        elif label.text.lower() == "dejado por":
                            json_template["obtainedBy"] = stat.find("div", class_="pi-data-value").text.strip()
                        elif label.text.lower() == "encontrado en":
                            json_template["obtainedBy"] = stat.find("div", class_="pi-data-value").text.strip()
                        elif label.text.lower() == "comprado a":
                            json_template["obtainedBy"] = "comprado a: " + stat.find("div", class_="pi-data-value").text.strip()
        else:
            logging.error(f"No statsSection found for item {id}")
        if not damageFound:
            logging.error(f"No damage found for item {id}")
        if not knockbackFound:
            logging.error(f"No knockback found for item {id}")
        if not useTimeFound:
            logging.error(f"No useTime found for item {id}")

        if velocidad and json_template["useTime"] == 0:
            json_template["useTime"] = velocidad

def get_materials(element):
    links = element.find_all('a')
    
    formatted_items = []
    
    for link in links:
        previous_text = link.previous_sibling
        if previous_text and isinstance(previous_text, str):  # Ensure previous_text is a string
            quantity = previous_text.strip().split()[0] if previous_text.strip() else '1'
            item_name = link.text
            formatted_items.append(f"{quantity}x {item_name}")
    
    return ' + '.join(formatted_items)


def get_materials_from_table(element):
    final_text = ""
    texts = list(element.find("td", class_="ingredients").stripped_strings)
    print(texts)
    for i in range(0, len(texts), 2):
        if i+1 < len(texts):
            final_text += f"{texts[i+1]}x {texts[i]}"
        else:
            final_text += f"{texts[i]}"
        if i < len(texts) - 2:
            final_text += " + "
    

def get_crafting(id,json_template,soup: BeautifulSoup):
    sideBar = soup.find("aside", class_="portable-infobox")
    materiales = None
    estacion = None
    if not sideBar:
        logging.error(f"No sideBar found for item {id}")
    else:
        sections = sideBar.findAll("section")
        if len(sections) > 1:
            for section in sections:
                stats = section.findAll("div", class_="pi-item")
                for stat in stats:
                    if stat.attrs["data-source"].lower() == "materiales":
                        materiales = get_materials(stat.find("div", class_="pi-data-value"))
                        json_template["createdWith"] = materiales
                        pass
                    elif stat.attrs["data-source"].lower() == "estacion":
                        links = stat.find("div", class_="pi-data-value").find_all("a", title=True)
                        station_names = [link['title'] for link in links]
                        estacion = " o ".join(station_names)
                        json_template["createdWith"] = "creado en " + estacion
                    label = stat.findNext("h3", class_="pi-data-label")
                    if (label):
                        if label.text.lower() == "creado con":
                            materiales = get_materials(stat.find("div", class_="pi-data-value"))
                            json_template["createdWith"] = materiales
                            pass
                        elif label.text.lower() == "creado en":
                            links = stat.find("div", class_="pi-data-value").find_all("a", title=True)
                            station_names = [link['title'] for link in links]
                            estacion = " o ".join(station_names)
                            json_template["obtainedBy"] = "creado en " + estacion                  
        else:
            logging.error(f"No statsSection found for item {id}")
    if (not materiales):
        #logging.error(f"No materials found for item {id}")
        pass
    recipieTable = soup.find("table", class_="recipes")
    if not recipieTable:
        recipieTable = soup.find("table")
        if recipieTable:
            header = recipieTable.find("tr", text="Resultado")
            if not header:
                recipieTable = None
    print(recipieTable,"\n")
    if recipieTable:
        #inspect the table firts row to get the materials
        row = recipieTable.find("tbody").find("tr", attrs={"data-rowid": True})
        print(row,"\n")
        if row:
            #check if result is the item
            result = row.find("td", class_="result").text
            print(result,"\n")
            if (json_template["name"].lower() in result.lower()):
                materiales = get_materials_from_table(row)
                json_template["createdWith"] = materiales
                estacion = row.find("td", class_="station").text

    if (not estacion):
        logging.error(f"No estacion found for item {id}")

# Get the buy and sell price of the item
def get_money(id,json_template,soup):
    sideBar = soup.find("aside", class_="portable-infobox")
    if not sideBar:
        logging.error(f"No sideBar found for item {id}")
    else:
        sections = sideBar.findAll("section")
        if len(sections) > 1:
            for section in sections:
                stats = section.findAll("div", class_="pi-item")
                for stat in stats:
                    if stat.attrs["data-source"].lower() == "compra":
                        json_template["buyPrice"] = get_money_value(id,  stat.find("div", class_="pi-data-value"))
                    elif stat.attrs["data-source"].lower() == "venta":
                        json_template["sellPrice"] = get_money_value(id, stat.find("div", class_="pi-data-value"))
                    label = stat.findNext("h3", class_="pi-data-label")
                    if (label):
                        if label.text.lower() == "compra":
                            json_template["buyPrice"] = get_money_value(id, stat.find("div", class_="pi-data-value"))
                        elif label.text.lower() == "venta":
                            json_template["sellPrice"] = get_money_value(id, stat.find("div", class_="pi-data-value"))
        else:
            logging.error(f"No statsSection found for item {id}")
        if not json_template["buyPrice"] and "comprado a" in json_template["obtainedBy"]:
            logging.error(f"No buyPrice found for item {id}")
        if not json_template["sellPrice"]:
            logging.error(f"No sellPrice found for item {id}")

# Get all item links
def get_item_links():
    logging.info(f"Getting item links from {url}")
    # Fetch the page content
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")

    # Find all sections marked by h3 > span
    sections = soup.find_all("h3")

    # Debug print to see all section titles
    for section in sections:
        spans = section.find_all("span")
        if spans:
            # Get the last span's text
            section_title = spans[-1].text.strip()

    # Initialize a dictionary to store links
    data = {}

    for section in sections:
        span = section.find_all("span")
        if not span or len(span) == 0:  # Skip sections without span tags
            continue
        section_title = span[-1].text.strip()
        
        if section_title not in categoriesToScrape:
            continue
            
        data[section_title] = []  # Create a list for this section
        
        # Locate the table under the section
        table = section.find_next("table")
        if not table:
            continue  # Skip if no table found

        # Find all rows in the table
        rows = table.find_all("tr")

        for row in rows:
            # Find the first column in the row
            first_column = row.find("td")
            if not first_column:
                continue  # Skip rows without <td>

            # Look for <a> tags in the first column
            # Find both <a> tags - first one has image, second has text/link
            links = first_column.find_all("a", href=True)
            if len(links) >= 2:  # Make sure we have both image and text links
                # Use the second link (text link) as it points to the item page
                full_url = requests.compat.urljoin(url, links[1]["href"])
                data[section_title].append(full_url)
                continue
    return data

#generate a json object from the item details
def get_item_details(id,category,url):
    #make the template
    json_template = {
        "id": id,
        "image": "",
        "name": "",
        "description": "",
        "damage": 0,
        "autoAttack": False,
        "knockback": 0,
        "critChance": 0,
        "useTime": 0,
        "buyPrice": 0,
        "sellPrice": 0,
        "createdWith": "",
        "obtainedBy": "",
        "category": get_category_name(category)
    }
    #start scraping the item details
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    
    get_name(id,json_template,soup)
    get_description(id,json_template,soup)
    get_stats(id,json_template,soup,get_category_name(category))
    if (json_template["obtainedBy"] == ""):
        get_crafting(id,json_template,soup)
    get_money(id,json_template,soup)

    get_image(id,json_template,soup)

    return json_template

#generate a json file from all the item urls
def generate_json_object(data):
    length = sum(len(urls) for urls in data.values())
    logging.info(f"item to scrape: {length}")
    items = []
    id = 0
    for category, urls in data.items():
        logging.info(f"Scraping category: {category}")
        for url in urls:
            logging.info(f"{id}/{length} Scraping item: {url}")
            print(f"{id}/{length} Scraping item: {url}")
            item_details = get_item_details(id, category, url)
            items.append(item_details)
            id += 1
            if test and id >= testAmount:
                break
        if test and id >= testAmount:
            break
    logging.info('Saving items to json')
    with open(os.path.join(scriptPath, "items.json"), "w") as file:
        json.dump({"items": items}, file, indent=4)

#Set up logging

logging.basicConfig(filename=os.path.join(scriptPath, "scraper.log"), level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

logging.info('Scraping process Started')
data = get_item_links()
generate_json_object(data)
logging.info('Scraping process Finished')