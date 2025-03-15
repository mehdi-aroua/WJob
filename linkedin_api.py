from linkedin_v2 import linkedin # type: ignore

API_KEY = 'TON_API_KEY'
API_SECRET = 'TON_API_SECRET'
RETURN_URL = 'L_URL_DE_RETOUR_POUR_L_AUTHENTIFICATION'
ACCESS_TOKEN = 'TON_ACCESS_TOKEN'

def authenticate_linkedin():

    authentication = linkedin.LinkedInAuthentication(
        API_KEY,
        API_SECRET,
        RETURN_URL,
        permissions=linkedin.PERMISSIONS.enums.values()
    )

    print(f"Veuillez visiter cette URL pour obtenir le code d'authentification: {authentication.authorization_url}")

    authentication.authorization_code = 'TON_CODE_AUTHENTIFICATION'
    access_token = authentication.get_access_token()
    return access_token

def get_profile():
    application = linkedin.LinkedInApplication(token=ACCESS_TOKEN)

    profile = application.get_profile(selectors=['id', 'first-name', 'last-name', 'headline', 'location'])

    print(f"Nom: {profile['firstName']} {profile['lastName']}")
    print(f"Titre: {profile['headline']}")
    print(f"Emplacement: {profile['location']['name']}")

    return profile

def get_connections():
    application = linkedin.LinkedInApplication(token=ACCESS_TOKEN)


    connections = application.get_connections()

    return connections
