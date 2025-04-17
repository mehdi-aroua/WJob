from django.contrib import admin
from .models import (
    TrainingPlatform, Course, Certification,
    CourseSkill, CertificationSkill, Recommendation
)


class CourseSkillInline(admin.TabularInline):
    model = CourseSkill
    extra = 1


class CertificationSkillInline(admin.TabularInline):
    model = CertificationSkill
    extra = 1


@admin.register(TrainingPlatform)
class TrainingPlatformAdmin(admin.ModelAdmin):
    list_display = ('name', 'website', 'is_free')
    list_filter = ('is_free',)
    search_fields = ('name', 'website', 'description')


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('title', 'platform', 'level', 'price', 'is_free')
    list_filter = ('platform', 'level')
    search_fields = ('title', 'description')
    inlines = [CourseSkillInline]


@admin.register(Certification)
class CertificationAdmin(admin.ModelAdmin):
    list_display = ('name', 'provider', 'cost')
    list_filter = ('provider',)
    search_fields = ('name', 'provider', 'description')
    inlines = [CertificationSkillInline]


@admin.register(Recommendation)
class RecommendationAdmin(admin.ModelAdmin):
    list_display = ('profile', 'get_recommendation_type', 'recommendation_score', 'created_at', 'viewed', 'saved')
    list_filter = ('viewed', 'saved', 'created_at')
    search_fields = ('profile__first_name', 'profile__last_name', 'reason')
    
    def get_recommendation_type(self, obj):
        if obj.course:
            return f"Course: {obj.course}"
        elif obj.certification:
            return f"Certification: {obj.certification}"
        return "Unknown"
    get_recommendation_type.short_description = 'Recommendation Type'
