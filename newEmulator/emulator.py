from classes import Vampire
import json

# bloodTypes = ["O_NEG","O_POS","A_NEG","A_POS","B_NEG","B_POS","AB_NEG","AB_POS"]
# statusTypes = ["UNCLEAN","CLEAN"]
# locationTypes = ["DUMP","VAMPIRE"]

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
        vampire.cleanUp()
    elif (cmd == "PRINT_INVENTORY"):
        printInventory()
    elif (cmd == "PRINT_LEVELS"):
        vampire.printLevels()
    elif (cmd == "PRINT_DONORS"):
        printDonors()
    elif (cmd == "PRINT_LOCATIONS"):
        vampire.printLocations()
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
    if vampire.login(loginID,password):
        print("GOOD")
    else:
        print("BAD")

def addDonor():
    firstName = input("First name: ")
    lastName = input("Last name: ")
    password = input("Password: ")
    vampire.addDonor(firstName,lastName,password)

def addBlood():
    donorID = input("Donor ID: ")
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    donateDate = int(input("Donation date: "))
    donateLoc = input("Donation location: ")
    expiryDate = int(input("Expiry date: "))
    vampire.makeDeposit(bloodTypeStr,donateDate,donateLoc,expiryDate,donorID)

def requestBlood():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("Number of packets: "))
    useBy = int(input("Use by: "))
    dest = input("Dest: ")
    if vampire.makeRequest(bloodTypeStr,nPackets,useBy,dest):
        print("Success")
    else:
        print("Failed")

def searchBlood():
    field = input("Search by: ").upper().replace(" ","_")
    value = input("Value: ")
    vampire.searchBlood(field,value)

def printInventory():
    field = input("Sort by: ").upper().replace(" ","_")
    vampire.printInventory(field)

def printBlood():
    field = input("Sort by: ").upper().replace(" ","_")
    vampire.printBlood(field)

def printDonors():
    vampire.printDonors()

def setLowLevel():
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    nPackets = int(input("New low level: "))
    if vampire.setLowLevel(bloodTypeStr,nPackets):
        print("Success")
    else:
        print("Failed")

vampire = Vampire()

# vampire.addDonor("Michael","Cunanan")
# vampire.addDonor("Mark","Estoque")
# vampire.addDonor("David","Leydon")
# vampire.addDonor("Tushar","Virk")
# vampire.addDonor("Kenvin","Yu")
# vampire.addDonor("Some","Guy")

with open('donors.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for donor in data:
        password = donor['password']
        firstName = donor['givenName']
        lastName = donor['surname']
        vampire.addDonor(firstName,lastName,password)

with open('hospitals.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for hospital in data:
        name = hospital['name']
        password = hospital['password']
        vampire.addHospital(name,password)

with open('inventory.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for packet in data:
        bloodTypeStr = packet["type"]
        donateDate = packet["donateDate"]
        donateLoc = packet["donateLoc"]
        expiryDate = packet["expiryDate"]
        donorID = packet["donorID"]
        vampire.makeDeposit(bloodTypeStr,donateDate,donateLoc,expiryDate,donorID)

while (True):
    cmd = input("$ ").upper().replace(" ","_")
    if (cmd == "QUIT"):
        break
    if not (processCommand(cmd)):
        print("'"+cmd+"'","is not a real command")
    print("---------------------------------")
print("Quitting....")