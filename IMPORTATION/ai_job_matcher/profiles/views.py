import requests
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.conf import settings
from django.http import JsonResponse

def home(request):
    return JsonResponse({"message": "Bienvenue sur AI WJOB API 🚀"})


# API d'Indeed
INDEED_API_URL = "https://api.indeed.com/ads/apisearch"
INDEED_PUBLISHER_ID = settings.INDEED_PUBLISHER_ID
INDEED_API_KEY = settings.INDEED_API_KEY

# API de LinkedIn
LINKEDIN_API_URL = "https://api.linkedin.com/v2/me"
LINKEDIN_ACCESS_TOKEN = settings.LINKEDIN_ACCESS_TOKEN

# Vue pour récupérer les profils Indeed
@api_view(['GET'])
def get_indeed_profiles(request):
    job_query = request.GET.get('query', 'developer')
    location = request.GET.get('location', 'France')
    
    params = {
        'publisher': INDEED_PUBLISHER_ID,
        'q': job_query,
        'l': location,
        'format': 'json',
        'v': '2',
        'userip': '1.2.3.4',
        'useragent': 'Mozilla/5.0',
    }
    
    response = requests.get(INDEED_API_URL, params=params)
    
    if response.status_code == 200:
        jobs = response.json().get('results', [])
        return Response({'jobs': jobs})
    else:
        return Response({'error': 'Unable to fetch Indeed profiles'}, status=response.status_code)

# Vue pour récupérer le profil LinkedIn
@api_view(['GET'])
def get_linkedin_profile(request):
    headers = {
        'Authorization': f'Bearer {LINKEDIN_ACCESS_TOKEN}',
    }
    
    response = requests.get(LINKEDIN_API_URL, headers=headers)
    
    if response.status_code == 200:
        linkedin_profile = response.json()
        return Response({'linkedin_profile': linkedin_profile})
    else:
        return Response({'error': 'Unable to fetch LinkedIn profile'}, status=response.status_code)
