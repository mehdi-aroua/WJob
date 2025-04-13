import requests

# URLs à tester
BASE_URL = "http://127.0.0.1:8000"
ENDPOINTS = [
    "/",  # Page d'accueil
    "/admin/",  # Interface d'administration Django
    "/api/profiles/",  # Exemple d'API pour les profils (à adapter)
]

def test_server():
    print("🔄 Test du serveur Django...\n")
    
    for endpoint in ENDPOINTS:
        url = BASE_URL + endpoint
        try:
            response = requests.get(url)
            if response.status_code == 200:
                print(f"✅ {url} est accessible !")
            elif response.status_code == 404:
                print(f"⚠️ {url} - Page non trouvée (404)")
            else:
                print(f"❌ {url} - Erreur {response.status_code}")
        except requests.ConnectionError:
            print(f"❌ Impossible d'accéder à {url}. Assure-toi que le serveur est lancé.")

if __name__ == "__main__":
    test_server()
