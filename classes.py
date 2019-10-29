import json
from abc import ABC
from flask_login import UserMixin
from enum import Enum
import csv
import json
import operator
import time
from datetime import datetime
from random import randint

class UserType(Enum): 
    DONOR = 0
    PATH_CENTRE = 1
    HOSPITAL = 2
    VAMPIRE = 3

class BloodType(Enum):
    O_NEG = 0
    O_POS = 1
    A_NEG = 2
    A_POS = 3
    B_NEG = 4
    B_POS = 5
    AB_NEG = 6
    AB_POS = 7

class BloodStatus(Enum):
    UNCLEAN = 0
    DISPOSED = 1
    CLEAN = 2
    IN_STORAGE = 3
    WITH_HOSPITAL = 4
    UNTESTED = 5
    ALMOST_EXPIRED = 6
    UNUSABLE = 7

class NotifType(Enum):
    NORMAL = 0
    WARNING = 1
    DANGER = 2

class MainSystem(ABC):
    def __init__(self):
        self._packetIDs = []
        self._donorIDs = []
        self._requestCounter = 0
        self._vampire = Vampire('password')
        self._donors = []
        self._pathCentres = []
        self._hospitals = []
        self._dump = []

        self.loadDonors()
        self.loadPathCentres()
        self.loadHospitals()
        self.loadVampireInventory()
        self.loadVampireSettings()

        
    def getVampire(self):
        return self._vampire

    def getDonors(self):
        return self._donors

    def addDonor(self,givenName,surname,email):
        nDonors = len(self._donors)
        newID = 'donor'+str(nDonors)
        self._donors.append(Donor(newID,givenName,surname,'password',email))
        self._donorIDs.append(newID)
        return newID

    def addPacket(self,user,bloodType,donateDate,donateLoc,donorID):
        d = self.get_user(donorID)
        if (d == None):
            return None
        newID = "packet"+str(randint(1111,9999))
        while newID in self._packetIDs:
            newID = "packet"+str(randint(1111,9999))
        self._packetIDs.append(newID)
        p = BloodPacket(newID,bloodType,donateDate,donateLoc,d.getID(),d.getGivenName(),d.getSurname())
        if (user._inventory.addPacket(p)):
            p.setCurrLoc(user.getID())
            return newID
        else:
            return None

    def disposePacket(self,user,packetID):
        p = user.removePacket(packetID)
        if (p == None):
            return False
        self._dump.append(p)
        return True

    def sendPacketByID(self,user,packetID,addressID):
        p = user.removePacket(packetID)
        if (p == None):
            return False
        if (p.getStatus() != BloodStatus.CLEAN):
            user.addPacket(p)
            return False
        address = self.get_user(addressID)
        # print('got address')
        if not (address.addPacket(p)):
            user.addPacket(p)
            return False
        else:
            return True

    def setPacketDate(self,user,packetID,expiryDate):
        return user.setPacketDate(packetID,expiryDate)
    
    def markPacket(self,user,packetID,newStatus):
        return user.markPacket(packetID,newStatus)

    def printInventory(self,user,field):
        user.printInventory(field)

    def searchInventory(self,user,field,value):
        user.searchInventory(field,BloodType[value].value)

    def printNotificatons(self,user):
        user.printNotificatons()

    def printLevels(self,user):
        user.printLevels()

    def setLevel(self,user,type,levelName,value):
        user.setLevel(BloodType[type],levelName,value)
    
    def showRequests(self,user):
        user.showRequests()

    def makeRequest(self,user,requestDate,type,nPackets,useBy):
        self._requestCounter += 1
        returnPackets = self._vampire.doRequest(BloodType[type],nPackets,useBy)
        if (returnPackets != None):
            for p in returnPackets:
                user.addPacket(p)
            return True
        else:
            return False

    def filterBadBlood(self,user):
        for id in user.filterBadBlood():
            self.disposePacket(user,id)
    
    def getPathCentres(self):
        return self._pathCentres

    def addPathCentre(self,newUser):
        return (self._pathCentres).append(newUser)
    
    def getHospitals(self):
        return self._hospitals

    def addHospital(self,newUser):
        return (self._hospitals).append(newUser)

    def get_user(self, id):
        if self._vampire.id == id:
            return self._vampire
        for user in self._donors:
            if user.id == id:
                return user
        for user in self._pathCentres:
            if user.id == id:
                return user
        for user in self._hospitals:
            if user.id == id:
                return user
        return None
        
    def loadDonors(self):
        with open('donors.json', 'r') as data_file:
            json_data = data_file.read()

        data = json.loads(json_data)
        for donor in data:
            donorID = donor['id']
            password = donor['password']
            givenName = donor['givenName']
            surname = donor['surname']
            email = donor['email']
            d = Donor(donorID,givenName,surname,password,email)

            self._donors.append(d)
            self._donorIDs.append(donorID)


    def loadPathCentres(self):
        with open('pathCentres.json', 'r') as data_file:
            json_data = data_file.read()

        data = json.loads(json_data)
        for pcentre in data:
            id = pcentre['id']
            name = pcentre['name']
            password = pcentre['password']
            pc = PathCentre(id,name,password)
            self._pathCentres.append(pc)

    def loadHospitals(self):
        with open('hospitals.json', 'r') as data_file:
            json_data = data_file.read()

        data = json.loads(json_data)
        for hospital in data:
            id = hospital['id']
            name = hospital['name']
            password = hospital['password']
            h = Hospital(id,name,password)
            self._hospitals.append(h)
    
    def loadVampireInventory(self):
        with open('vampireInventory.json', 'r') as data_file:
            json_data = data_file.read()
        # ,packetID,type,donateDate,donateLoc,donorID)
        data = json.loads(json_data)
        for packet in data:
            packetID = packet['packetID']
            type = packet['type']
            donateDate = packet['donateDate']
            donateLoc = packet['donateLoc']
            donorID = packet['donorID']
            status = BloodStatus[packet['status']]
            expiryDate = packet['expiryDate']
            currLoc = packet['currLoc']

            d = self.get_user(donorID)
            b = BloodPacket(packetID,type,donateDate,donateLoc,d.getID(),d.getGivenName(),d.getSurname())
            b.setStatus(status)
            b.setExpiry(expiryDate)
            b.setCurrLoc(currLoc)

            self._vampire.addPacket(b)

    def loadVampireSettings(self):
        for type in BloodType:
            self._vampire.setLevel(type,'lowLevel',2)
            self._vampire.setLevel(type,'maxLevel',10)

