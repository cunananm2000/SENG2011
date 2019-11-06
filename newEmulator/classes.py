from algos import objectBubbleSort,objectSortedInsert,objectLinearSearch



    # def Login(self,loginID,password):
    #     if (loginID == "vampire"):
    #         if (password == self._password):
    #             return "vampire"
    #         else:
    #             return ""
    #     user = self._donorDatabase.login(loginID,password)
    #     if (user != None):
    #         self._currentUser = user
    #         return "donor"
    #     user = self._hospitalDatabase.login(loginID,password)
    #     if (user != None):
    #         return "hospital"

class System(object):
    def __init__(self):
        self._bloodTypeTable = {
            "O_NEG" : 0,
            "O_POS" : 1,
            "A_NEG" : 2,
            "A_POS" : 3,
            "B_NEG" : 4,
            "B_POS" : 5,
            "AB_NEG" : 6,
            "AB_POS" : 7
        }

        self._statusTable = {
            "UNCLEAN": 0,
            "CLEAN": 1
        }

        self._day = 0
        self._buffer = 1

        self._vampire = Vampire(len(self._bloodTypeTable))
        self._donorDatabase = DonorDatabase()
        self._hospitalDatabase = HospitalDatabase()
        self._bloodDatabase = BloodDatabase()

    def login(self,loginID,password):
        if (loginID == self._vampire.getID()):
            if (password == self._vampire.getPassword()):
                return self._vampire.getID()
            else:
                return ""
        user = self._donorDatabase.login(loginID,password)
        if (user != None):
            return user.getID()
        if (user !- None):
        user = self._hospitalDatabase.login(loginID,password)
            return user.getID()
        return = ""
        

    # Add a donor to the system
    def addDonor(self,firstName,lastName,password):
        self._donorDatabase.addDonor(firstName,lastName,password)

    def addHospital(self,name,password):
        self._hospitalDatabase.addHospital(name,password)

    def printHospitals(self):
        self._hospitalDatabase.printHospitals()

    def makeDeposit(self,bloodTypeStr,donateDate,donateLoc,expiryDate,donorID):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        d = self._donorDatabase.search(donorID)
        if d == None:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        firstName = d.getField("FIRST_NAME")
        lastName = d.getField("LAST_NAME")
        newPacket = self._bloodDatabase.addPacket(bloodIndex,donateDate,donateLoc,expiryDate,donorID,firstName,lastName)
        self._vampire.makeDeposit(newPacket)

    def makeRequest(self,bloodTypeStr,nPackets,useBy,dest):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        if self._hospitalDatabase.search(dest) == None:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        return self._vampire.makeRequest(bloodIndex,nPackets,useBy,dest)

    def searchBlood(self,field,value):
        val = value
        if (field == "TYPE" and value.upper().replace(" ","_") in self._bloodTypeTable):
            val = self._bloodTypeTable[value.upper().replace(" ","_")]
        packets = self._bloodDatabase.searchBlood(field,val)
        for p in packets:
            p.toString(self._day,self._buffer)

    def setLowLevel(self,bloodTypeStr,amount):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        self._vampire.setLowLevel(bloodIndex,amount)

    # Debugging
    def printDonors(self):
        self._donorDatabase.printDonors()

    # Debugging
    def printBlood(self,field):
        print("Current day:",self._day)
        self._bloodDatabase.printBlood(field,self._day,self._buffer)

    def searchDonor(self,id):
        d = self._donorDatabase.search(id)
        return d
    
    def printInventory(self,field):
        print("Current day:",self._day)
        self._vampire.printInventory(field,self._day,self._buffer)

    def cleanUp(self):
        self._vampire.cleanUp(self._day)

    def printLevels(self):
        self._vampire.printLevels()


class User(object):
    def __init__(self,id,password):
        self._id = id
        self._password = password

    def getID(self):
        return self._id

    def getPassword(self):
        return self._password

