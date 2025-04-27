# """
# Script principal pour tester les fonctionnalités du système d'intégration LinkedIn/Indeed
# avec recommandations de formation et coaching IA pour entretiens.

# Ce script permet de tester rapidement les différentes fonctionnalités sans passer par l'API.
# """

# import os
# import sys
# import django
# import json
# import random
# from datetime import datetime, timedelta
# import argparse
# from django.utils import timezone

# # Configurer Django
# os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'linkedin_indeed_integration.settings')
# django.setup()

# # Importer les modèles après la configuration de Django
# from profiles.models import Profile, Experience, Education, Skill, ProfileSkill
# from training_recommendations.models import (
#     TrainingPlatform, Course, Certification, CourseSkill, 
#     CertificationSkill, Recommendation
# )
# from interview_coaching.models import (
#     CoachingPlatform, InterviewType, InterviewQuestion,
#     InterviewSession, InterviewResponse, FeedbackCategory,
#     SessionFeedbackItem
# )


# def create_test_data():
#     """Créer des données de test pour démontrer les fonctionnalités"""
#     print("Création des données de test...")
    
#     # Créer des compétences
#     skills = [
#         "Python", "Django", "JavaScript", "React", "SQL", "Machine Learning",
#         "Data Science", "DevOps", "Cloud Computing", "Docker", "Kubernetes",
#         "HTML/CSS", "Node.js", "Java", "C#", "PHP", "Ruby", "Scala", "Go",
#         "TensorFlow", "PyTorch", "NLP", "Computer Vision", "Data Analysis"
#     ]
    
#     skill_objects = {}
#     for skill_name in skills:
#         skill, created = Skill.objects.get_or_create(name=skill_name)
#         skill_objects[skill_name] = skill
#         if created:
#             print(f"Compétence créée: {skill_name}")
    
#     # Créer des plateformes de formation
#     platforms = [
#         {
#             "name": "MyMooc",
#             "website": "https://www.mymooc.fr",
#             "description": "Plateforme gratuite de MOOCs",
#             "is_free": True
#         },
#         {
#             "name": "Udemy",
#             "website": "https://www.udemy.com",
#             "description": "Plateforme payante de cours en ligne",
#             "is_free": False
#         },
#         {
#             "name": "Coursera",
#             "website": "https://www.coursera.org",
#             "description": "Plateforme de cours en ligne des universités",
#             "is_free": False
#         }
#     ]
    
#     platform_objects = {}
#     for platform_data in platforms:
#         platform, created = TrainingPlatform.objects.get_or_create(
#             name=platform_data["name"],
#             defaults=platform_data
#         )
#         platform_objects[platform_data["name"]] = platform
#         if created:
#             print(f"Plateforme de formation créée: {platform_data['name']}")
    
#     # Créer des plateformes de coaching
#     coaching_platforms = [
#         {
#             "name": "Huru.ai",
#             "website": "https://www.huru.ai",
#             "description": "Coaching IA gratuit pour entretiens",
#             "is_free": True
#         },
#         {
#             "name": "CoachHub",
#             "website": "https://www.coachhub.io",
#             "description": "Plateforme payante de coaching professionnel",
#             "is_free": False
#         }
#     ]
    
#     coaching_platform_objects = {}
#     for platform_data in coaching_platforms:
#         platform, created = CoachingPlatform.objects.get_or_create(
#             name=platform_data["name"],
#             defaults=platform_data
#         )
#         coaching_platform_objects[platform_data["name"]] = platform
#         if created:
#             print(f"Plateforme de coaching créée: {platform_data['name']}")
    
#     # Créer des types d'entretien
#     interview_types = [
#         {
#             "name": "Technique",
#             "description": "Entretien technique pour évaluer les compétences techniques"
#         },
#         {
#             "name": "Comportemental",
#             "description": "Entretien pour évaluer le comportement et les soft skills"
#         },
#         {
#             "name": "RH",
#             "description": "Entretien avec les ressources humaines"
#         }
#     ]
    
#     interview_type_objects = {}
#     for type_data in interview_types:
#         interview_type, created = InterviewType.objects.get_or_create(
#             name=type_data["name"],
#             defaults=type_data
#         )
#         interview_type_objects[type_data["name"]] = interview_type
#         if created:
#             print(f"Type d'entretien créé: {type_data['name']}")
    
#     # Créer des questions d'entretien
#     questions = [
#         {
#             "question_text": "Décrivez votre expérience avec Python et Django.",
#             "interview_type": interview_type_objects["Technique"],
#             "difficulty": "medium",
#             "ideal_answer": "J'ai 5 ans d'expérience avec Python et 3 ans avec Django. J'ai développé plusieurs applications web avec Django REST Framework, mis en place des tests automatisés, et optimisé les performances des applications."
#         },
#         {
#             "question_text": "Racontez une situation difficile au travail et comment vous l'avez gérée.",
#             "interview_type": interview_type_objects["Comportemental"],
#             "difficulty": "medium",
#             "ideal_answer": "J'ai rencontré un conflit avec un collègue sur la direction technique d'un projet. J'ai organisé une réunion pour discuter ouvertement, écouté son point de vue, et nous avons trouvé un compromis qui a amélioré le projet."
#         },
#         {
#             "question_text": "Pourquoi voulez-vous rejoindre notre entreprise ?",
#             "interview_type": interview_type_objects["RH"],
#             "difficulty": "easy",
#             "ideal_answer": "J'admire votre culture d'innovation et vos valeurs. Vos produits ont un impact réel sur les utilisateurs, et j'aimerais contribuer à cette mission tout en développant mes compétences dans un environnement stimulant."
#         }
#     ]
    
#     for question_data in questions:
#         question, created = InterviewQuestion.objects.get_or_create(
#             question_text=question_data["question_text"],
#             defaults=question_data
#         )
#         if created:
#             print(f"Question d'entretien créée: {question_data['question_text'][:40]}...")
    
#     # Créer des cours
#     courses = [
#         {
#             "title": "Django pour débutants",
#             "description": "Apprenez les bases de Django pour créer des applications web",
#             "platform": platform_objects["MyMooc"],
#             "url": "https://www.mymooc.fr/cours/django-debutants",
#             "level": "beginner",
#             "price": None,  # gratuit
#             "duration_hours": 10,
#             "skills": ["Python", "Django", "HTML/CSS"]
#         },
#         {
#             "title": "Machine Learning avec Python",
#             "description": "Maîtrisez les algorithmes d'apprentissage automatique avec Python",
#             "platform": platform_objects["Udemy"],
#             "url": "https://www.udemy.com/course/machine-learning-python",
#             "level": "intermediate",
#             "price": 49.99,
#             "duration_hours": 25,
#             "skills": ["Python", "Machine Learning", "Data Science"]
#         }
#     ]
    
#     for course_data in courses:
#         skills_data = course_data.pop("skills")
#         course, created = Course.objects.get_or_create(
#             title=course_data["title"],
#             defaults=course_data
#         )
#         if created:
#             print(f"Cours créé: {course_data['title']}")
            
#         # Ajouter les compétences au cours
#         for skill_name in skills_data:
#             CourseSkill.objects.get_or_create(
#                 course=course,
#                 skill=skill_objects[skill_name],
#                 defaults={"relevance_score": random.uniform(0.7, 1.0)}
#             )
    
#     print("Données de test créées avec succès!")


# def import_dummy_linkedin_profile(profile_num=1):
#     """Importer un profil LinkedIn fictif pour démonstration"""
#     print("Importation d'un profil LinkedIn fictif...")
    
#     # Profils fictifs LinkedIn
#     profiles_data = [
#         {
#             'firstName': 'Jean',
#             'lastName': 'Dupont',
#             'headline': 'Développeur Full Stack',
#             'summary': 'Développeur full stack avec 5 ans d\'expérience en Python, Django, React et Node.js.',
#             'location': 'Paris, France',
#             'source': 'linkedin',
#             'source_profile_id': 'jean-dupont-123',
#             'linkedin_url': 'https://www.linkedin.com/in/jean-dupont-123/',
#             'positions': [
#                 {
#                     'title': 'Développeur Full Stack',
#                     'company': 'TechCorp',
#                     'startDate': '2020-01-01',
#                     'endDate': None,
#                     'isCurrent': True,
#                     'description': 'Développement d\'applications web avec Django et React'
#                 },
#                 {
#                     'title': 'Développeur Front-end',
#                     'company': 'WebAgency',
#                     'startDate': '2018-03-01',
#                     'endDate': '2019-12-31',
#                     'isCurrent': False,
#                     'description': 'Développement d\'interfaces utilisateur avec React et Angular'
#                 }
#             ],
#             'education': [
#                 {
#                     'schoolName': 'Université de Paris',
#                     'degree': 'Master',
#                     'fieldOfStudy': 'Informatique',
#                     'startDate': '2016-09-01',
#                     'endDate': '2018-06-30',
#                     'description': 'Spécialisation en développement web'
#                 }
#             ],
#             'skills': [
#                 {'name': 'Python', 'endorsements': 15},
#                 {'name': 'Django', 'endorsements': 12},
#                 {'name': 'React', 'endorsements': 18},
#                 {'name': 'JavaScript', 'endorsements': 20},
#                 {'name': 'HTML/CSS', 'endorsements': 10}
#             ]
#         },
#         {
#             'firstName': 'Marie',
#             'lastName': 'Martin',
#             'headline': 'Data Scientist',
#             'summary': 'Data scientist avec 3 ans d\'expérience en analyse de données, machine learning et deep learning.',
#             'location': 'Lyon, France',
#             'source': 'linkedin',
#             'source_profile_id': 'marie-martin-456',
#             'linkedin_url': 'https://www.linkedin.com/in/marie-martin-456/',
#             'positions': [
#                 {
#                     'title': 'Data Scientist',
#                     'company': 'DataInsight',
#                     'startDate': '2022-01-01',
#                     'endDate': None,
#                     'isCurrent': True,
#                     'description': 'Développement de modèles de machine learning pour la prédiction de comportements clients'
#                 },
#                 {
#                     'title': 'Data Analyst',
#                     'company': 'AnalyticsLab',
#                     'startDate': '2020-06-01',
#                     'endDate': '2021-12-31',
#                     'isCurrent': False,
#                     'description': 'Analyse de données marketing et création de tableaux de bord'
#                 }
#             ],
#             'education': [
#                 {
#                     'schoolName': 'École Centrale Lyon',
#                     'degree': 'Master',
#                     'fieldOfStudy': 'Data Science',
#                     'startDate': '2018-09-01',
#                     'endDate': '2020-06-30',
#                     'description': 'Spécialisation en machine learning'
#                 }
#             ],
#             'skills': [
#                 {'name': 'Python', 'endorsements': 22},
#                 {'name': 'Machine Learning', 'endorsements': 18},
#                 {'name': 'SQL', 'endorsements': 15},
#                 {'name': 'TensorFlow', 'endorsements': 12},
#                 {'name': 'Data Analysis', 'endorsements': 20}
#             ]
#         }
#     ]
    
