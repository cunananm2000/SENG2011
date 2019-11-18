package unsw;

public class Donor extends User{
	private String firstName;
	private String lastName;
	
	public Donor(int id, String password,String firstName,String lastName) {
		super(id,password);
		this.firstName = firstName;
		this.lastName = lastName;
//		System.out.println("New donor:"+this.getId()+this.getPassword());
	}
	
	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}
	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}
	
	@Override
	public void printOut() {
		System.out.println(id+" "+firstName+" "+lastName);
	}
}
