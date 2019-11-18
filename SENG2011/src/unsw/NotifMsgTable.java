package unsw;

import java.util.HashMap;

public class NotifMsgTable {
	private static final HashMap<String,String> table = new HashMap<String,String>();
	
	public NotifMsgTable() {
		table.put("EXPIRED_PACKETS", "The following packets have expired:");
		table.put("LOW_BLOOD_LEVELS", "The following levels are very low:");
		table.put("ALMOST_EXPIRED", "The following packets are about to expire:");
		table.put("REQUEST_MADE", "The following packets were sent to");
		table.put("DEPOSIT_MADE", "The following packet was just deposited from");
	}
	
	public String get(String key) {
		return table.get(key);
	}
}
