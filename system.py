from data_generator import *
class MainSystem(ABC):
	def __init__(self):
		self._vampire = Vampire('password')
		self._donors = loadDonors()
		self._pathCentres = loadPathCentres()
		self._hospitals = loadHospitals()
		
	def getVampire(self):
		return self._vampire

	def getDonors(self):
		return self._donors

	def addDonor(self,givenName,familyName,email):
		nLines = getLineCount('donors.csv')
		with open('donors.csv', mode='a') as file:
			file_writer = csv.writer(file, delimiter=',')
			file_writer.writerow(['donor'+str(nLines),'password',givenName,familyName,email])
		(self._donors).append(Donor('donor'+str(nLines),'password',givenName,familyName,email))
	
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
		