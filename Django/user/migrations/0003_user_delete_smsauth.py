# Generated by Django 4.1.6 on 2023-02-13 08:02

from django.db import migrations, models
import django.db.models.manager


class Migration(migrations.Migration):

    dependencies = [
        ('user', '0002_smsauth_delete_authsms'),
    ]

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('studentID', models.CharField(max_length=8, unique=True)),
                ('name', models.CharField(max_length=40)),
                ('phone_num', models.CharField(max_length=13, unique=True)),
            ],
            options={
                'abstract': False,
            },
            managers=[
                ('object', django.db.models.manager.Manager()),
            ],
        ),
        migrations.DeleteModel(
            name='SmsAuth',
        ),
    ]
