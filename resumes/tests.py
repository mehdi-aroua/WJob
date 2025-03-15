
from django.test import TestCase # type: ignore
from django.urls import reverse # type: ignore
from unittest.mock import patch
from .models import Resume
from .linkedin_api import get_profile

class ResumeModelTest(TestCase):
    def test_resume_creation(self):
        resume = Resume.objects.create(name="John Doe", file="cv_john_doe.pdf")
        self.assertEqual(resume.name, "John Doe")
        self.assertEqual(resume.file, "cv_john_doe.pdf")

class UploadCVViewTest(TestCase):
    def test_upload_cv_view(self):
        resume_data = {'name': 'Jane Doe', 'file': 'cv_jane_doe.pdf'}
        response = self.client.post(reverse('upload_cv'), resume_data)
        self.assertEqual(response.status_code, 302)
        self.assertEqual(Resume.objects.count(), 1)
        self.assertEqual(Resume.objects.first().name, 'Jane Doe')

class LinkedInApiTest(TestCase):
    @patch('app.linkedin_api.linkedin.LinkedInApplication')
    def test_get_profile(self, MockLinkedIn):
        mock_instance = MockLinkedIn.return_value
        mock_instance.get_profile.return_value = {
            'firstName': 'John',
            'lastName': 'Doe',
            'headline': 'Software Engineer',
            'location': {'name': 'Paris'}
        }

        profile = get_profile()

        self.assertEqual(profile['firstName'], 'John')
        self.assertEqual(profile['lastName'], 'Doe')
        self.assertEqual(profile['headline'], 'Software Engineer')
        self.assertEqual(profile['location']['name'], 'Paris')
