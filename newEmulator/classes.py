from algos import objectBubbleSort,objectSortedInsert,objectLinearSearch

class User(object):
    def __init__(self,type):
        self._type = type

class Vampire(object):
    # Invariant: Day >= 0, increasing
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

        self._locationTable = {
            "DUMP": 0,
            "VAMPIRE": 1
        }

        self._inventory = Inventory(len(self._bloodTypeTable))

        self._donorDatabase = DonorDatabase()
        self._bloodDatabase = BloodDatabase()

        self._day = 0
        self._buffer = 1

#     method containsValue(m: map<int,char>, val: char) returns (b: bool) 
#     ensures b <==> exists i :: i in m && m[i] == val;
# {
#     return val in m.Values;
# }

    # Add a donor to the system
    def addDonor(self,firstName,lastName,password):
        self._donorDatabase.addDonor(firstName,lastName,password)

    def addLocation(self,loc):
        self._locationTable[loc] = len(self._locationTable)

    def printLocations(self):
        for key in self._locationTable:
            print(str(self._locationTable[key])+":",key)

    # Accept blood
    def makeDeposit(self,bloodTypeStr,donateDate,donateLoc,expiryDate,donorID):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        d = self._donorDatabase.search(donorID)
        if d == None:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        newPacket = self._bloodDatabase.addPacket(bloodIndex,donateDate,donateLoc,expiryDate,donorID,d.getField("FIRST_NAME"),d.getField("LAST_NAME"))
        self._inventory.addPacketID(newPacket)
        return True

    # Give blood
    def makeRequest(self,bloodTypeStr,nPackets,useBy,dest):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        if dest not in self._locationTable:
            self.addLocation(dest)
        destIndex = self._locationTable[dest]
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        accepted = self._inventory.doRequest(bloodIndex,nPackets,useBy,destIndex)
        return accepted

    # Increment the day and remove bad blood
    def cleanUp(self):
        self._day += 1
        self._inventory.cleanUp(self._day)

    # Debugging
    def printInventory(self,field):
        print("Current day:",self._day)
        self._inventory.printInventory(field,self._day,self._buffer)

    # Debugging
    def printDonors(self,field):
        self._donorDatabase.printDonors(field)

    # Debugging
    def printBlood(self,field):
        print("Current day:",self._day)
        self._bloodDatabase.printBlood(field,self._day,self._buffer)

    # Search blood database
    def searchBlood(self,field,value):
        val = value
        if (field == "TYPE" and value.upper().replace(" ","_") in self._bloodTypeTable):
            val = self._bloodTypeTable[value.upper().replace(" ","_")]
        packets = self._bloodDatabase.searchBlood(field,val)
        for p in packets:
            p.toString(self._day,self._buffer)

    def printLevels(self):
        self._inventory.printLevels()

    def searchDonor(self,id):
        d = self._donorDatabase.search(id)
        return d

    def setLowLevel(self,bloodTypeStr,amount):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        return self._inventory.setLowLevel(bloodIndex,amount)

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
    def addPacketID(self,packetObj):
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
            p.sendTo(0)
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
        self._currLoc = 1
    
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

class DonorDatabase(object):
    def __init__(self):
        self._entries = []
        self._sortedBy = "LAST_NAME"

    def addDonor(self,firstName,lastName,password):
        d = Donor(firstName,lastName,password,'donor'+str(len(self._entries)))
        objectSortedInsert(self._entries,self._sortedBy,d)

    def printDonors(self,field):
        objectBubbleSort(self._entries,field)
        self._sortedBy = field
        for d in self._entries:
            d.toString()

    def search(self,id):
        return objectLinearSearch(self._entries,"ID",id)

class Donor(object):
    def __init__(self,firstName,lastName,password,id):
        self._id = id
        self._firstName = firstName
        self._lastName = lastName
        self._password = password

    def toString(self):
        print(self._id,self._firstName,self._lastName,self._password)

    def getField(self,field):
        if (field == "FIRST_NAME"):
            return self._firstName
        elif (field == "LAST_NAME"):
            return self._lastName
        elif (field == "ID"):
            return self._id
        return -1