class User(UserMixin):
    def __init__(self,id,name,password,type):
        self.id = id
        self._name = name
        self._password = password
        self._type = type
        if type != UserType.DONOR:
            self._isCentre = True
        else:
            self._isCentre = False

    def getID(self):
        return self.id

    def getName(self):
        return self._name

    def getPassword(self):
        return self._password

    def getType(self):
        return self._type
    
    def getTypeName(self):
        return self._type.name

    def isCentre(self):
        return self._isCentre

class BloodPacket(object):
    def __init__(self,packetID,type,donateDate,donateLoc,donorID,donorFirstName,donorLastName):
        self._packetID = packetID
        self._type = BloodType[type]
        self._donateDate = donateDate
        self._donateLoc = donateLoc
        self._donorID = donorID
        self._donorFirstName = donorFirstName
        self._donorLastName = donorLastName
        self._events = []
        self._status = BloodStatus.UNTESTED
        self._expiryDate = -1
        self._currLoc = None
    
    def setExpiry(self,date):
        self._expiryDate = date

    def setCurrLoc(self,loc):
        self._currLoc = loc

    def getType(self):
        return self._type

    def getDonateDate(self):
        return self._donateDate

    def getDonateLoc(self):
        return self._donateLoc

    def getTypeName(self):
        return self.getType().name

    def getStatus(self):
        return self._status

    def getID(self):
        return self._packetID

    def getExpiryDate(self):
        return self._expiryDate

    def printSummary(self):
        print(self._packetID,self._type.name,datetime.fromtimestamp(self._donateDate),self._donateLoc,self._donorID,self._donorFirstName,self._donorLastName,self._status.name,datetime.fromtimestamp(self._expiryDate),self._currLoc)

    def setStatus(self,status):
        self._status = status

    # Return an integer/string version of it
    def getSortableField(self,field):
        if (field == "type"):
            return self._type.value
        elif (field == "donatedate"):
            return self._donateDate
        elif (field == "expirydate"):
            return self._expiryDate
        elif (field == "donateloc"):
            return self._donateLoc
        elif (field == "firstname"):
            return self._donorFirstName
        elif (field == "lastname"):
            return self._donorLastName
        elif (field == "currloc"):
            return self._currLoc
        return None


class Event(object):
    def __init__(self,packetID,status,location,otherInfo,date):
        self._packetID = packetID
        self._status = status
        self._location = location
        self._otherInfo = otherInfo
        self._date = date

class Donor(User):
    def __init__(self,donorID,givenName,surname,password,email):
        super().__init__(donorID,givenName+' '+surname,password,UserType.DONOR)
        self._givenName = givenName
        self._surname = surname
        self._email = email
    
    def getGivenName(self):
        return self._givenName
    
    def getSurname(self):
        return self._surname
    
    def getEmail(self):
        return self._email

