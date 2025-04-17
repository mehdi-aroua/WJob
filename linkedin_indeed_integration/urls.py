"""
URL configuration for linkedin_indeed_integration project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse

# Vue simple pour la page d'accueil
def home_view(request):
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>LinkedIn/Indeed Integration avec IA</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                line-height: 1.6;
                margin: 0;
                padding: 20px;
                max-width: 800px;
                margin: 0 auto;
                color: #333;
            }
            h1 { color: #2c3e50; }
            h2 { color: #3498db; }
            .endpoints {
                background: #f8f9fa;
                padding: 15px;
                border-radius: 4px;
                margin: 20px 0;
            }
            a {
                color: #3498db;
                text-decoration: none;
            }
            a:hover { text-decoration: underline; }
            .feature {
                margin-bottom: 20px;
                padding-bottom: 10px;
                border-bottom: 1px solid #eee;
            }
        </style>
    </head>
    <body>
        <h1>LinkedIn/Indeed Integration avec IA</h1>
        <p>Bienvenue sur notre plateforme d'intégration LinkedIn/Indeed avec des fonctionnalités d'IA pour l'analyse de profils, les recommandations de formation et le coaching d'entretien.</p>
        
        <div class="endpoints">
            <h2>API Endpoints disponibles :</h2>
            <ul>
                <li><a href="/api/profiles/">/api/profiles/</a> - Gestion des profils professionnels</li>
                <li><a href="/api/training/">/api/training/</a> - Recommandations de formation</li>
                <li><a href="/api/interviews/">/api/interviews/</a> - Coaching d'entretien</li>
            </ul>
        </div>
        
        <div class="feature">
            <h2>Importation de profils</h2>
            <p>Le système permet d'importer des profils depuis LinkedIn ou via des fichiers JSON personnalisés.</p>
        </div>
        
        <div class="feature">
            <h2>Recommandations de formation</h2>
            <p>Analyse des compétences et recommandations personnalisées de cours et certifications pour atteindre vos objectifs professionnels.</p>
        </div>
        
        <div class="feature">
            <h2>Coaching d'entretien</h2>
            <p>Simulation d'entretiens avec des questions adaptées à votre profil et évaluation automatique des réponses.</p>
        </div>
    </body>
    </html>
    """
    return HttpResponse(html_content)

urlpatterns = [
    path('', home_view, name='home'),  # Page d'accueil
    
    # API endpoints
    path('api/profiles/', include('profiles.api.urls')),
    path('api/training/', include('training_recommendations.api.urls')),
    path('api/interviews/', include('interview_coaching.api.urls')),
    
    # Authentication URLs
    path('api-auth/', include('rest_framework.urls')),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)