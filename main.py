"""
Script principal pour tester les fonctionnalités du système d'intégration LinkedIn/Indeed
avec recommandations de formation et coaching IA pour entretiens.

Ce script permet de tester rapidement les différentes fonctionnalités sans passer par l'API.
"""

import os
import sys
import django
import json
import random
from datetime import datetime, timedelta
import argparse
from django.utils import timezone

# Configurer Django
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
        if created:
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


def start_interview_simulation(profile):
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


def main():
    """Fonction principale pour tester les fonctionnalités"""
    parser = argparse.ArgumentParser(description='Testeur pour le système d\'intégration LinkedIn/Indeed')
    parser.add_argument('--init', action='store_true', help='Initialiser les données de test')
    parser.add_argument('--import-profile', type=int, default=0, help='Importer un profil LinkedIn fictif (numéro du profil)')
    parser.add_argument('--json-file', type=str, help='Chemin vers un fichier JSON contenant un profil à importer')
    parser.add_argument('--recommend', action='store_true', help='Générer des recommandations de formation')
    parser.add_argument('--interview', action='store_true', help='Démarrer une simulation d\'entretien')
    parser.add_argument('--all', action='store_true', help='Exécuter toutes les fonctionnalités')
    
    args = parser.parse_args()
    
    # Si aucune option n'est spécifiée, afficher l'aide
    if not any(vars(args).values()):
        parser.print_help()
        return
    
    # Initialiser les données de test
    if args.init or args.all:
        create_test_data()
    
    profile = None
    
    # Importer un profil depuis un fichier JSON
    if args.json_file:
        profile = import_profile_from_json(args.json_file)
    # Importer un profil LinkedIn fictif
    elif args.import_profile > 0 or args.all:
        profile = import_dummy_linkedin_profile(args.import_profile if args.import_profile > 0 else 1)
    
    # Si aucun profil n'a été importé mais nécessaire pour la suite
    if (args.recommend or args.interview or args.all) and not profile:
        profiles = Profile.objects.all()
        if profiles:
            profile = profiles.first()
            print(f"Utilisation du profil existant: {profile}")
        else:
            print("Aucun profil disponible. Importation d'un profil fictif...")
            profile = import_dummy_linkedin_profile()
    
    # Générer des recommandations de formation
    if (args.recommend or args.all) and profile:
        generate_training_recommendations(profile)
    
    # Démarrer une simulation d'entretien
    if (args.interview or args.all) and profile:
        start_interview_simulation(profile)
    
    print("Tests terminés avec succès!")


if __name__ == "__main__":
    main()