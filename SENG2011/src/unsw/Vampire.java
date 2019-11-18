package unsw;

public class Vampire extends User {
	private NotifPile notifs = new NotifPile(20);
	private PacketPile[] piles;
	private int packetCounter = 0;
	
	private NotifPriorityTable notifPriority = new NotifPriorityTable();
	private NotifMsgTable notifMsg = new NotifMsgTable();
	private BloodTypeTable bloodTypes = new BloodTypeTable();
	
	private PacketSorter sorter = new PacketBubbleSort();
	
	private int currDay = 0;
	private int buffer = 1;
	
	public Vampire(int nTypes) {
		super(0,"password");
		piles = new PacketPile[nTypes];
		
		int i = 0;
		while (i < nTypes) {
			piles[i] = new PacketPile(10,1);
			i += 1;
		}
	}
	
	public BloodPacket makeDeposit(int bloodType,int donateDate, String donateLoc,int expiryDate,int donorID,String firstName,String lastName) {
		int newID = packetCounter;
		BloodPacket p = new BloodPacket(newID,bloodType,donateDate,donateLoc,expiryDate,donorID,firstName,lastName);
		packetCounter += 1;
		
//		System.out.println("About to push "+p.toString());
		piles[bloodType].push(p);
//		System.out.println("Pushed "+p.toString());
		
		int[] things = {newID};
		this.addNotif("DEPOSIT_MADE", donateLoc, things);
//		System.out.println("Added notif for "+p.toString());
		return p;
	}
	
	public void addNotif(String type, String info, int[] things) {
		int priority = notifPriority.get(type);
		String desc = notifMsg.get(type) + " " + info;
		Notification n = new Notification(type,priority,desc,currDay,things);
		this.notifs.push(n);
	}
	
	public boolean makeRequest(String bloodType, int nPackets, int useBy, String dest) {
		int bloodIndex = bloodTypes.get(bloodType);
		int[] packets = piles[bloodIndex].doRequest(nPackets, useBy, dest);
		
		if (packets != null) {
            this.addNotif("REQUEST_MADE", dest, packets);
            return true;
		} else {
			return false;
		}
	}
	
	public void cleanUp() {
		int totalSize = 0;
		int i = 0;
		while (i < piles.length) {
			totalSize += piles[i].getCount();
			i += 1;
		}
		
		int[] expired = new int[totalSize];
		int[] almostExpired = new int[totalSize];
		
		i = 0;
		while (i < totalSize) {
			expired[i] = -1;
			almostExpired[i] = -1;
			i += 1;
		}
		
//		System.out.println("A");
		
		i = 0;
		int expiredCount = 0;
		int almostExpiredCount = 0;
		while (i < piles.length) {
			int[] expiredIDs = piles[i].cleanUp(currDay, buffer);
			int[] tempAlmostExpiredIDs = piles[i].getAlmostExpired();
			
			int j = 0;
			while (j < expiredIDs.length) {
				expired[expiredCount] = expiredIDs[j];
				j += 1;
				expiredCount += 1;
			}
			
			j = 0;
			while (j < tempAlmostExpiredIDs.length) {
				almostExpired[almostExpiredCount] = tempAlmostExpiredIDs[j];
				j += 1;
				almostExpiredCount += 1;
			}
			
			i += 1;
		}
		
//		System.out.println("B");
		
		
		if (expiredCount > 0) {
			addNotif("EXPIRED_PACKETS","",truncate(expired,expiredCount));
		}
		
//		System.out.println("C");
		
		if (almostExpiredCount > 0) {
			addNotif("ALMOST_EXPIRED","",truncate(almostExpired,almostExpiredCount));
		}
		
//		System.out.println("D");
		
		this.findLows();
		System.out.println("Found lows");
		
		this.currDay += 1;
	}
	
	public void findLows() {
		int[] lows = new int[piles.length];
		int count = 0;
		int i = 0;
		while (i < piles.length) {
			if (piles[i].isLow()) {
				lows[count] = i;
				count += 1;
			}
			i += 1;
		}
		lows = truncate(lows,count);
		this.addNotif("LOW_BLOOD_LEVELS", "", lows);
	}
	
	public void setLowLevel(String bloodType, int amount) {
		int bloodIndex = bloodTypes.get(bloodType);
		piles[bloodIndex].setLow(amount);
	}
	
	public void setMaxLevel(String bloodType, int amount) {
		int bloodIndex = bloodTypes.get(bloodType);
		piles[bloodIndex].resize(amount);
	}
	
	public int[] truncate(int[] a, int newSize) {
		if (newSize >= a.length) return a;
		int[] newA = new int[newSize];
		int i = 0;
		while (i < newSize) {
			newA[i] = a[i];
			i += 1;
		}
		return newA;
	}
	
	public boolean login(int loginID, String password) {
		return (this.id == loginID && this.password.equals(password));
	}
	
	public void printNotifs() {
		notifs.printOut();
	}
	
	public void printInventory(String field) {
		int totalSize = 0;
		int i = 0;
		while (i < piles.length) {
			totalSize += piles[i].getCount();
			i += 1;
		}
		BloodPacket[] everything = new BloodPacket[totalSize];
		
		i = 0;
		int next = 0;
		while (i < piles.length) {
			BloodPacket[] buf = piles[i].getBuf();
			int j = 0;
			while (j < buf.length) {
				everything[next] = buf[j];
				next += 1;
				j += 1;
			}
			i += 1;
		}
		
		
		sorter.sort(everything, field);
	    
		i = 0;
		while (i < totalSize) {
			everything[i].printOut();
			i += 1;
		}
	}
	
	public void printLevels() {
		int i = 0;
		while (i < piles.length) {
			piles[i].printLevel();
		}
	}

	public void setBuffer(int newBuffer) {
		this.buffer = newBuffer;
		
	}
	
}
