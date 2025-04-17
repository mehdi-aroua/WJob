from django.db import models
from profiles.models import Profile, Skill


class TrainingPlatform(models.Model):
    """Model for storing training platforms such as My Mooc, Udemy etc."""
    name = models.CharField(max_length=100)
    website = models.URLField()
    description = models.TextField(blank=True, null=True)
    is_free = models.BooleanField(default=False)
    logo = models.ImageField(upload_to='platform_logos/', blank=True, null=True)
    api_key = models.CharField(max_length=255, blank=True, null=True)
    
    def __str__(self):
        return self.name


class Course(models.Model):
    """Model for storing courses from different platforms"""
    COURSE_LEVEL_CHOICES = [
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced'),
        ('all_levels', 'All Levels'),
    ]
    
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    platform = models.ForeignKey(TrainingPlatform, on_delete=models.CASCADE, related_name='courses')
    url = models.URLField()
    image_url = models.URLField(blank=True, null=True)
    level = models.CharField(max_length=20, choices=COURSE_LEVEL_CHOICES, default='all_levels')
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)  # Null if free
    duration_hours = models.PositiveIntegerField(null=True, blank=True)
    course_id_on_platform = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.title
    
    @property
    def is_free(self):
        return self.price is None or self.price == 0


class CourseSkill(models.Model):
    """Model for mapping skills to courses"""
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='skills')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE, related_name='courses')
    relevance_score = models.FloatField(default=1.0)  # Scale of 0-1, how relevant is the course for the skill
    
    class Meta:
        unique_together = ('course', 'skill')
    
    def __str__(self):
        return f"{self.skill.name} - {self.course.title}"


class Certification(models.Model):
    """Model for storing certification information"""
    name = models.CharField(max_length=200)
    provider = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    url = models.URLField(blank=True, null=True)
    cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    expiration_years = models.PositiveIntegerField(null=True, blank=True)  # How many years before it expires
    
    def __str__(self):
        return f"{self.name} by {self.provider}"


class CertificationSkill(models.Model):
    """Model for mapping skills to certifications"""
    certification = models.ForeignKey(Certification, on_delete=models.CASCADE, related_name='skills')
    skill = models.ForeignKey(Skill, on_delete=models.CASCADE, related_name='certifications')
    relevance_score = models.FloatField(default=1.0)
    
    class Meta:
        unique_together = ('certification', 'skill')
    
    def __str__(self):
        return f"{self.skill.name} - {self.certification.name}"


class Recommendation(models.Model):
    """Model for storing personalized training recommendations"""
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='recommendations')
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='recommendations', null=True, blank=True)
    certification = models.ForeignKey(Certification, on_delete=models.CASCADE, related_name='recommendations', null=True, blank=True)
    recommendation_score = models.FloatField()  # Higher score means more recommended
    reason = models.TextField()  # AI-generated explanation for the recommendation
    created_at = models.DateTimeField(auto_now_add=True)
    viewed = models.BooleanField(default=False)
    saved = models.BooleanField(default=False)
    
    class Meta:
        unique_together = [
            ('profile', 'course'),
            ('profile', 'certification')
        ]
    
    def __str__(self):
        if self.course:
            return f"{self.profile} - {self.course}"
        return f"{self.profile} - {self.certification}"
