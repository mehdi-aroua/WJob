from rest_framework import serializers
from ..models import Profile, Experience, Education, Skill, ProfileSkill

class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = ['id', 'name']

class ProfileSkillSerializer(serializers.ModelSerializer):
    skill = SkillSerializer(read_only=True)
    
    class Meta:
        model = ProfileSkill
        fields = ['id', 'skill', 'endorsements']

class ExperienceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Experience
        fields = ['id', 'title', 'company', 'location', 'start_date', 
                  'end_date', 'is_current', 'description']

class EducationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Education
        fields = ['id', 'institution', 'degree', 'field_of_study', 
                  'start_date', 'end_date', 'description']

class ProfileSerializer(serializers.ModelSerializer):
    experiences = ExperienceSerializer(many=True, read_only=True)
    educations = EducationSerializer(many=True, read_only=True)
    skills = serializers.SerializerMethodField()
    
    class Meta:
        model = Profile
        fields = ['id', 'name', 'email', 'phone', 'location', 'profile_url', 
                  'profile_picture', 'source', 'external_id', 'resume_text',
                  'imported_at', 'updated_at', 'experiences', 'educations', 'skills']
    
    def get_skills(self, obj):
        profile_skills = ProfileSkill.objects.filter(profile=obj)
        return ProfileSkillSerializer(profile_skills, many=True).data