from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from job_scraper_project.modules.extract_text import extract_text_from_pdf
from job_scraper_project.modules.summarize import summarize_text
from job_scraper_project.modules.extract_info import extract_info
from job_scraper_project.modules.job_scraper import fetch_jobs
from job_scraper_project.modules.job_matcher import match_jobs
from job_scraper_project.modules.job_filter import filter_jobs
from job_scraper_project.modules.company_stats import show_company_stats

def get_user_input():
    """Collect user filters through input."""
    job_title = input("🔹 Nom du poste (laisser vide pour ignorer) : ").strip().lower()
    skills_input = input("🔹 Compétences (séparées par une virgule, laisser vide pour ignorer) : ").strip().lower()
    skills = [skill.strip() for skill in skills_input.split(",") if skill.strip()]
    company = input("🔹 Nom de l'entreprise (laisser vide pour ignorer) : ").strip().lower()
    location = input("🔹 Lieu (exemple : Tunisia, France, laisser vide pour ignorer) : ").strip().lower()
    experience_level = input("🔹 Niveau d'expérience (exemple : Junior, Senior, laisser vide pour ignorer) : ").strip().lower()
    salary_range = input("🔹 Salaire (exemple : 50000-70000, laisser vide pour ignorer) : ").strip()
    date_posted = input("🔹 Date de publication (exemple : 1 jour, 1 semaine, laisser vide pour ignorer) : ").strip().lower()

    return {
        "job_title": job_title,
        "skills": ", ".join(skills),
        "company": company,
        "location": location,
        "experience_level": experience_level,
        "salary_range": salary_range,
        "date_posted": date_posted
    }

service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service)
driver.get("https://www.linkedin.com/jobs/search?keywords=&location=Worldwide&geoId=92000000")

def main():
    # Extraction des informations du CV
    pdf_path = "K:/WJob/analysethecv/cv/CV.pdf"
    text = extract_text_from_pdf(pdf_path)
    summary = summarize_text(text)
    info = extract_info(text)

    print("\n🔹 Extraction et analyse du CV terminées...\n")
    print("🔹 Résumé du CV:\n", summary)
    print("\n🔹 Informations extraites:\n", info)

    # Scraper les offres d'emploi
    jobs = fetch_jobs(driver)
    
    # Filtrer et afficher les 10 meilleures offres selon le CV
    best_jobs = match_jobs(info, jobs)

    print("\n🎯 **Top 10 Jobs Correspondant à votre CV** 🎯\n")
    for i, job in enumerate(best_jobs, 1):
        print(f"[{i}] {job['title']} - {job['location']} (Score: {job.get('score', 0.00):.2f})")
        print(f"🔗 {job['link']}")
        print("-" * 50)    

    choice = input("\n🛠️ Tu veux appliquer plus de filtres ? (oui/non) : ").strip().lower()
    if choice == "oui":
        user_input = get_user_input()
        filtered_jobs = filter_jobs(user_input, jobs)
        print("\n🎯 **Offres d'emploi après filtrage** 🎯\n")
        for i, job in enumerate(filtered_jobs, 1):
            print(f"[{i}] {job['title']} - {job['location']}")
            print(f"🔗 {job['link']}")
            print("-" * 50)
    # Demander à l'utilisateur de choisir un job pour voir les statistiques
    while True:
        try:
            choice = int(input("\n👉 Entrez le numéro du job pour voir les statistiques de l'entreprise (0 pour quitter) : "))
            if choice == 0:
                break
            selected_job = next(job for job in jobs if job["index"] == choice)
            print(f"\n📊 Affichage des statistiques pour : {selected_job['title']}")
            show_company_stats(driver, selected_job["link"])
        except ValueError:
            print("❌ Veuillez entrer un numéro valide.")
        except StopIteration:
            print("❌ Numéro invalide, essayez encore.")
    driver.quit()

if __name__ == "__main__":
    main()
  