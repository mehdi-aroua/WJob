from django.db import models
from django.contrib.auth.models import User
import json

class Profile(models.Model):
    """Modèle pour stocker les profils importés de LinkedIn ou Indeed"""
    SOURCE_CHOICES = (
        ('linkedin', 'LinkedIn'),
        ('indeed', 'Indeed'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='profiles')
    source = models.CharField(max_length=10, choices=SOURCE_CHOICES)
    profile_id = models.CharField(max_length=255, blank=True, null=True)
    full_name = models.CharField(max_length=255)
    email = models.EmailField(blank=True, null=True)
    profile_url = models.URLField(blank=True, null=True)
    current_position = models.CharField(max_length=255, blank=True, null=True)
    location = models.CharField(max_length=255, blank=True, null=True)
    industry = models.CharField(max_length=255, blank=True, null=True)
    summary = models.TextField(blank=True, null=True)
    raw_data = models.TextField(blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    imported_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.full_name} ({self.source})"
    
    def set_raw_data(self, data_dict):
        """Convertit les données brutes en JSON"""
        self.raw_data = json.dumps(data_dict)
    
    def get_raw_data(self):
        """Récupère les données brutes du JSON"""
        if self.raw_data:
            return json.loads(self.raw_data)
        return {}


class Experience(models.Model):
    """Modèle pour stocker les expériences professionnelles des profils"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='experiences')
    title = models.CharField(max_length=255)
    company = models.CharField(max_length=255)
    location = models.CharField(max_length=255, blank=True, null=True)
    start_date = models.DateField(blank=True, null=True)
    end_date = models.DateField(blank=True, null=True)
    is_current = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.title} at {self.company}"


class Education(models.Model):
    """Modèle pour stocker les formations des profils"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='education')
    school = models.CharField(max_length=255)
    degree = models.CharField(max_length=255, blank=True, null=True)
    field_of_study = models.CharField(max_length=255, blank=True, null=True)
    start_date = models.DateField(blank=True, null=True)
    end_date = models.DateField(blank=True, null=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.degree} in {self.field_of_study} from {self.school}"


class Skill(models.Model):
    """Modèle pour stocker les compétences des profils"""
    name = models.CharField(max_length=255, unique=True)
    
    def __str__(self):
        return self.name


class ProfileSkill(models.Model):
    """Table de liaison entre profils et compétences"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='profile_skills')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE)
    endorsement_count = models.IntegerField(default=0)
    
    class Meta:
        unique_together = ('profile', 'skill')
    
    def __str__(self):
        return f"{self.profile.full_name} - {self.skill.name}"


class ImportTask(models.Model):
    """Modèle pour suivre les importations de profils"""
    STATUS_CHOICES = (
        ('pending', 'En attente'),
        ('in_progress', 'En cours'),
        ('completed', 'Terminé'),
        ('failed', 'Échoué'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    source = models.CharField(max_length=10, choices=Profile.SOURCE_CHOICES)
    search_query = models.CharField(max_length=255, blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    profiles_count = models.IntegerField(default=0)
    error_message = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return f"{self.source} import - {self.status} ({self.profiles_count} profiles)"
