import os
import sys
from django.core.management import execute_from_command_line

def main():
    """Point d'entrée principal pour le projet Django."""
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mon_projet.settings')
    
    try:
        # Exécute la commande passée en argument
        execute_from_command_line(sys.argv)
    except Exception as e:
        print(f"Une erreur est survenue : {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

