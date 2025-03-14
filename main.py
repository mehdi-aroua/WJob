# from extract_text import extract_text_from_pdf
# from summarize import summarize_text
# from extract_info import extract_info
# from job import fetch_jobs

# def main():
#     pdf_path = "K:/WJob/analysethecv/cv/CV.pdf"  
#     text = extract_text_from_pdf(pdf_path)

#     print("🔹 Extraction du texte terminée...\n")
    
#     summary = summarize_text(text)
#     print("🔹 Résumé du CV:\n", summary)

#     print("\n🔹 Texte extrait:\n", text)
#     info = extract_info(text)
#     print("\n🔹 Informations extraites:\n", info)

#     skills = info.get("Skills", [])  
    

# if __name__ == "__main__":
#     main()
from extract_text import extract_text_from_pdf
from summarize import summarize_text
from extract_info import extract_info
from scrapping import fetch_jobs
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from datetime import datetime

def match_jobs(cv_info, jobs):
    """Matches jobs to CV skills/experience using TF-IDF + Cosine Similarity."""
    cv_text = " ".join(cv_info["Skills"] + cv_info["Experience"])
    job_texts = [
        job["title"] + " " + job.get("description", "") + " " + " ".join(cv_info["Skills"])
        for job in jobs
    ]

    # print("\n📝 Exemples de descriptions d'emplois:\n", job_texts[:3])
    # print("\n📝 Contenu du CV utilisé pour le matching:\n", cv_text)
    if not job_texts:
        print("❌ No jobs found!")
        return []

    vectorizer = TfidfVectorizer()
    vectors = vectorizer.fit_transform([cv_text] + job_texts)

    similarity_scores = cosine_similarity(vectors[0:1], vectors[1:]).flatten()
    job_matches = [(jobs[i], similarity_scores[i]) for i in range(len(jobs))]
    job_matches = sorted(job_matches, key=lambda x: x[1], reverse=True)

    # 🔹 Debug: Print top 5 similarity scores
    print(f"\n🔍 Top 5 similarity scores: {[round(score, 2) for _, score in job_matches[:5]]}")

    matched_jobs = [job for job, score in job_matches if score > 0.0001]  # Lowered threshold
    return matched_jobs

# def display_jobs(matched_jobs):
#     """Displays job information including title, posting time, and link."""
#     for job in matched_jobs[:10]:  
#         title = job.get("title", "N/A")
#         location = job.get("location", "N/A")
#         link = job.get("link", "N/A")
#         posted_time = job.get("posted_time", "N/A")  # Assuming the time posted is available

#         # Convert posted time to human-readable format (assuming it is in "X days ago")
#         print(f"dggredrfe✅ {title} - {location}")
#         print(f"🔗 {link}")

#         if posted_time != "N/A":
#             # If posted_time is in the form of 'X days ago' or 'X hours ago', just show it
#             print(f"📅 Posted: {posted_time}")
#         else:
#             # Otherwise, you could add more logic to process different formats
#             print(f"📅 Posted: Unknown time")

#         print()  # New line for separation

def main():
    pdf_path = "K:/WJob/analysethecv/cv/CV.pdf"
    text = extract_text_from_pdf(pdf_path)

    print("\n🔹 Extraction du texte terminée...\n")
    
    summary = summarize_text(text)
    print("🔹 Résumé du CV:\n", summary)

    info = extract_info(text)
    print("\n🔹 Informations extraites:\n", info)

    jobs = fetch_jobs()
    print(f"\n🔹 {len(jobs)} jobs scraped from LinkedIn:")

    if not jobs:
        print("❌ No jobs were scraped! Check `fetch_jobs()` function.")
        return

    matched_jobs = match_jobs(info, jobs)

    if not matched_jobs:
        print("❌ No matching jobs found. Try lowering the similarity threshold.")
        return

    print("\n🔹 Meilleurs emplois pour votre CV:\n")
    for job in matched_jobs[:10]:  # Show top 5 jobs
        # print(job)
        print(f"✅ {job['title']} - {job['location']} ({job['posted_time']})")
        print(f"🔗 {job['link']}\n")

if __name__ == "__main__":
    main()
