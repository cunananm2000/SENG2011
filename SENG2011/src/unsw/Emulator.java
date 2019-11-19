package unsw;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException; 
import java.io.InputStreamReader;

import javax.swing.JOptionPane;

import java.io.FileNotFoundException;
import java.io.FileReader;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;
//import java.util.Iterator;
//import java.util.Map;


public class Emulator {
	private static MainSystem mainSystem = new MainSystem();
	private static User user = null;
	private static String userType = "";
	private static BloodTypeTable bloodTypes = new BloodTypeTable();
	
	
	private boolean printHelp() {
	    if (userType == "") {
	        println("LOGIN ----------------- Login");
	    } else if (userType.equals("DONOR")) {
	        return true;
	    } else if (userType.equals("HOSPITAL")) { 
	        println("REQUEST_BLOOD --------- Request blood");
	    } else if (userType.equals("VAMPIRE")) {
	        println("ADD_DONOR ------------- Add a new donor");
	        println("CLEAN_UP -------------- Remove bad blood packets");
	        println("PRINT_INVENTORY ------- Print inventory");
	        println("PRINT_NOTIFS ---------- Print notifications");
	        println("PRINT_LEVELS ---------- Print current levels");
	        println("PRINT_DONORS ---------- Print donors");
	        println("PRINT_HOSPITALS ------- Print hospitals");
	        println("PRINT_PATH_CENTRES ---- Print pathology centres");
	        println("PRINT_BLOOD_DATABASE -- Print blood database");
	        println("SEARCH_BLOOD ---------- Search blood database");
	        println("SET_LOW_LEVEL --------- Set low level of a specific blood type");
	        println("SET_BUFFER ------------ Set a warning buffer");
	    } else if (userType.equalsIgnoreCase("PATH_CENTRE")) {
	        println("ADD_BLOOD ------------- Add a new blood packet");
	    }
	    return true;
	}

	public void print(String string) {
		System.out.print(string);
	}
	
	public static void println(String string) {
		System.out.println(string);
	}
	
	public String input(String prompt) throws IOException {
		print(prompt);
		//Enter data using BufferReader 
        BufferedReader reader =  
                   new BufferedReader(new InputStreamReader(System.in)); 
         
        // Reading data using readLine 
        return reader.readLine();
	}
	
	
	public void login() throws IOException {
		String type = input("User type: ").toUpperCase().replace('_', ' ');
		int loginID = Integer.parseInt(input("Login ID: "));
		String password = input("Password: ");
		
		User u = mainSystem.login(type,loginID, password);
		if (u != null) {
			this.user = u;
			this.userType = type;
			println("Hello "+loginID+", a "+userType);
		} else {
			println("Bad login");
		}
	}
	

	public boolean routeCommand(String cmd) throws IOException {
		if (userType.equals("")) {
			return processNormalCmd(cmd);
		} else if (userType.equals("DONOR")) {
			return false;
		} else if (userType.equals("VAMPIRE")) {
			return processVampireCmd(cmd);
		} else if (userType.equals("HOSPITAL")) {
			return processHospitalCmd(cmd);
		} else if (userType.equalsIgnoreCase("PATH_CENTRE")) {
			return processPathCentreCmd(cmd);
			
		}
		return false;
	}
	
	private void printLevels() {
		int[][] levels = mainSystem.getLevels();
		int i = 0;
		while (i < levels[0].length) {
			if (levels[2][i] == 1) {
				System.out.println(levels[0][i]+"/"+levels[1][i]+" <---- LOW LEVEL");
			} else {
				System.out.println(levels[0][i]+"/"+levels[1][i]);
			}
			i += 1;
		}
	}
	
	private void printNotifs() {
		Notification[] notifs = mainSystem.getNotifs();
		int i = 0;
		while (i < notifs.length) {
			notifs[i].printOut();
			i += 1;
		}
	}
	
	

	private boolean processVampireCmd(String cmd) throws IOException {
		if (cmd.equals("ADD_DONOR")) {
	        addDonor();
		} else if (cmd.equals("CLEAN_UP")) {
	        mainSystem.cleanUp();
		} else if (cmd.equals("PRINT_INVENTORY")) {
	        printInventory();
		} else if (cmd.equals("PRINT_NOTIFS")) {
	        printNotifs();
		} else if (cmd.equals("PRINT_LEVELS")) {
	        printLevels();
		} else if (cmd.equals("PRINT_DONORS")) {
	        printDonors();
		} else if (cmd.equals("PRINT_HOSPITALS")) {
	        printHospitals();
		} else if (cmd.equals("PRINT_PATH_CENTRES")) {
	        printPathCentres();
		} else if (cmd.equals("PRINT_BLOOD_DATABASE")) {
	        printBlood();
		} else if (cmd.equals("SEARCH_BLOOD")) {
	        searchBlood();
		} else if (cmd.equals("SET_LOW_LEVEL")) {
	        setLowLevel();
		} else if (cmd.equals("SET_MAX_LEVEL")) {
	        setMaxLevel();
		} else if (cmd.equals("SET_BUFFER")) {
	        setBuffer();
        } else {
	        return false;
	    }
	    return true;
	}
	
