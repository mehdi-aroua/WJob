from rest_framework import serializers
from .models import User
import base64

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField()

class SignupSerializer(serializers.ModelSerializer):
    photo = serializers.CharField(required=False, allow_blank=True)
    
    class Meta:
        model = User
        fields = '__all__'
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate_photo(self, value):
        if value:
            try:
                # Ensure the string is properly encoded before decoding
                return base64.b64decode(value.encode('utf-8'))
            except Exception as e:
                raise serializers.ValidationError(f"Invalid base64 image data: {str(e)}")
        return b''
