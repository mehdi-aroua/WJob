from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    CoachingPlatformViewSet, InterviewTypeViewSet,
    InterviewQuestionViewSet, InterviewSessionViewSet,
    InterviewResponseViewSet
)

router = DefaultRouter()
router.register(r'platforms', CoachingPlatformViewSet)
router.register(r'interview-types', InterviewTypeViewSet)
router.register(r'questions', InterviewQuestionViewSet)
router.register(r'sessions', InterviewSessionViewSet)
router.register(r'responses', InterviewResponseViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
