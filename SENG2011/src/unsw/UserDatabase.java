package unsw;

public class UserDatabase {
	protected User[] users;
	protected int count = 0;
	
	public UserDatabase() {
		users = new User[20];
		int i = 0;
		while (i < users.length) {
			users[i] = null;
			i += 1;
		}
	}
	
	public User search(int id) {
		int i = 0;
		while (i < count && users[i].getId() != id) {
			i += 1;
		}
		if (i == users.length) {
			return null;
		} else {
			return users[i];
		}
	}
	
	// Binary search for users
	public User binarySearch(int key) {
		int low =  0;		// Setting range
		int high = count;
		while (low < high){
			int mid = (low+high/2);	// Finding midpoint
			int id = users[mid].getId();
			if (key == id){			// Found key
				return users[mid];
			} else if (key < id){	// Key must be in lower half
				high = mid;
			} else {				// Key must be in upper half
				low = mid + 1;
			}
		}
		return null;				// Didn't find key
	}

	public User login(int id, String password) {
		User user = this.search(id);
//		System.out.println(user);
//		if (user != null) System.out.println(user.getPassword());
		if (user == null || !user.getPassword().equals(password)) {
			return null;
		} else {
			return user;
		}
	}
	
	public void doubleSize() {
		User[] newUsers = new User[users.length*2];
		int i = 0;
		while (i < users.length) {
			newUsers[i] = users[i];
			i += 1;
		}
		while (i < newUsers.length) {
			newUsers[i] = null;
			i += 1;
		}
		users = newUsers;
	}
	
	public void sortedInsert(User newUser) {
		if (count == users.length) {
			doubleSize();
		}
		int i = 0;
		while (i < count && users[i].getId() < newUser.getId()) {
			i += 1;
		}
		int j = count -1;
		while (j >= i) {
			users[j+1] = users[j];
			j -= 1;
		}
		count += 1;
		users[i] = newUser;
	}
	
	public User[] getUsers() {
		return this.users;
	}
	
}