class Vampire(User):
    # Invariant: Day >= 0, increasing
    def __init__(self,nTypes):
        super().__init__("vampire","password")
        self._inventory = Inventory(nTypes)
        self._buffer = 1

    # Accept blood
    def makeDeposit(self,newPacket):
        self._inventory.addPacket(newPacket)
        return True

    # Give blood
    def makeRequest(self,bloodIndex,nPackets,useBy,dest):
        accepted = self._inventory.doRequest(bloodIndex,nPackets,useBy,dest)
        return accepted

    # Increment the day and remove bad blood
    def cleanUp(self,currDay):
        self._inventory.cleanUp(currDay)

    # Debugging
    def printInventory(self,field,currDay,buffer):
        print("Current day:",currDay)
        self._inventory.printInventory(field,currDay,buffer)

    def printLevels(self):
        self._inventory.printLevels()

    def setLowLevel(self,bloodIndex,amount):
        return self._inventory.setLowLevel(bloodIndex,amount)

    def login(self,loginID,password):
        if (loginID == "vampire"):
            if (password == self._password):
                return True
            else:
                return False
        

class Inventory(object):
    # Invariant: packets always sorted by expiry date
    def __init__(self,nBloodTypes):
        self._lowBloodLevels = [1] * nBloodTypes
        self._maxBloodLevels = [10] * nBloodTypes
        self._currBloodLevels = [0] * nBloodTypes
        self._packets = []

    def setLowLevel(self,bloodIndex,amount):
        if (amount <= 0):
            return False
        self._lowBloodLevels[bloodIndex] = amount
        return True

    def printLevels(self):
        i = 0
        while (i < len(self._currBloodLevels)):
            if (self._currBloodLevels[i] <= self._lowBloodLevels[i]):
                print(str(i)+": "+str(self._currBloodLevels[i])+"/"+str(self._maxBloodLevels[i])+" <----- Low Level")
            else:
                print(str(i)+": "+str(self._currBloodLevels[i])+"/"+str(self._maxBloodLevels[i]))
            i += 1

    # Put a packet into the inventory
    def addPacket(self,packetObj):
        bloodType = packetObj.getField("TYPE")
        if (self._currBloodLevels[bloodType] == self._maxBloodLevels[bloodType]):
            return
        self._currBloodLevels[bloodType] += 1
        objectSortedInsert(self._packets,"EXPIRY_DATE",packetObj)
        
    # Remove anything past expiry
    def cleanUp(self,currDay):
        trash = []
        for p in self._packets:
            if p.getField("EXPIRY_DATE") < currDay:
                trash.append(p)
        for p in trash:
            p.sendTo("dump")
            self._packets.remove(p)

    # Debugging, print the inventory
    def printInventory(self,field,currDay,buffer):
        objectBubbleSort(self._packets,field)
        for p in self._packets:
            p.toString(currDay,buffer)
        objectBubbleSort(self._packets,"EXPIRY_DATE")

    # Do the request
    def doRequest(self,type,nPackets,useBy,dest):
        sendPackets = []
        i = 0
        while i < len(self._packets) and len(sendPackets) < nPackets:
            if (self._packets[i].getField("TYPE") == type and useBy <= self._packets[i].getField("EXPIRY_DATE")):
                sendPackets.append(self._packets[i])
            i += 1

        if len(sendPackets) < nPackets:
            return False

        for p in sendPackets:
            self._packets.remove(p)
            bloodIndex = p.getField("TYPE")
            self._currBloodLevels[bloodIndex] -= 1
            p.sendTo(dest)

        return True

class BloodDatabase(object):
    # Invariant: Entries sorted by expiry date
    def __init__(self):
        self._entries = []
        self._sortedBy = "EXPIRY_DATE"

    def addPacket(self,bloodType,donateDate,donateLoc,expiryDate,donorID,firstName,lastName):
        p = BloodPacket(bloodType,donateDate,donateLoc,expiryDate,donorID,firstName,lastName)
        objectSortedInsert(self._entries,self._sortedBy,p)
        return p

    def printBlood(self,field,currDay,buffer):
        objectBubbleSort(self._entries,field)
        for p in self._entries:
            p.toString(currDay,buffer)
        objectBubbleSort(self._entries,self._sortedBy)

    def searchBlood(self,field,value):
        returnPackets = []
        for p in self._entries:
            if (p.getField(field) == value):
                returnPackets.append(p)
        return returnPackets

