package unsw;

public class HospitalDatabase extends UserDatabase {
	
	public HospitalDatabase() {
		super();
	}
	
	public void addHospital(String name, String password) {
		Hospital h = new Hospital(count,name,password);
		this.sortedInsert(h);
	}

	public Hospital searchByName(String dest) {
		int i = 0;
		while (i < users.length) {
			Hospital h = (Hospital) users[i];
			if (h.getName().equals(dest)) return h;
		}
		return null;
	}
}
