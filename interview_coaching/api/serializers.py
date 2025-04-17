from rest_framework import serializers
from interview_coaching.models import (
    CoachingPlatform, InterviewType, InterviewQuestion,
    InterviewSession, InterviewResponse, FeedbackCategory,
    SessionFeedbackItem
)
from profiles.models import Profile  # Ajout de l'import manquant
from profiles.api.serializers import ProfileSerializer


class CoachingPlatformSerializer(serializers.ModelSerializer):
    class Meta:
        model = CoachingPlatform
        fields = ['id', 'name', 'website', 'description', 'is_free', 'logo']


class InterviewTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = InterviewType
        fields = ['id', 'name', 'description']


class InterviewQuestionSerializer(serializers.ModelSerializer):
    interview_type = InterviewTypeSerializer(read_only=True)
    interview_type_id = serializers.PrimaryKeyRelatedField(
        queryset=InterviewType.objects.all(),
        source='interview_type',
        write_only=True,
        required=False
    )
    
    class Meta:
        model = InterviewQuestion
        fields = [
            'id', 'question_text', 'interview_type', 'interview_type_id',
            'difficulty', 'ideal_answer', 'tips', 'created_at'
        ]


class InterviewResponseSerializer(serializers.ModelSerializer):
    question = InterviewQuestionSerializer(read_only=True)
    question_id = serializers.PrimaryKeyRelatedField(
        queryset=InterviewQuestion.objects.all(),
        source='question',
        write_only=True
    )
    
    class Meta:
        model = InterviewResponse
        fields = [
            'id', 'session', 'question', 'question_id', 'response_text',
            'response_audio', 'feedback', 'score', 'response_time_seconds',
            'created_at'
        ]
        read_only_fields = ['session', 'feedback', 'score']


class FeedbackCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = FeedbackCategory
        fields = ['id', 'name', 'description']


class SessionFeedbackItemSerializer(serializers.ModelSerializer):
    category = FeedbackCategorySerializer(read_only=True)
    
    class Meta:
        model = SessionFeedbackItem
        fields = [
            'id', 'session', 'category', 'feedback_text',
            'score', 'improvement_suggestion'
        ]
        read_only_fields = ['session']


class InterviewSessionSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer(read_only=True)
    profile_id = serializers.PrimaryKeyRelatedField(
        queryset=Profile.objects.all(),
        source='profile',
        write_only=True
    )
    platform = CoachingPlatformSerializer(read_only=True)
    platform_id = serializers.PrimaryKeyRelatedField(
        queryset=CoachingPlatform.objects.all(),
        source='platform',
        write_only=True
    )
    interview_type = InterviewTypeSerializer(read_only=True)
    interview_type_id = serializers.PrimaryKeyRelatedField(
        queryset=InterviewType.objects.all(),
        source='interview_type',
        write_only=True
    )
    responses = InterviewResponseSerializer(many=True, read_only=True)
    feedback_items = SessionFeedbackItemSerializer(many=True, read_only=True)
    
    class Meta:
        model = InterviewSession
        fields = [
            'id', 'profile', 'profile_id', 'platform', 'platform_id',
            'interview_type', 'interview_type_id', 'session_date', 'status',
            'session_notes', 'session_feedback', 'session_recording',
            'session_transcript', 'session_score', 'external_session_id',
            'created_at', 'updated_at', 'responses', 'feedback_items'
        ]


class InterviewSimulationSerializer(serializers.Serializer):
    profile_id = serializers.IntegerField()
    interview_type_id = serializers.IntegerField()
    job_title = serializers.CharField(required=False)
    job_description = serializers.CharField(required=False)
    difficulty = serializers.ChoiceField(
        choices=['easy', 'medium', 'hard'],
        default='medium'
    )
    num_questions = serializers.IntegerField(default=5)
    
    def validate(self, data):
        # In a real app, you might perform additional validations here
        return data