from classes import *

system = MainSystem()
currentUser = None
def login():
    userType = input("Login Type (DONOR|PATH_CENTRE|HOSPITAL|VAMPIRE): ")
    loginID = input("Login ID: ")
    password = input("Password: ")
    userList = []
    if userType == "DONOR":
        userList = system.getDonors()
    elif userType == "PATH_CENTRE":
        userList = system.getPathCentres()
    elif userType == "HOSPITAL":
        userList = system.getHospitals()
    elif userType == "VAMPIRE":
        userList.append(system.getVampire())
    
    for user in userList:
        if user.id == loginID and user.getPassword() == password:
            global currentUser
            currentUser = user
            return True
    
    return False

def showHelp():
    global currentUser
    print("You can use commands:")
    if (currentUser == None):
        print("LOGIN - Login")
    elif (currentUser.getType() == UserType.DONOR):
        print("You can't do sht yet")
        print("Have a nice day")
    elif (currentUser.getType() == UserType.PATH_CENTRE):
        print("ADD_DONOR - Add a new donor")
        print("ADD_BLOOD - Add a new packet of blood")
        print("CHECK_INVENTORY - Check the inventory")
        print("MARK_BLOOD - Mark blood as clean/unclean")
        print("SEND_BLOOD - Send a specific packet to vampire")
    elif (currentUser.getType() == UserType.HOSPITAL):
        print("ADD_DONOR - Add a new donor")
        print("ADD_BLOOD - Add a new packet of blood")
        print("CHECK_INVENTORY - Check the inventory")
        print("MARK_BLOOD - Mark blood as clean/unclean")
        print("SEND_BLOOD - Send a specific packet to vampire")
    elif (currentUser.getType() == UserType.VAMPIRE):
        print("CHECK_INVENTORY - Check the inventory")
        print("CHECK_BLOOD_LEVELS - Get a summary of the blood levels")
    print("LOGOUT - Logout")

def normalCommand(cmd):
    global currentUser
    if (cmd == "LOGIN"):
        if (login()):
            print("Log in succeeded, hello",currentUser.getName())
            print("Type LOGOUT to logout")
        else:
            print("Log in failed")
        return True
    return False

def donorCommand(cmd):
    return True

def processCommand(cmd):
    global currentUser
    if (cmd == "HELP"):
        showHelp()
        return True
    else:
        if (currentUser == None):
            return normalCommand(cmd)
        else:
            type = currentUser.getType()
            if (cmd == "LOGOUT"):
                return logout()
            elif (type == UserType.DONOR):
                return donorCommand(cmd)
            elif (type == UserType.PATH_CENTRE):
                return pathCentreCommand(cmd)
            elif (type == UserType.VAMPIRE):
                return vampireCommand(cmd)
            elif (type == UserType.HOSPITAL):
                return hospitalCommand(cmd)
            
        return False

def addDonor():
    givenName = input("Given Name: ")
    familyName = input("Family Name: ")
    email = input("Email: ")

    newID = system.addDonor(givenName,familyName,email)

    print("New ID:",newID,", Password: password")
    return True

def addBlood():
    bloodType = input("Blood type (O_NEG,O_POS,etc.): ")
    donateDate = input("Date (DD/MM/YYYY): ")
    donateLoc = input("Location: ")

    system.addPacket(currentUser,bloodType,donateDate,donateLoc)
    print("Packet added!")
    return True

def markBlood():
    packetID = input("Packet ID: ")
    newStatus = input("New status (CLEAN/UNCLEAN): ")
    currentUser.markPacket(packetID,newStatus)
    print("Status of",packetID,"set to",newStatus)
    return True

def sendBlood():
    packetID = input("Packet ID: ")
    hospitalID = input("Hospital ID: ")
    if (system.sendPacket(currentUser,packetID,hospitalID)):
        print("Sent packet",packetID,"to",hospitalID)
        return True
    else:
        print("Bad request")
        return False

def pathCentreCommand(cmd):
    found = True
    if (cmd == "ADD_DONOR"):
        addDonor()
    elif (cmd == "ADD_BLOOD"):
        addBlood()
    elif (cmd == "CHECK_INVENTORY"):
        currentUser.printInventory()
    elif (cmd == "MARK_BLOOD"):
        markBlood()
    elif (cmd == "SEND_BLOOD"):
        sendBlood()
    else:
        found = False
    return found

def vampireCommand(cmd):
    found = True
    if (cmd == "CHECK_INVENTORY"):
        currentUser.printInventory()
    else:
        found = False
    return found

def hospitalCommand(cmd):
    print("TODO")
    return True

def showStatus():
    global currentUser
    if (currentUser == None):
        print("Not logged in")
    else:
        print("Name: ",currentUser.getName())
        print("Type: ",currentUser.getTypeName())

def logout():
    global currentUser
    currentUser = None
    print("Logging out...")
    return True

on = True
print("Type 'QUIT' to quit, 'STATUS' for your current info, 'HELP' for available commands")
while on:
    cmd = input("$ ")
    tempCmd = cmd.upper()
    tempCmd = tempCmd.replace(' ','_')
    if (tempCmd == "QUIT"):
        print("Shutting down...")
        on = False
    elif (tempCmd == "STATUS"):
        showStatus()
    else:
        if not (processCommand(tempCmd)):
            print("'"+cmd+"'",'is not a real command')
    print("----------------------------")
