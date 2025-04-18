from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time


def fetch_jobs(driver):
    """Scrape LinkedIn job postings and return a list of job details."""
    try:
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "h3.base-search-card__title"))
        )
        print("✅ Page loaded successfully.")
    except Exception as e:
        print("❌ Error loading page:", e)
        driver.quit()
        return []

    # Scrolling pour charger plus d'offres
    scroll_attempts, last_count = 0, 0
    while scroll_attempts < 25:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(3)
        job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
        current_count = len(job_listings)
        if current_count == last_count:
            scroll_attempts += 1
        else:
            scroll_attempts, last_count = 0, current_count

    jobs = []
    job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")

    for index, listing in enumerate(job_listings, 1):
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
            job["description"] = listing.find_element(By.CSS_SELECTOR, "p.job-card-list__snippet").text.strip()
        except:
            job["description"] = "No description available"

        # Extract company name if possible
        try:
            job["company"] = listing.find_element(By.CSS_SELECTOR, "h4.base-search-card__subtitle").text.strip()
        except:
            job["company"] = "No company found"

        # Extract salary if available (can vary based on job listing)
        try:
            job["salary"] = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__salary-info").text.strip()
        except:
            job["salary"] = "No salary info found"

        # Extract experience level if available
        try:
            job["experience"] = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__experience").text.strip()
        except:
            job["experience"] = "No experience info found"

        # Extract date posted (if available)
        try:
            job["date_posted"] = listing.find_element(By.CSS_SELECTOR, "time.job-search-card__listdate").text.strip()
        except:
            job["date_posted"] = "No date info found"

        jobs.append({
            "index": index,
            **job
        })

    return jobs