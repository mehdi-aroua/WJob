from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),  # Add this line for the root URL
]
