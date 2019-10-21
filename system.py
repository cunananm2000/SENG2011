from data_generator import *

class MainSystem(ABC):
	def __init__(self):
		self._vampire = Vampire('password')
		self._donors = loadDonors()
		self._pathCentres = loadPathCentres()
		self._hospitals = []

	def getDonors(self):
		return self._donors

	def getVampire(self):
		return self._vampire
	
	def getPathCentres(self):
		return self._pathCentres
	
	def getHospitals(self):
		return self._hospitals

	def get_user(self, id):
		for user in self._donors:
			if user.id == id:
				return user