#     # Sélectionner le profil à importer
#     profile_index = min(profile_num - 1, len(profiles_data) - 1)
#     linkedin_data = profiles_data[profile_index]
    
#     # Créer le profil
#     profile, created = Profile.objects.get_or_create(
#         source='linkedin',
#         source_profile_id=linkedin_data['source_profile_id'],
#         defaults={
#             'first_name': linkedin_data['firstName'],
#             'last_name': linkedin_data['lastName'],
#             'headline': linkedin_data['headline'],
#             'summary': linkedin_data['summary'],
#             'location': linkedin_data['location'],
#             'linkedin_url': linkedin_data['linkedin_url']
#         }
#     )
    
#     if not created:
#         print(f"Le profil {linkedin_data['firstName']} {linkedin_data['lastName']} existe déjà.")
#         return profile
    
#     print(f"Profil créé: {linkedin_data['firstName']} {linkedin_data['lastName']}")
    
#     # Ajouter les expériences
#     for position in linkedin_data['positions']:
#         Experience.objects.create(
#             profile=profile,
#             company=position['company'],
#             title=position['title'],
#             start_date=position['startDate'],
#             end_date=position['endDate'],
#             current=position['isCurrent'],
#             description=position['description']
#         )
#         print(f"Expérience ajoutée: {position['title']} chez {position['company']}")
    
#     # Ajouter les formations
#     for edu in linkedin_data['education']:
#         Education.objects.create(
#             profile=profile,
#             institution=edu['schoolName'],
#             degree=edu['degree'],
#             field_of_study=edu['fieldOfStudy'],
#             start_date=edu['startDate'],
#             end_date=edu['endDate'],
#             description=edu['description']
#         )
#         print(f"Formation ajoutée: {edu['degree']} en {edu['fieldOfStudy']} à {edu['schoolName']}")
    
#     # Ajouter les compétences
#     for skill_data in linkedin_data['skills']:
#         skill_name = skill_data['name']
#         skill, _ = Skill.objects.get_or_create(name=skill_name)
        
#         ProfileSkill.objects.create(
#             profile=profile,
#             skill=skill,
#             endorsements=skill_data['endorsements']
#         )
#         print(f"Compétence ajoutée: {skill_name} avec {skill_data['endorsements']} recommandations")
    
#     print(f"Profil LinkedIn importé avec succès: {profile}")
#     return profile


# def import_profile_from_json(json_file_path=None):
#     """Importer un profil depuis un fichier JSON"""
#     if not json_file_path:
#         print("Aucun fichier JSON spécifié. Utilisez --json-file pour spécifier un fichier.")
#         return None
    
#     print(f"Importation du profil depuis {json_file_path}...")
    
#     try:
#         with open(json_file_path, 'r', encoding='utf-8') as f:
#             profile_data = json.load(f)
#     except FileNotFoundError:
#         print(f"Erreur: Le fichier {json_file_path} n'existe pas.")
#         return None
#     except json.JSONDecodeError:
#         print(f"Erreur: Le fichier {json_file_path} n'est pas un JSON valide.")
#         return None
    
#     # Vérifier la structure du JSON
#     required_fields = ['firstName', 'lastName', 'headline', 'summary', 'skills']
#     for field in required_fields:
#         if field not in profile_data:
#             print(f"Erreur: Le champ '{field}' est requis mais manquant dans le JSON.")
#             return None
    
#     # Générer un ID unique si non fourni
#     if 'source_profile_id' not in profile_data:
#         import uuid
#         profile_data['source_profile_id'] = str(uuid.uuid4())
    
#     # Créer ou mettre à jour le profil
#     profile, created = Profile.objects.get_or_create(
#         source='custom',
#         source_profile_id=profile_data['source_profile_id'],
#         defaults={
#             'first_name': profile_data['firstName'],
#             'last_name': profile_data['lastName'],
#             'headline': profile_data['headline'],
#             'summary': profile_data['summary'],
#             'location': profile_data.get('location', ''),
#             'linkedin_url': profile_data.get('linkedin_url', '')
#         }
#     )
    
#     if not created:
#         print(f"Le profil {profile_data['firstName']} {profile_data['lastName']} existe déjà.")
#         # Mettre à jour les champs existants
#         profile.headline = profile_data['headline']
#         profile.summary = profile_data['summary']
#         if 'location' in profile_data:
#             profile.location = profile_data['location']
#         if 'linkedin_url' in profile_data:
#             profile.linkedin_url = profile_data['linkedin_url']
#         profile.save()
#     else:
#         print(f"Profil créé: {profile_data['firstName']} {profile_data['lastName']}")
    
#     # Ajouter/mettre à jour les expériences
#     if 'positions' in profile_data:
#         # Supprimer les anciennes expériences pour éviter les doublons
#         if not created:
#             Experience.objects.filter(profile=profile).delete()
            
#         for position in profile_data['positions']:
#             Experience.objects.create(
#                 profile=profile,
#                 company=position['company'],
#                 title=position['title'],
#                 start_date=position.get('startDate'),
#                 end_date=position.get('endDate'),
#                 current=position.get('isCurrent', False),
#                 description=position.get('description', '')
#             )
#             print(f"Expérience ajoutée: {position['title']} chez {position['company']}")
    
#     # Ajouter/mettre à jour les formations
#     if 'education' in profile_data:
#         # Supprimer les anciennes formations pour éviter les doublons
#         if not created:
#             Education.objects.filter(profile=profile).delete()
            
#         for edu in profile_data['education']:
#             Education.objects.create(
#                 profile=profile,
#                 institution=edu['schoolName'],
#                 degree=edu.get('degree', ''),
#                 field_of_study=edu.get('fieldOfStudy', ''),
#                 start_date=edu.get('startDate'),
#                 end_date=edu.get('endDate'),
#                 description=edu.get('description', '')
#             )
#             print(f"Formation ajoutée: {edu.get('degree', 'Formation')} à {edu['schoolName']}")
    
#     # Ajouter/mettre à jour les compétences
#     # Supprimer les anciennes compétences pour éviter les doublons
#     if not created:
#         ProfileSkill.objects.filter(profile=profile).delete()
        
#     for skill_data in profile_data['skills']:
#         if isinstance(skill_data, dict):
#             skill_name = skill_data['name']
#             endorsements = skill_data.get('endorsements', 0)
#         else:
#             skill_name = skill_data
#             endorsements = 0
            
#         skill, _ = Skill.objects.get_or_create(name=skill_name)
        
#         ProfileSkill.objects.create(
#             profile=profile,
#             skill=skill,
#             endorsements=endorsements
#         )
#         print(f"Compétence ajoutée: {skill_name}")
    
#     print(f"Profil importé avec succès: {profile}")
#     return profile


# def generate_training_recommendations(profile):
#     """Générer des recommandations de formation pour un profil"""
#     print(f"Génération des recommandations de formation pour {profile}...")
    
#     # Récupérer les compétences actuelles du profil
#     current_skills = set(ps.skill.name for ps in ProfileSkill.objects.filter(profile=profile))
#     print(f"Compétences actuelles: {current_skills}")
    
#     # Simuler des compétences manquantes pour le poste cible
#     target_job = "Data Scientist"
#     target_skills = {"Python", "Machine Learning", "Data Science", "SQL", "TensorFlow"}
    
#     # Identifier les compétences manquantes
#     missing_skills = target_skills - current_skills
#     print(f"Compétences manquantes pour {target_job}: {missing_skills}")
    
#     recommendations = []
    
#     # Générer des recommandations pour chaque compétence manquante
#     for skill_name in missing_skills:
#         try:
#             skill = Skill.objects.get(name=skill_name)
#         except Skill.DoesNotExist:
#             print(f"La compétence {skill_name} n'existe pas dans la base de données.")
#             continue
        
