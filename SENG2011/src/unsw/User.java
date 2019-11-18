package unsw;

public class User {
	protected int id;
	protected String password;
	/**
	 * @param id
	 * @param password
	 */
	public User(int id, String password) {
		super();
		this.id = id;
		this.password = password;
	}
	/**
	 * @return the id
	 */
	public int getId() {
		return id;
	}
	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}
	
	public void printOut() {
		System.out.println(id+" "+password);
	}
	
	
}
