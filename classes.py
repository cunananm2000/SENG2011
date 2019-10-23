import json
from abc import ABC
from flask_login import UserMixin
from flask_table import Table, Col, LinkCol, ButtonCol
from enum import Enum
import csv
import json
import operator

class MainSystem(ABC):
    def __init__(self):
        self._packetIDs = []
        self._vampire = Vampire('password')
        self._donors = []
        self._pathCentres = []
        self._hospitals = []
        self._dump = []

        self.loadDonors()
        self.loadPathCentres()
        self.loadHospitals()

        
    def getVampire(self):
        return self._vampire

    def getDonors(self):
        return self._donors

    def addDonor(self,givenName,familyName,email):
        nDonors = len(self._donors)
        newID = 'donor'+str(nDonors)
        self._donors.append(Donor(newID,givenName,familyName,'password',email))
        return newID

    def addPacket(self,user,bloodType,donateDate,donateLoc):
        newID = "packet"+str(len(self._packetIDs))
        p = BloodPacket(newID,bloodType,donateDate,donateLoc)
        user._inventory.addPacket(p)

    def disposePacket(self,user,packetID):
        p = user.removePacket(packetID)
        self._dump.append(p)

    def sendPacket(self,user,packetID,addressID):
        p = user.removePacket(packetID)
        if (p.getStatus() != BloodStatus.CLEAN):
            user.addPacket(p)
            return False
        address = self.get_user(addressID)
        address.addPacket(p)
        return True
    
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
        
    def loadDonors(self):
        with open('donors.json', 'r') as data_file:
            json_data = data_file.read()

        data = json.loads(json_data)
        for donor in data:
            donorID = donor['id']
            password = donor['password']
            givenName = donor['givenName']
            familyName = donor['familyName']
            email = donor['email']
            d = Donor(donorID,givenName,familyName,password,email)
            self._donors.append(d)


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

def getLineCount(file):
	return sum(1 for line in open(file))

def stringToID(string):
    string = string.replace(' ','')
    string = string[::-1]
    return string

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
    def __init__(self,packetID,type,donateDate,donateLoc):
        self._packetID = packetID
        self._type = BloodType[type]
        self._donateDate = donateDate
        self._donateLoc = donateLoc
        self._donorID = "madlad"
        self._events = []
        self._status = BloodStatus.UNTESTED
    
    def setExpiry(self,date):
        self._expireDate = date

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

    def printSummary(self):
        print(self._packetID,self._type.name,self._donateDate,self._donateLoc,self._donorID,self._status)

    def setStatus(self,status):
        self._status = status

class Event(object):
    def __init__(self,packetID,status,location,otherInfo,date):
        self._packetID = packetID
        self._status = status
        self._location = location
        self._otherInfo = otherInfo
        self._date = date

class Donor(User):
    def __init__(self,donorID,givenName,familyName,password,email):
        super().__init__(donorID,givenName+' '+familyName,password,UserType.DONOR)
        self._givenName = givenName
        self._familyName = familyName
        self._email = email
    
    def getGivenName(self):
        return self._givenName
    
    def getFamilyName(self):
        return self._familyName
    
    def getEmail(self):
        return self._email

class Centre(User):
    def __init__(self,centreID,centreName,password,type):
        super().__init__(centreID,centreName,password,type)
        self._inventory = Inventory()

    def addPacket(self,p):
        self._inventory.addPacket(p)

    def getPacket(self,packetID):
        return self._inventory.getPacket(packetID)
    
    def removePacket(self,packetID):
        return self._inventory.removePacket(packetID)

    def printInventory(self):
        self._inventory.printInventory()

    def disposePacket(self,packetID):
        p = self.getPacket(packetID)
        p.setStatus(BloodStatus.DISPOSED)
        self._inventory.removePacket(packetID)
        return p

class Hospital(Centre):
    def __init__(self,hospitalID,hospitalName,password):
        super().__init__(hospitalID,hospitalName,password,UserType.HOSPITAL)

class Request(object):
    def __init__(self,hospitalID,requestDate,type,mL,useBy):
        self._hospitalID = hospitalID
        self._requestDate = requestDate
        self._type = type
        self._mL = mL
        self._useBy = useBy

class Notification(object):
    def __init__(self,date,type,message,packetIDs):
        self._date = date
        self._type = type
        self._message = message
        self._packetIDs = packetIDs

class Vampire(Centre):
    def __init__(self,password):
        super().__init__('vampire','Vampire',password,UserType.VAMPIRE)
        self._notifications = []
        self._requests = []

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
            self._lowBloodLevels[type] = 0
            self._maxBloodLevels[type] = 100

    def addPacket(self,packet):
        if (packet.getStatus() == BloodStatus.UNCLEAN):
            self._badPackets.append(packet)
        elif (packet.getStatus() == BloodStatus.CLEAN):
            self._goodPackets.append(packet)
        else:
            self._newPackets.append(packet)
        self.updateCurrentLevels()
        # self.getSummary()

    def getNewPackets(self):
        # print(self._newPackets)
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

    def updateCurrentLevels(self):
        for type in BloodType:
            self._currBloodLevels[type] = 0

        for packet in self._newPackets:
            self._currBloodLevels[packet.getType()] += 1
        for packet in self._goodPackets:
            self._currBloodLevels[packet.getType()] += 1

    def getCurrentLevel(self,type):
        return self._currBloodLevels[type]

    def getSummary(self):
        for type in BloodType:
            print(type.name,self.getCurrentLevel(type))

        self.printInventory()
    
    #for debugging
    def printInventory(self):
        print("----new Packets----")
        for packet in self._newPackets:
            packet.printSummary()

        print("----good Packets----")
        for packet in self._goodPackets:
            packet.printSummary()

        print("----bad Packets----")
        for packet in self._badPackets:
            packet.printSummary()


class PathCentre(Centre):
    def __init__(self,pathCentreID,pathCentreName,password):
        super().__init__(pathCentreID,pathCentreName,password,UserType.PATH_CENTRE)

    def getPackets(self):
        return self._inventory.getNewPackets()

    def markPacket(self,packetID,status):
        newStatus = BloodStatus[status]
        p = self._inventory.removePacket(packetID)
        p.setStatus(newStatus)
        self.addPacket(p)