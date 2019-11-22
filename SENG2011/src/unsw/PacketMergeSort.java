package unsw;

public class PacketMergeSort extends PacketSorter {
	
	@Override
	public BloodPacket[] sort(BloodPacket[] oldPackets, String field) {
	    //mergeSort(packets, 0, packets.length, field);
		BloodPacket[] packets = new BloodPacket[oldPackets.length];
		for (int i = 0; i < packets.length; i++)
			packets[i] = oldPackets[i];
		mergeSort(packets, 0, packets.length, field);
		return packets;
	}
	
	private void mergeSort(BloodPacket[] a, int low, int high, String field) {
		int mid = low + (high-low)/2;
		if (a.length > 1 && low < mid) {
			mergeSort(a, low, mid, field);
			mergeSort(a, mid, high, field);
			mergeSubarrays(a, low, mid, high, field);
		}
	}
	
	private void mergeSubarrays(BloodPacket[] a, int low, int mid, int high, String field) {
		// Creating temp left and right arrays
		int i, j;
		BloodPacket [] left = new BloodPacket[mid-low];
		BloodPacket [] right = new BloodPacket[high-mid];
		for (i = 0; i < mid-low; i++) {
			left[i] = a[low+i];
		}
		for (j = 0; j < high-mid; j++) {
			right[j] = a[mid+j];
		}
				
		i = 0; j = 0;	// Index for left and right arrays
		int k = low;		// Index for a (original array)
			
		while (i < mid-low || j < high-mid){
			// If neither 'queue' is empty, find lowest value and add to a
			if (i < mid-low && j < high-mid) {
				if (compare(left[i], right[j], field)) {
					a[k] = left[i];
					i++;
				} else {
					a[k] = right[j];
					j++;
				}
			// If right is empty, add from left
			} else if (i < mid-low) {
				a[k] = left[i];
				i++;
			// If left is empty, add from right
			} else {
				a[k] = right[j];
				j++;
			}
			k++;
		}
	}
}
