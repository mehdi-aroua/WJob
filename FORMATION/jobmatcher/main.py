import os
import django
from django.core.management import execute_from_command_line

def main():
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jobmatcher.settings')
    django.setup()
    print('🚀 Démarrage du serveur Django...')
    execute_from_command_line(['manage.py', 'runserver'])

if __name__ == '__main__':
    main()
