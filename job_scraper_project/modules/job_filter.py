from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

def filter_jobs(user_input, jobs):
    """Matches jobs to user input using TF-IDF + Cosine Similarity."""
    # Collect user inputs
    job_title = user_input.get("job_title", "").strip().lower()
    skills = [skill.strip().lower() for skill in user_input.get("skills", "").split(",") if skill.strip()]
    company = user_input.get("company", "").strip().lower()
    location = user_input.get("location", "").strip().lower()
    experience_level = user_input.get("experience_level", "").strip().lower()
    salary_range = user_input.get("salary_range", "").strip()
    date_posted = user_input.get("date_posted", "").strip().lower()

    # Prepare the user's filter query (concatenate all the fields)
    user_query = f"{job_title} {' '.join(skills)} {company} {location} {experience_level} {salary_range} {date_posted}"

    # Prepare the job texts
    job_texts = []
    for job in jobs:
        # Build a job text from the job attributes
        job_text = f"{job['title']} {job.get('description', '')} {job.get('company', '')} {job.get('location', '')} {job.get('experience_level', '')} {job.get('salary_range', '')} {job.get('date_posted', '')}"
        job_texts.append(job_text)

    if not job_texts:  # Check if there are any jobs to compare
        print("❌ No relevant job offers found.")
        return []

    vectorizer = TfidfVectorizer()
    vectors = vectorizer.fit_transform([user_query] + job_texts)

    if vectors.shape[0] < 2:  # Check if there's enough data to compare
        print("❌ Not enough data to compare.")
        return []

    similarity_scores = cosine_similarity(vectors[0], vectors[1:]).flatten()

    # Sort the jobs by similarity score
    sorted_indices = similarity_scores.argsort()[::-1]
    best_jobs = [jobs[i] for i in sorted_indices[:20]]  # Get top 10 best jobs

    return best_jobs
