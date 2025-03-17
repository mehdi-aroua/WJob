from django.db import models

class MockInterview(models.Model):
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)  # Associe l'entretien à un utilisateur
    job_role = models.CharField(max_length=100)
    questions = models.TextField()
    answers = models.TextField(null=True, blank=True)  # Réponses de l'utilisateur
    coaching_site = models.CharField(max_length=50, choices=[('Huru.ai', 'Huru.ai'), ('CoachHub', 'CoachHub')], null=True, blank=True)

    def __str__(self):
        return f"Entretien simulé pour {self.user.username} pour le rôle de {self.job_role}"
