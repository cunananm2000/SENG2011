from algos import objectBubbleSort,objectSortedInsert,objectLinearSearch,notifSortedInsert
from enum import Enum

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
            "BAD": 0,
            "ALMOST_BAD": 1,
            "CLEAN": 2
        }

        self._day = 0
        self._buffer = 1

        self._vampire = Vampire(len(self._bloodTypeTable))
        self._donorDatabase = DonorDatabase()
        self._hospitalDatabase = HospitalDatabase()
        self._pathCentreDatabase = PathCentreDatabase()
        self._bloodDatabase = BloodDatabase()

    def login(self,loginID,password):
        if (loginID == self._vampire.getID()):
            if (password == self._vampire.getPassword()):
                return self._vampire.getID(),"vampire"
            else:
                return "",""
        user = self._donorDatabase.login(loginID,password)
        if (user != None):
            return user.getID(),"donor"
        user = self._hospitalDatabase.login(loginID,password)
        if (user != None):
            return user.getID(),"hospital"
        user = self._pathCentreDatabase.login(loginID,password)
        if (user != None):
            return user.getID(),"pathCentre"
        return "",""
        
    # Add a donor to the system
    def addDonor(self,firstName,lastName,password):
        return self._donorDatabase.addDonor(firstName,lastName,password)

    def addHospital(self,name,password):
        self._hospitalDatabase.addHospital(name,password)

    def addPathCentre(self,name,password):
        self._pathCentreDatabase.addPathCentre(name,password)

    def printHospitals(self):
        self._hospitalDatabase.printHospitals()

    def printPathCentres(self):
        self._pathCentreDatabase.printPathCentres()

    def makeDeposit(self,bloodTypeStr,donateDate,donateLoc,expiryDate,donorID):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        d = self._donorDatabase.search(donorID)
        if d == None:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        firstName = d.getField("FIRST_NAME")
        lastName = d.getField("LAST_NAME")
        newPacket = self._vampire.makeDeposit(self._day,bloodIndex,donateDate,donateLoc,expiryDate,donorID,firstName,lastName)
        if (newPacket != None):
            self._bloodDatabase.addPacket(newPacket)
            return True
        else:
            return False

    def makeRequest(self,bloodTypeStr,nPackets,useBy,dest):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        if self._hospitalDatabase.search(dest) == None:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        return self._vampire.makeRequest(self._day,bloodIndex,nPackets,useBy,dest)

    def searchBlood(self,field,value):
        val = value
        if (field == "TYPE" and value.upper().replace(" ","_") in self._bloodTypeTable):
            val = self._bloodTypeTable[value.upper().replace(" ","_")]
        packets = self._bloodDatabase.searchBlood(field,val)
        print("Current day:",self._day)
        for p in packets:
            p.toString()

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
        self._day += 1
        self._vampire.cleanUp(self._day,self._buffer)

    def printLevels(self):
        self._vampire.printLevels(self._day)

    def setWarning(self,buffer):
        self._buffer = buffer

    def setMaxLevel(self,bloodTypeStr,amount):
        if bloodTypeStr not in self._bloodTypeTable:
            return False
        bloodIndex = self._bloodTypeTable[bloodTypeStr]
        self._vampire.setMaxLevel(bloodIndex,amount)

    def printNotifs(self):
        self._vampire.printNotifs()

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
        self._buffer = 1
        self._notifs = []
        self._piles = []
        self._packetID = 0

        i = 0
        while (i < nTypes):
            self._piles.append(PacketPile(10,1))
            i += 1

        # self._notifPriorityTable = ["EXPIRED_PACKETS","LOW_BLOOD_LEVELS","ALMOST_EXPIRED","REQUEST_MADE","DEPOSIT_MADE"]
        self._notifPriorityTable = {
            "EXPIRED_PACKETS": 0,
            "LOW_BLOOD_LEVELS": 1,
            "ALMOST_EXPIRED": 2,
            "REQUEST_MADE": 3,
            "DEPOSIT_MADE": 4
        }

        self._notifMsgTable = {
            "EXPIRED_PACKETS": "The following packets have expired:",
            "LOW_BLOOD_LEVELS": "The following levels are very low:",
            "ALMOST_EXPIRED": "The following packets are about to expire:",
            "REQUEST_MADE": "The following packets were sent to",
            "DEPOSIT_MADE": "The following packet was just deposited from"
        }

    # Accept blood
    def makeDeposit(self,currDay,bloodIndex,donateDate,donateLoc,expiryDate,donorID,firstName,lastName):
        newID = 'packet'+str(self._packetID)
        p = BloodPacket(newID,bloodIndex,donateDate,donateLoc,expiryDate,donorID,firstName,lastName)
        # print("PUSHING",newID,"TO",bloodType)
        self._piles[bloodIndex].Push(p)
        self._packetID += 1

        typeStr = "DEPOSIT_MADE"
        priority = self._notifPriorityTable[typeStr]
        desc = self._notifMsgTable[typeStr] + " " + donateLoc
        things = [newID]
        n = Notification(priority,typeStr,desc,currDay,things)
        notifSortedInsert(self._notifs,n)

        return p
    
    # Give blood
    def makeRequest(self,currDay,bloodIndex,nPackets,useBy,dest):
        packets = self._piles[bloodIndex].doRequest(nPackets,useBy,dest)

        if (len(packets) > 0):
            typeStr = "REQUEST_MADE"
            priority = self._notifPriorityTable[typeStr]
            desc = self._notifMsgTable[typeStr] + " " + dest
            things = []
            i = 0
            while (i < len(packets)):
                things.append(packets[i].getField("ID"))
                i += 1
            n = Notification(priority,typeStr,desc,currDay,things)
            notifSortedInsert(self._notifs,n)
            return True
        return False
    # Increment the day and remove bad blood
    def cleanUp(self,currDay,buffer):
        expired = []
        almostExpired = []
        i = 0
        while (i < len(self._piles)):
            newExpired,newAlmostExpired = self._piles[i].cleanUp(currDay,buffer)
            expired += newExpired
            almostExpired += newAlmostExpired
            i += 1
        
        if (len(expired) > 0):
            typeStr = "EXPIRED_PACKETS"
            priority = self._notifPriorityTable[typeStr]
            desc = self._notifMsgTable[typeStr]
            things = []
            i = 0
            while (i < len(expired)):
                things.append(expired[i].getField("ID"))
                i += 1
            n = Notification(priority,typeStr,desc,currDay,things)
            notifSortedInsert(self._notifs,n)

        if (len(almostExpired) > 0):
            typeStr = "ALMOST_EXPIRED"
            priority = self._notifPriorityTable[typeStr]
            desc = self._notifMsgTable[typeStr]
            things = []
            i = 0
            while (i < len(almostExpired)):
                things.append(almostExpired[i].getField("ID"))
                i += 1
            n = Notification(priority,typeStr,desc,currDay,things)
            notifSortedInsert(self._notifs,n)

        lows = []
        i = 0
        while (i < len(self._piles)):
            if (self._piles[i].isLow()):
                lows.append(str(i))
            i += 1
        if (len(lows) > 0):
            typeStr = "LOW_BLOOD_LEVELS"
            priority = self._notifPriorityTable[typeStr]
            desc = self._notifMsgTable[typeStr]
            n = Notification(priority,typeStr,desc,currDay,lows)
            notifSortedInsert(self._notifs,n)

    def printNotifs(self):
        i = 0
        while (i < len(self._notifs)):
            self._notifs[i].toString()
            i += 1
        
    # Debugging
    def printInventory(self,field,currDay,buffer):
        everything = []
        for p in self._piles:
            everything += p.getBuf()
        objectBubbleSort(everything,field)
        for p in everything:
            p.toString()

    def printLevels(self,currDay):
        i = 0
        while (i < len(self._piles)):
            self._piles[i].printLevel()
            i += 1

        lows = []
        i = 0
        while (i < len(self._piles)):
            if (self._piles[i].isLow()):
                lows.append(str(i))
            i += 1
        if (len(lows) > 0):
            typeStr = "LOW_BLOOD_LEVELS"
            priority = self._notifPriorityTable[typeStr]
            desc = self._notifMsgTable[typeStr]
            n = Notification(priority,typeStr,desc,currDay,lows)
            notifSortedInsert(self._notifs,n)

    def setLowLevel(self,bloodIndex,amount):
        return self._piles[bloodIndex].setLow(amount)

    def setMaxLevel(self,bloodIndex,amount):
        return self._piles[bloodIndex].Resize(amount)

    def login(self,loginID,password):
        if (loginID == "vampire"):
            if (password == self._password):
                return True
            else:
                return False

