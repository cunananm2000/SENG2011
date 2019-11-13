#!/usr/bin/python3
from classes import System
import json

# bloodTypes = ["O_NEG","O_POS","A_NEG","A_POS","B_NEG","B_POS","AB_NEG","AB_POS"]
# statusTypes = ["UNCLEAN","CLEAN"]
# locationTypes = ["DUMP","VAMPIRE"]

currentUserID = ""
currentUserType = ""
mainSystem = System()

def routeCommand(cmd):
    global currentUserType
    if currentUserType == "":
        return processNormalCmd(cmd)
    if currentUserType == "donor":
        return False
    if currentUserType == "hospital":
        return processHospitalCmd(cmd)
    if currentUserType == "vampire":
        return processVampireCmd(cmd)
    if currentUserType == "pathCentre":
        return processPathCentreCmd(cmd)

def printHelp():
    global currentUserType
    if currentUserType == "":
        print("LOGIN ----------------- Login")
    if currentUserType == "donor":
        return True
    if currentUserType == "hospital":
        print("REQUEST_BLOOD --------- Request blood")
    if currentUserType == "vampire":
        print("ADD_DONOR ------------- Add a new donor")
        print("CLEAN_UP -------------- Remove bad blood packets")
        print("PRINT_INVENTORY ------- Print inventory")
        print("PRINT_NOTIFS ---------- Print notifications")
        print("PRINT_LEVELS ---------- Print current levels")
        print("PRINT_DONORS ---------- Print donors")
        print("PRINT_HOSPITALS ------- Print hospitals")
        print("PRINT_PATH_CENTRES ---- Print pathology centres")
        print("PRINT_BLOOD_DATABASE -- Print blood database")
        print("SEARCH_BLOOD ---------- Search blood database")
        print("SET_LOW_LEVEL --------- Set low level of a specific blood type")
        print("SET_BUFFER ------------ Set a warning buffer")
    if currentUserType == "pathCentre":
        print("ADD_BLOOD ------------- Add a new blood packet")
    return True

def processNormalCmd(cmd):
    if (cmd == "LOGIN"):
        login()
        return True
    else:
        return False

def processHospitalCmd(cmd):
    if (cmd == "REQUEST_BLOOD"):
        requestBlood()
        return True
    else:
        return False

def processPathCentreCmd(cmd):
    if (cmd == "ADD_BLOOD"):
        addBlood()
        return True
    else:
        return False

def processVampireCmd(cmd):
    if (cmd == "ADD_DONOR"):
        addDonor()
    elif (cmd == "CLEAN_UP"):
        mainSystem.cleanUp()
    elif (cmd == "PRINT_INVENTORY"):
        printInventory()
    elif (cmd == "PRINT_NOTIFS"):
        mainSystem.printNotifs()
    elif (cmd == "PRINT_LEVELS"):
        mainSystem.printLevels()
    elif (cmd == "PRINT_DONORS"):
        printDonors()
    elif (cmd == "PRINT_HOSPITALS"):
        mainSystem.printHospitals()
    elif (cmd == "PRINT_PATH_CENTRES"):
        mainSystem.printPathCentres()
    elif (cmd == "PRINT_BLOOD_DATABASE"):
        printBlood()
    elif (cmd == "SEARCH_BLOOD"):
        searchBlood()
    elif (cmd == "SET_LOW_LEVEL"):
        setLowLevel()
    elif (cmd == "SET_BUFFER"):
        setBuffer()
    else:
        return False
    return True

def login():
    loginID = input("Login ID: ")
    password = input("Password: ")

    userID,userType = mainSystem.login(loginID,password)
    if userID != "" and userType != "":
        global currentUserID
        currentUserID = userID
        global currentUserType
        currentUserType = userType
        print("Hello",userID+", a",userType)
    else:
        print("BAD LOGIN")

def logout():
    global currentUserID
    currentUserID = ""
    global currentUserType
    currentUserType = ""

def addDonor():
    firstName = input("First name: ")
    lastName = input("Last name: ")
    password = input("Password: ")
    print(mainSystem.addDonor(firstName,lastName,password))

def addBlood():
    donorID = input("Donor ID: ")
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    donateDate = int(input("Donation date: "))
    global currentUserID
    expiryDate = int(input("Expiry date: "))
    if mainSystem.makeDeposit(bloodTypeStr,donateDate,currentUserID,expiryDate,donorID):
        print("Added!")
    else:
        print("Failed")

def requestBlood():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("Number of packets: "))
    useBy = int(input("Use by: "))
    global currentUserID
    if mainSystem.makeRequest(bloodTypeStr,nPackets,useBy,currentUserID):
        print("Success")
    else:
        print("Failed")

def searchBlood():
    field = input("Search by: ").upper().replace(" ","_")
    value = input("Value: ")
    mainSystem.searchBlood(field,value)

def printInventory():
    field = input("Sort by: ").upper().replace(" ","_")
    mainSystem.printInventory(field)

def printBlood():
    field = input("Sort by: ").upper().replace(" ","_")
    mainSystem.printBlood(field)

def setBuffer():
    nDays = int(input("Number of days for warning: "))
    mainSystem.setWarning(nDays)

def printDonors():
    mainSystem.printDonors()

def setLowLevel():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("New low level: "))
    if mainSystem.setLowLevel(bloodTypeStr,nPackets):
        print("Success")
    else:
        print("Failed")

def setMaxLevel():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("New max level: "))
    if mainSystem.setMaxLevel(bloodTypeStr,nPackets):
        print("Success")
    else:
        print("Failed")

with open('donors.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for donor in data:
        password = donor['password']
        firstName = donor['givenName']
        lastName = donor['surname']
        mainSystem.addDonor(firstName,lastName,password)

with open('hospitals.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for hospital in data:
        name = hospital['name']
        password = hospital['password']
        mainSystem.addHospital(name,password)

with open('pathCentres.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for pathCentre in data:
        name = pathCentre['name']
        password = pathCentre['password']
        mainSystem.addPathCentre(name,password)

with open('inventory.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for packet in data:
        bloodTypeStr = packet["type"]
        donateDate = packet["donateDate"]
        donateLoc = packet["donateLoc"]
        expiryDate = packet["expiryDate"]
        donorID = packet["donorID"]
        mainSystem.makeDeposit(bloodTypeStr,donateDate,donateLoc,expiryDate,donorID)

print("Print HELP for help, QUIT to quit")
while (True):
    cmd = input("$ ").upper().replace(" ","_")
    if (cmd == "QUIT"):
        break
    elif (cmd == "LOGOUT"):
        logout()
        print("Logging out...")
        print("Logged out")
    elif (cmd == "HELP"):
        printHelp()
    elif not (routeCommand(cmd)):
        print("'"+cmd+"'","is not a real command")
    print("---------------------------------")
print("Quitting....")