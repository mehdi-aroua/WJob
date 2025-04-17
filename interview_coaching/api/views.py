from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
import logging
import datetime
import random
from django.utils import timezone

from profiles.models import Profile
from interview_coaching.models import (
    CoachingPlatform, InterviewType, InterviewQuestion,
    InterviewSession, InterviewResponse, FeedbackCategory,
    SessionFeedbackItem
)
from .serializers import (
    CoachingPlatformSerializer, InterviewTypeSerializer,
    InterviewQuestionSerializer, InterviewSessionSerializer,
    InterviewResponseSerializer, FeedbackCategorySerializer,
    SessionFeedbackItemSerializer, InterviewSimulationSerializer
)

logger = logging.getLogger(__name__)


class CoachingPlatformViewSet(viewsets.ModelViewSet):
    """
    API endpoint for coaching platforms like Huru.ai and CoachHub
    """
    queryset = CoachingPlatform.objects.all().order_by('id')
    serializer_class = CoachingPlatformSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public


class InterviewTypeViewSet(viewsets.ModelViewSet):
    """
    API endpoint for interview types (Technical, Behavioral, etc.)
    """
    queryset = InterviewType.objects.all()
    serializer_class = InterviewTypeSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public


class InterviewQuestionViewSet(viewsets.ModelViewSet):
    """
    API endpoint for interview questions
    """
    queryset = InterviewQuestion.objects.all()
    serializer_class = InterviewQuestionSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def get_queryset(self):
        queryset = InterviewQuestion.objects.all()
        
        # Filter by interview type
        interview_type_id = self.request.query_params.get('interview_type_id', None)
        if interview_type_id:
            queryset = queryset.filter(interview_type_id=interview_type_id)
        
        # Filter by difficulty
        difficulty = self.request.query_params.get('difficulty', None)
        if difficulty:
            queryset = queryset.filter(difficulty=difficulty)
        
        return queryset


