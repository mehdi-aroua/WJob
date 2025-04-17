from django.contrib import admin
from .models import Profile, Experience, Education, Skill, ProfileSkill


class ExperienceInline(admin.TabularInline):
    model = Experience
    extra = 1


class EducationInline(admin.TabularInline):
    model = Education
    extra = 1


class ProfileSkillInline(admin.TabularInline):
    model = ProfileSkill
    extra = 1


@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('first_name', 'last_name', 'source', 'location', 'created_at')
    list_filter = ('source', 'created_at')
    search_fields = ('first_name', 'last_name', 'email', 'headline')
    inlines = [ExperienceInline, EducationInline, ProfileSkillInline]


@admin.register(Skill)
class SkillAdmin(admin.ModelAdmin):
    list_display = ('name',)
    search_fields = ('name',)


admin.site.register(Experience)
admin.site.register(Education)
