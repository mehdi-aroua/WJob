from django.urls import path # type: ignore
from . import views
urlpatterns = [
    path('', views.index, name='index'),
    path('upload/', views.upload_cv, name='upload_cv'),
    path('resume/<int:pk>/', views.resume_detail, name='resume_detail'),
]
