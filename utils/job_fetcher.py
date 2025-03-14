import requests

API_URL = "https://indeed12.p.rapidapi.com/jobs/search"
HEADERS = {
    "x-rapidapi-key": "9487206fcemshc7cdcc591eb208dp12595ajsne92a11f0f7ef",
    "x-rapidapi-host": "indeed12.p.rapidapi.com"
}

PARAMS = {
    "query": "manager",
    "location": "chicago",
    "page_id": 1,
    "locality": "fr",
    "fromage": 1,
    "radius": 50,
    "sort": "date",
    "job_type": "permanent"
}

def fetch_jobs():
    response = requests.get(API_URL, headers=HEADERS, params=PARAMS)
    
    if response.status_code == 200:
        return response.json()  # Returns the JSON response
    else:
        print(f"Error: {response.status_code}, {response.text}")
        return None

