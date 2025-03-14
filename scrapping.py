# from selenium import webdriver
# from selenium.webdriver.common.by import By
# import time
# from selenium.webdriver.chrome.service import Service
# from webdriver_manager.chrome import ChromeDriverManager
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC

# # Setup WebDriver
# service = Service(ChromeDriverManager().install())
# driver = webdriver.Chrome(service=service)

# # Open LinkedIn Jobs page
# driver.get("https://www.linkedin.com/jobs/search")

# # Wait for initial load
# try:
#     WebDriverWait(driver, 20).until(
#         EC.presence_of_element_located((By.CSS_SELECTOR, "h3.base-search-card__title"))
#     )
#     print("Page loaded successfully.")
# except Exception as e:
#     print("Error waiting for page to load:", e)
#     driver.quit()
#     exit()

# # Scroll to load all jobs (5 attempts)
# scroll_attempts = 0
# last_count = 0
# while scroll_attempts < 5:
#     driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
#     time.sleep(3)  # Wait for loading
    
#     # Get current number of jobs
#     job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
#     current_count = len(job_listings)
    
#     if current_count == last_count:
#         scroll_attempts += 1
#     else:
#         scroll_attempts = 0
#         last_count = current_count

# # Extract job data
# try:
#     job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
#     print(f"Found {len(job_listings)} job listings.")

#     for index, listing in enumerate(job_listings, 1):
#         try:
#             # Job Title
#             title = listing.find_element(By.CSS_SELECTOR, "h3.base-search-card__title").text.strip()
            
#             # Address
#             address = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__location").text.strip()
            
#             # Link
#             link = listing.find_element(By.CSS_SELECTOR, "a.base-card__full-link").get_attribute("href")
            
#             print(f"Job #{index}:")
#             print(f"Title: {title}")
#             print(f"Location: {address}")
#             print(f"Link: {link}")
#             print("-" * 50)
            
#         except Exception as e:
#             print(f"Error processing job #{index}: {str(e)}")
#             continue

# except Exception as e:
#     print("Error finding job listings:", e)

# driver.quit()

from selenium import webdriver
from selenium.webdriver.common.by import By
import time
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

def fetch_jobs():
    """Scrapes LinkedIn job postings and returns a list of jobs."""
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service)

    driver.get("https://www.linkedin.com/jobs/search")

    try:
        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "h3.base-search-card__title"))
        )
        print("✅ Page loaded successfully.")
    except Exception as e:
        print("❌ Error loading page:", e)
        driver.quit()
        return []

    # Scroll to load more jobs
    scroll_attempts = 0
    last_count = 0
    while scroll_attempts < 5:
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(3)
        job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
        current_count = len(job_listings)
        if current_count == last_count:
            scroll_attempts += 1
        else:
            scroll_attempts = 0
            last_count = current_count

    # Extract job data
    jobs = []
    job_listings = driver.find_elements(By.CSS_SELECTOR, "ul.jobs-search__results-list li")
    
    for index, listing in enumerate(job_listings, 1):
        try:
            title = listing.find_element(By.CSS_SELECTOR, "h3.base-search-card__title").text.strip()
        except Exception as e:
            title = "No title found"
        try:
            location = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__location").text.strip()
        except Exception as e:
            location = "No location found"
        try:
            # title = listing.find_element(By.CSS_SELECTOR, "h3.base-search-card__title").text.strip()
            # address = listing.find_element(By.CSS_SELECTOR, "span.job-search-card__location").text.strip()
            link = listing.find_element(By.CSS_SELECTOR, "a.base-card__full-link").get_attribute("href")
        except Exception as e:
                link = "No link found"
        
        try:
            posted_time = listing.find_element(By.CSS_SELECTOR, "time").get_attribute("datetime")
        except Exception as e:
            posted_time = "Unknown"
            
        jobs.append({"title": title, "location": location, "link": link ,"posted_time": posted_time})
    # except Exception as e:
    #     print(f"❌ Error processing job #{index}: {str(e)}")
    #     continue

    driver.quit()
    return jobs
