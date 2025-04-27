from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .serializers import SignupSerializer, LoginSerializer
from .models import User
from django.contrib.auth.hashers import make_password, check_password , is_password_usable
from django.contrib.auth import authenticate
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import base64

@api_view(['POST'])
def signup(request):
    serializer = SignupSerializer(data=request.data)
    if serializer.is_valid():
        data = serializer.validated_data
        
        if User.objects.filter(email=data['email']).exists():
            return Response({"message": "Email already exists"}, status=400)

        # Get the decoded photo data from the serializer
        photo_data = serializer.validated_data.get('photo', b'')
        print("Password before hashing:", data['password'])
        hashed_password = make_password(data['password'])
        print("Password after hashing:", hashed_password)
        
        user = User.objects.create(
            nom=data['nom'],
            prenom=data['prenom'],
            ville=data['ville'],
            phone=data['phone'],
            password= hashed_password,
            email=data['email'],
            photo=photo_data,  # Use the decoded binary data
            date_anniverssaire=data['date_anniverssaire']
        )
        print("Password before hashing:", data['password'])
        print("Password after hashing:", make_password(data['password']))

        return Response({"message": "User created", "user_id": user.id}, status=201)
    
    return Response(serializer.errors, status=400)


def verify_password(plain_password, hashed_password):
    """Robust password check that won’t blow up on malformed hashes."""
    if not hashed_password or not is_password_usable(hashed_password):
        print("Password is not usable or hashed_password is missing")
        return False
    try:
        result = check_password(plain_password, hashed_password)
        print("Password check result:", result)
        return result
    except (ValueError, TypeError) as e:
        print(f"Error checking password: {e}")
        return False

@api_view(['POST'])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        
        print(f"Login attempt for email: {email}")
        print(f"Entered password: {password}")

        try:
            user = User.objects.get(email=email)
            print(f"Found user with ID: {user.id}")
            print(f"Stored password hash: {user.password}")
            
            # Check if the stored password is properly formatted
            if not is_password_usable(user.password):
                print("WARNING: Stored password hash is not in a usable format!")
                return Response({"message": "Account configuration error"}, status=500)
            
            # Try direct comparison with check_password
            is_valid = check_password(password, user.password)
            print(f"Password verification result: {is_valid}")
            
            if is_valid:
                print("Login successful!")
                return Response({"message": "Login successful", "user_id": user.id}, status=status.HTTP_200_OK)
            else:
                # If the password check fails, create a new hash and compare
                print("Password verification failed, comparing raw strings:")
                print(f"Stored hash: {user.password}")
                print(f"New hash from same password: {make_password(password)}")
                
                return Response({"message": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
                
        except User.DoesNotExist:
            print(f"User not found: {email}")
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Dans views.py, ajoutez cette nouvelle fonction
@require_http_methods(["GET"])
def get_all_users(request):
    # Vérifier les credentials via Basic Auth
    if "HTTP_AUTHORIZATION" in request.META:
        auth = request.META["HTTP_AUTHORIZATION"].split()
        if len(auth) == 2 and auth[0].lower() == "basic":
            email, password = base64.b64decode(auth[1]).decode("utf-8").split(":")
            user = authenticate(email=email, password=password)
            if user is not None:
                users = User.objects.all()
                data = [{
                    "id": u.id,
                    "email": u.email,
                    "nom": u.nom,
                } for u in users]
                return JsonResponse(data, safe=False)
    
    return JsonResponse({"error": "Authentification requise"}, status=401)