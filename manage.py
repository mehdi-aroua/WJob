import os
import sys

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "AIJobMatcher.settings")
    try:
        from django.core.management import execute_from_command_line # type: ignore
    except ImportError as exc:
        raise ImportError(
            "Impossible d'importer Django. Vérifie si Django est installé et accessible."
        ) from exc
    execute_from_command_line(sys.argv)
