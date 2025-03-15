import requests # type: ignore
from bs4 import BeautifulSoup # type: ignore
from time import sleep

url = "https://www.indeed.com/resumes?q=python+developer&l=Remote"

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

def scrape_indeed():
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        soup = BeautifulSoup(response.content, "html.parser")

        resumes = soup.find_all("div", class_="resume-item")

        for resume in resumes:
            name = resume.find("h2", class_="title").text.strip()
            location = resume.find("span", class_="location").text.strip() if resume.find("span", class_="location") else "Non spécifié"
            print(f"Nom: {name}, Localisation: {location}")

    else:
        print("Erreur de connexion avec Indeed")

scrape_indeed()
