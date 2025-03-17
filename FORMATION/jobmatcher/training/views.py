import requests
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Skill, UserProfile
from django.http import HttpResponse

def home(request):
    return HttpResponse("Bienvenue sur l'application AI WJOB!")


MY_MOOC_API = "https://www.my-mooc.com/api"
UDEMY_API = "https://www.udemy.com/api-2.0/courses/"

@api_view(['GET'])
def recommend_courses(request, user_id):
    try:
        user_profile = UserProfile.objects.get(user_id=user_id)
        user_skills = set(user_profile.skills.values_list('name', flat=True))
        
        required_skills = {"Python", "Django", "Machine Learning"}  # Exemple de compétences attendues
        missing_skills = required_skills - user_skills

        if not missing_skills:
            return Response({"message": "Aucune formation requise, toutes les compétences sont acquises."})

        courses = []

        # Rechercher des formations sur My Mooc (exemple)
        for skill in missing_skills:
            response = requests.get(f"{MY_MOOC_API}/search?query={skill}")
            if response.status_code == 200:
                data = response.json()
                courses.extend(data.get("courses", [])[:3])

        # Rechercher des formations sur Udemy (exemple)
        headers = {"Authorization": "Bearer VOTRE_UDENY_TOKEN"}  # Ajoutez votre clé API Udemy
        for skill in missing_skills:
            response = requests.get(f"{UDEMY_API}?search={skill}", headers=headers)
            if response.status_code == 200:
                data = response.json()
                courses.extend(data.get("results", [])[:3])

        return Response({"missing_skills": list(missing_skills), "courses": courses})

    except UserProfile.DoesNotExist:
        return Response({"error": "Utilisateur non trouvé."}, status=404)
