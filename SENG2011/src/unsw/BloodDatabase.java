package unsw;

public class BloodDatabase {
	BloodPacket[] packets;
	PacketSorter sorter = new PacketBubbleSort();
	int count = 0;
	
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
			if (packets[i].matchFieldInt(field,value)) {
				System.out.println(packets[i]);
				returnPackets[total] = packets[i];
				total += 1;
			}
			i += 1;
		}
		returnPackets = truncate(returnPackets,total);
		returnPackets = sorter.sort(returnPackets, field);
		return returnPackets;
	}
	
	public BloodPacket[] searchBloodString(String field, String value) {
		int i = 0;
		int total = 0;
		BloodPacket[] returnPackets = new BloodPacket[count];
		while (i < count) {
			if (packets[i].matchFieldString(field,value)) {
				returnPackets[total] = packets[i];
				total += 1;
			}
			i += 1;
		}
		returnPackets = truncate(returnPackets,total);
		returnPackets = sorter.sort(returnPackets, field);
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
	
	
	
	public BloodPacket[] truncate(BloodPacket[] a, int newSize) {
		if (newSize >= a.length) return a;
		BloodPacket[] newA = new BloodPacket[newSize];
		int i = 0;
		while (i < newSize) {
			newA[i] = a[i];
			i += 1;
		}
		return newA;
	}
}
