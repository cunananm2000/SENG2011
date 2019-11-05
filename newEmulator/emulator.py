from classes import Vampire
import json

# bloodTypes = ["O_NEG","O_POS","A_NEG","A_POS","B_NEG","B_POS","AB_NEG","AB_POS"]
# statusTypes = ["UNCLEAN","CLEAN"]
# locationTypes = ["DUMP","VAMPIRE"]

def processCommand(cmd):
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
    elif (cmd == "PRINT_DONORS"):
        vampire.printDonors()
    elif (cmd == "PRINT_LOCATIONS"):
        vampire.printLocations()
    elif (cmd == "PRINT_BLOOD_DATABASE"):
        printBlood()
    elif (cmd == "SEARCH_BLOOD"):
        searchBlood()
    else:
        return False
    return True

def addDonor():
    firstName = input("First name: ")
    lastName = input("Last name: ")
    vampire.addDonor(firstName,lastName)

def addBlood():
    donorID = input("Donor ID: ")
    bloodTypeStr = input("Blood type: ").upper().replace(" ","_")
    expiryDate = int(input("Expiry date: "))
    vampire.makeDeposit(bloodTypeStr,expiryDate,donorID)

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
    field = input("Search by: ").upper().replace(" ","_")
    vampire.printInventory(field)

def printBlood():
    field = input("Search by: ").upper().replace(" ","_")
    vampire.printBlood(field)

vampire = Vampire()

vampire.addDonor("Michael","Cunanan")
vampire.addDonor("Mark","Estoque")
vampire.addDonor("David","Leydon")
vampire.addDonor("Tushar","Virk")
vampire.addDonor("Kenvin","Yu")
vampire.addDonor("Some","Guy")

with open('inventory.json', 'r') as data_file:
    json_data = data_file.read()
    data = json.loads(json_data)
    for packet in data:
        bloodTypeStr = packet["type"]
        expiryDate = packet["expiryDate"]
        donorID = packet["donorID"]
        vampire.makeDeposit(bloodTypeStr,expiryDate,donorID)

while (True):
    cmd = input("$ ").upper().replace(" ","_")
    if (cmd == "QUIT"):
        break
    if not (processCommand(cmd)):
        print("'"+cmd+"'","is not a real command")
    print("---------------------------------")
print("Quitting....")