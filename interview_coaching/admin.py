from django.contrib import admin
from .models import (
    CoachingPlatform, InterviewType, InterviewQuestion,
    InterviewSession, InterviewResponse, FeedbackCategory,
    SessionFeedbackItem
)


class InterviewResponseInline(admin.TabularInline):
    model = InterviewResponse
    extra = 1
    readonly_fields = ('feedback', 'score')


class SessionFeedbackItemInline(admin.TabularInline):
    model = SessionFeedbackItem
    extra = 1
    readonly_fields = ('score',)


@admin.register(CoachingPlatform)
class CoachingPlatformAdmin(admin.ModelAdmin):
    list_display = ('name', 'website', 'is_free')
    list_filter = ('is_free',)
    search_fields = ('name', 'description')


@admin.register(InterviewType)
class InterviewTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name', 'description')


@admin.register(InterviewQuestion)
class InterviewQuestionAdmin(admin.ModelAdmin):
    list_display = ('question_text_short', 'interview_type', 'difficulty', 'created_at')
    list_filter = ('interview_type', 'difficulty', 'created_at')
    search_fields = ('question_text', 'ideal_answer', 'tips')
    
    def question_text_short(self, obj):
        return obj.question_text[:50] + "..." if len(obj.question_text) > 50 else obj.question_text
    question_text_short.short_description = 'Question'


@admin.register(InterviewSession)
class InterviewSessionAdmin(admin.ModelAdmin):
    list_display = ('profile', 'interview_type', 'platform', 'session_date', 'status', 'session_score')
    list_filter = ('status', 'platform', 'interview_type', 'session_date')
    search_fields = ('profile__first_name', 'profile__last_name', 'session_notes', 'session_feedback')
    readonly_fields = ('session_score',)
    inlines = [InterviewResponseInline, SessionFeedbackItemInline]


@admin.register(InterviewResponse)
class InterviewResponseAdmin(admin.ModelAdmin):
    list_display = ('session', 'question_short', 'score', 'response_time_seconds', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('response_text', 'feedback')
    readonly_fields = ('feedback', 'score')
    
    def question_short(self, obj):
        return obj.question.question_text[:50] + "..." if len(obj.question.question_text) > 50 else obj.question.question_text
    question_short.short_description = 'Question'


@admin.register(FeedbackCategory)
class FeedbackCategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name', 'description')


admin.site.register(SessionFeedbackItem)