class Centre(User):
    def __init__(self,centreID,centreName,password,type):
        super().__init__(centreID,centreName,password,type)
        self._inventory = Inventory()

    def addPacket(self,p):
        return self._inventory.addPacket(p)

    def getPacket(self,packetID):
        return self._inventory.getPacket(packetID)
    
    def removePacket(self,packetID):
        return self._inventory.removePacket(packetID)

    def printInventory(self,field):
        self._inventory.printInventory(field)

    def printLevels(self):
        self._inventory.printLevels()

    def disposePacket(self,packetID):
        p = self.getPacket(packetID)
        if (p == None):
            return p
        p.setStatus(BloodStatus.DISPOSED)
        self._inventory.removePacket(packetID)
        return p

    def searchInventory(self,field,value):
        self._inventory.searchInventory(field,value)

    def setLevel(self,type,levelName,value):
        if (levelName == "lowLevel"):
            self._inventory.setLowLevel(type,value)
        elif (levelName == "maxLevel"):
            self._inventory.setMaxLevel(type,value)

class Hospital(Centre):
    def __init__(self,hospitalID,hospitalName,password):
        super().__init__(hospitalID,hospitalName,password,UserType.HOSPITAL)

class Request(object):
    def __init__(self,requestID,hospitalID,requestDate,type,nPackets,useBy):
        self._requestID = requestID
        self._hospitalID = hospitalID
        self._requestDate = requestDate
        self._type = type
        self._nPackets = nPackets
        self._useBy = useBy

    def toString(self):
        return f"{self._requestID}: {self._hospitalID} wants {self._nPackets} packets of {self._type.name} blood by {self._requestDate} to be used by {self._useBy}"

class Notification(object):
    def __init__(self,date,type,packetIDs):
        self._date = date
        self._type = type #Normal, Warning or Danger
        self._packetIDs = packetIDs

    def printSummary(self):
        print("***Notif on:", datetime.fromtimestamp(self._date),"***")
        if (self._type == NotifType.WARNING):
            print("The following blood will soon expire:")
        elif (self._type == NotifType.DANGER):
            print("The following blood has expired:")
        for id in self._packetIDs:
            print("     ",id)

class Vampire(Centre):
    def __init__(self,password):
        super().__init__('vampire','Vampire',password,UserType.VAMPIRE)
        self._notifications = []
        self._requests = []
        self._warningPeriod = 10

    def addRequest(self,req):
        self._requests.append(req)

    def showRequests(self):
        for request in self._requests:
            print(request.toString())

    def doRequest(self,type,nPackets,useBy):
        return self._inventory.doRequest(type,nPackets,useBy)

    def printNotificatons(self):
        for notif in self._notifications:
            notif.printSummary()
    
    def setWarningPeriod(self,days):
        self._warningPeriod = days

    def filterBadBlood(self):
        badIDs = self._inventory.filterBadBlood(self._warningPeriod)
        badBlood = []
        almostBadBlood = []
        for id in badIDs:
            packet = self.getPacket(id)
            if (packet.getStatus() == BloodStatus.UNUSABLE):
                badBlood.append(id)
            elif (packet.getStatus() == BloodStatus.ALMOST_EXPIRED):
                almostBadBlood.append(id)

        if (badBlood != []):
            notif = Notification(time.time(),NotifType.DANGER,badBlood)
            self._notifications.append(notif)

        if (almostBadBlood != []):
            notif = Notification(time.time(),NotifType.WARNING,almostBadBlood)
            self._notifications.append(notif)

        return badBlood

