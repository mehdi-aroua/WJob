from django.db import models
from profiles.models import Profile


class CoachingPlatform(models.Model):
    """Model for interview coaching platforms like Huru.ai and CoachHub"""
    name = models.CharField(max_length=100)
    website = models.URLField()
    description = models.TextField(blank=True, null=True)
    is_free = models.BooleanField(default=False)
    logo = models.ImageField(upload_to='platform_logos/', blank=True, null=True)
    api_key = models.CharField(max_length=255, blank=True, null=True)
    api_endpoint = models.URLField(blank=True, null=True)
    
    def __str__(self):
        return self.name


class InterviewType(models.Model):
    """Model for different types of interviews"""
    name = models.CharField(max_length=100)  # e.g. Technical, Behavioral, HR, etc.
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return self.name


class InterviewQuestion(models.Model):
    """Model for storing interview questions"""
    DIFFICULTY_CHOICES = [
        ('easy', 'Easy'),
        ('medium', 'Medium'),
        ('hard', 'Hard'),
    ]
    
    question_text = models.TextField()
    interview_type = models.ForeignKey(InterviewType, on_delete=models.CASCADE, related_name='questions')
    difficulty = models.CharField(max_length=10, choices=DIFFICULTY_CHOICES, default='medium')
    ideal_answer = models.TextField(blank=True, null=True)  # Sample/ideal answer
    tips = models.TextField(blank=True, null=True)  # Tips for answering this question
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.question_text[:50]


class InterviewSession(models.Model):
    """Model for storing interview coaching sessions"""
    STATUS_CHOICES = [
        ('scheduled', 'Scheduled'),
        ('in_progress', 'In Progress'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='interview_sessions')
    platform = models.ForeignKey(CoachingPlatform, on_delete=models.CASCADE, related_name='sessions')
    interview_type = models.ForeignKey(InterviewType, on_delete=models.CASCADE, related_name='sessions')
    session_date = models.DateTimeField()
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='scheduled')
    session_notes = models.TextField(blank=True, null=True)  # Notes before the session
    session_feedback = models.TextField(blank=True, null=True)  # AI feedback after the session
    session_recording = models.FileField(upload_to='interview_recordings/', blank=True, null=True)
    session_transcript = models.TextField(blank=True, null=True)
    session_score = models.FloatField(null=True, blank=True)  # Score from 0-100
    external_session_id = models.CharField(max_length=255, blank=True, null=True)  # ID from external platform
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.profile} - {self.interview_type} Interview ({self.get_status_display()})"


class InterviewResponse(models.Model):
    """Model for storing responses to interview questions during a session"""
    session = models.ForeignKey(InterviewSession, on_delete=models.CASCADE, related_name='responses')
    question = models.ForeignKey(InterviewQuestion, on_delete=models.CASCADE, related_name='responses')
    response_text = models.TextField()
    response_audio = models.FileField(upload_to='interview_responses/', blank=True, null=True)
    feedback = models.TextField(blank=True, null=True)  # AI-generated feedback on the response
    score = models.FloatField(null=True, blank=True)  # Score from 0-100
    response_time_seconds = models.PositiveIntegerField(null=True, blank=True)  # How long it took to answer
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Response to: {self.question}"


class FeedbackCategory(models.Model):
    """Model for categorizing interview feedback"""
    name = models.CharField(max_length=100)  # e.g. Communication, Technical Knowledge, Body Language
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return self.name


class SessionFeedbackItem(models.Model):
    """Model for detailed feedback items for a session"""
    session = models.ForeignKey(InterviewSession, on_delete=models.CASCADE, related_name='feedback_items')
    category = models.ForeignKey(FeedbackCategory, on_delete=models.CASCADE, related_name='feedback_items')
    feedback_text = models.TextField()
    score = models.FloatField(null=True, blank=True)  # Category-specific score
    improvement_suggestion = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return f"{self.category} Feedback for {self.session}"
