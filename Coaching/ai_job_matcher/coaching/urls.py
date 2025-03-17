from django.urls import path
from . import views

urlpatterns = [
    path('mock_interview/', views.mock_interview, name='mock_interview'),
    path('submit_answers/', views.submit_answers, name='submit_answers'),
    path('coaching_recommendation/', views.coaching_recommendation, name='coaching_recommendation'),
]
