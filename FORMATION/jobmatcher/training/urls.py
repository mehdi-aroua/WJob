from django.urls import path
from .views import recommend_courses

urlpatterns = [
    path('recommendations/<int:user_id>/', recommend_courses, name='recommend_courses'),
]
