package unsw;

public class DonorDatabase extends UserDatabase {
	
	public DonorDatabase() {
		super();
	}
	
	public int addDonor(String password, String firstName, String lastName) {
		int newID = count;
		Donor d = new Donor(count,password,firstName,lastName);
		this.sortedInsert(d);
		return newID;
	}
}