	public boolean processHospitalCmd(String cmd) throws IOException {
		if (cmd.equals("REQUEST_BLOOD")) {
			requestBlood();
			return true;
		} else {
			return false;
		}
	}
	
	private boolean processPathCentreCmd(String cmd) throws IOException {
		if (cmd.equals("ADD_BLOOD")) {
			addBlood();
			return true;
		} else {
			return false;
		}
	}

	private boolean processNormalCmd(String cmd) throws IOException {
		if (cmd.equals("LOGIN")) {
			login();
			return true;
		}
		return false;
	}
	

	public void addDonor() throws IOException {
	    String firstName = input("First name: ");
	    String lastName = input("Last name: ");
	    String password = input("Password: ");
	    System.out.println(mainSystem.addDonor(password,firstName,lastName));
	}
	

	public void addBlood() throws IOException {
	    int donorID = Integer.parseInt(input("Donor ID: "));
	    int bloodType = Integer.parseInt(input("Blood type: "));
	    int donateDate = Integer.parseInt((input("Donation date: ")));
	    int expiryDate = Integer.parseInt((input("Expiry date: ")));
		PathCentre pc = (PathCentre) user;
	    mainSystem.makeDeposit(bloodType,donateDate,pc.getName(),expiryDate,donorID);
	}

	public void addBlood(int donorID, int bloodType, int donateDate, int expiryDate) throws IOException {
		PathCentre pc = (PathCentre) user;
	    mainSystem.makeDeposit(bloodType,donateDate,pc.getName(),expiryDate,donorID);
	    JOptionPane.showMessageDialog(null, "successfully added blood packet");
	}
	
	public void requestBlood() throws IOException {
		int bloodType = Integer.parseInt(input("Blood Type: "));
	    int nPackets = Integer.parseInt(input("Number of packets: "));
	    int useBy = Integer.parseInt(input("Use by: "));
	    Hospital h = (Hospital) user;
	    if (mainSystem.makeRequest(bloodType,nPackets,useBy,h.getName())) {
	        println("Success");
		} else {
	        println("Failed");
		}
	}
	
	// for frontend
	public void requestBlood(int bloodType, int nPackets, int useBy) throws IOException {
	    Hospital h = (Hospital) user;
	    if (mainSystem.makeRequest(bloodType,nPackets,useBy,h.getName())) {
	    	JOptionPane.showMessageDialog(null, "successfully requested blood packet");
	    	println("Success");
		} else {
			JOptionPane.showMessageDialog(null, "failed to add blood packet");
	        println("Failed");
		}
	}
	
	public void searchBlood() throws IOException {
	    String field = input("Search by: ").toUpperCase().replace(' ', '_');
	    BloodPacket[] packets;
	    if (field.equals("DONATE_LOC") 
				|| field.equals("FIRST_NAME")
				|| field.equals("LAST_NAME")
				|| field.equals("CURR_LOC"))
	    {
	    	String value = input("Value: ");
	    	packets = mainSystem.searchBloodString(field,value);
		} else {
			int value = Integer.parseInt(input("Value: "));
			packets = mainSystem.searchBloodInt(field, value);
		}
	    int i = 0;
	    while (i < packets.length) {
	    	packets[i].printOut();
	    	i += 1;
	    }
	}


    public void printInventory() throws IOException {
	    String field = input("Sort by: ").toUpperCase().replace(" ","_");
	    BloodPacket[] packets = mainSystem.getInventory(field);
	    System.out.println(packets.length + " packets");
	    int i = 0;
	    while (i < packets.length) {
	    	packets[i].printOut();
	    	i += 1;
	    }
    }
    
    public void printBlood() throws IOException {
        String field = input("Sort by: ").toUpperCase().replace(" ","_");
        BloodPacket[] packets = mainSystem.getBloodDatabase(field);
        int i = 0;
	    while (i < packets.length) {
	    	packets[i].printOut();
	    	i += 1;
	    }
    }

