from django.urls import path
from .views import home, get_indeed_profiles, get_linkedin_profile

urlpatterns = [
    path('', home, name='home'),  # Page d’accueil API
    path('indeed-profiles/', get_indeed_profiles, name='indeed-profiles'),
    path('linkedin-profile/', get_linkedin_profile, name='linkedin-profile'),
]
