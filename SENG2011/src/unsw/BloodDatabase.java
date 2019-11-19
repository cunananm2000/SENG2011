package unsw;

public class BloodDatabase {
	BloodPacket[] packets;
	PacketSorter sorter = new PacketBubbleSort();
	int count = 0;
	
	public BloodPacket[] getPackets() {
		return packets;
	}
	
	public BloodDatabase() {
		packets = new BloodPacket[50];
	}
	
	public void addPacket(BloodPacket newPacket) {
		if (count == packets.length) {
			doubleSize();
		}
		int i = 0;
		while (i < count && packets[i].getExpiryDate() < newPacket.getExpiryDate()) {
			i += 1;
		}
		int j = count -1;
		while (j >= i) {
			packets[j+1] = packets[j];
			j -= 1;
		}
		count += 1;
		packets[i] = newPacket;
	}
	
	public void doubleSize() {
		BloodPacket[] newPackets = new BloodPacket[packets.length*2];
		int i = 0;
		while (i < packets.length) {
			newPackets[i] = packets[i];
			i += 1;
		}
		while (i < newPackets.length) {
			newPackets[i] = null;
			i += 1;
		}
		packets = newPackets;
	}
	
	public BloodPacket[] getBlood(String field) {
		return sorter.sort(packets, field);
	}
	
	public BloodPacket[] searchBloodInt(String field, int value) {
		int i = 0;
		int total = 0;
		BloodPacket[] returnPackets = new BloodPacket[packets.length];
		while (i < count) {
			if (matchFieldInt(packets[i],field,value)) {
				returnPackets[total] = packets[i];
				total += 1;
			}
			i += 1;
		}
		sorter.sort(returnPackets, field);
		return returnPackets;
	}
	
	public BloodPacket[] searchBloodString(String field, String value) {
		int i = 0;
		int total = 0;
		BloodPacket[] returnPackets = new BloodPacket[packets.length];
		while (i < count) {
			if (matchFieldString(packets[i],field,value)) {
				returnPackets[total] = packets[i];
				total += 1;
			}
			i += 1;
		}
		returnPackets = truncate(returnPackets,total);
		sorter.sort(returnPackets, field);
		return returnPackets;
	}
	
//	private int id;
//	private String bloodType;
//	private int donateDate;
//	private String donateLoc;
//	private int expiryDate;
//	private int donorID;
//	private String firstName;
//	private String lastName;
//	private String status;
//	private String currLoc;
	
	public boolean matchFieldInt(BloodPacket p, String field, int value) {
		if (field == "ID") {
			return p.getID() == value;
		} else if (field == "BLOOD_TYPE") {
				return p.getBloodType() == value;
		} else if (field == "DONATE_DATE") {
			return p.getDonateDate() == value;
		} else if (field == "EXPIRY_DATE") {
			return p.getExpiryDate() == value;
		} else if (field == "DONOR_ID") {
			return p.getDonorID() == value;
		}  else if (field == "STATUS") {
			return p.getStatus() == value;
		}
		return false;
	}
	
	public boolean matchFieldString(BloodPacket p, String field, String value) {
		if (field == "DONATE_LOC") {
			return p.getDonateLoc().equals(value);
		} else if (field == "FIRST_NAME") {
			return p.getFirstName().equals(value);
		} else if (field == "LAST_NAME") {
			return p.getLastName().equals(value);
		} else if (field == "CURR_LOC") {
			return p.getCurrLoc().equals(value);
		}
		return false;
	}
	
	public BloodPacket[] truncate(BloodPacket[] a, int newSize) {
		if (newSize >= a.length) return a;
		BloodPacket[] newA = new BloodPacket[newSize];
		int i = 0;
		while (i < newSize) {
			newA[i] = a[i];
		}
		return newA;
	}
}