    public void setBuffer() throws NumberFormatException, IOException {
    	int nDays = Integer.parseInt(input("Number of days for warning: "));
    	mainSystem.setWarning(nDays);
	}
    
    public void printDonors() {
        User[] users = mainSystem.getDonors();
        int i = 0;
        while (i < users.length) {
        	if (users[i] != null) {
        		users[i].printOut();
        	}
        	i += 1;
        }
    }
    
    public void printHospitals() {
        User[] users = mainSystem.getHospitals();
        int i = 0;
        while (i < users.length) {
        	users[i].printOut();
        	i += 1;
        }
    }
    
    public void printPathCentres() {
        User[] users = mainSystem.getPathCentres();
        int i = 0;
        while (i < users.length) {
        	users[i].printOut();
        	i += 1;
        }
    }

    public void setLowLevel() throws NumberFormatException, IOException {
        int bloodType = Integer.parseInt((input("Blood type: ")));
        int nPackets = Integer.parseInt((input("New low level: ")));
        if (nPackets > 0) {
        	mainSystem.setLowLevel(bloodType,nPackets);
        	
            println("Success");
        } else {
            println("Failed");
        }
    }

    public void setMaxLevel() throws NumberFormatException, IOException {
        int bloodType = Integer.parseInt((input("Blood type: ")));
        int nPackets = Integer.parseInt((input("New low level: ")));
        if (nPackets > 0) {
        	mainSystem.setMaxLevel(bloodType,nPackets);
            println("Success");
        } else {
            println("Failed");
        }
    }
	
	public void run() throws IOException {
		loadDonors();
		System.out.println("Added donors");
		loadHospitals();
		System.out.println("Added hospitals");
		loadPathCentres();
		System.out.println("Added path centres");
		loadInventory();
		System.out.println("Added inventory");
		println("Print HELP for help, QUIT to quit");
		while (true) {
			String cmd = input("$ ").toUpperCase().replace(' ', '_');
			if (cmd.equals("QUIT")) {
				break;
			}
			else if (cmd.equals("PRINT")) {
				printDonors();
			}
			else if (cmd.equals("LOGOUT")) {
				user = null;
				userType = "";
				println("Logging out...");
				println("Logged out");
			} else if (cmd.equals("HELP")) {
				printHelp();
			} else if (!routeCommand(cmd)) {
				println("'"+cmd+"' is not a real command");
			}
			println("---------------------------------");
		}
		print("Quitting....");
	}
	
	public void loadDonors() throws IOException {
		JSONArray jsonArray = new JSONArray(new JSONTokener(new FileReader("SENG2011/testData/donors.json")));
		
		jsonArray.forEach(e -> {
			JSONObject temp = (JSONObject) e;
			String password = temp.getString("password");
			String firstName = temp.getString("givenName");
			String lastName = temp.getString("surname");
			this.mainSystem.addDonor(password, firstName, lastName);
		});
	}
	
	public void loadHospitals() throws IOException {
		JSONArray jsonArray = new JSONArray(new JSONTokener(new FileReader("SENG2011/testData/hospitals.json")));
		
		jsonArray.forEach(e -> {
			JSONObject temp = (JSONObject) e;
			String name = temp.getString("name");
			String password = temp.getString("password");
			this.mainSystem.addHospital(name, password);
		});
	}
	
	public void loadPathCentres() throws IOException {
		JSONArray jsonArray = new JSONArray(new JSONTokener(new FileReader("SENG2011/testData/pathCentres.json")));
		
		jsonArray.forEach(e -> {
			JSONObject temp = (JSONObject) e;
			String name = temp.getString("name");
			String password = temp.getString("password");
			this.mainSystem.addPathCentre(name, password);
		});
	}
	
	public void loadInventory() throws IOException {
		JSONArray jsonArray = new JSONArray(new JSONTokener(new FileReader("SENG2011/testData/inventory.json")));
		
		jsonArray.forEach(e -> {
			JSONObject temp = (JSONObject) e;
			int bloodType = temp.getInt("type");
			int donateDate = temp.getInt("donateDate");
			String donateLoc = temp.getString("donateLoc");
			int expiryDate = temp.getInt("expiryDate");
			int donorID = temp.getInt("donorID");
			this.mainSystem.makeDeposit(bloodType, donateDate, donateLoc, expiryDate, donorID);
//			System.out.println("added blood packet"+e.toString());
		});
	}

	public MainSystem getMainSystem() {
		return mainSystem;
	}
	public void setUser(User u) {
		this.user = u;
	}
	public User getUser() {
		return user;
	}

	public String setUserType(String type) {
		return type;
	}
}
