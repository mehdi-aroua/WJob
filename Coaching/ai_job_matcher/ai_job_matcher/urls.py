"""
URL configuration for ai_job_matcher project.

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
# ai_job_matcher/urls.py

from django.contrib import admin
from django.urls import path, include
from coaching import views  # Assure-toi d'importer la vue home

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', views.home, name='home'),  # Lien avec la vue home
    path('coaching/', include('coaching.urls')),  # Lien vers les URLs de l'application coaching
]

