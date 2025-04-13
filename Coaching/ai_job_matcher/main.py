#!/usr/bin/env python
import os
import sys

def main():
    """
    Cette fonction lance les commandes de gestion Django, comme `runserver` ou `test`.
    """
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ai_job_matcher.settings')

    try:
        # Exécution de la commande Django (par exemple, test, runserver)
        from django.core.management import execute_from_command_line
        execute_from_command_line(sys.argv)
    except Exception as exc:
        print(f"Une erreur s'est produite: {exc}")
        raise

if __name__ == '__main__':
    main()
