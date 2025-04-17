from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
import logging
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from profiles.models import Profile, Skill, ProfileSkill
from training_recommendations.models import (
    TrainingPlatform, Course, Certification,
    CourseSkill, CertificationSkill, Recommendation
)
from .serializers import (
    TrainingPlatformSerializer, CourseSerializer, 
    CertificationSerializer, RecommendationSerializer,
    SkillGapAnalysisSerializer
)

logger = logging.getLogger(__name__)


class TrainingPlatformViewSet(viewsets.ModelViewSet):
    """
    API endpoint for training platforms like MyMooc and Udemy
    """
    queryset = TrainingPlatform.objects.all()
    serializer_class = TrainingPlatformSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public


class CourseViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing courses
    """
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def get_queryset(self):
        queryset = Course.objects.all()
        
        # Filter by platform
        platform_id = self.request.query_params.get('platform_id', None)
        if platform_id:
            queryset = queryset.filter(platform_id=platform_id)
        
        # Filter by price (free/paid)
        is_free = self.request.query_params.get('is_free', None)
        if is_free:
            is_free = is_free.lower() == 'true'
            # For free courses, price is NULL or 0
            if is_free:
                queryset = queryset.filter(price__isnull=True) | queryset.filter(price=0)
            else:
                queryset = queryset.exclude(price__isnull=True).exclude(price=0)
        
        # Filter by skill
        skill = self.request.query_params.get('skill', None)
        if skill:
            queryset = queryset.filter(skills__skill__name__icontains=skill)
        
        # Filter by level
        level = self.request.query_params.get('level', None)
        if level:
            queryset = queryset.filter(level=level)
        
        return queryset


class CertificationViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing certifications
    """
    queryset = Certification.objects.all()
    serializer_class = CertificationSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def get_queryset(self):
        queryset = Certification.objects.all()
        
        # Filter by provider
        provider = self.request.query_params.get('provider', None)
        if provider:
            queryset = queryset.filter(provider__icontains=provider)
        
        # Filter by skill
        skill = self.request.query_params.get('skill', None)
        if skill:
            queryset = queryset.filter(skills__skill__name__icontains=skill)
        
        return queryset


class RecommendationViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing recommendations
    """
    queryset = Recommendation.objects.all()
    serializer_class = RecommendationSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def get_queryset(self):
        queryset = Recommendation.objects.all()
        
        # Filter by profile
        profile_id = self.request.query_params.get('profile_id', None)
        if profile_id:
            queryset = queryset.filter(profile_id=profile_id)
        
        # Filter by viewed status
        viewed = self.request.query_params.get('viewed', None)
        if viewed is not None:
            viewed = viewed.lower() == 'true'
            queryset = queryset.filter(viewed=viewed)
        
        # Filter by saved status
        saved = self.request.query_params.get('saved', None)
        if saved is not None:
            saved = saved.lower() == 'true'
            queryset = queryset.filter(saved=saved)
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def mark_viewed(self, request, pk=None):
        """
        Mark a recommendation as viewed
        """
        recommendation = self.get_object()
        recommendation.viewed = True
        recommendation.save()
        return Response({'status': 'recommendation marked as viewed'})
    
    @action(detail=True, methods=['post'])
    def toggle_saved(self, request, pk=None):
        """
        Toggle the saved status of a recommendation
        """
        recommendation = self.get_object()
        recommendation.saved = not recommendation.saved
        recommendation.save()
        return Response({'status': 'recommendation saved status toggled', 'saved': recommendation.saved})
    
    @action(detail=False, methods=['post'], serializer_class=SkillGapAnalysisSerializer)
    def analyze_skills_gap(self, request):
        """
        Analyze skills gap and generate recommendations
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            profile_id = serializer.validated_data['profile_id']
            job_title = serializer.validated_data.get('job_title', '')
            job_description = serializer.validated_data.get('job_description', '')
            target_skills = serializer.validated_data.get('target_skills', [])
            max_recommendations = serializer.validated_data.get('max_recommendations', 5)
            
            # Get profile and current skills
            try:
                profile = Profile.objects.get(pk=profile_id)
            except Profile.DoesNotExist:
                return Response(
                    {"error": f"Profile with id {profile_id} not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            current_skills = set(ps.skill.name for ps in ProfileSkill.objects.filter(profile=profile))
            
            # Identify missing skills
            missing_skills = []
            
            # Case 1: User provided target skills directly
            if target_skills:
                missing_skills = [skill for skill in target_skills if skill not in current_skills]
            
            # Case 2: User provided job info - use NLP to extract skills
            elif job_title or job_description:
                # In a real application, you would use a more sophisticated model
                # Here we're using a simple TF-IDF approach for demonstration
                skill_corpus = [skill.name for skill in Skill.objects.all()]
                
                if not skill_corpus:
                    return Response(
                        {"error": "No skills found in the database for comparison"},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                
                # Create job text
                job_text = f"{job_title} {job_description}"
                
                # Extract potential skills from job text
                vectorizer = TfidfVectorizer(stop_words='english')
                tfidf_matrix = vectorizer.fit_transform(skill_corpus + [job_text])
                
                # Calculate similarity between job text and each skill
                doc_similarities = cosine_similarity(tfidf_matrix[-1:], tfidf_matrix[:-1])[0]
                
                # Get skills that are likely mentioned in the job description
                relevant_skill_indices = np.where(doc_similarities > 0.1)[0]  # Threshold can be adjusted
                relevant_skills = [skill_corpus[i] for i in relevant_skill_indices]
                
                # Find which skills are missing from the profile
                missing_skills = [skill for skill in relevant_skills if skill not in current_skills]
            
            # Get courses and certifications that teach these missing skills
            recommendations = []
            
            # Look for courses that teach the missing skills
            for skill_name in missing_skills:
                try:
                    skill = Skill.objects.get(name=skill_name)
                except Skill.DoesNotExist:
                    # Create the skill if it doesn't exist
                    skill = Skill.objects.create(name=skill_name)
                
                # Find courses for this skill
                course_skills = CourseSkill.objects.filter(
                    skill=skill
                ).order_by('-relevance_score')[:5]  # Top 5 most relevant courses
                
                for course_skill in course_skills:
                    course = course_skill.course
                    
                    # Generate AI reason (in a real app, you'd use LLM for better explanations)
                    reason = (
                        f"This course teaches {skill_name}, which is a skill you may need "
                        f"based on your profile and target job. "
                        f"The course has a relevance score of {course_skill.relevance_score:.2f} for this skill."
                    )
                    
                    # Create recommendation
                    recommendation = Recommendation.objects.create(
                        profile=profile,
                        course=course,
                        certification=None,
                        recommendation_score=course_skill.relevance_score,
                        reason=reason
                    )
                    recommendations.append(recommendation)
                
                # Find certifications for this skill
                cert_skills = CertificationSkill.objects.filter(
                    skill=skill
                ).order_by('-relevance_score')[:3]  # Top 3 most relevant certifications
                
                for cert_skill in cert_skills:
                    certification = cert_skill.certification
                    
                    # Generate AI reason
                    reason = (
                        f"This certification validates your knowledge of {skill_name}, "
                        f"which is a skill you may need based on your profile and target job. "
                        f"The certification has a relevance score of {cert_skill.relevance_score:.2f} for this skill."
                    )
                    
                    # Create recommendation
                    recommendation = Recommendation.objects.create(
                        profile=profile,
                        course=None,
                        certification=certification,
                        recommendation_score=cert_skill.relevance_score,
                        reason=reason
                    )
                    recommendations.append(recommendation)
            
            # Sort by recommendation score and limit to max_recommendations
            recommendations = sorted(
                recommendations, 
                key=lambda r: r.recommendation_score, 
                reverse=True
            )[:max_recommendations]
            
            # Return serialized recommendations
            return Response(
                RecommendationSerializer(recommendations, many=True).data,
                status=status.HTTP_200_OK
            )
            
        except Exception as e:
            logger.error(f"Error generating recommendations: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)