class BloodPacket(object):
    # Invariant: status >= 0 and currLoc >= 0
    # Invariant: old(status) == 0 ==> status == 0
    def __init__(self,bloodType,donateDate,donateLoc,expiryDate,donorID,firstName,lastName):
        self._bloodType = bloodType
        self._donateDate = donateDate
        self._donateLoc = donateLoc
        self._expiryDate = expiryDate
        self._donorID = donorID
        self._firstName = firstName
        self._lastName = lastName
        self._status = 1
        self._currLoc = "warehouse"
    
    def toString(self,currDay,buffer):
        if (self._expiryDate - currDay < 0):
            print("TYPE:",self._bloodType,"DON DATE:",self._donateDate,"DON LOC:",self._donateLoc,"EXP DATE:",self._expiryDate,"DONOR:",self._donorID,self._firstName,self._lastName,"STATUS:",self._status,"LOC:",self._currLoc,"<---- Expired")
        elif (self._expiryDate - currDay <= buffer):
            print("TYPE:",self._bloodType,"DON DATE:",self._donateDate,"DON LOC:",self._donateLoc,"EXP DATE:",self._expiryDate,"DONOR:",self._donorID,self._firstName,self._lastName,"STATUS:",self._status,"LOC:",self._currLoc,"<---- Almost expired")
        else:
            print("TYPE:",self._bloodType,"DON DATE:",self._donateDate,"DON LOC:",self._donateLoc,"EXP DATE:",self._expiryDate,"DONOR:",self._donorID,self._firstName,self._lastName,"STATUS:",self._status,"LOC:",self._currLoc)
        
    def getField(self,field):
        if (field == "TYPE"):
            return self._bloodType
        elif (field == "DONATE_DATE"):
            return self._donateDate
        elif (field == "DONATE_LOC"):
            return self._donateLoc
        elif (field == "EXPIRY_DATE"):
            return self._expiryDate
        elif (field == "DONOR_ID"):
            return self._donorID
        if (field == "FIRST_NAME"):
            return self._firstName
        elif (field == "LAST_NAME"):
            return self._lastName
        elif (field == "STATUS"):
            return self._status
        elif (field == "CURR_LOC"):
            return self._currLoc
        return -1

    def sendTo(self,dest):
        self._currLoc = dest
        if (dest == 0):
            self._status = 0

class UserDatabase(object):
    def __init__(self):
        self._entries = []

    def login(self,id,password):
        user = objectLinearSearch(self._entries,"ID",id)
        if (user.getPassword() == password):
            return user
        else:
            return None

class DonorDatabase(UserDatabase):
    def __init__(self):
        super().__init__()

    def addDonor(self,firstName,lastName,password):
        d = Donor(firstName,lastName,password,'donor'+str(len(self._entries)))
        objectSortedInsert(self._entries,"LAST_NAME",d)

    def printDonors(self):
        objectBubbleSort(self._entries,"LAST_NAME")
        for d in self._entries:
            d.toString()

    def search(self,id):
        return objectLinearSearch(self._entries,"ID",id)

class Donor(User):
    def __init__(self,firstName,lastName,password,id):
        super().__init__(id,password)
        self._firstName = firstName
        self._lastName = lastName

    def toString(self):
        print(self._id,self._firstName,self._lastName,self._password)

    def getField(self,field):
        if (field == "FIRST_NAME"):
            return self._firstName
        elif (field == "LAST_NAME"):
            return self._lastName
        elif (field == "ID"):
            return self._id
        elif (field == "PASSWORD"):
            return self._password
        return -1

class HospitalDatabase(UserDatabase):
    def __init__(self):
        super().__init__()

    def addHospital(self,name,password):
        h = Hospital('hospital'+str(len(self._entries)),name,password)
        objectSortedInsert(self._entries,"ID",h)

    def printHospitals(self):
        for h in self._entries:
            h.toString()

    def search(self,id):
        return objectLinearSearch(self._entries,"ID",id)

class Hospital(User):
    def __init__(self,id,name,password):
        super().__init__(id,password)
        self._name = name

    def toString(self):
        print(self._id,self._password)

    def getField(self,field):
        if (field == "ID"):
            return self._id
        elif (field == "PASSWORD"):
            return self._password
        return -1