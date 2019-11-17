package unsw;

public abstract class PacketSorter {
	public final BloodTypeTable bloodTypes = new BloodTypeTable();
	public final BloodStatusTable statusTypes = new BloodStatusTable();
	
	public void sort(BloodPacket[] packets, String field) {
		
	}
	
	
//	this.id = id;
//	this.bloodType = bloodType;
//	this.donateDate = donateDate;
//	this.donateLoc = donateLoc;
//	this.expiryDate = expiryDate;
//	this.donorID = donorID;
//	this.firstName = firstName;
//	this.lastName = lastName;
//	this.currLoc = "warehouse";
//	this.status = status;
	
	public boolean compare(BloodPacket a, BloodPacket b, String field) {
		if (field == "ID") {
			return a.getID() > b.getID();
		} else if (field == "BLOOD_TYPE") {
			return bloodTypes.get(a.getBloodType()) > bloodTypes.get(b.getBloodType());
		} else if (field == "DONATE_DATE") {
			return a.getDonateDate() > b.getDonateDate();
		} else if (field == "DONATE_LOC") {
			return a.getDonateLoc().compareTo(b.getDonateLoc()) > 0;
		} else if (field == "EXPIRY_DATE") {
			return a.getExpiryDate() > b.getExpiryDate();
		} else if (field == "DONOR_ID") {
			return a.getDonorID() > b.getDonorID();
		} else if (field == "FIRST_NAME") {
			return a.getFirstName().compareTo(b.getFirstName()) > 0;
		} else if (field == "LAST_NAME") {
			return a.getLastName().compareTo(b.getLastName()) > 0;
		} else if (field == "CURR_LOC") {
			return a.getCurrLoc().compareTo(b.getCurrLoc()) > 0;
		} else if (field == "STATUS") {
			return statusTypes.get(a.getStatus()) > statusTypes.get(b.getStatus());
		}
		return false;
	}
}
