from classes import System
import json

# bloodTypes = ["O_NEG","O_POS","A_NEG","A_POS","B_NEG","B_POS","AB_NEG","AB_POS"]
# statusTypes = ["UNCLEAN","CLEAN"]
# locationTypes = ["DUMP","VAMPIRE"]

currentUser = None
mainSystem = System()

def processCommand(cmd):
    if (cmd == "LOGIN"):
        login()
    if (cmd == "ADD_DONOR"):
        addDonor()
    elif (cmd == "ADD_BLOOD"):
        addBlood()
    elif (cmd == "REQUEST_BLOOD"):
        requestBlood()
    elif (cmd == "CLEAN_UP"):
        mainSystem.cleanUp()
    elif (cmd == "PRINT_INVENTORY"):
        printInventory()
    elif (cmd == "PRINT_LEVELS"):
        mainSystem.printLevels()
    elif (cmd == "PRINT_DONORS"):
        printDonors()
    elif (cmd == "PRINT_HOSPITALS"):
        mainSystem.printHospitals()
    elif (cmd == "PRINT_BLOOD_DATABASE"):
        printBlood()
    elif (cmd == "SEARCH_BLOOD"):
        searchBlood()
    elif (cmd == "SET_LOW_LEVEL"):
        setLowLevel()
    else:
        return False
    return True

def login():
    loginID = input("Login ID: ")
    password = input("Password: ")
    if mainSystem.login(loginID,password) != "":
        print("GOOD")
    else:
        print("BAD")

def addDonor():
    firstName = input("First name: ")
    lastName = input("Last name: ")
    password = input("Password: ")
    mainSystem.addDonor(firstName,lastName,password)

def addBlood():
    donorID = input("Donor ID: ")
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    donateDate = int(input("Donation date: "))
    donateLoc = input("Donation location: ")
    expiryDate = int(input("Expiry date: "))
    mainSystem.makeDeposit(bloodTypeStr,donateDate,donateLoc,expiryDate,donorID)

def requestBlood():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("Number of packets: "))
    useBy = int(input("Use by: "))
    dest = input("Dest: ")
    if mainSystem.makeRequest(bloodTypeStr,nPackets,useBy,dest):
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

def printDonors():
    mainSystem.printDonors()

def setLowLevel():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("New low level: "))
    if mainSystem.setLowLevel(bloodTypeStr,nPackets):
        print("Success")
    else:
        print("Failed")

# mainSystem.addDonor("Michael","Cunanan")
# mainSystem.addDonor("Mark","Estoque")
# mainSystem.addDonor("David","Leydon")
# mainSystem.addDonor("Tushar","Virk")
# mainSystem.addDonor("Kenvin","Yu")
# mainSystem.addDonor("Some","Guy")

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

while (True):
    cmd = input("$ ").upper().replace(" ","_")
    if (cmd == "QUIT"):
        break
    if not (processCommand(cmd)):
        print("'"+cmd+"'","is not a real command")
    print("---------------------------------")
print("Quitting....")