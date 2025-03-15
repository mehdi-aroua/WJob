from django.shortcuts import render, redirect # type: ignore
from django.http import HttpResponse # type: ignore
from .models import Resume
from .forms import ResumeForm

def index(request):
    resumes = Resume.objects.all()
    return render(request, 'index.html', {'resumes': resumes})


def upload_cv(request):
    if request.method == 'POST':
        form = ResumeForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            return redirect('index')
    else:
        form = ResumeForm()
    return render(request, 'upload_cv.html', {'form': form})

def resume_detail(request, pk):
    resume = Resume.objects.get(pk=pk)
    return render(request, 'cv_detail.html', {'resume': resume})
