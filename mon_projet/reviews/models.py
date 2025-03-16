from django.db import models

class Review(models.Model):
    rating = models.PositiveIntegerField()  # Note de l'évaluation, entre 1 et 5
    comment = models.TextField()  # Commentaire de l'utilisateur

    def __str__(self):
        return f"Review {self.rating} - {self.comment[:20]}"
