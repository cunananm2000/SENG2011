package unsw;

public class Hospital extends User {
	private String name;
	
	public Hospital(int id, String name, String password) {
		super(id,password);
		this.name = name;
	}
	
	/**
	 * @return the name
	 */
	public String getName() {
		return name;
	}
	
	@Override
	public void printOut() {
		System.out.println(id+" "+password+" "+name);
	}
}
