FROM python:latest

# Setting environment variables. (Good Practice)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
SHELL ["/bin/bash", "-c"]

# Install dependencies
RUN apt update -y
RUN apt install --upgrade libpq-dev -y
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

#Run Migration
RUN python3 /app/babyshop_app/manage.py makemigrations
RUN python3 /app/babyshop_app/manage.py migrate

# Expose the necessary port for action
EXPOSE 8000

# Set the start up command
CMD [ "python3", "/app/babyshop_app/manage.py", "runserver", "0.0.0.0:8000"]