#         # Chercher des cours pour cette compétence
#         course_skills = CourseSkill.objects.filter(skill=skill).order_by('-relevance_score')[:2]
        
#         for course_skill in course_skills:
#             course = course_skill.course
            
#             # Vérifier si une recommandation pour ce profil et ce cours existe déjà
#             existing_recommendation = Recommendation.objects.filter(profile=profile, course=course).first()
#             if existing_recommendation:
#                 print(f"Une recommandation pour le cours '{course.title}' existe déjà pour ce profil.")
#                 recommendations.append(existing_recommendation)
#                 continue
            
#             reason = (
#                 f"Ce cours enseigne {skill_name}, une compétence importante pour un poste de {target_job} "
#                 f"qui n'est pas présente dans votre profil. "
#                 f"Ce cours a un score de pertinence de {course_skill.relevance_score:.2f} pour cette compétence."
#             )
            
#             recommendation = Recommendation.objects.create(
#                 profile=profile,
#                 course=course,
#                 certification=None,
#                 recommendation_score=course_skill.relevance_score,
#                 reason=reason
#             )
#             recommendations.append(recommendation)
#             print(f"Recommandation créée: {course.title} (score: {course_skill.relevance_score:.2f})")
    
#     print(f"{len(recommendations)} recommandations générées avec succès!")
#     return recommendations


# def start_interview_simulation(profile):
#     """Démarrer une simulation d'entretien"""
#     print(f"Démarrage d'une simulation d'entretien pour {profile}...")
    
#     # Récupérer le type d'entretien technique
#     try:
#         interview_type = InterviewType.objects.get(name="Technique")
#     except InterviewType.DoesNotExist:
#         print("Le type d'entretien 'Technique' n'existe pas.")
#         return None
    
#     # Récupérer la plateforme Huru.ai
#     try:
#         platform = CoachingPlatform.objects.get(name="Huru.ai")
#     except CoachingPlatform.DoesNotExist:
#         print("La plateforme 'Huru.ai' n'existe pas.")
#         return None
    
#     # Créer une session d'entretien
#     session = InterviewSession.objects.create(
#         profile=profile,
#         platform=platform,
#         interview_type=interview_type,
#         session_date=timezone.now(),
#         status='in_progress',
#         session_notes=f"Simulation d'entretien technique pour {profile}"
#     )
#     print(f"Session d'entretien créée: {session}")
    
#     # Récupérer des questions pour l'entretien
#     questions = InterviewQuestion.objects.filter(interview_type=interview_type)[:3]
    
#     if not questions:
#         print("Aucune question trouvée pour ce type d'entretien.")
#         return None
    
#     print(f"Questions sélectionnées pour l'entretien:")
#     for i, question in enumerate(questions):
#         print(f"{i+1}. {question.question_text}")
        
#         # Simuler une réponse
#         response_text = f"Voici ma réponse à la question sur {question.question_text.split()[0:3]}... J'ai de l'expérience dans ce domaine et j'ai travaillé sur plusieurs projets liés. Par exemple, j'ai développé une application qui..."
        
#         # Créer la réponse
#         response = InterviewResponse.objects.create(
#             session=session,
#             question=question,
#             response_text=response_text,
#             response_time_seconds=random.randint(30, 120)
#         )
        
#         # Générer un feedback simple
#         feedback = "Bonne réponse, mais vous pourriez donner plus d'exemples concrets."
#         score = random.uniform(60, 90)
        
#         # Mettre à jour la réponse avec le feedback
#         response.feedback = feedback
#         response.score = score
#         response.save()
        
#         print(f"   Réponse enregistrée avec un score de {score:.2f}")
    
#     # Terminer la session
#     session.status = 'completed'
#     session.session_score = random.uniform(70, 90)
#     session.session_feedback = "Bonne performance générale. Continuez à travailler sur des exemples concrets."
#     session.save()
    
#     print(f"Session d'entretien terminée avec un score de {session.session_score:.2f}")
#     return session


# def main():
#     """Fonction principale pour tester les fonctionnalités"""
#     parser = argparse.ArgumentParser(description='Testeur pour le système d\'intégration LinkedIn/Indeed')
#     parser.add_argument('--init', action='store_true', help='Initialiser les données de test')
#     parser.add_argument('--import-profile', type=int, default=0, help='Importer un profil LinkedIn fictif (numéro du profil)')
#     parser.add_argument('--json-file', type=str, help='Chemin vers un fichier JSON contenant un profil à importer')
#     parser.add_argument('--recommend', action='store_true', help='Générer des recommandations de formation')
#     parser.add_argument('--interview', action='store_true', help='Démarrer une simulation d\'entretien')
#     parser.add_argument('--all', action='store_true', help='Exécuter toutes les fonctionnalités')
    
#     args = parser.parse_args()
    
#     # Si aucune option n'est spécifiée, afficher l'aide
#     if not any(vars(args).values()):
#         parser.print_help()
#         return
    
#     # Initialiser les données de test
#     if args.init or args.all:
#         create_test_data()
    
#     profile = None
    
#     # Importer un profil depuis un fichier JSON
#     if args.json_file:
#         profile = import_profile_from_json(args.json_file)
#     # Importer un profil LinkedIn fictif
#     elif args.import_profile > 0 or args.all:
#         profile = import_dummy_linkedin_profile(args.import_profile if args.import_profile > 0 else 1)
    
#     # Si aucun profil n'a été importé mais nécessaire pour la suite
#     if (args.recommend or args.interview or args.all) and not profile:
#         profiles = Profile.objects.all()
#         if profiles:
#             profile = profiles.first()
#             print(f"Utilisation du profil existant: {profile}")
#         else:
#             print("Aucun profil disponible. Importation d'un profil fictif...")
#             profile = import_dummy_linkedin_profile()
    
#     # Générer des recommandations de formation
#     if (args.recommend or args.all) and profile:
#         generate_training_recommendations(profile)
    
#     # Démarrer une simulation d'entretien
#     if (args.interview or args.all) and profile:
#         start_interview_simulation(profile)
    
#     print("Tests terminés avec succès!")


# if __name__ == "__main__":
#     main()

from fastapi import FastAPI, UploadFile, File, Query , HTTPException
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import threading
import os
import django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'job_scraper_project.settings')
django.setup()
from job_scraper_project.modules.extract_text import extract_text_from_pdf
from job_scraper_project.modules.summarize import summarize_text
from job_scraper_project.modules.extract_info import extract_info
from job_scraper_project.modules.job_scraper import fetch_jobs
from job_scraper_project.modules.job_matcher import match_jobs , match_jobsLinkdin
from job_scraper_project.modules.job_filter import filter_jobs
from job_scraper_project.modules.company_stats import show_company_stats
from django.contrib.auth.hashers import make_password, check_password
from login.models import User
from fastapi import FastAPI, HTTPException
from django.contrib.auth.hashers import make_password, check_password, is_password_usable
import os
import django
import sys
import base64
from typing import  List, Dict, Any
import traceback
from asgiref.sync import sync_to_async
import json
import random
from datetime import datetime, timedelta
import argparse
from django.utils import timezone
from fastapi import APIRouter
from linkdinScrap  import linkdiScrap as scrape_linkedin_profile 
import requests 
import uuid 




os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'linkedin_indeed_integration.settings')
django.setup()

# Importer les modèles après la configuration de Django
from profiles.models import Profile, Experience, Education, Skill, ProfileSkill
from training_recommendations.models import (
    TrainingPlatform, Course, Certification, CourseSkill, 
    CertificationSkill, Recommendation
)
from interview_coaching.models import (
    CoachingPlatform, InterviewType, InterviewQuestion,
    InterviewSession, InterviewResponse, FeedbackCategory,
    SessionFeedbackItem
)

app = FastAPI()
router = APIRouter(prefix="/api")
app.include_router(router)

def create_driver():
    """Créer une instance du driver Selenium."""
    service = Service(ChromeDriverManager().install())
    return webdriver.Chrome(service=service)

@app.get("/")
def home():
    """Message d'accueil."""
    return {"message": "Bienvenue sur l'API de Job Matching !"}

# @app.post("/extract-cv")
# def extract_cv(file: UploadFile = File(...)):
#     """Extraction du texte et des infos depuis un CV importé."""
#     file_path = f"temp_{file.filename}"
    
#     with open(file_path, "wb") as buffer:
#         buffer.write(file.file.read())
    
#     text = extract_text_from_pdf(file_path)
#     os.remove(file_path)  # Supprime le fichier après extraction
#     summary = summarize_text(text)
#     info = extract_info(text)
    
#     return {"summary": summary, "extracted_info": info}
LAST_EXTRACTED_CV = None

@app.post("/extract-cv")
def extract_cv(file: UploadFile = File(...)):
    """Extraction du texte et des infos depuis un CV importé."""
    global LAST_EXTRACTED_CV
    
    file_path = f"temp_{file.filename}"
    
    with open(file_path, "wb") as buffer:
        buffer.write(file.file.read())
    
    text = extract_text_from_pdf(file_path)
    os.remove(file_path)
    summary = summarize_text(text)
    info = extract_info(text)
    
    # Store the extracted data
    LAST_EXTRACTED_CV = {
        "summary": summary,
        "extracted_info": info,
        "raw_text": text  # Optional: store raw text if needed
    }
    
    return LAST_EXTRACTED_CV

sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'job_scraper_project.settings')
django.setup()

from login.models import User

# app = FastAPI()
@app.on_event("startup")
async def startup_event():
    await check_db_connection()

@sync_to_async
def check_db_connection():
    from django.db import connections
    try:
        db_conn = connections['default']
        db_conn.cursor()
        print("✅ Database connection successful!")
    except Exception as e:
        print("❌ Database connection failed!")
        print(f"Error: {e}")

def verify_password(plain_password, hashed_password):
    """Robust password check that won't blow up on malformed hashes."""
    if not hashed_password or not is_password_usable(hashed_password):
        return False
    try:
        return check_password(plain_password, hashed_password)
    except (ValueError, TypeError):
        # gracefully fail rather than crash
        return False
hashed = make_password("motdepasse123")
print(hashed)

@app.post("/signup")
def signup(user: Dict[str, Any]):
    try:
        if User.objects.filter(email=user['email']).exists():
            raise HTTPException(status_code=400, detail="Email déjà utilisé")
        
        photo_data = b''
        if 'photo' in user and user['photo']:
            try:
                photo_data = base64.b64decode(user['photo'].encode('utf-8'))
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Photo invalide: {str(e)}")
        
        # Create user instance without saving first
        user_instance = User(
            nom=user['nom'],
            prenom=user['prenom'],
            ville=user['ville'],
            phone=user['phone'],
            email=user['email'],
            photo=photo_data,
            date_anniverssaire=user['date_anniverssaire'],
        )
        
        # Properly hash the password using Django's make_password
        user_instance.password = make_password(user['password'])
        
        # Now save the user
        user_instance.save()

        return {
            "message": "Utilisateur créé",  
            "user_id": user_instance.id,    
            "email": user_instance.email ,
            "nom" : user_instance.nom, 
            "prenom" : user_instance.prenom ,
            "phone" : user_instance.phone 
        }

    except Exception as e:
        traceback_str = traceback.format_exc()
        print("🔴 Full traceback:\n", traceback_str)
        raise HTTPException(status_code=500, detail=str(e))

import logging
logger = logging.getLogger(__name__)

@app.post("/login")
async def login(credentials: Dict[str, Any]):
    try:
        email = credentials.get('email', '').strip().lower()
        password = credentials.get('password', '')
        
        if not email or not password:
            raise HTTPException(status_code=400, detail="Email and password are required")

        logger.debug(f"Login attempt for: {email}")

        try:
            user = await sync_to_async(User.objects.get)(email=email)
            logger.debug(f"User found: {user.id}")
        except User.DoesNotExist:
            logger.warning(f"User not found: {email}")
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        try:
            # Use Django's built-in check_password with error handling
            is_valid = await sync_to_async(verify_password)(password, user.password)
            
            if not is_valid:
                logger.warning(f"Password verification failed for {email}")
                raise HTTPException(status_code=401, detail="Invalid credentials")

            logger.info(f"Successful login for {email}")
            return {
                "message": "Login successful",
                "user_id": user.id,
                "email": user.email
            }
        except Exception as e:
            logger.error(f"Password verification error: {str(e)}")
            raise HTTPException(status_code=401, detail="Invalid credentials")

    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Unexpected error during login: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")

@app.get("/users/", response_model=List[Dict[str, Any]])
async def get_all_users():
    try:
        # Récupérer tous les utilisateurs de manière asynchrone
        users = await sync_to_async(list)(User.objects.all())
        
        # Convertir les données utilisateur en format sérialisable
        user_list = []
        for user in users:
            user_data = {
                "id": user.id,
                "nom": user.nom,
                "prenom": user.prenom,
                "email": user.email,
                "ville": user.ville,
                "phone": user.phone,
                "date_anniverssaire": user.date_anniverssaire.isoformat() if user.date_anniverssaire else None,
                # Convertir la photo en base64 si elle existe
                "photo": base64.b64encode(user.photo).decode('utf-8') if user.photo else None
            }
            user_list.append(user_data)
        
        return user_list
        
    except Exception as e:
        logger.exception(f"Error fetching users: {str(e)}")
        raise HTTPException(status_code=500, detail="Internal server error")
@app.get("/scrape-jobs")
def scrape_jobs():
    """Scraper les offres d'emploi sur LinkedIn."""
    driver = create_driver()
    driver.get("https://www.linkedin.com/jobs/search?keywords=&location=Worldwide&geoId=92000000")

    jobs = fetch_jobs(driver)
    driver.quit()

    return {"jobs": jobs[:10]}  # Retourner seulement les 10 premiers jobs

# @app.get("/match-jobs")
# def match_jobs_api():
#     """Faire correspondre les jobs au profil extrait du CV."""
#     pdf_path = "K:/WJob/analysethecv/cv/CV.pdf"
#     text = extract_text_from_pdf(pdf_path)
#     info = extract_info(text)

#     driver = create_driver()
#     driver.get("https://www.linkedin.com/jobs/search?keywords=&location=Worldwide&geoId=92000000")

#     jobs = fetch_jobs(driver)
#     best_jobs = match_jobs(info, jobs)
#     driver.quit()

#     return {"best_jobs": best_jobs[:10]}  # Retourner les 10 meilleurs jobs
@app.get("/match-jobs")
def match_jobs_api():
    """Faire correspondre les jobs au dernier CV extrait."""
    global LAST_EXTRACTED_CV
    
    if not LAST_EXTRACTED_CV:
        raise HTTPException(
            status_code=400,
            detail="No CV extracted yet. Please call /extract-cv first."
        )
    
    # Use the stored CV data
    info = LAST_EXTRACTED_CV["extracted_info"]
    
    driver = create_driver()
    driver.get("https://www.linkedin.com/jobs/search?keywords=&location=Worldwide")
    jobs = fetch_jobs(driver)
    best_jobs = match_jobs(info, jobs)
    driver.quit()

    return {
        "cv_analysis": LAST_EXTRACTED_CV,  # Include original CV analysis
        "best_jobs": best_jobs[:10],
        "total_matches": len(best_jobs)
    }

@app.get("/filter-jobs")
def filter_jobs_api(
    job_title: str = Query(None),
    skills: str = Query(None),
    company: str = Query(None),
    location: str = Query(None),
    experience_level: str = Query(None),
    salary_range: str = Query(None),
    date_posted: str = Query(None),
):
    """Filtrer les jobs selon les critères utilisateur."""
    driver = create_driver()
    driver.get("https://www.linkedin.com/jobs/search?keywords=&location=Worldwide&geoId=92000000")

    jobs = fetch_jobs(driver)
    driver.quit()

    filters = {
        "job_title": job_title,
        "skills": skills,
        "company": company,
        "location": location,
        "experience_level": experience_level,
        "salary_range": salary_range,
        "date_posted": date_posted
    }
    filters = {key: value for key, value in filters.items() if value is not None}
    filtered_jobs = filter_jobs(filters, jobs)

    return {"filtered_jobs": filtered_jobs[:10]}

@app.get("/company-stats")
def company_stats(job_link: str):
    """Obtenir les statistiques d'une entreprise pour une offre donnée."""
    if not job_link:
        raise HTTPException(status_code=400, detail="Le lien de l'offre est requis.")

    try:
        driver = create_driver()
        driver.get(job_link)  # utilise le lien directement
        stats = show_company_stats(driver, job_link)
        driver.quit()
        return {"company_stats": stats}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de l'analyse de l'entreprise : {str(e)}")



def run_full_process():
    """Exécuter tout le processus en arrière-plan."""
    extract_cv()
    scrape_jobs()
    match_jobs_api()

