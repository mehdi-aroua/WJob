from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
import requests
import json
import logging
import os
from django.conf import settings

from profiles.models import Profile, Skill, ProfileSkill
from .serializers import (
    ProfileSerializer, 
    LinkedInProfileImportSerializer, 
    IndeedProfileImportSerializer,
    SkillSerializer
)

logger = logging.getLogger(__name__)


class ProfileViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing profiles
    """
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    @action(detail=False, methods=['post'], serializer_class=LinkedInProfileImportSerializer)
    def import_from_linkedin(self, request):
        """
        Import a profile from LinkedIn
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            # In a real application, you would use the LinkedIn API
            # This is a simplified example
            linkedin_data = None
            
            if 'linkedin_url' in serializer.validated_data:
                linkedin_url = serializer.validated_data['linkedin_url']
                # Call LinkedIn API to get profile data using the URL
                # linkedin_data = call_linkedin_api_by_url(linkedin_url)
                
                # Mocked response for demonstration
                linkedin_data = {
                    'firstName': 'John',
                    'lastName': 'Doe',
                    'headline': 'Software Engineer at Tech Company',
                    'summary': 'Experienced software engineer with skills in Python and Django',
                    'location': 'Paris, France',
                    'positions': [
                        {
                            'title': 'Software Engineer',
                            'company': 'Tech Company',
                            'startDate': '2020-01-01',
                            'endDate': None,
                            'isCurrent': True,
                            'description': 'Working on backend development with Django'
                        }
                    ],
                    'education': [
                        {
                            'schoolName': 'University of Technology',
                            'degree': 'Master',
                            'fieldOfStudy': 'Computer Science',
                            'startDate': '2015-09-01',
                            'endDate': '2017-06-30',
                            'description': 'Focus on software engineering'
                        }
                    ],
                    'skills': [
                        {'name': 'Python', 'endorsements': 15},
                        {'name': 'Django', 'endorsements': 10},
                        {'name': 'JavaScript', 'endorsements': 8}
                    ]
                }
            
            elif 'linkedin_profile_id' in serializer.validated_data:
                profile_id = serializer.validated_data['linkedin_profile_id']
                # Call LinkedIn API to get profile data using ID
                # linkedin_data = call_linkedin_api_by_id(profile_id)
                # Implementation similar to above
            
            if not linkedin_data:
                return Response({"error": "Failed to retrieve data from LinkedIn"}, status=status.HTTP_400_BAD_REQUEST)
            
            # Transform LinkedIn data to our model format
            profile_data = {
                'source': 'linkedin',
                'source_profile_id': serializer.validated_data.get('linkedin_profile_id', ''),
                'first_name': linkedin_data.get('firstName', ''),
                'last_name': linkedin_data.get('lastName', ''),
                'headline': linkedin_data.get('headline', ''),
                'summary': linkedin_data.get('summary', ''),
                'location': linkedin_data.get('location', ''),
                'linkedin_url': serializer.validated_data.get('linkedin_url', ''),
                'experiences': [],
                'education': [],
                'skills': []
            }
            
            # Add experiences
            for position in linkedin_data.get('positions', []):
                profile_data['experiences'].append({
                    'company': position.get('company', ''),
                    'title': position.get('title', ''),
                    'start_date': position.get('startDate', '2000-01-01'),
                    'end_date': position.get('endDate'),
                    'current': position.get('isCurrent', False),
                    'description': position.get('description', '')
                })
            
            # Add education
            for edu in linkedin_data.get('education', []):
                profile_data['education'].append({
                    'institution': edu.get('schoolName', ''),
                    'degree': edu.get('degree', ''),
                    'field_of_study': edu.get('fieldOfStudy', ''),
                    'start_date': edu.get('startDate', '2000-01-01'),
                    'end_date': edu.get('endDate'),
                    'description': edu.get('description', '')
                })
            
            # Add skills
            for skill_data in linkedin_data.get('skills', []):
                skill_name = skill_data.get('name', '')
                if skill_name:
                    # Get or create skill
                    skill, created = Skill.objects.get_or_create(name=skill_name)
                    
                    profile_data['skills'].append({
                        'skill_id': skill.id,
                        'endorsements': skill_data.get('endorsements', 0)
                    })
            
            # Create the profile using the standard serializer
            profile_serializer = ProfileSerializer(data=profile_data)
            profile_serializer.is_valid(raise_exception=True)
            profile = profile_serializer.save()
            
            return Response(profile_serializer.data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            logger.error(f"Error importing profile from LinkedIn: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'], serializer_class=IndeedProfileImportSerializer)
    def import_from_indeed(self, request):
        """
        Import a profile from Indeed
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            # In a real application, you would use the Indeed API
            # This is a simplified example
            indeed_data = None
            
            if 'indeed_url' in serializer.validated_data:
                indeed_url = serializer.validated_data['indeed_url']
                # Call Indeed API to get resume data using URL
                # indeed_data = call_indeed_api_by_url(indeed_url)
                
                # Mocked response for demonstration
                indeed_data = {
                    'firstName': 'Jane',
                    'lastName': 'Smith',
                    'headline': 'Data Scientist',
                    'summary': 'Data scientist with expertise in machine learning and statistical analysis',
                    'location': 'Lyon, France',
                    'workExperience': [
                        {
                            'jobTitle': 'Data Scientist',
                            'company': 'Analytics Inc',
                            'startDate': '2019-03-01',
                            'endDate': None,
                            'current': True,
                            'description': 'Building machine learning models for customer segmentation'
                        }
                    ],
                    'education': [
                        {
                            'institution': 'National Institute of Technology',
                            'degree': 'Ph.D.',
                            'fieldOfStudy': 'Data Science',
                            'startDate': '2015-09-01',
                            'endDate': '2019-01-30',
                            'description': 'Research on deep learning models'
                        }
                    ],
                    'skills': [
                        {'name': 'Machine Learning'},
                        {'name': 'Python'},
                        {'name': 'Statistical Analysis'},
                        {'name': 'TensorFlow'}
                    ]
                }
            
            elif 'indeed_resume_id' in serializer.validated_data:
                resume_id = serializer.validated_data['indeed_resume_id']
                # Call Indeed API to get resume data using ID
                # indeed_data = call_indeed_api_by_id(resume_id)
                # Implementation similar to above
            
            if not indeed_data:
                return Response({"error": "Failed to retrieve data from Indeed"}, status=status.HTTP_400_BAD_REQUEST)
            
            # Transform Indeed data to our model format
            profile_data = {
                'source': 'indeed',
                'source_profile_id': serializer.validated_data.get('indeed_resume_id', ''),
                'first_name': indeed_data.get('firstName', ''),
                'last_name': indeed_data.get('lastName', ''),
                'headline': indeed_data.get('headline', ''),
                'summary': indeed_data.get('summary', ''),
                'location': indeed_data.get('location', ''),
                'indeed_url': serializer.validated_data.get('indeed_url', ''),
                'experiences': [],
                'education': [],
                'skills': []
            }
            
            # Add experiences
            for job in indeed_data.get('workExperience', []):
                profile_data['experiences'].append({
                    'company': job.get('company', ''),
                    'title': job.get('jobTitle', ''),
                    'start_date': job.get('startDate', '2000-01-01'),
                    'end_date': job.get('endDate'),
                    'current': job.get('current', False),
                    'description': job.get('description', '')
                })
            
            # Add education
            for edu in indeed_data.get('education', []):
                profile_data['education'].append({
                    'institution': edu.get('institution', ''),
                    'degree': edu.get('degree', ''),
                    'field_of_study': edu.get('fieldOfStudy', ''),
                    'start_date': edu.get('startDate', '2000-01-01'),
                    'end_date': edu.get('endDate'),
                    'description': edu.get('description', '')
                })
            
            # Add skills
            for skill_data in indeed_data.get('skills', []):
                skill_name = skill_data.get('name', '')
                if skill_name:
                    # Get or create skill
                    skill, created = Skill.objects.get_or_create(name=skill_name)
                    
                    profile_data['skills'].append({
                        'skill_id': skill.id,
                        'endorsements': 0  # Indeed doesn't provide endorsements like LinkedIn
                    })
            
            # Create the profile using the standard serializer
            profile_serializer = ProfileSerializer(data=profile_data)
            profile_serializer.is_valid(raise_exception=True)
            profile = profile_serializer.save()
            
            return Response(profile_serializer.data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            logger.error(f"Error importing profile from Indeed: {str(e)}")
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SkillViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for retrieving skills
    """
    queryset = Skill.objects.all()
    serializer_class = SkillSerializer
    permission_classes = [permissions.AllowAny]  # Modifier pour permettre l'accès public
    
    def get_queryset(self):
        queryset = Skill.objects.all()
        name = self.request.query_params.get('name', None)
        if name:
            queryset = queryset.filter(name__icontains=name)
        return queryset