class BloodDatabase(object):
    # Invariant: Entries sorted by expiry date
    def __init__(self):
        self._entries = []

    def addPacket(self,newPacket):
        objectSortedInsert(self._entries,"EXPIRY_DATE",newPacket)

    def printBlood(self,field,currDay,buffer):
        objectBubbleSort(self._entries,field)
        for p in self._entries:
            p.toString()
        objectBubbleSort(self._entries,"EXPIRY_DATE")

    def searchBlood(self,field,value):
        objectBubbleSort(self._entries,field)
        returnPackets = []
        for p in self._entries:
            if (p.getField(field) == value):
                returnPackets.append(p)
        objectBubbleSort(self._entries,"EXPIRY_DATE")
        return returnPackets

class BloodPacket(object):
    # Invariant: status >= 0 and currLoc >= 0
    # Invariant: old(status) == 0 ==> status == 0
    def __init__(self,id,bloodType,donateDate,donateLoc,expiryDate,donorID,firstName,lastName):
        self._id = id
        self._bloodType = bloodType
        self._donateDate = donateDate
        self._donateLoc = donateLoc
        self._expiryDate = expiryDate
        self._donorID = donorID
        self._firstName = firstName
        self._lastName = lastName
        self._status = 2
        self._currLoc = "warehouse"
    
    def toString(self):
        if (self._status == 0):
            print(self._id, "TYPE:",self._bloodType,"DON DATE:",self._donateDate,"DON LOC:",self._donateLoc,"EXP DATE:",self._expiryDate,"DONOR:",self._donorID,self._firstName,self._lastName,"STATUS:",self._status,"LOC:",self._currLoc,"<---- Expired")
        elif (self._status == 1):
            print(self._id, "TYPE:",self._bloodType,"DON DATE:",self._donateDate,"DON LOC:",self._donateLoc,"EXP DATE:",self._expiryDate,"DONOR:",self._donorID,self._firstName,self._lastName,"STATUS:",self._status,"LOC:",self._currLoc,"<---- Almost expired")
        else:
            print(self._id, "TYPE:",self._bloodType,"DON DATE:",self._donateDate,"DON LOC:",self._donateLoc,"EXP DATE:",self._expiryDate,"DONOR:",self._donorID,self._firstName,self._lastName,"STATUS:",self._status,"LOC:",self._currLoc)
        
    def getField(self,field):
        if (field == "ID"):
            return self._id
        elif (field == "TYPE"):
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

    def setStatus(self,status):
        self._status = status

