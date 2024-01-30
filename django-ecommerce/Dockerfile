FROM python:3.9

# Setting environment variables. (Good Practice)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
RUN pip install django Pillow

# Copy the django project
COPY . /app/

# Set the current working directory
WORKDIR /app

#Define ENV's for admin credentials
ENV DJANGO_DB_NAME=default
ENV DJANGO_SU_PASSWORD=admin
ENV DJANGO_SU_NAME=admin
ENV DJANGO_SU_EMAIL=admin@gmail.com

RUN python -c "import django; django.setup(); \
   from django.contrib.auth.management.commands.createsuperuser import get_user_model; \
   get_user_model()._default_manager.db_manager('$DJANGO_DB_NAME').create_superuser( \
   username='$DJANGO_SU_NAME', \
   email='$DJANGO_SU_EMAIL', \
   password='$DJANGO_SU_PASSWORD')"

#Run Migration
RUN python3 /app/babyshop_app/manage.py makemigrations
RUN python3 /app/babyshop_app/manage.py migrate

# Expose the necessary port for action
EXPOSE 8000

# Set the start up command
CMD [ "python3", "/app/babyshop_app/manage.py", "runserver", "0.0.0.0:8000"]