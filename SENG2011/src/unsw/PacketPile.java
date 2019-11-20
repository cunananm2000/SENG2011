package unsw;

public class PacketPile {
	private BloodPacket[] buf;
	private int count = 0;
	private int low;
	
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
			i += 1;
		}
		count -= 1;
		return el;
	}
	
	public void push(BloodPacket el) {
		if (count == buf.length) {
			BloodPacket p = this.popAtIndex(0);
			p.setStatus(2);
			p.sendTo("dump");
		}
		int index = 0;
		while (index < count && buf[index].getExpiryDate() < el.getExpiryDate()) {
			index += 1;
		}
		int i = count - 1;
		while (i >= index) {
			buf[i+1] = buf[i];
			i -= 1;
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
		if (newSize < count) {
			int shift = count - newSize; 
			while (i < newSize) {
				newBuf[i] = buf[shift + i]; 
				i++; 
			}
			count = newSize; 
		} else {
			while (i < count) {
				newBuf[i] = buf[i];
				i++;
			}
		}
		if (low > newSize) low = newSize; // Ensure low makes sense still
		buf = newBuf;
	}
	
	public boolean isLow() {
		System.out.println(count+"/"+low);
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
		int cutoff = 0;
	    while (cutoff < count && buf[cutoff].getExpiryDate() <= currDay)
	    {
	         BloodPacket p = buf[cutoff];
	         p.setStatus(2);
	         p.sendTo("dump");
	         cutoff = cutoff + 1;
	    }
	
	    int i = 0;
	    while (i < count && buf[i].getExpiryDate() <= currDay + buffer) 
	    {
	    	buf[i].setStatus(1);
	        i = i + 1;
	    }
	
	    int[] trashIDs = new int[cutoff];
	    i = 0;
	    while (i < cutoff)
	    {
	        trashIDs[i] = buf[i].getID();
	        i = i + 1;
	    }
	    count = count - cutoff;
	
	    i = 0;
	    while (i < count)
	    {
	        buf[i] = buf[cutoff+i];
	        i = i + 1;
	    }
	    
	    return trashIDs;
	}
	
	public int[] doRequest(int nPackets, int useBy, String dest) {
		BloodPacket[] sendPackets = new BloodPacket[count];
		int nFound = 0;
		int i = 0;
		while (i < count) {
			if (useBy <= buf[i].getExpiryDate()) {
				sendPackets[nFound] = buf[i];
				nFound += 1;
			}
			i += 1;
		}
		
		if (nFound < nPackets) return null;
		
		int[] sendIDs = new int[nPackets];
		i = 0;
		while (i < nPackets) {
			sendIDs[i] = sendPackets[i].getID();
			sendPackets[i].sendTo(dest);
			this.removePacket(sendPackets[i]);
			i += 1;
		}
		
		return sendIDs;
	}
	
	public int getNAlmostExpired() {
		int i = 0;
		int total = 0;
		while (i < count) {
			if (buf[i].getStatus() == 1) {
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
			if (buf[i].getStatus() == 1){
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
	
	public void printOut() {
		int i = 0;
		while (i < count) {
			buf[i].printOut();
			i += 1;
		}
	}
}
