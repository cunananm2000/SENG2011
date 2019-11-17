package unsw;

import java.util.HashMap;

public class NotifPriorityTable {
	private static final HashMap<String,Integer> table = new HashMap<String,Integer>();
	
	public NotifPriorityTable() {
		table.put("EXPIRED_PACKETS", 0);
		table.put("LOW_BLOOD_LEVELS", 1);
		table.put("ALMOST_EXPIRED", 2);
		table.put("REQUEST_MADE", 3);
		table.put("DEPOSIT_MADE", 4);
	}
	
	public int get(String key) {
		return table.get(key);
	}
}
