package unsw;

public class MainSystem {
	Vampire vampire = new Vampire(8);
	DonorDatabase donorDatabase = new DonorDatabase();
	HospitalDatabase hospitalDatabase = new HospitalDatabase();
	PathCentreDatabase pathCentreDatabase = new PathCentreDatabase();
	BloodDatabase bloodDatabase = new BloodDatabase();
	
	public MainSystem() {
		super();
	}
	
	public User login(String userType, int id, String password) {
		if (userType.equals("VAMPIRE")) {
			if (vampire.login(id, password)) {
				return vampire;
			} else {
				return null;
			}
		} else if (userType.equalsIgnoreCase("DONOR")) {
			return donorDatabase.login(id, password);
		} else if (userType.equals("HOSPITAL")) {
			return hospitalDatabase.login(id, password);
		} else if (userType.equals("PATH_CENTRE")) {
			return pathCentreDatabase.login(id, password);
		}
		return null;
	}
	
	public int addDonor(String password, String firstName, String lastName) {
		return donorDatabase.addDonor(password, firstName, lastName);
	}
	
	public void printDonors() {
		donorDatabase.printOut();
	}
	
	public void addHospital(String name, String password) {
		hospitalDatabase.addHospital(name, password);
	}
	
	public void printHospitals() {
		hospitalDatabase.printOut();
	}
	
	public void addPathCentre(String name, String password) {
		pathCentreDatabase.addPathCentre(name, password);
	}
	
	public void printPathCentres() {
		pathCentreDatabase.printOut();
	}
	
	public void printBloodDatabase(String field) {
		bloodDatabase.printBlood(field);
	}
	
	public void printInventory(String field) {
		vampire.printInventory(field);
	}
	
	public void cleanUp() {
		vampire.cleanUp();
	}
	
	public void printLevels() {
		vampire.printLevels();
	}
	
	public void setWarning(int buffer) {
		vampire.setBuffer(buffer);
	}
	
	public void setLowLevel(String bloodType, int level) {
		vampire.setLowLevel(bloodType, level);
	}
	
	public void setMaxLevel(String bloodType, int level) {
		vampire.setMaxLevel(bloodType, level);
	}
	
	public void printNotifs() {
		vampire.printNotifs();
	}
	
	public void searchBloodInt(String field,int value) {
		bloodDatabase.searchBloodInt(field, value);
	}
	
	public void searchBloodString(String field, String value) {
		bloodDatabase.searchBloodString(field, value);
	}
	
	public void makeDeposit(int bloodType, int donateDate, String donateLoc, int expiryDate, int donorID) {
		Donor d = (Donor) donorDatabase.search(donorID);
		if (d == null) return;
		String firstName = d.getFirstName();
		String lastName = d.getLastName();
//		System.out.println("Got "+bloodType+donateLoc);
		BloodPacket p = vampire.makeDeposit(bloodType, donateDate, donateLoc, expiryDate, donorID, firstName, lastName);
//		System.out.println("Made"+p.toString());
		bloodDatabase.addPacket(p);
//		System.out.println("Added"+p.getID());
	}
	
	public boolean makeRequest(String bloodType, int nPackets, int useBy, String dest) {
		if (hospitalDatabase.searchByName(dest) == null) return false;
		return vampire.makeRequest(bloodType, nPackets, useBy, dest);
	}

}
