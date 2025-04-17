from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    TrainingPlatformViewSet, CourseViewSet, 
    CertificationViewSet, RecommendationViewSet
)

router = DefaultRouter()
router.register(r'platforms', TrainingPlatformViewSet)
router.register(r'courses', CourseViewSet)
router.register(r'certifications', CertificationViewSet)
router.register(r'recommendations', RecommendationViewSet)

urlpatterns = [
    path('', include(router.urls)),
]