class UserDatabase(object):
    def __init__(self):
        self._entries = []

    def login(self,id,password):
        user = objectLinearSearch(self._entries,"ID",id)
        if (user != None and user.getPassword() == password):
            return user
        else:
            return None

class DonorDatabase(UserDatabase):
    def __init__(self):
        super().__init__()

    def addDonor(self,firstName,lastName,password):
        newID = 'donor'+str(len(self._entries))
        d = Donor(firstName,lastName,password,newID)
        objectSortedInsert(self._entries,"LAST_NAME",d)
        return newID

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

class PathCentreDatabase(UserDatabase):
    def __init__(self):
        super().__init__()
    
    def addPathCentre(self,name,password):
        pc = PathCentre('path'+str(len(self._entries)),name,password)
        objectSortedInsert(self._entries,"ID",pc)

    def printPathCentres(self):
        for pc in self._entries:
            pc.toString()

    def search(self,id):
        return objectLinearSearch(self._entries,"ID",id)

class PathCentre(User):
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

class PacketPile(object):
    def __init__(self,n,low):
        self._buf = [None]*n
        self._count = 0
        self._low = low

    #Ensure that nothing between 0 and count is None
    def Pop(self,n):
        if (n < 0 or n >= self._count):
            return None
        el = self._buf[n]
        i = 0
        while (i < self._count - 1):
            self._buf[i] = self._buf[i+1]
            i += 1
        self._count -= 1
        return el

    def Push(self,el):
        if (self._count == len(self._buf)):
            p = self.Pop(0)
            p.setStatus(0)
            p.sendTo("dump")
        n = 0
        while (n < self._count and self._buf[n].getField("EXPIRY_DATE") < el.getField("EXPIRY_DATE")):
            n += 1
        i = self._count-1
        while (i >= n):
            self._buf[i+1] = self._buf[i]
            i -= 1
        self._count += 1
        self._buf[n] = el

    def Remove(self,el):
        i = 0
        while (i < self._count and self._buf[i] != el):
            i += 1
        if (i == self._count):
            return None
        return self.Pop(i)
        

    def Resize(self,n):
        newBuf = [None]*n
        i = 0
        while (i < n and i < len(self._buf)):
            newBuf[i] = self._buf[i]
            i += 1
        self._buf = newBuf

    def isLow(self):
        return (self._count <= self._low)

    def setLow(self,low):
        self._low = low

    def getSize(self):
        return len(self._buf)

    def getCount(self):
        return self._count

    def cleanUp(self,currDay,buffer):
        trash = []
        almostTrash = []
        i = 0
        while i < self._count:
            p = self._buf[i]
            if p.getField("EXPIRY_DATE") - currDay <= 0:
                trash.append(p)
                p.setStatus(0)
            elif p.getField("EXPIRY_DATE") - currDay <= buffer:
                almostTrash.append(p)
                p.setStatus(1)
            i += 1
        i = 0
        while (i < len(trash)):
            self.Remove(trash[i])
            i += 1
        return trash,almostTrash
    
    def getBuf(self):
        packets = [None]*self._count
        i = 0
        while (i < self._count):
            packets[i] = self._buf[i]
            i += 1
        return packets

    def printLevel(self):
        if (self.isLow()):
            print(str(self._count)+"/"+str(len(self._buf))+" <----- Low level")
        else:
            print(str(self._count)+"/"+str(len(self._buf)))

    def doRequest(self,nPackets,useBy,dest):
        sendPackets = []

        i = 0
        while i < len(self._buf) and len(sendPackets) < nPackets:
            if (useBy <= self._buf[i].getField("EXPIRY_DATE")):
                sendPackets.append(self._buf[i])
            i += 1

        if len(sendPackets) < nPackets:
            return []

        for p in sendPackets:
            p.sendTo(dest)
            self.Remove(p)
        
        return sendPackets

    def printPackets(self):
        for p in self._buf:
            if p == None:
                break
            p.toString()

class Notification(object):
    def __init__(self,priority,typeStr,desc,date,things):
        self._priority = priority
        self._typeStr = typeStr
        self._desc = desc
        self._date = date
        self._things = things

    def getDate(self):
        return self._date

    def getPriority(self):
        return self._priority
    
    def toString(self):
        print("************************")
        print("* TYPE:",self._typeStr)
        print("* DATE:",self._date)
        print("* DESC:",self._desc)
        if (len(self._things) > 0):
            i = 0
            while (i < len(self._things)):
                print("*    -",self._things[i])
                i += 1
        else:
            print("NO DETIALS?")
        print("************************")