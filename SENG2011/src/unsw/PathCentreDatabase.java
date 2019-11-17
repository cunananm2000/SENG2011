package unsw;

public class PathCentreDatabase extends UserDatabase {
	
	public PathCentreDatabase() {
		super();
	}
	
	public void addPathCentre(String name, String password) {
		PathCentre pc = new PathCentre(count,name,password);
		this.sortedInsert(pc);
	}
}
