package unsw;

import java.util.HashMap;

public class BloodTypeTable {
	private static final HashMap<String,Integer> table = new HashMap<String,Integer>();
	
	public BloodTypeTable() {
		table.put("O_NEG",0);
		table.put("O_POS",1);
		table.put("A_NEG",2);
		table.put("A_POS",3);
		table.put("B_NEG",4);
		table.put("B_POS",5);
		table.put("AB_NEG",6);
		table.put("AB_POS",7);
	}
	
	public int get(String key) {
		return table.get(key);
	}
}
