package unsw;

public class Notification {
	private int priority;
	private String type;
	private String desc;
	private int date;
	private int[] things;
	
	
	public Notification(String type,int priority,String desc,int date,int[] things) {
		this.priority = priority;
		this.type = type;
		this.desc = desc;
		this.date = date;
		this.things = things;
	}
	
	public String getType() {
		return type;
	}

	public String getDesc() {
		return desc;
	}

	public int[] getThings() {
		return things;
	}

	public int getDate() {
		return this.date;
	}
	
	public int getPriority() {
		return this.priority;
	}
	
	public void printOut() {
		System.out.println("************************");
		System.out.println("* TYPE: "+type);
		System.out.println("* DATE: "+date);
		System.out.println("* DESC: "+desc);
		if (things.length > 0) {
			int i = 0;
			while (i < things.length) {
				System.out.println("*     - "+things[i]);
				i += 1;
			}
		} else {
			System.out.println("*     No further details");
		}
		System.out.println("************************");
	}
}
