from django.shortcuts import render
from django.http import JsonResponse
from .forms import ReviewForm
from django.shortcuts import render

def home(request):
    return render(request, 'home.html')  # Assurez-vous que ce fichier 'home.html' existe dans le dossier templates


def submit_review(request):
    if request.method == 'POST':
        form = ReviewForm(request.POST)
        if form.is_valid():
            form.save()
            return JsonResponse({'message': 'Review submitted successfully'}, status=200)
        else:
            return JsonResponse({'message': 'Invalid input'}, status=400)
    else:
        return JsonResponse({'message': 'Only POST method is allowed'}, status=405)
