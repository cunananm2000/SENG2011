package unsw;

public abstract class PacketSorter {
	public final static BloodTypeTable bloodTypes = new BloodTypeTable();
	public final static BloodStatusTable statusTypes = new BloodStatusTable();
	
	public BloodPacket[] sort(BloodPacket[] packets, String field) {
		return packets;
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
	
	public static boolean compare(BloodPacket a, BloodPacket b, String field) {
		if (field.equals("ID")) {
			return a.getID() < b.getID();
		} else if (field.equals("BLOOD_TYPE")) {
			return a.getBloodType() < b.getBloodType();
		} else if (field.equals("DONATE_DATE")){
			return a.getDonateDate() < b.getDonateDate();
		} else if (field.equals("DONATE_LOC")) {
			return a.getDonateLoc().compareTo(b.getDonateLoc()) < 0;
		} else if (field.equals("EXPIRY_DATE")) {
			return a.getExpiryDate() < b.getExpiryDate();
		} else if (field.equals("DONOR_ID")) {
			return a.getDonorID() < b.getDonorID();
		} else if (field.equals("FIRST_NAME")) {
			return a.getFirstName().compareTo(b.getFirstName()) < 0;
		} else if (field.equals("LAST_NAME")) {
			return a.getLastName().compareTo(b.getLastName()) < 0;
		} else if (field.equals("CURR_LOC")) {
			return a.getCurrLoc().compareTo(b.getCurrLoc()) < 0;
		} else if (field.equals("STATUS")) {
			return a.getStatus() < b.getStatus();
		}
		return false;
	}
}
