from django.shortcuts import render
from django.http import JsonResponse
from .models import MockInterview
# coaching/views.py

from django.shortcuts import render
from django.http import HttpResponse

def home(request):
    return HttpResponse("Bienvenue sur la page d'accueil de l'application AI WJOB !")

import random

def generate_interview_questions(job_role):
    questions = {
        'Développeur Python': [
            "Peux-tu me parler de ton expérience avec Django?",
            "Quelles sont les différences entre Python 2 et Python 3?",
            "Comment gères-tu les erreurs dans ton code?"
        ],
        'Data Scientist': [
            "Comment abordes-tu un projet d'analyse de données?",
            "Peux-tu expliquer un modèle de régression linéaire?",
            "Quel est ton processus pour nettoyer un jeu de données?"
        ],
    }

    return questions.get(job_role, ["Parlez-moi de vous.", "Pourquoi voulez-vous ce poste?"])

def mock_interview(request):
    if request.method == 'POST':
        job_role = request.POST.get('job_role')
        user = request.user  # Utilisateur connecté
        questions = generate_interview_questions(job_role)

        # Crée un entretien simulé dans la base de données
        interview = MockInterview.objects.create(user=user, job_role=job_role, questions="\n".join(questions))

        return JsonResponse({'questions': questions})

    return JsonResponse({'error': 'Method not allowed'}, status=405)

def submit_answers(request):
    if request.method == 'POST':
        interview_id = request.POST.get('interview_id')
        answers = request.POST.get('answers')  # Réponses de l'utilisateur
        interview = MockInterview.objects.get(id=interview_id)
        interview.answers = answers
        interview.save()

        # Feedback basé sur les réponses
        feedback = "Bravo! Tu as bien répondu aux questions."
        return JsonResponse({'feedback': feedback})

    return JsonResponse({'error': 'Method not allowed'}, status=405)

def coaching_recommendation(request):
    if request.method == 'POST':
        interview_id = request.POST.get('interview_id')
        interview = MockInterview.objects.get(id=interview_id)

        if interview.answers:
            if "développeur" in interview.job_role.lower():
                coaching_site = 'CoachHub'
            else:
                coaching_site = 'Huru.ai'

            interview.coaching_site = coaching_site
            interview.save()

            return JsonResponse({'coaching_site': coaching_site})

    return JsonResponse({'error': 'Method not allowed'}, status=405)
