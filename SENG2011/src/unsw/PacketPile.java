package unsw;

public class PacketPile {
	private BloodPacket[] buf;
	private int count = 0;
	private int low;
	private BloodStatusTable bloodStatuses = new BloodStatusTable();
	
	public PacketPile(int size,int low) {
		this.buf = new BloodPacket[size];
		int i = 0;
		while (i < size) {
			buf[i] = null;
			i += 1;
		}
		this.low = low;
	}
	
	public BloodPacket popAtIndex(int index) {
		if (index < 0 || index >= count) return null;
		BloodPacket el = buf[index];
		int i = index;
		while (i < count - 1) {
			buf[i] = buf[i+1];
		}
		count -= 1;
		return el;
	}
	
	public void push(BloodPacket el) {
		if (count == buf.length) {
			BloodPacket p = this.popAtIndex(0);
			p.setStatus("EXPIRED");
			p.sendTo("dump");
		}
		int index = 0;
		while (index < count && buf[index].getExpiryDate() < el.getExpiryDate()) {
			index += 1;
		}
		int i = count - 1;
		while (i >= index) {
			buf[i+1] = buf[i];
		}
		count += 1;
		buf[index] = el;
	}
	
	public BloodPacket removePacket(BloodPacket el) {
		int i = 0;
		while (i < count && buf[i] != el) {
			i++;
		}
		if (i == count) {
			return null;
		} else {
			return this.popAtIndex(i);
		}
	}
	
	public void resize(int newSize) {
		BloodPacket[] newBuf = new BloodPacket[newSize];
		int i = 0;
		while (i < newSize && i < buf.length) {
			newBuf[i] = buf[i];
			i += 1;
		}
		buf = newBuf;
	}
	
	public boolean isLow() {
		return count <= low;
	}
	
	public void setLow(int low) {
		this.low = low;
	}
	
	public int getSize() {
		return buf.length;
	}
	
	public int getCount() {
		return count;
	}
	
	public int[] cleanUp(int currDay, int buffer) {
		BloodPacket[] trash = new BloodPacket[count];
		int trashCount = 0;
		
		int i = 0;
		while (i < count) {
			trash[i] = null;
			i += 1;
		}
		
		i = 0;
		while (i < count) {
			BloodPacket p = buf[i];
			int timeDiff = p.getExpiryDate() - currDay;
			if (timeDiff <= 0) {
				trash[trashCount] = p;
				p.setStatus("EXPIRED");
				trashCount += 1;
			} else if (timeDiff <= buffer) {
				p.setStatus("ALMOST_EXPIRED");
			}
			i += 1;
		}
		
		int[] trashIDs = new int[trashCount];
		
		i = 0;
		while (i < trashCount) {
			trashIDs[i] = trash[i].getID();
			this.removePacket(trash[i]);
			i += 1;
		}
		
		return trashIDs;
	}
	
	public int[] doRequest(int nPackets, int useBy, String dest) {
		BloodPacket[] sendPackets = new BloodPacket[nPackets];
		int nFound = 0;
		int i = 0;
		while (i < buf.length && nFound < nPackets) {
			if (useBy <= buf[i].getExpiryDate()) {
				sendPackets[nFound] = buf[i];
				nFound += 1;
			}
			i += 1;
		}
		
		if (nFound < nPackets) return null;
		
		int[] sendIDs = new int[nFound];
		i = 0;
		while (i < nFound) {
			sendIDs[i] = sendPackets[i].getID();
			sendPackets[i].sendTo(dest);
			this.removePacket(sendPackets[i]);
		}
		
		return sendIDs;
	}
	
	public int getNAlmostExpired() {
		int i = 0;
		int total = 0;
		while (i < count) {
			if (buf[i].getStatus().equals("ALMOST_EXPIRED")) {
				total += 1;
			}
			i += 1;
		}
		return total;
	}
	
	public int[] getAlmostExpired() {
		int[] almostTrashIDs = new int[this.getNAlmostExpired()];
		int i = 0;
		int next = 0;
		while (i < count) {
			if (buf[i].getStatus().equals("ALMOST_EXPIRED")){
				almostTrashIDs[next] = buf[i].getID();
				next += 1;
			}
			i += 1;
		}
		return almostTrashIDs;
	}
	
	public BloodPacket[] getBuf() {
		BloodPacket[] packets = new BloodPacket[count];
		int i = 0;
		while (i < count) {
			packets[i] = buf[i];
			i += 1;
		}
		return packets;
	}
	
	public void printLevel() {
		System.out.print(count+"/"+buf.length);
		if (this.isLow()) {
			System.out.println("<--- LOW LEVEL");
		} else {
			System.out.println("");
		}
	}
	
	public void printOut() {
		int i = 0;
		while (i < count) {
			buf[i].printOut();
			i += 1;
		}
	}
}
