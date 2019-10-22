from classes import *
import csv
import operator

def loadDonors():
	donorList = []
	with open('donors.csv') as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=',')
		for row in csv_reader:
			donorID = row[0]
			password = row[1]
			givenName = row[2]
			familyName = row[3]
			email = row[4]
			d = Donor(donorID,givenName,familyName,password,email)
			donorList.append(d)
	return donorList

def loadPathCentres():
	centreList = []
	with open('pathCentres.csv') as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=',')
		for row in csv_reader:
			centreID = row[0]
			name = row[1]
			password = row[2]
			pc = PathCentre(centreID,name,password)
			centreList.append(pc)
	return centreList

def loadHospitals():
	hospitalList = []
	with open('hospitals.csv') as csv_file:
		csv_reader = csv.reader(csv_file, delimiter=',')
		for row in csv_reader:
			hospitalID = row[0]
			name = row[1]
			password = row[2]
			h = Hospital(hospitalID,name,password)
			hospitalList.append(h)
	return hospitalList

def getLineCount(file):
	return sum(1 for line in open(file))