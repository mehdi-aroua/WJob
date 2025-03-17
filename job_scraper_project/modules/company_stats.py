# company_stats.py

from selenium import webdriver
from selenium.webdriver.common.by import By
import time

def show_company_stats(driver, job_link):
    """
    Ouvre la page du job et extrait les statistiques de l'entreprise.
    """
    driver.get(job_link)
    time.sleep(5)  # Attendre le chargement de la page

    try:
        # Récupérer le nom de l'entreprise
        company_name = driver.find_element(By.CSS_SELECTOR, "a.topcard__org-name-link").text.strip()
    except:
        company_name = "Nom inconnu"

    try:
        # Nombre d'employés (si disponible)
        employees = driver.find_element(By.CSS_SELECTOR, "span.jobs-company__inline-information")
        #employees = driver.find_element(By.CSS_SELECTOR, "span.jobs-unified-top-card__job-insight").text.strip()
    except:
        employees = "Non disponible"

    try:
        # Secteur d'activité (si disponible)
        industry = driver.find_element(By.CSS_SELECTOR, "div.show-more-less-html__markup").text.strip()
        if not industry:
            industry = "Non précisé"
    except Exception as e:
        print(f"Error fetching industry: {e}")
        industry = "Non précisé"

    print("\n📊 **Statistiques de l'entreprise**")
    print(f"🏢 Entreprise : {company_name}")
    print(f"👥 Nombre d'employés : {employees}")
    print(f"🏭 Secteur d'activité : {industry}")
    print("-" * 50)