from rest_framework import serializers
from training_recommendations.models import (
    TrainingPlatform, Course, Certification,
    CourseSkill, CertificationSkill, Recommendation
)
from profiles.api.serializers import SkillSerializer


class CourseSkillSerializer(serializers.ModelSerializer):
    """Sérialiseur pour le modèle intermédiaire CourseSkill"""
    skill = SkillSerializer(read_only=True)
    
    class Meta:
        model = CourseSkill
        fields = ['skill', 'relevance_score']


class TrainingPlatformSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainingPlatform
        fields = ['id', 'name', 'website', 'description', 'is_free', 'logo']


class CourseSerializer(serializers.ModelSerializer):
    platform = TrainingPlatformSerializer(read_only=True)
    platform_id = serializers.PrimaryKeyRelatedField(
        queryset=TrainingPlatform.objects.all(),
        source='platform',
        write_only=True
    )
    skills = CourseSkillSerializer(many=True, read_only=True)
    
    class Meta:
        model = Course
        fields = [
            'id', 'title', 'description', 'platform', 'platform_id',
            'url', 'image_url', 'level', 'price', 'duration_hours',
            'created_at', 'updated_at', 'skills', 'is_free'
        ]


class CertificationSkillSerializer(serializers.ModelSerializer):
    """Sérialiseur pour le modèle intermédiaire CertificationSkill"""
    skill = SkillSerializer(read_only=True)
    
    class Meta:
        model = CertificationSkill
        fields = ['skill', 'relevance_score']


class CertificationSerializer(serializers.ModelSerializer):
    skills = CertificationSkillSerializer(many=True, read_only=True)
    
    class Meta:
        model = Certification
        fields = [
            'id', 'name', 'provider', 'description',
            'url', 'cost', 'expiration_years', 'skills'
        ]


class RecommendationSerializer(serializers.ModelSerializer):
    course = CourseSerializer(read_only=True)
    certification = CertificationSerializer(read_only=True)
    
    class Meta:
        model = Recommendation
        fields = [
            'id', 'profile', 'course', 'certification',
            'recommendation_score', 'reason', 
            'created_at', 'viewed', 'saved'
        ]
        read_only_fields = ['profile', 'course', 'certification', 'recommendation_score', 'reason', 'created_at']


class SkillGapAnalysisSerializer(serializers.Serializer):
    profile_id = serializers.IntegerField()
    job_title = serializers.CharField(required=False)
    job_description = serializers.CharField(required=False)
    target_skills = serializers.ListField(
        child=serializers.CharField(),
        required=False
    )
    max_recommendations = serializers.IntegerField(default=5)
    
    def validate(self, data):
        # Validate that either job info or target skills are provided
        if not ('job_title' in data or 'job_description' in data or 'target_skills' in data):
            raise serializers.ValidationError(
                "You must provide either job_title, job_description, or target_skills"
            )
        return data