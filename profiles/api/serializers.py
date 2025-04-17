from rest_framework import serializers
from profiles.models import Profile, Experience, Education, Skill, ProfileSkill


class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model = Skill
        fields = ['id', 'name']


class ProfileSkillSerializer(serializers.ModelSerializer):
    skill = SkillSerializer(read_only=True)
    skill_id = serializers.PrimaryKeyRelatedField(
        queryset=Skill.objects.all(), 
        source='skill', 
        write_only=True
    )
    
    class Meta:
        model = ProfileSkill
        fields = ['id', 'skill', 'skill_id', 'endorsements']


class ExperienceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Experience
        fields = [
            'id', 'company', 'title', 'location', 'start_date', 
            'end_date', 'current', 'description'
        ]


class EducationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Education
        fields = [
            'id', 'institution', 'degree', 'field_of_study', 
            'start_date', 'end_date', 'current', 'description'
        ]


class ProfileSerializer(serializers.ModelSerializer):
    experiences = ExperienceSerializer(many=True, required=False)
    education = EducationSerializer(many=True, required=False)
    skills = ProfileSkillSerializer(many=True, required=False)
    
    class Meta:
        model = Profile
        fields = [
            'id', 'source', 'source_profile_id',
            'first_name', 'last_name', 'email', 'phone',
            'headline', 'summary', 'location', 'profile_picture',
            'linkedin_url', 'indeed_url', 'portfolio_url',
            'created_at', 'updated_at', 'experiences', 'education', 'skills'
        ]
    
    def create(self, validated_data):
        experiences_data = validated_data.pop('experiences', [])
        education_data = validated_data.pop('education', [])
        skills_data = validated_data.pop('skills', [])
        
        profile = Profile.objects.create(**validated_data)
        
        # Create experiences
        for experience_data in experiences_data:
            Experience.objects.create(profile=profile, **experience_data)
        
        # Create education entries
        for education_item in education_data:
            Education.objects.create(profile=profile, **education_item)
        
        # Create skills
        for skill_data in skills_data:
            skill = skill_data.pop('skill')
            ProfileSkill.objects.create(profile=profile, skill=skill, **skill_data)
        
        return profile
    
    def update(self, instance, validated_data):
        experiences_data = validated_data.pop('experiences', [])
        education_data = validated_data.pop('education', [])
        skills_data = validated_data.pop('skills', [])
        
        # Update profile fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Handle nested data (simplified - in production would need to handle updates and deletions)
        if experiences_data:
            instance.experiences.all().delete()
            for experience_data in experiences_data:
                Experience.objects.create(profile=instance, **experience_data)
        
        if education_data:
            instance.education.all().delete()
            for education_item in education_data:
                Education.objects.create(profile=instance, **education_item)
        
        if skills_data:
            instance.skills.all().delete()
            for skill_data in skills_data:
                skill = skill_data.pop('skill')
                ProfileSkill.objects.create(profile=instance, skill=skill, **skill_data)
        
        return instance


class LinkedInProfileImportSerializer(serializers.Serializer):
    linkedin_url = serializers.URLField(required=False)
    linkedin_profile_id = serializers.CharField(required=False)
    access_token = serializers.CharField(required=False)
    
    def validate(self, data):
        if not ('linkedin_url' in data or 'linkedin_profile_id' in data):
            raise serializers.ValidationError("Either linkedin_url or linkedin_profile_id must be provided")
        return data


class IndeedProfileImportSerializer(serializers.Serializer):
    indeed_url = serializers.URLField(required=False)
    indeed_resume_id = serializers.CharField(required=False)
    access_token = serializers.CharField(required=False)
    
    def validate(self, data):
        if not ('indeed_url' in data or 'indeed_resume_id' in data):
            raise serializers.ValidationError("Either indeed_url or indeed_resume_id must be provided")
        return data