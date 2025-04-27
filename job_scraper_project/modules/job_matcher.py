from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

import re

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

def preprocess_text(text):
    """Nettoyage du texte pour l'analyse"""
    if isinstance(text, list):
        text = ' '.join(text)
    text = text.lower()
    text = re.sub(r'[^\w\s]', '', text)  # Supprimer la ponctuation
    return text

def match_jobsLinkdin(profile_data, jobs, top_n=10):
    """
    Match les jobs avec le profil LinkedIn
    
    Args:
        profile_data (dict): Doit contenir 'compétences' (list) et 'expériences' (list)
        jobs (list): Liste des offres d'emploi
        top_n (int): Nombre de meilleurs matches à retourner
    
    Returns:
        list: Jobs triés par pertinence
    """
    try:
        # Validation des entrées
        if not jobs:
            return []
        
        # Préparation des données CV (utilisation des clés françaises)
        competences = profile_data.get('compétences', [])
        experiences = profile_data.get('expériences', [])
        
        # Création du texte CV
        skills_text = ' '.join(competences)
        experience_text = ' '.join([
            f"{exp.get('titre', '')} {exp.get('description', '')}" 
            for exp in experiences
        ])
        
        cv_text = preprocess_text(f"{skills_text} {experience_text}")
        
        # Préparation des données jobs
        job_texts = []
        valid_jobs = []
        
        for job in jobs:
            if not job.get('title'):
                continue
                
            title = job['title']
            description = job.get('description', '')
            company = job.get('company', '')
            
            job_text = preprocess_text(f"{title} {description} {company}")
            job_texts.append(job_text)
            valid_jobs.append(job)
        
        if not job_texts:
            return []
        
        # Calcul de similarité
        vectorizer = TfidfVectorizer(stop_words=['english', 'french'])
        tfidf_matrix = vectorizer.fit_transform([cv_text] + job_texts)
        
        # Calcul des similarités cosinus
        cosine_similarities = cosine_similarity(tfidf_matrix[0:1], tfidf_matrix[1:]).flatten()
        
        # Tri des jobs par similarité
        scored_jobs = list(zip(valid_jobs, cosine_similarities))
        scored_jobs.sort(key=lambda x: x[1], reverse=True)
        
        # Formatage des résultats
        results = []
        for job, score in scored_jobs[:top_n]:
            results.append({
                'title': job['title'],
                'company': job.get('company', 'Inconnu'),
                'location': job.get('location', 'Non précisé'),
                'similarity_score': round(float(score), 4),
                'url': job.get('url', '#'),
                'description': job.get('description', '')[:200] + '...'  # Résumé
            })
        
        return results
        
    except Exception as e:
        print(f"Erreur dans match_jobs: {str(e)}")
        return []