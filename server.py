#a function to read in from provider csv and return a list of class type Centres
import csv
import math
from classes import *
from system import *
from flask import Flask
from flask_login import LoginManager
from flask_table import Table, Col
import datetime
import operator
from decimal import *
from random import randint

app = Flask(__name__)
app.secret_key = 'very-secret-123'  # Used to add entropy
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

system = MainSystem()