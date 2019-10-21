from abc import ABC
from flask_login import UserMixin
from flask_table import Table, Col, LinkCol, ButtonCol
from enum import Enum 
  
class UserType(Enum): 
    DONOR = 1
    PATH_CENTRE = 2
    HOSPITAL = 3
    VAMPIRE = 4

class User(UserMixin):
    def __init__(self,id,name,password,type):
        self.id = id
        self._name = name
        self._password = password
        self._type = type

    def getName(self):
        return self._name

    def getPassword(self):
        return self._password

    def getType(self):
        return self._type

class BloodPacket(object):
    def __init__(self,packetID,type,ml,donateDate,expireDate,donorID):
        self._packetID = packetID
        self._type = type
        self._ml = ml
        self._donateDate = donateDate
        self._expireDate = expireDate
        self._donorID = donorID
        self._events = []
        self._status = "TBD"

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

class Hospital(User):
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

class Vampire(User):
    def __init__(self,password):
        super().__init__('vampire','Vampire',password,UserType.VAMPIRE)
        self._notifications = []
        self._requests = []

class Inventory(object):
    def __init__(self):
        self._currBloodLevels = []
        self._lowBloodLevels = []
        self._maxBloodLevels = []
        self._goodPackets = []
        self._badPackets = []

class PathCentre(User):
    def __init__(self,pathCentreID,pathCentreName,password):
        super().__init__(pathCentreID,pathCentreName,password,UserType.PATH_CENTRE)
        self._packets = []

# class MainSystem(object):
#     def __init__(self):
#         self._vampire = Vampire('password')
#         self._donors = []
#         self._pathCentres = []
#         self._hospitals = []