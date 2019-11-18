package unsw;

import java.util.HashMap;

public class BloodStatusTable {
	private static final HashMap<String,Integer> table = new HashMap<String,Integer>();
	
	public BloodStatusTable() {
		table.put("EXPIRED", 0);
		table.put("ALMOST_EXPIRED", 1);
		table.put("CLEAN", 2);
	}
	
	public int get(String key) {
		return table.get(key);
	}
}