class Inventory(object):
    def __init__(self):
        self._currBloodLevels = {}
        self._lowBloodLevels = {}
        self._maxBloodLevels = {}
        self._newPackets = [] #Untested
        self._goodPackets = [] #Verified
        self._badPackets = [] #Assume these are disposed

        for type in BloodType:
            self._currBloodLevels[type] = 0
            self._lowBloodLevels[type] = 1
            self._maxBloodLevels[type] = 10

    def addPacket(self,packet):
        self.updateCurrentLevels()
        type = packet.getType()
        if (packet.getStatus() == BloodStatus.UNCLEAN):
            self._badPackets.append(packet)
        elif (packet.getStatus() == BloodStatus.CLEAN):
            if (self._currBloodLevels[type] < self._maxBloodLevels[type]):
                self._goodPackets.append(packet)
                self.sortPackets(self._goodPackets)
            else:
                return False
        else:
            self._newPackets.append(packet)
        return True

    def sortPackets(self,a,field='expiryDate'):
        if (len(a) == 0):
            return True
        if (a[0].getSortableField(field) == None):
            return False
        i = len(a) - 1
        swapped = True
        while (i > 0 and swapped):
            swapped = False
            j = 0
            while (j < i):
                if a[j].getSortableField(field) > a[j+1].getSortableField(field):
                    a[j],a[j+1] = a[j+1],a[j]
                    swapped = True
                j += 1
            i -= 1
        return True

    def getNewPackets(self):
        return self._newPackets

    def getPacket(self,packetID):
        for packet in self._newPackets:
            if packet.getID() == packetID:
                return packet
        for packet in self._goodPackets:
            if packet.getID() == packetID:
                return packet
        for packet in self._badPackets:
            if packet.getID() == packetID:
                return packet
        return None

    def removePacket(self,packetID):
        for packet in self._newPackets:
            if packet.getID() == packetID:
                p = packet
                self._newPackets.remove(p)
                return p
        for packet in self._goodPackets:
            if packet.getID() == packetID:
                p = packet
                self._goodPackets.remove(p)
                return p
        for packet in self._badPackets:
            if packet.getID() == packetID:
                p = packet
                self._badPackets.remove(p)
                return p
        return None

    def updateCurrentLevels(self):
        for type in BloodType:
            self._currBloodLevels[type] = 0

        for packet in self._goodPackets:
            self._currBloodLevels[packet.getType()] += 1

    def getCurrentLevel(self,type):
        return self._currBloodLevels[type]

    def getLowLevel(self,type):
        return self._lowBloodLevels[type]

    def getMaxLevel(self,type):
        return self._maxBloodLevels[type]

    def setLowLevel(self,type,value):
        self._lowBloodLevels[type] = value

    def setMaxLevel(self,type,value):
        self._maxBloodLevels[type] = value

    def getSummary(self):
        self.printLevels()
        self.printInventory('expiryDate')
    
    def printInventory(self,field='expiryDate'):
        if not (self.sortPackets(self._goodPackets,field)):
            print("Can't sort by "+field)
            return

        print("----new Packets----")
        for packet in self._newPackets:
            packet.printSummary()

        print("----good Packets----")
        for packet in self._goodPackets:
            packet.printSummary()

        print("----bad Packets----")
        for packet in self._badPackets:
            packet.printSummary()

    def searchInventory(self,field,value):
        if not (self.sortPackets(self._goodPackets,field)):
            print("Can't search by "+field)
            return

        for packet in self._goodPackets:
            if (packet.getSortableField(field) == value):
                packet.printSummary()
    
    def printLevels(self):
        self.updateCurrentLevels()
        lowBlood = []
        for type in BloodType:
            print(type.name,str(self.getCurrentLevel(type))+'/'+str(self.getMaxLevel(type)))
            if (self.getCurrentLevel(type) <= self.getLowLevel(type)):
                lowBlood.append(type)
        if (lowBlood != []):
            print("The following types are in low levels")
            for type in lowBlood:
                print(type.name)

    def doRequest(self,type,nPackets,useBy):
        self.updateCurrentLevels()
        packets = []
        i = 0
        while i < len(self._goodPackets) and useBy < self._goodPackets[i].getExpiryDate() and len(packets) < nPackets:
            if (self._goodPackets[i].getType() == type):
                packets.append(self._goodPackets[i])
            i += 1
        
        if (len(packets) != nPackets):
            return None

        for p in packets:
            self._goodPackets.remove(p)

        return packets

    def setWarningPeriod(self,days):
        self._warningPeriod = days

    def filterBadBlood(self,days):
        now = time.time()
        targetBlood = []
        for packet in self._goodPackets:
            timeDiff = packet.getExpiryDate() - now
            if (timeDiff < 0):
                targetBlood.append(packet.getID())
                packet.setStatus(BloodStatus.UNUSABLE)
            elif (timeDiff < days*24*60*60):
                targetBlood.append(packet.getID())
                packet.setStatus(BloodStatus.ALMOST_EXPIRED)

        return targetBlood

class PathCentre(Centre):
    def __init__(self,pathCentreID,pathCentreName,password):
        super().__init__(pathCentreID,pathCentreName,password,UserType.PATH_CENTRE)

    def getPackets(self):
        return self._inventory.getNewPackets()

    def markPacket(self,packetID,status):
        newStatus = BloodStatus[status]
        p = self._inventory.getPacket(packetID)
        if (p == None):
            return False
        p.setStatus(newStatus)
        return True

    def setPacketDate(self,packetID,expiryDate):
        p = self._inventory.getPacket(packetID)
        if (p == None):
            return False
        p.setExpiry(expiryDate)
        return True