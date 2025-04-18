# import spacy

# def extract_info(text):
#     nlp = spacy.load("en_core_web_sm")
#     doc = nlp(text)
#     info = {"Name": "", "Skills": [], "Experience": []}

#     for ent in doc.ents:
#         if ent.label_ == "PERSON":
#             info["Name"] = ent.text
#         elif ent.label_ in ["ORG", "GPE"]:  # Entreprise ou Lieu
#             info["Experience"].append(ent.text)

#     # Extraction basique des compétences (à améliorer avec une liste plus complète)
#     skills_keywords = ["Python", "JavaScript", "SQL", "AI", "Machine Learning", "React", "Django"]
#     info["Skills"] = [word for word in text.split() if word in skills_keywords]

#     return info
import re

def extract_info(text):
    """Extrait les compétences et expériences du CV."""
    info = {"Name": "", "Skills": [], "Experience": []}

    # Liste des technologies pertinentes
    valid_skills = {"Flutter", "Dart", "Vue.js", "Node.js", "Next.js", "SQL", "HTML", "CSS", "JavaScript", "Android"}

    # Extraire les compétences après "TECHNICAL SKILLS" ou "Languages"
    skills_match = re.search(r"TECHNICAL SKILLS\s*([\s\S]+?)\n\n", text, re.IGNORECASE)
    if skills_match:
        skills_text = skills_match.group(1)
        skills = re.findall(r"\b[A-Za-z0-9+#.]+\b", skills_text)  # Récupérer les mots-clés techniques
        info["Skills"] = list(set(skills) & valid_skills)  # Filtrer uniquement les compétences valides

    # Extraire le nom (recherche du premier mot en majuscule suivi d'un autre mot en majuscule)
    name_match = re.search(r"\b([A-Z][a-z]+ [A-Z][a-z]+)\b", text)
    if name_match:
        info["Name"] = name_match.group(1)

    # Extraire l'expérience à partir des mots-clés technologiques
    experience_keywords = valid_skills  # Expérience basée sur les mêmes technologies
    found_experience = [word for word in experience_keywords if word in text]
    info["Experience"] = found_experience

    return info
