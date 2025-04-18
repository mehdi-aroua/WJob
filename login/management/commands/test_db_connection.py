# login/management/commands/test_db_connection.py
from django.core.management.base import BaseCommand
from django.db import connection
from django.db.utils import OperationalError

class Command(BaseCommand):
    help = 'Test MySQL Database Connection'

    def handle(self, *args, **kwargs):
        try:
            connection.ensure_connection()
            self.stdout.write(self.style.SUCCESS('Database connection successful'))
        except OperationalError as e:
            self.stdout.write(self.style.ERROR(f'Database connection failed: {e}'))
