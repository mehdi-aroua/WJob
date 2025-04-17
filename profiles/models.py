from django.db import models
from django.contrib.auth.models import User


class Profile(models.Model):
    """Model for storing imported LinkedIn/Indeed profiles"""
    SOURCE_CHOICES = [
        ('linkedin', 'LinkedIn'),
        ('indeed', 'Indeed'),
        ('manual', 'Manual Entry'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)
    source = models.CharField(max_length=10, choices=SOURCE_CHOICES, default='manual')
    source_profile_id = models.CharField(max_length=255, blank=True, null=True)
    
    # Basic information
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    headline = models.CharField(max_length=255, blank=True, null=True)
    summary = models.TextField(blank=True, null=True)
    location = models.CharField(max_length=100, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    
    # Profile URLs
    linkedin_url = models.URLField(blank=True, null=True)
    indeed_url = models.URLField(blank=True, null=True)
    portfolio_url = models.URLField(blank=True, null=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.first_name} {self.last_name}"


class Experience(models.Model):
    """Model for storing work experience"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='experiences')
    company = models.CharField(max_length=100)
    title = models.CharField(max_length=100)
    location = models.CharField(max_length=100, blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField(blank=True, null=True)
    current = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return f"{self.title} at {self.company}"


class Education(models.Model):
    """Model for storing education information"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='education')
    institution = models.CharField(max_length=100)
    degree = models.CharField(max_length=100, blank=True, null=True)
    field_of_study = models.CharField(max_length=100, blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField(blank=True, null=True)
    current = models.BooleanField(default=False)
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return f"{self.degree} at {self.institution}"


class Skill(models.Model):
    """Model for storing skills"""
    name = models.CharField(max_length=100, unique=True)
    
    def __str__(self):
        return self.name


class ProfileSkill(models.Model):
    """Model for storing profile skills with endorsements"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='skills')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE, related_name='profiles')
    endorsements = models.IntegerField(default=0)
    
    class Meta:
        unique_together = ('profile', 'skill')
    
    def __str__(self):
        return f"{self.skill.name} ({self.endorsements} endorsements)"