class InterviewSessionViewSet(viewsets.ModelViewSet):
    """
    API endpoint for interview sessions
    """
    queryset = InterviewSession.objects.all()
    serializer_class = InterviewSessionSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def get_queryset(self):
        queryset = InterviewSession.objects.all()
        
        # Filter by profile
        profile_id = self.request.query_params.get('profile_id', None)
        if profile_id:
            queryset = queryset.filter(profile_id=profile_id)
        
        # Filter by interview type
        interview_type_id = self.request.query_params.get('interview_type_id', None)
        if interview_type_id:
            queryset = queryset.filter(interview_type_id=interview_type_id)
        
        # Filter by status
        status_param = self.request.query_params.get('status', None)
        if status_param:
            queryset = queryset.filter(status=status_param)
        
        # Filter by date range
        start_date = self.request.query_params.get('start_date', None)
        end_date = self.request.query_params.get('end_date', None)
        if start_date and end_date:
            queryset = queryset.filter(session_date__range=[start_date, end_date])
        
        return queryset
    
    @action(detail=False, methods=['post'], serializer_class=InterviewSimulationSerializer)
    def start_simulation(self, request):
        """
        Start a new interview simulation
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            profile_id = serializer.validated_data['profile_id']
            interview_type_id = serializer.validated_data['interview_type_id']
            difficulty = serializer.validated_data.get('difficulty', 'medium')
            num_questions = serializer.validated_data.get('num_questions', 5)
            job_title = serializer.validated_data.get('job_title', '')
            job_description = serializer.validated_data.get('job_description', '')
            
            # Get profile and interview type
            try:
                profile = Profile.objects.get(pk=profile_id)
            except Profile.DoesNotExist:
                return Response(
                    {"error": f"Profile with id {profile_id} not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
                
            try:
                interview_type = InterviewType.objects.get(pk=interview_type_id)
            except InterviewType.DoesNotExist:
                return Response(
                    {"error": f"Interview type with id {interview_type_id} not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # For now, we'll use Huru.ai as the default platform (in a real app, user would choose)
            # Or create it if it doesn't exist
            platform, created = CoachingPlatform.objects.get_or_create(
                name='Huru.ai',
                defaults={
                    'website': 'https://huru.ai',
                    'description': 'Free AI-powered interview coaching',
                    'is_free': True
                }
            )
            
            # Create a new interview session
            session = InterviewSession.objects.create(
                profile=profile,
                platform=platform,
                interview_type=interview_type,
                session_date=timezone.now(),
                status='in_progress',
                session_notes=f"Interview simulation for {job_title if job_title else 'general position'}",
            )
            
            # Get questions for the simulation
            # In a real app, you would use an AI to generate personalized questions
            # based on the job title, description, and profile skills
            questions = InterviewQuestion.objects.filter(
                interview_type=interview_type,
                difficulty=difficulty
            )
            
            # If we don't have enough questions, generate some placeholder questions
            if questions.count() < num_questions:
                # Create some placeholder questions based on job title if provided
                placeholder_questions = [
                    f"Tell me about your experience with {profile.skills.all()[i].skill.name if profile.skills.count() > i else 'this skill'}" 
                    for i in range(3)
                ]
                
                if job_title:
                    placeholder_questions.extend([
                        f"Why are you interested in this {job_title} position?",
                        f"What relevant experience do you have for this {job_title} role?",
                        f"How would you handle a challenging situation as a {job_title}?"
                    ])
                else:
                    placeholder_questions.extend([
                        "Tell me about yourself.",
                        "What are your strengths and weaknesses?",
                        "Where do you see yourself in five years?"
                    ])
                
                # Create these questions in the database
                for q_text in placeholder_questions:
                    InterviewQuestion.objects.create(
                        question_text=q_text,
                        interview_type=interview_type,
                        difficulty=difficulty
                    )
                
                # Refresh questions queryset
                questions = InterviewQuestion.objects.filter(
                    interview_type=interview_type,
                    difficulty=difficulty
                )
            
            # Select random questions up to num_questions
            if questions.count() > num_questions:
                question_ids = list(questions.values_list('id', flat=True))
                selected_ids = random.sample(question_ids, num_questions)
                questions = InterviewQuestion.objects.filter(id__in=selected_ids)
            
            # Prepare question data for response
            question_data = InterviewQuestionSerializer(questions, many=True).data
            session_data = InterviewSessionSerializer(session).data
            
            # Add questions to the response
            response_data = {
                'session': session_data,
                'questions': question_data
            }
            
            return Response(response_data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            logger.error(f"Error starting interview simulation: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @action(detail=True, methods=['post'])
    def complete_session(self, request, pk=None):
        """
        Complete an interview session and generate feedback
        """
        session = self.get_object()
        
        if session.status == 'completed':
            return Response(
                {"error": "This session is already completed"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Update session status
            session.status = 'completed'
            
            # Generate overall feedback (in a real app, you'd use an AI for this)
            responses = InterviewResponse.objects.filter(session=session)
            if responses.exists():
                avg_score = sum(r.score for r in responses if r.score) / responses.filter(score__isnull=False).count() \
                    if responses.filter(score__isnull=False).exists() else 0
                
                session.session_score = avg_score
                
                # Generate feedback based on score
                if avg_score >= 80:
                    feedback = (
                        "Excellent performance! You demonstrated strong communication skills and provided "
                        "comprehensive answers to the questions. Your responses were well-structured and relevant."
                    )
                elif avg_score >= 60:
                    feedback = (
                        "Good performance. You handled most questions well, but there's room for improvement "
                        "in some areas. Try to provide more specific examples and structure your answers better."
                    )
                else:
                    feedback = (
                        "You need more practice. Focus on structuring your answers using the STAR method "
                        "(Situation, Task, Action, Result) and prepare more concrete examples from your experience."
                    )
                
                session.session_feedback = feedback
            
            session.save()
            
            # Create feedback items for different categories
            categories = {
                'Communication': "Your communication was clear and professional.",
                'Content': "Your answers contained relevant information and examples.",
                'Confidence': "You projected confidence in your responses."
            }
            
            feedback_items = []
            for cat_name, feedback_text in categories.items():
                category, _ = FeedbackCategory.objects.get_or_create(name=cat_name)
                
                # Generate random score for demonstration (in a real app, use AI)
                score = random.uniform(50, 95)
                
                # Generate improvement suggestion based on score
                if score < 70:
                    suggestion = f"Work on improving your {cat_name.lower()} skills by practicing more."
                else:
                    suggestion = f"Continue to develop your {cat_name.lower()} skills."
                
                # Create feedback item
                feedback_item = SessionFeedbackItem.objects.create(
                    session=session,
                    category=category,
                    feedback_text=feedback_text,
                    score=score,
                    improvement_suggestion=suggestion
                )
                feedback_items.append(feedback_item)
            
            return Response(
                {
                    'session': InterviewSessionSerializer(session).data,
                    'feedback_items': SessionFeedbackItemSerializer(feedback_items, many=True).data
                },
                status=status.HTTP_200_OK
            )
            
        except Exception as e:
            logger.error(f"Error completing interview session: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class InterviewResponseViewSet(viewsets.ModelViewSet):
    """
    API endpoint for interview responses
    """
    queryset = InterviewResponse.objects.all()
    serializer_class = InterviewResponseSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def create(self, request, *args, **kwargs):
        """
        Create a response and generate AI feedback
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            # Get the interview session
            session_id = request.data.get('session')
            try:
                session = InterviewSession.objects.get(pk=session_id)
            except InterviewSession.DoesNotExist:
                return Response(
                    {"error": f"Interview session with id {session_id} not found"},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Create response object
            response = serializer.save(session=session)
            
            # Generate AI feedback (in a real app, you would use an AI model)
            question = response.question
            response_text = response.response_text
            
            # Simple feedback logic based on response length and keywords
            # In a real app, you would use NLP and compare to ideal answers
            words = response_text.split()
            word_count = len(words)
            
            # Basic scoring logic
            if word_count < 20:
                feedback = "Your answer is too brief. Try to elaborate more and provide specific examples."
                score = 40
            elif word_count < 50:
                feedback = "Your answer could be more detailed. Consider including more specific examples from your experience."
                score = 60
            else:
                feedback = "Good detailed answer. You've provided sufficient information and examples."
                score = 80
            
            # Check for ideal answer keywords if available
            if question.ideal_answer:
                ideal_keywords = set(word.lower() for word in question.ideal_answer.split())
                response_keywords = set(word.lower() for word in response_text.split())
                keyword_matches = ideal_keywords.intersection(response_keywords)
                
                # Adjust score based on keyword matches
                keyword_score = min(100, int(len(keyword_matches) / max(1, len(ideal_keywords)) * 100))
                score = (score + keyword_score) / 2
                
                if keyword_score > 70:
                    feedback += " Your answer includes many of the key points we were looking for."
                elif keyword_score > 40:
                    feedback += " You've mentioned some important points, but missed others."
                else:
                    feedback += " Try to address the key points relevant to this question."
            
            # Update response with feedback
            response.feedback = feedback
            response.score = score
            response.save()
            
            return Response(
                self.get_serializer(response).data,
                status=status.HTTP_201_CREATED
            )
            
        except Exception as e:
            logger.error(f"Error processing interview response: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)