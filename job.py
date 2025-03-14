# import http.client
# import urllib.parse

# # Analyse extraite du CV
# skills = ["Flutter", "Dart", "Vue.js", "Node.js", "Next.js", "SQL", "HTML/CSS", "JavaScript"]
# location = "France"  # Modifier en fonction de l'emplacement souhaité
# query = " ".join(skills)  # Construire une requête avec les compétences

# # Encoder la requête pour l'URL
# encoded_query = urllib.parse.quote(query)

# conn = http.client.HTTPSConnection("indeed12.p.rapidapi.com")

# headers = {
#     'x-rapidapi-key': "9487206fcemshc7cdcc591eb208dp12595ajsne92a11f0f7ef",
#     'x-rapidapi-host': "indeed12.p.rapidapi.com"
# }

# # Construire dynamiquement l'URL avec la requête
# url = f"/jobs/search?query={encoded_query}&location={urllib.parse.quote(location)}&page_id=1&locality=fr&fromage=1&radius=50&sort=date&job_type=permanent"

# conn.request("GET", url, headers=headers)

# res = conn.getresponse()
# data = res.read()

# print(data.decode("utf-8"))
import http.client
import urllib.parse

def fetch_jobs(skills, location="fr"):
    """Recherche des offres d'emploi basées sur les compétences et la localisation."""
    skills = skills[:5]
    query = "  ".join(skills)  # Construire une requête avec les compétences
    encoded_query = urllib.parse.quote(query)

    conn = http.client.HTTPSConnection("indeed12.p.rapidapi.com")

    headers = {
        'x-rapidapi-key': "9487206fcemshc7cdcc591eb208dp12595ajsne92a11f0f7ef",
        'x-rapidapi-host': "indeed12.p.rapidapi.com"
    }

    url = f"/jobs/search?query={encoded_query}&location={urllib.parse.quote(location)}&page_id=1&locality=fr&fromage=1&radius=50&sort=date&job_type=permanent"
    
    conn.request("GET", url, headers=headers)
    res = conn.getresponse()
    data = res.read()

    return data.decode("utf-8")  # Retourner les résultats
