from django import forms
from .models import Review  # Assurez-vous que vous avez un modèle Review défini

class ReviewForm(forms.ModelForm):
    class Meta:
        model = Review
        fields = ['rating', 'comment']  # Remplacez 'rating' et 'comment' par les champs de votre modèle
