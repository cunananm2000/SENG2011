package unsw;

public class PathCentre extends User{
	private String name;
	
	public PathCentre(int id, String name, String password) {
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