@app.get("/run-job-matching")
def run_job_matching():
    """Exécuter tout le job matching en arrière-plan avec un CV par défaut"""
    try:
        # Use a default CV file path
        default_cv_path = "K:/WJob/analysethecv/cv/CV.pdf"  # Update this path
        
        # Run the process in a thread with the default CV
        thread = threading.Thread(target=run_full_process, args=(default_cv_path,))
        thread.start()
        
        return {
            "message": "Le job matching est en cours d'exécution...",
            "note": "Utilisation du CV par défaut à l'emplacement spécifié"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/create-test-data")
def create_test_data_endpoint():
    """Endpoint pour retourner des données de test mockées (sans base de données)"""
    try:
        return {
            "message": "Données de test mockées générées avec succès!",
            "skills": [
                "Python", "Django", "JavaScript", "React", "SQL", "Machine Learning",
                "Data Science", "DevOps", "Cloud Computing", "Docker", "Kubernetes",
                "HTML/CSS", "Node.js", "Java", "C#", "PHP", "Ruby", "Scala", "Go",
                "TensorFlow", "PyTorch", "NLP", "Computer Vision", "Data Analysis"
            ],
            "training_platforms": [
                {
                    "name": "MyMooc",
                    "website": "https://www.mymooc.fr",
                    "description": "Plateforme gratuite de MOOCs",
                    "is_free": True
                },
                {
                    "name": "Udemy",
                    "website": "https://www.udemy.com",
                    "description": "Plateforme payante de cours en ligne",
                    "is_free": False
                }
            ],
            "interview_questions": [
                {
                    "question": "Décrivez votre expérience avec Python et Django.",
                    "type": "Technique",
                    "difficulty": "medium"
                },
                {
                    "question": "Racontez une situation difficile au travail...",
                    "type": "Comportemental",
                    "difficulty": "medium"
                }
            ],
            "courses": [
                {
                    "title": "Django pour débutants",
                    "platform": "MyMooc",
                    "skills": ["Python", "Django", "HTML/CSS"]
                },
                {
                    "title": "Machine Learning avec Python",
                    "platform": "Udemy", 
                    "skills": ["Python", "Machine Learning", "Data Science"]
                }
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
def create_test_data():
    """Créer des données de test pour démontrer les fonctionnalités"""
    print("Création des données de test...")
    
    # Créer des compétences
    skills = [
        "Python", "Django", "JavaScript", "React", "SQL", "Machine Learning",
        "Data Science", "DevOps", "Cloud Computing", "Docker", "Kubernetes",
        "HTML/CSS", "Node.js", "Java", "C#", "PHP", "Ruby", "Scala", "Go",
        "TensorFlow", "PyTorch", "NLP", "Computer Vision", "Data Analysis"
    ]
    
    skill_objects = {}
    for skill_name in skills:
        skill, created = Skill.objects.get_or_create(name=skill_name)
        skill_objects[skill_name] = skill
        if created :
            print(f"Compétence créée: {skill_name}")
    
    # Créer des plateformes de formation
    platforms = [
        {
            "name": "MyMooc",
            "website": "https://www.mymooc.fr",
            "description": "Plateforme gratuite de MOOCs",
            "is_free": True
        },
        {
            "name": "Udemy",
            "website": "https://www.udemy.com",
            "description": "Plateforme payante de cours en ligne",
            "is_free": False
        },
        {
            "name": "Coursera",
            "website": "https://www.coursera.org",
            "description": "Plateforme de cours en ligne des universités",
            "is_free": False
        }
    ]
    
    platform_objects = {}
    for platform_data in platforms:
        platform, created = TrainingPlatform.objects.get_or_create(
            name=platform_data["name"],
            defaults=platform_data
        )
        platform_objects[platform_data["name"]] = platform
        if created:
            print(f"Plateforme de formation créée: {platform_data['name']}")
    
    # Créer des plateformes de coaching
    coaching_platforms = [
        {
            "name": "Huru.ai",
            "website": "https://www.huru.ai",
            "description": "Coaching IA gratuit pour entretiens",
            "is_free": True
        },
        {
            "name": "CoachHub",
            "website": "https://www.coachhub.io",
            "description": "Plateforme payante de coaching professionnel",
            "is_free": False
        }
    ]
    
    coaching_platform_objects = {}
    for platform_data in coaching_platforms:
        platform, created = CoachingPlatform.objects.get_or_create(
            name=platform_data["name"],
            defaults=platform_data
        )
        coaching_platform_objects[platform_data["name"]] = platform
        if created:
            print(f"Plateforme de coaching créée: {platform_data['name']}")
    
    # Créer des types d'entretien
    interview_types = [
        {
            "name": "Technique",
            "description": "Entretien technique pour évaluer les compétences techniques"
        },
        {
            "name": "Comportemental",
            "description": "Entretien pour évaluer le comportement et les soft skills"
        },
        {
            "name": "RH",
            "description": "Entretien avec les ressources humaines"
        }
    ]
    
    interview_type_objects = {}
    for type_data in interview_types:
        interview_type, created = InterviewType.objects.get_or_create(
            name=type_data["name"],
            defaults=type_data
        )
        interview_type_objects[type_data["name"]] = interview_type
        if created:
            print(f"Type d'entretien créé: {type_data['name']}")
    
    # Créer des questions d'entretien
    questions = [
        {
            "question_text": "Décrivez votre expérience avec Python et Django.",
            "interview_type": interview_type_objects["Technique"],
            "difficulty": "medium",
            "ideal_answer": "J'ai 5 ans d'expérience avec Python et 3 ans avec Django. J'ai développé plusieurs applications web avec Django REST Framework, mis en place des tests automatisés, et optimisé les performances des applications."
        },
        {
            "question_text": "Racontez une situation difficile au travail et comment vous l'avez gérée.",
            "interview_type": interview_type_objects["Comportemental"],
            "difficulty": "medium",
            "ideal_answer": "J'ai rencontré un conflit avec un collègue sur la direction technique d'un projet. J'ai organisé une réunion pour discuter ouvertement, écouté son point de vue, et nous avons trouvé un compromis qui a amélioré le projet."
        },
        {
            "question_text": "Pourquoi voulez-vous rejoindre notre entreprise ?",
            "interview_type": interview_type_objects["RH"],
            "difficulty": "easy",
            "ideal_answer": "J'admire votre culture d'innovation et vos valeurs. Vos produits ont un impact réel sur les utilisateurs, et j'aimerais contribuer à cette mission tout en développant mes compétences dans un environnement stimulant."
        }
    ]
    
    for question_data in questions:
        question, created = InterviewQuestion.objects.get_or_create(
            question_text=question_data["question_text"],
            defaults=question_data
        )
        if created:
            print(f"Question d'entretien créée: {question_data['question_text'][:40]}...")
    
    # Créer des cours
    courses = [
        {
            "title": "Django pour débutants",
            "description": "Apprenez les bases de Django pour créer des applications web",
            "platform": platform_objects["MyMooc"],
            "url": "https://www.mymooc.fr/cours/django-debutants",
            "level": "beginner",
            "price": None,  # gratuit
            "duration_hours": 10,
            "skills": ["Python", "Django", "HTML/CSS"]
        },
        {
            "title": "Machine Learning avec Python",
            "description": "Maîtrisez les algorithmes d'apprentissage automatique avec Python",
            "platform": platform_objects["Udemy"],
            "url": "https://www.udemy.com/course/machine-learning-python",
            "level": "intermediate",
            "price": 49.99,
            "duration_hours": 25,
            "skills": ["Python", "Machine Learning", "Data Science"]
        }
    ]
    
    for course_data in courses:
        skills_data = course_data.pop("skills")
        course, created = Course.objects.get_or_create(
            title=course_data["title"],
            defaults=course_data
        )
        if created:
            print(f"Cours créé: {course_data['title']}")
            
        # Ajouter les compétences au cours
        for skill_name in skills_data:
            CourseSkill.objects.get_or_create(
                course=course,
                skill=skill_objects[skill_name],
                defaults={"relevance_score": random.uniform(0.7, 1.0)}
            )
    
    print("Données de test créées avec succès!")

@app.get("/import-dummy-linkedin-profile")
def import_dummy_linkedin_profile_endpoint(profile_num: int = 1):
    """Endpoint pour retourner un profil LinkedIn fictif mocké (sans base de données)"""
    try:
        # Profils fictifs LinkedIn
        profiles_data = [
            {
                "id": 1,
                "first_name": "Jean",
                "last_name": "Dupont",
                "headline": "Développeur Full Stack",
                "summary": "Développeur full stack avec 5 ans d'expérience en Python, Django, React et Node.js.",
                "location": "Paris, France",
                "linkedin_url": "https://www.linkedin.com/in/jean-dupont-123/",
                "positions": [
                    {
                        "title": "Développeur Full Stack",
                        "company": "TechCorp",
                        "start_date": "2020-01-01",
                        "end_date": None,
                        "current": True,
                        "description": "Développement d'applications web avec Django et React"
                    }
                ],
                "education": [
                    {
                        "institution": "Université de Paris",
                        "degree": "Master",
                        "field_of_study": "Informatique",
                        "description": "Spécialisation en développement web"
                    }
                ],
                "skills": [
                    {"name": "Python", "endorsements": 15},
                    {"name": "Django", "endorsements": 12}
                ]
            },
            {
                "id": 2,
                "first_name": "Marie",
                "last_name": "Martin",
                "headline": "Data Scientist",
                "summary": "Data scientist avec 3 ans d'expérience en analyse de données...",
                "location": "Lyon, France",
                "linkedin_url": "https://www.linkedin.com/in/marie-martin-456/",
                "positions": [
                    {
                        "title": "Data Scientist",
                        "company": "DataInsight",
                        "start_date": "2022-01-01",
                        "end_date": None,
                        "current": True,
                        "description": "Développement de modèles de machine learning"
                    }
                ],
                "education": [
                    {
                        "institution": "École Centrale Lyon",
                        "degree": "Master",
                        "field_of_study": "Data Science",
                        "description": "Spécialisation en machine learning"
                    }
                ],
                "skills": [
                    {"name": "Python", "endorsements": 22},
                    {"name": "Machine Learning", "endorsements": 18}
                ]
            },
            {
        "id": 3,
        "first_name": "Lucas",
        "last_name": "Bernard",
        "headline": "Ingénieur DevOps",
        "summary": "Ingénieur DevOps avec expertise en automatisation CI/CD et gestion d'infrastructure cloud.",
        "location": "Toulouse, France",
        "linkedin_url": "https://www.linkedin.com/in/lucas-bernard-789/",
        "positions": [
            {
                "title": "Ingénieur DevOps",
                "company": "CloudWorks",
                "start_date": "2019-05-01",
                "end_date": None,
                "current": True,
                "description": "Mise en place de pipelines CI/CD et gestion AWS."
            }
        ],
        "education": [
            {
                "institution": "INSA Toulouse",
                "degree": "Diplôme d'ingénieur",
                "field_of_study": "Informatique",
                "description": "Spécialisation en systèmes et réseaux."
            }
        ],
        "skills": [
            {"name": "AWS", "endorsements": 20},
            {"name": "Docker", "endorsements": 18}
        ]
    },
    {
        "id": 5,
        "first_name": "Thomas",
        "last_name": "Petit",
        "headline": "Chef de projet IT",
        "summary": "Chef de projet IT avec 7 ans d'expérience dans la gestion de projets informatiques complexes.",
        "location": "Nantes, France",
        "linkedin_url": "https://www.linkedin.com/in/thomas-petit-202/",
        "positions": [
            {
                "title": "Chef de projet IT",
                "company": "ITManage",
                "start_date": "2018-09-01",
                "end_date": None,
                "current": True,
                "description": "Gestion de projets de transformation digitale."
            }
        ],
        "education": [
            {
                "institution": "IMT Atlantique",
                "degree": "Master",
                "field_of_study": "Management des Systèmes d'Information",
                "description": "Spécialisation en gestion de projet agile."
            }
        ],
        "skills": [
            {"name": "Scrum", "endorsements": 19},
            {"name": "Gestion de projet", "endorsements": 23}
        ]
    }, {
        "id": 6,
        "first_name": "Clara",
        "last_name": "Moreau",
        "headline": "Consultante en cybersécurité",
        "summary": "Consultante spécialisée en cybersécurité avec une expérience en audit et en protection des données.",
        "location": "Lille, France",
        "linkedin_url": "https://www.linkedin.com/in/clara-moreau-303/",
        "positions": [
            {
                "title": "Consultante en cybersécurité",
                "company": "SecureIT",
                "start_date": "2020-06-01",
                "end_date": None,
                "current": True,
                "description": "Réalisation d'audits de sécurité et conseil en conformité RGPD."
            }
        ],
        "education": [
            {
                "institution": "Université de Lille",
                "degree": "Master",
                "field_of_study": "Sécurité informatique",
                "description": "Spécialisation en cybersécurité des systèmes."
            }
        ],
        "skills": [
            {"name": "Cybersecurity", "endorsements": 21},
            {"name": "ISO 27001", "endorsements": 14}
        ]
    },
    {
        "id": 7,
        "first_name": "Antoine",
        "last_name": "Girard",
        "headline": "Architecte Cloud",
        "summary": "Architecte Cloud avec 8 ans d'expérience dans la conception d'architectures AWS et Azure.",
        "location": "Bordeaux, France",
        "linkedin_url": "https://www.linkedin.com/in/antoine-girard-404/",
        "positions": [
            {
                "title": "Architecte Cloud",
                "company": "CloudMasters",
                "start_date": "2017-02-01",
                "end_date": None,
                "current": True,
                "description": "Conception et déploiement d'architectures cloud sécurisées et scalables."
            }
        ],
        "education": [
            {
                "institution": "ENSEIRB-MATMECA",
                "degree": "Diplôme d'ingénieur",
                "field_of_study": "Informatique",
                "description": "Spécialisation en systèmes distribués."
            }
        ],
        "skills": [
            {"name": "AWS", "endorsements": 30},
            {"name": "Azure", "endorsements": 27}
        ]
    }
        ]
        
        # Sélectionner le profil demandé
        profile_index = min(profile_num - 1, len(profiles_data) - 1)
        profile_data = profiles_data[profile_index]
        
        return {
            "message": "Profil LinkedIn fictif mocké généré avec succès",
            "profile": profile_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
def import_dummy_linkedin_profile(profile_num=1):
    """Importer un profil LinkedIn fictif pour démonstration"""
    print("Importation d'un profil LinkedIn fictif...")
    
    # Profils fictifs LinkedIn
    profiles_data = [
        {
            'firstName': 'Jean',
            'lastName': 'Dupont',
            'headline': 'Développeur Full Stack',
            'summary': 'Développeur full stack avec 5 ans d\'expérience en Python, Django, React et Node.js.',
            'location': 'Paris, France',
            'source': 'linkedin',
            'source_profile_id': 'jean-dupont-123',
            'linkedin_url': 'https://www.linkedin.com/in/jean-dupont-123/',
            'positions': [
                {
                    'title': 'Développeur Full Stack',
                    'company': 'TechCorp',
                    'startDate': '2020-01-01',
                    'endDate': None,
                    'isCurrent': True,
                    'description': 'Développement d\'applications web avec Django et React'
                },
                {
                    'title': 'Développeur Front-end',
                    'company': 'WebAgency',
                    'startDate': '2018-03-01',
                    'endDate': '2019-12-31',
                    'isCurrent': False,
                    'description': 'Développement d\'interfaces utilisateur avec React et Angular'
                }
            ],
            'education': [
                {
                    'schoolName': 'Université de Paris',
                    'degree': 'Master',
                    'fieldOfStudy': 'Informatique',
                    'startDate': '2016-09-01',
                    'endDate': '2018-06-30',
                    'description': 'Spécialisation en développement web'
                }
            ],
            'skills': [
                {'name': 'Python', 'endorsements': 15},
                {'name': 'Django', 'endorsements': 12},
                {'name': 'React', 'endorsements': 18},
                {'name': 'JavaScript', 'endorsements': 20},
                {'name': 'HTML/CSS', 'endorsements': 10}
            ]
        },
        {
            'firstName': 'Marie',
            'lastName': 'Martin',
            'headline': 'Data Scientist',
            'summary': 'Data scientist avec 3 ans d\'expérience en analyse de données, machine learning et deep learning.',
            'location': 'Lyon, France',
            'source': 'linkedin',
            'source_profile_id': 'marie-martin-456',
            'linkedin_url': 'https://www.linkedin.com/in/marie-martin-456/',
            'positions': [
                {
                    'title': 'Data Scientist',
                    'company': 'DataInsight',
                    'startDate': '2022-01-01',
                    'endDate': None,
                    'isCurrent': True,
                    'description': 'Développement de modèles de machine learning pour la prédiction de comportements clients'
                },
                {
                    'title': 'Data Analyst',
                    'company': 'AnalyticsLab',
                    'startDate': '2020-06-01',
                    'endDate': '2021-12-31',
                    'isCurrent': False,
                    'description': 'Analyse de données marketing et création de tableaux de bord'
                }
            ],
            'education': [
                {
                    'schoolName': 'École Centrale Lyon',
                    'degree': 'Master',
                    'fieldOfStudy': 'Data Science',
                    'startDate': '2018-09-01',
                    'endDate': '2020-06-30',
                    'description': 'Spécialisation en machine learning'
                }
            ],
            'skills': [
                {'name': 'Python', 'endorsements': 22},
                {'name': 'Machine Learning', 'endorsements': 18},
                {'name': 'SQL', 'endorsements': 15},
                {'name': 'TensorFlow', 'endorsements': 12},
                {'name': 'Data Analysis', 'endorsements': 20}
            ]
        }
    ]
    
    # Sélectionner le profil à importer
    profile_index = min(profile_num - 1, len(profiles_data) - 1)
    linkedin_data = profiles_data[profile_index]
    
    # Créer le profil
    profile, created = Profile.objects.get_or_create(
        source='linkedin',
        source_profile_id=linkedin_data['source_profile_id'],
        defaults={
            'first_name': linkedin_data['firstName'],
            'last_name': linkedin_data['lastName'],
            'headline': linkedin_data['headline'],
            'summary': linkedin_data['summary'],
            'location': linkedin_data['location'],
            'linkedin_url': linkedin_data['linkedin_url']
        }
    )
    
    if not created:
        print(f"Le profil {linkedin_data['firstName']} {linkedin_data['lastName']} existe déjà.")
        return profile
    
    print(f"Profil créé: {linkedin_data['firstName']} {linkedin_data['lastName']}")
    
    # Ajouter les expériences
    for position in linkedin_data['positions']:
        Experience.objects.create(
            profile=profile,
            company=position['company'],
            title=position['title'],
            start_date=position['startDate'],
            end_date=position['endDate'],
            current=position['isCurrent'],
            description=position['description']
        )
        print(f"Expérience ajoutée: {position['title']} chez {position['company']}")
    
    # Ajouter les formations
    for edu in linkedin_data['education']:
        Education.objects.create(
            profile=profile,
            institution=edu['schoolName'],
            degree=edu['degree'],
            field_of_study=edu['fieldOfStudy'],
            start_date=edu['startDate'],
            end_date=edu['endDate'],
            description=edu['description']
        )
        print(f"Formation ajoutée: {edu['degree']} en {edu['fieldOfStudy']} à {edu['schoolName']}")
    
    # Ajouter les compétences
    for skill_data in linkedin_data['skills']:
        skill_name = skill_data['name']
        skill, _ = Skill.objects.get_or_create(name=skill_name)
        
        ProfileSkill.objects.create(
            profile=profile,
            skill=skill,
            endorsements=skill_data['endorsements']
        )
        print(f"Compétence ajoutée: {skill_name} avec {skill_data['endorsements']} recommandations")
    
    print(f"Profil LinkedIn importé avec succès: {profile}")
    return profile

@app.post("/import-profile-from-json")
async def import_profile_from_json_endpoint(file: UploadFile = File(...)):
    """Endpoint pour importer un profil depuis un fichier JSON (sans base de données)"""
    try:
        # Lire le contenu du fichier
        content = await file.read()
        profile_data = json.loads(content)
        
        # Valider la structure minimale
        if not all(field in profile_data for field in ['firstName', 'lastName', 'headline', 'summary']):
            raise HTTPException(status_code=400, detail="JSON invalide - champs requis manquants")
        
        # Formater la réponse sans interaction avec la base de données
        response = {
            "message": "Profil importé avec succès (mode sans base de données)",
            "profile": {
                "name": f"{profile_data['firstName']} {profile_data['lastName']}",
                "headline": profile_data['headline'],
                "summary": profile_data['summary'],
                "skills": profile_data.get('skills', []),
                "positions": profile_data.get('positions', []),
                "education": profile_data.get('education', [])
            }
        }
        
        return response
        
    except json.JSONDecodeError:
        raise HTTPException(status_code=400, detail="Fichier JSON invalide")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
def import_profile_from_json(json_file_path=None):
    """Importer un profil depuis un fichier JSON"""
    if not json_file_path:
        print("Aucun fichier JSON spécifié. Utilisez --json-file pour spécifier un fichier.")
        return None
    
    print(f"Importation du profil depuis {json_file_path}...")
    
    try:
        with open(json_file_path, 'r', encoding='utf-8') as f:
            profile_data = json.load(f)
    except FileNotFoundError:
        print(f"Erreur: Le fichier {json_file_path} n'existe pas.")
        return None
    except json.JSONDecodeError:
        print(f"Erreur: Le fichier {json_file_path} n'est pas un JSON valide.")
        return None
    
    # Vérifier la structure du JSON
    required_fields = ['firstName', 'lastName', 'headline', 'summary', 'skills']
    for field in required_fields:
        if field not in profile_data:
            print(f"Erreur: Le champ '{field}' est requis mais manquant dans le JSON.")
            return None
    
    # Générer un ID unique si non fourni
    if 'source_profile_id' not in profile_data:
        import uuid
        profile_data['source_profile_id'] = str(uuid.uuid4())
    
    # Créer ou mettre à jour le profil
    profile, created = Profile.objects.get_or_create(
        source='custom',
        source_profile_id=profile_data['source_profile_id'],
        defaults={
            'first_name': profile_data['firstName'],
            'last_name': profile_data['lastName'],
            'headline': profile_data['headline'],
            'summary': profile_data['summary'],
            'location': profile_data.get('location', ''),
            'linkedin_url': profile_data.get('linkedin_url', '')
        }
    )
    
    if not created:
        print(f"Le profil {profile_data['firstName']} {profile_data['lastName']} existe déjà.")
        # Mettre à jour les champs existants
        profile.headline = profile_data['headline']
        profile.summary = profile_data['summary']
        if 'location' in profile_data:
            profile.location = profile_data['location']
        if 'linkedin_url' in profile_data:
            profile.linkedin_url = profile_data['linkedin_url']
        profile.save()
    else:
        print(f"Profil créé: {profile_data['firstName']} {profile_data['lastName']}")
    
    # Ajouter/mettre à jour les expériences
    if 'positions' in profile_data:
        # Supprimer les anciennes expériences pour éviter les doublons
        if not created:
            Experience.objects.filter(profile=profile).delete()
            
        for position in profile_data['positions']:
            Experience.objects.create(
                profile=profile,
                company=position['company'],
                title=position['title'],
                start_date=position.get('startDate'),
                end_date=position.get('endDate'),
                current=position.get('isCurrent', False),
                description=position.get('description', '')
            )
            print(f"Expérience ajoutée: {position['title']} chez {position['company']}")
    
    # Ajouter/mettre à jour les formations
    if 'education' in profile_data:
        # Supprimer les anciennes formations pour éviter les doublons
        if not created:
            Education.objects.filter(profile=profile).delete()
            
        for edu in profile_data['education']:
            Education.objects.create(
                profile=profile,
                institution=edu['schoolName'],
                degree=edu.get('degree', ''),
                field_of_study=edu.get('fieldOfStudy', ''),
                start_date=edu.get('startDate'),
                end_date=edu.get('endDate'),
                description=edu.get('description', '')
            )
            print(f"Formation ajoutée: {edu.get('degree', 'Formation')} à {edu['schoolName']}")
    
    # Ajouter/mettre à jour les compétences
    # Supprimer les anciennes compétences pour éviter les doublons
    if not created:
        ProfileSkill.objects.filter(profile=profile).delete()
        
    for skill_data in profile_data['skills']:
        if isinstance(skill_data, dict):
            skill_name = skill_data['name']
            endorsements = skill_data.get('endorsements', 0)
        else:
            skill_name = skill_data
            endorsements = 0
            
        skill, _ = Skill.objects.get_or_create(name=skill_name)
        
        ProfileSkill.objects.create(
            profile=profile,
            skill=skill,
            endorsements=endorsements
        )
        print(f"Compétence ajoutée: {skill_name}")
    
    print(f"Profil importé avec succès: {profile}")
    return profile


@app.get("/generate-recommendations/{user_id}")
async def generate_recommendations(user_id: int):
    """Endpoint pour retourner des recommandations de formation mockées (sans base de données)"""
    try:
        # Mock profile data based on user_id
        profile_data = {
            "user_id": user_id,
            "current_skills": ["Python", "Django", "SQL"],
            "target_job": "Data Scientist"
        }
        
        # Mock missing skills for target job
        target_skills = {
            "Data Scientist": ["Machine Learning", "Data Analysis", "TensorFlow", "Python", "SQL"]
        }
        
        # Calculate missing skills
        missing_skills = list(set(target_skills[profile_data["target_job"]]) - 
                          set(profile_data["current_skills"]))
        
        # Mock course recommendations
        mock_courses = {
            "Machine Learning": [
                {
                    "course_id": 101,
                    "title": "Machine Learning Fundamentals",
                    "platform": "Coursera",
                    "score": 0.95,
                    "url": "https://www.coursera.org/learn/machine-learning"
                },
                {
                    "course_id": 102,
                    "title": "Applied Data Science with Python",
                    "platform": "Udemy",
                    "score": 0.88,
                    "url": "https://www.udemy.com/course/data-science-python"
                }
            ],
            "Data Analysis": [
                {
                    "course_id": 201,
                    "title": "Data Analysis with Pandas",
                    "platform": "DataCamp",
                    "score": 0.92,
                    "url": "https://www.datacamp.com/courses/data-analysis-with-pandas"
                }
            ],
            "TensorFlow": [
                {
                    "course_id": 301,
                    "title": "Deep Learning with TensorFlow",
                    "platform": "Udacity",
                    "score": 0.97,
                    "url": "https://www.udacity.com/course/deep-learning--ud730"
                }
            ]
        }
        
        # Generate mock recommendations
        recommendations = []
        for skill in missing_skills:
            if skill in mock_courses:
                for course in mock_courses[skill]:
                    recommendations.append({
                        "course_id": course["course_id"],
                        "course_title": course["title"],
                        "platform": course["platform"],
                        "reason": f"Ce cours enseigne {skill}, une compétence importante pour un poste de {profile_data['target_job']}",
                        "score": course["score"],
                        "url": course["url"]
                    })
        
        return {
            "message": "Recommandations mockées générées avec succès",
            "user_id": user_id,
            "target_job": profile_data["target_job"],
            "current_skills": profile_data["current_skills"],
            "missing_skills": missing_skills,
            "count": len(recommendations),
            "recommendations": recommendations
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de la génération des recommandations: {str(e)}")
    
def generate_training_recommendations(profile):
    """Générer des recommandations de formation pour un profil"""
    print(f"Génération des recommandations de formation pour {profile}...")
    
    # Récupérer les compétences actuelles du profil
    current_skills = set(ps.skill.name for ps in ProfileSkill.objects.filter(profile=profile))
    print(f"Compétences actuelles: {current_skills}")
    
    # Simuler des compétences manquantes pour le poste cible
    target_job = "Data Scientist"
    target_skills = {"Python", "Machine Learning", "Data Science", "SQL", "TensorFlow"}
    
    # Identifier les compétences manquantes
    missing_skills = target_skills - current_skills
    print(f"Compétences manquantes pour {target_job}: {missing_skills}")
    
    recommendations = []
    
    # Générer des recommandations pour chaque compétence manquante
    for skill_name in missing_skills:
        try:
            skill = Skill.objects.get(name=skill_name)
        except Skill.DoesNotExist:
            print(f"La compétence {skill_name} n'existe pas dans la base de données.")
            continue
        
        # Chercher des cours pour cette compétence
        course_skills = CourseSkill.objects.filter(skill=skill).order_by('-relevance_score')[:2]
        
        for course_skill in course_skills:
            course = course_skill.course
            
            # Vérifier si une recommandation pour ce profil et ce cours existe déjà
            existing_recommendation = Recommendation.objects.filter(profile=profile, course=course).first()
            if existing_recommendation:
                print(f"Une recommandation pour le cours '{course.title}' existe déjà pour ce profil.")
                recommendations.append(existing_recommendation)
                continue
            
            reason = (
                f"Ce cours enseigne {skill_name}, une compétence importante pour un poste de {target_job} "
                f"qui n'est pas présente dans votre profil. "
                f"Ce cours a un score de pertinence de {course_skill.relevance_score:.2f} pour cette compétence."
            )
            
            recommendation = Recommendation.objects.create(
                profile=profile,
                course=course,
                certification=None,
                recommendation_score=course_skill.relevance_score,
                reason=reason
            )
            recommendations.append(recommendation)
            print(f"Recommandation créée: {course.title} (score: {course_skill.relevance_score:.2f})")
    
    print(f"{len(recommendations)} recommandations générées avec succès!")
    return recommendations

@app.post("/start-interview-simulation/{user_id}")
async def api_start_interview_simulation(user_id: int):
    """Endpoint pour démarrer une simulation d'entretien mockée (sans base de données)"""
    try:
        # Mock interview data
        mock_interview_types = {
            1: "Technique",
            2: "Comportemental",
            3: "RH"
        }
        
        mock_platforms = {
            1: "Huru.ai",
            2: "CoachHub"
        }
        
        mock_questions = {
            "Technique": [
                "Décrivez votre expérience avec Python et Django",
                "Comment optimiseriez-vous une requête SQL lente?",
                "Expliquez le principe de REST API"
            ],
            "Comportemental": [
                "Parlez-moi d'une situation difficile et comment vous l'avez résolue",
                "Comment gérez-vous les désaccords avec vos collègues?",
                "Donnez un exemple où vous avez dû apprendre rapidement"
            ],
            "RH": [
                "Pourquoi voulez-vous travailler dans notre entreprise?",
                "Où vous voyez-vous dans 5 ans?",
                "Quel est votre plus grand défaut?"
            ]
        }
        
        # Select random interview type
        interview_type_id = random.choice(list(mock_interview_types.keys()))
        interview_type = mock_interview_types[interview_type_id]
        
        # Select random platform
        platform_id = random.choice(list(mock_platforms.keys()))
        platform = mock_platforms[platform_id]
        
        # Generate mock session
        session_id = random.randint(1000, 9999)
        session_date = datetime.now().isoformat()
        
        # Generate mock questions and responses
        questions = random.sample(mock_questions[interview_type], 3)
        responses = []
        
        for i, question in enumerate(questions):
            response_text = f"Voici ma réponse à la question sur {question.split()[0:3]}... J'ai de l'expérience dans ce domaine..."
            score = round(random.uniform(60, 90), 1)
            
            responses.append({
                "question_number": i+1,
                "question": question,
                "response": response_text,
                "score": score,
                "feedback": "Bonne réponse, mais vous pourriez donner plus d'exemples concrets."
            })
        
        # Calculate overall score
        overall_score = round(sum(r['score'] for r in responses) / len(responses), 1)
        
        # Create response data
        session_data = {
            "session_id": session_id,
            "user_id": user_id,
            "interview_type": interview_type,
            "platform": platform,
            "status": "completed",
            "score": overall_score,
            "date": session_date,
            "questions": responses,
            "overall_feedback": "Bonne performance générale. Continuez à travailler sur des exemples concrets."
        }
        
        return {
            "message": "Simulation d'entretien mockée démarrée avec succès",
            "session": session_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur lors de la simulation d'entretien: {str(e)}")
    
def start_interview_simulation(profile) :
    """Démarrer une simulation d'entretien"""
    print(f"Démarrage d'une simulation d'entretien pour {profile}...")
    
    # Récupérer le type d'entretien technique
    try:
        interview_type = InterviewType.objects.get(name="Technique")
    except InterviewType.DoesNotExist:
        print("Le type d'entretien 'Technique' n'existe pas.")
        return None
    
    # Récupérer la plateforme Huru.ai
    try:
        platform = CoachingPlatform.objects.get(name="Huru.ai")
    except CoachingPlatform.DoesNotExist:
        print("La plateforme 'Huru.ai' n'existe pas.")
        return None
    
    # Créer une session d'entretien
    session = InterviewSession.objects.create(
        profile=profile,
        platform=platform,
        interview_type=interview_type,
        session_date=timezone.now(),
        status='in_progress',
        session_notes=f"Simulation d'entretien technique pour {profile}"
    )
    print(f"Session d'entretien créée: {session}")
    
    # Récupérer des questions pour l'entretien
    questions = InterviewQuestion.objects.filter(interview_type=interview_type)[:3]
    
    if not questions:
        print("Aucune question trouvée pour ce type d'entretien.")
        return None
    
    print(f"Questions sélectionnées pour l'entretien:")
    for i, question in enumerate(questions):
        print(f"{i+1}. {question.question_text}")
        
        # Simuler une réponse
        response_text = f"Voici ma réponse à la question sur {question.question_text.split()[0:3]}... J'ai de l'expérience dans ce domaine et j'ai travaillé sur plusieurs projets liés. Par exemple, j'ai développé une application qui..."
        
        # Créer la réponse
        response = InterviewResponse.objects.create(
            session=session,
            question=question,
            response_text=response_text,
            response_time_seconds=random.randint(30, 120)
        )
        
        # Générer un feedback simple
        feedback = "Bonne réponse, mais vous pourriez donner plus d'exemples concrets."
        score = random.uniform(60, 90)
        
        # Mettre à jour la réponse avec le feedback
        response.feedback = feedback
        response.score = score
        response.save()
        
        print(f"   Réponse enregistrée avec un score de {score:.2f}")
    
    # Terminer la session
    session.status = 'completed'
    session.session_score = random.uniform(70, 90)
    session.session_feedback = "Bonne performance générale. Continuez à travailler sur des exemples concrets."
    session.save()
    
    print(f"Session d'entretien terminée avec un score de {session.session_score:.2f}")
    return session
    

# Stockage temporaire des profils en mémoire (exemple simplifié)
profiles = {}

# Clé API et ID de PhantomBuster
PHANTOMBUSTER_API_KEY = "Vz3MkhnQ2I7nplMLEYktO4mYjbeCKcUOnStivBWuejU"
PHANTOMBUSTER_AGENT_ID = "4611848888784137"

def get_linkedin_data_from_phantombuster(linkedin_url: str) -> dict:
    headers = {
        "X-Phantombuster-Key-1": PHANTOMBUSTER_API_KEY
    }

    payload = {
        "id": PHANTOMBUSTER_AGENT_ID,
        "arguments": {
            "profileUrls": [linkedin_url]
        }
    }

    response = requests.post(
        "https://api.phantombuster.com/api/v2/agents/launch",
        headers=headers,
        json=payload
    )

    if response.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Erreur PhantomBuster: {response.text}")

    data = response.json()
    try:
        return data["data"]["resultObject"]
    except KeyError:
        raise HTTPException(status_code=500, detail="Profil LinkedIn non trouvé dans la réponse PhantomBuster.")


@app.post("/import-linkedin")
def api_start_interview_simulationsdfdfds(linkedin_url: str = Query(...)):
    profile_data = get_linkedin_data_from_phantombuster(linkedin_url)

    required_fields = ['firstName', 'lastName', 'headline']
    for field in required_fields:
        if field not in profile_data:
            raise HTTPException(status_code=422, detail=f"Champ requis manquant: {field}")

    # Générer un ID unique pour le profil
    source_profile_id = str(uuid.uuid4())

    # Vérifier si un profil existe déjà en mémoire
    if source_profile_id in profiles:
        profile = profiles[source_profile_id]
        # Mise à jour
        profile.update({
            'first_name': profile_data['firstName'],
            'last_name': profile_data['lastName'],
            'headline': profile_data['headline'],
            'summary': profile_data.get('summary', ''),
            'location': profile_data.get('location', ''),
            'linkedin_url': linkedin_url,
        })
    else:
        # Créer un nouveau profil
        profile = {
            'source': 'linkedin',
            'source_profile_id': source_profile_id,
            'first_name': profile_data['firstName'],
            'last_name': profile_data['lastName'],
            'headline': profile_data['headline'],
            'summary': profile_data.get('summary', ''),
            'location': profile_data.get('location', ''),
            'linkedin_url': linkedin_url,
            'experiences': profile_data.get('experiences', []),
            'education': profile_data.get('education', []),
            'skills': profile_data.get('skills', [])
        }
        profiles[source_profile_id] = profile

    return {
        "status": "success",
        "message": f"Profil importé depuis LinkedIn : {profile['first_name']} {profile['last_name']}",
        "profile_id": source_profile_id,
        "profile_data": profile
    }



@app.get("/scrape-linkedin-profile")
def run_linkedin_scraper(profile_url: str = Query(..., description="LinkedIn profile URL to scrape")):
    """Run the LinkedIn profile scraper with a specified profile URL"""
    try:
        profile_data = scrape_linkedin_profile(profile_url)
        app.state.profile_data = profile_data
        if profile_data:
            return profile_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
@app.get("/match-jobs-Linkdin")
def match_jobs_apiLinkdin():
    if not hasattr(app.state, 'profile_data'):
        raise HTTPException(status_code=400, detail="Scrapez un profil d'abord")
    
    driver = create_driver()
    try:
        driver.get("https://www.linkedin.com/jobs/search?keywords=&location=Tunisie")
        jobs = fetch_jobs(driver)
        
        # Get the profile data
        profile_data = app.state.profile_data
        
        # Ensure we're using the correct keys (French or English)
        if 'compétences' in profile_data or 'expériences' in profile_data:
            # French keys
            profile_data_for_matching = {
                'compétences': profile_data.get('compétences', []),
                'expériences': profile_data.get('expériences', [])
            }
        else:
            # English keys as fallback
            profile_data_for_matching = {
                'compétences': profile_data.get('skills', []),
                'expériences': profile_data.get('experiences', [])
            }
        
        best_jobs = match_jobsLinkdin(profile_data_for_matching, jobs)
        
        return {
            "best_jobs": best_jobs[:10],
            "total_matches": len(best_jobs)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        driver.quit()
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
