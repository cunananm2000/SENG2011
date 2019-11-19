package unsw;

public class Level {

	private int bloodType;
	private String capacity;
	private String warning;
	public Level(int bloodType, String capacity, String warning) {
		super();
		this.bloodType = bloodType;
		this.capacity = capacity;
		this.warning = warning;
	}
	public int getBloodType() {
		return bloodType;
	}
	public void setBloodType(int bloodType) {
		this.bloodType = bloodType;
	}
	public String getCapacity() {
		return capacity;
	}
	public void setCapacity(String capacity) {
		this.capacity = capacity;
	}
	public String getWarning() {
		return warning;
	}
	public void setWarning(String warning) {
		this.warning = warning;
	}
	
	
}
