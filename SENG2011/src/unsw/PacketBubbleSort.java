package unsw;

public class PacketBubbleSort extends PacketSorter {

	@Override
	public BloodPacket[] sort(BloodPacket[] oldPackets, String field) {
//		System.out.println("E");
		BloodPacket[] packets = new BloodPacket[oldPackets.length];
		int i = 0;
		while (i < packets.length) {
			packets[i] = oldPackets[i];
			i += 1;
		}
		if (packets.length <= 1) return packets;
	    
	    i = packets.length - 1;
	    while (i > 0) {
	        int j = 0;
	        while (j < i) {
	        	if (packets[j] == null) {
	        		return packets;
	        	}
	            if (compare(packets[j],packets[j+1],field)) {
	            	BloodPacket temp = packets[j];
	            	packets[j] = packets[j+1];
	            	packets[j+1] = temp;
	            }
	            j += 1;
	        }
	        i -= 1;
	    }
	    return packets;
	}

}
