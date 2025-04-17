from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth.models import BaseUserManager, AbstractBaseUser

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email must be set')
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

class User(AbstractBaseUser):
    # Champs exacts de votre table MySQL
    nom = models.CharField(max_length=20)
    prenom = models.CharField(max_length=20)
    ville = models.CharField(max_length=100)
    phone = models.CharField(max_length=30)
    password = models.CharField("password", max_length=128)
    photo = models.BinaryField()
    email = models.EmailField(max_length=50, unique=True)
    date_anniverssaire = models.DateField()

    # Nécessaire pour Django Auth
    is_active = models.BooleanField(default=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nom', 'prenom', 'ville', 'phone']

    objects = UserManager()

    def __str__(self):
        return self.email

    # Méthodes requises pour l'authentification
    def has_perm(self, perm, obj=None):
        return True

    def has_module_perms(self, app_label):
        return True

    @property
    def is_staff(self):
        return False  # Adaptez si vous avez des admins

    @property
    def is_admin(self):
        return False  # Compatibilité sans colonne en base

    class Meta:
        db_table = 'user'