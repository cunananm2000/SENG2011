from server import *
from flask import Flask, redirect, request, render_template, url_for, session
from flask_login import LoginManager,login_user, current_user, login_required, logout_user, UserMixin
from datetime import datetime

@login_manager.user_loader
def load_user(id):
	return get_user(id)

def get_user(id):
	return system.get_user(id)

@app.route("/", methods=['GET','POST'])
@app.route("/login", methods=['GET','POST'])
def login():
	if request.method == "POST":
		userType = request.form["userType"]
		loginID = request.form["loginID"]
		message = "Incorrect username or password"
		password = request.form["password"]

		print("USER TYPE:",userType)

		error = False
		if userType == "":
			message = "Please choose one"
			error = True
		
		if loginID == "":
			message = "Please enter your ID"
			error = True
		
		if password == "":
			message = "Please enter a password"
			error = True
			
		if error:
			return render_template("login.html",title="Login",message=message)

		userList = []
		if userType == "Donor":
			userList = system.getDonors()
		elif userType == "Pathology Centre":
			userList = system.getPathCentres()
		elif userType == "Hospital":
			userList = system.getHospitals()
		elif userType == "Vampire":
			userList += system.getVampire()
		
		for user in userList:
			if user.id == loginID and user.getPassword() == password:
				login_user(user)
				message = "Wassup " + user.getName()
				return render_template("home.html",title="Home",message=message)
		
		return render_template("login.html",title="Login",message="U DONE FKED UP")
	else:
		return render_template("login.html",title="Login",message="")

@app.route("/home", methods=["POST","GET"])
@login_required
def home():
	message = "Hello "
	message = message + " " + current_user.getName()
	return render_template("home.html",title="Home",message=message)

@app.route('/logout', methods=["POST", "GET"])
@login_required
def logout():
    logout_user()
    return redirect(url_for("login"))

@app.route("/addDonor", methods=["POST","GET"])
@login_required
def addDonor():
	errors = []
	if request.method == "POST":
		givenName = request.form["givenName"]
		familyName = request.form["familyName"]
		email = request.form["email"]
		print("HEERRRREEE")
		if givenName == "":
			errors.append("Given Name")
		if familyName == "":
			errors.append("Family Name")
		if email == "":
			errors.append("Email")
			
		system.addDonor(givenName,familyName,email)
		return render_template("addDonor.html",title="Add donor",booked=True,errors=errors)
	return render_template("addDonor.html",title="Add donor",booked=False,errors=errors)