from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def match_jobs(cv_info, jobs):
    """Matches jobs to CV skills/experience using TF-IDF + Cosine Similarity."""
    cv_text = " ".join(cv_info["Skills"] + cv_info["Experience"])
    job_texts = [
        job["title"] + " " + job.get("description", "") + " " + " ".join(cv_info["Skills"])
        for job in jobs
        if job.get("description")  # S'assurer que la description n'est pas vide
    ]

    if not job_texts:  # Vérifier s'il y a des jobs exploitables
        print("❌ Aucune offre d'emploi pertinente trouvée.")
        return []

    vectorizer = TfidfVectorizer()
    vectors = vectorizer.fit_transform([cv_text] + job_texts)

    if vectors.shape[0] < 2:  # Vérifier qu'on a bien des données pour comparer
        print("❌ Pas assez de données pour comparer.")
        return []

    similarity_scores = cosine_similarity(vectors[0], vectors[1:]).flatten()
    
    # Trier les jobs par score de similarité
    sorted_indices = similarity_scores.argsort()[::-1]  
    best_jobs = [jobs[i] for i in sorted_indices[:10]]  # Prendre les 10 meilleurs jobs

    return best_jobs

