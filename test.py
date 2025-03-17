from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time
import random

# 🎯 Configuration du WebDriver avec un User-Agent pour éviter le blocage
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# 🔍 URL de recherche LinkedIn (change le mot-clé et la localisation selon tes besoins)
url = "https://www.linkedin.com/jobs/search/?keywords=developer&location=worldwide"
driver.get(url)

def fetch_jobs(driver, max_jobs=10000):
    """Scrape LinkedIn job postings and return a list of job details."""
    jobs = []
    page = 1

    while len(jobs) < max_jobs:
        try:
            WebDriverWait(driver, 20).until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "h3.base-search-card__title"))
            )
        except Exception as e:
            print("❌ Error loading page:", e)
            break

        # 📜 Scrolling pour charger plus d'offres
        last_count = 0
        scroll_attempts = 0
        while scroll_attempts < 10:  # Augmenté pour s'assurer du chargement
            driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(random.uniform(2, 4))  # Pause aléatoire pour éviter le blocage
            job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
            current_count = len(job_listings)
            if current_count == last_count:
                scroll_attempts += 1
            else:
                scroll_attempts = 0
                last_count = current_count

        # 🔥 Extraction des offres
        job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")

        for listing in job_listings:
            if len(jobs) >= max_jobs:
                break

            job = {}

            try:
                job["title"] = listing.find_element(By.CSS_SELECTOR, "h3.base-search-card__title").text.strip()
            except:
                job["title"] = "No title found"

            try:
                job["location"] = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__location").text.strip()
            except:
                job["location"] = "No location found"

            try:
                job["link"] = listing.find_element(By.CSS_SELECTOR, "a.base-card__full-link").get_attribute("href")
            except:
                job["link"] = "No link found"

            try:
                job["company"] = listing.find_element(By.CSS_SELECTOR, "h4.base-search-card__subtitle").text.strip()
            except:
                job["company"] = "No company found"

            try:
                job["salary"] = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__salary-info").text.strip()
            except:
                job["salary"] = "No salary info found"

            try:
                job["date_posted"] = listing.find_element(By.CSS_SELECTOR, "time.job-search-card__listdate").text.strip()
            except:
                job["date_posted"] = "No date info found"

            jobs.append(job)

        print(f"✅ {len(jobs)} jobs scraped so far...")

        # ➡️ Pagination : aller à la page suivante
        try:
            next_button = driver.find_element(By.XPATH, "//button[contains(@aria-label, 'Next')]")
            driver.execute_script("arguments[0].click();", next_button)
            time.sleep(random.uniform(3, 6))  # Pause aléatoire pour imiter un utilisateur
            page += 1
        except:
            print("❌ No more pages available.")
            break

    return jobs

# 🚀 Exécuter le scraping
job_results = fetch_jobs(driver, max_jobs=10000)

# 🛑 Fermer le navigateur
driver.quit()

# 📊 Affichage des résultats
print(f"Total jobs scraped: {len(job_results)}")
