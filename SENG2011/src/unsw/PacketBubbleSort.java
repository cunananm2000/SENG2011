package unsw;

public class PacketBubbleSort extends PacketSorter {

	@Override
	public void sort(BloodPacket[] packets, String field) {
		if (packets.length <= 1) return;
	    
	    int i = packets.length - 1;
	    while (i > 0) {
	        int j = 0;
	        while (j < i) {
	            if (compare(packets[i],packets[i+1],field)) {
	            	BloodPacket temp = packets[j];
	            	packets[j] = packets[j+1];
	            	packets[j+1] = temp;
	            }
	            j += 1;
	        }
	        i -= 1;
	    }
	}

}
