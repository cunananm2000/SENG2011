package unsw;

public class BloodPacket {
	private int id;
	private int bloodType;
	private int donateDate;
	private String donateLoc;
	private int expiryDate;
	private int donorID;
	private String firstName;
	private String lastName;
	private int status;
	private String currLoc;
	
	public BloodPacket(int id, int bloodType, int donateDate, String donateLoc, int expiryDate, int donorID, String firstName, String lastName) {
		this.id = id;
		this.bloodType = bloodType;
		this.donateDate = donateDate;
		this.donateLoc = donateLoc;
		this.expiryDate = expiryDate;
		this.donorID = donorID;
		this.firstName = firstName;
		this.lastName = lastName;
		this.currLoc = "warehouse";
		this.status = 0;
	}

	public void setStatus(int status) {
		this.status = status;
		
	}

	public void sendTo(String dest) {
		this.currLoc = dest;
	}

	
	
	/**
	 * @return the id
	 */
	public int getID() {
		return id;
	}

	/**
	 * @return the bloodType
	 */
	public int getBloodType() {
		return bloodType;
	}

	/**
	 * @return the donateDate
	 */
	public int getDonateDate() {
		return donateDate;
	}

	/**
	 * @return the donateLoc
	 */
	public String getDonateLoc() {
		return donateLoc;
	}

	/**
	 * @return the expiryDate
	 */
	public int getExpiryDate() {
		return expiryDate;
	}

	/**
	 * @return the donorID
	 */
	public int getDonorID() {
		return donorID;
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

	/**
	 * @return the status
	 */
	public int getStatus() {
		return status;
	}

	/**
	 * @return the currLoc
	 */
	public String getCurrLoc() {
		return currLoc;
	}

	public void printOut() {
		System.out.println(id+" TYPE: "+bloodType+" DON DATE: "+donateDate+" DON LOC: "+donateLoc+" EXP DATE: "+expiryDate+" DONOR: "+donorID+" "+firstName+" "+lastName+" STATUS: "+status+" LOC: "+currLoc+" <---- "+status);
	}
}