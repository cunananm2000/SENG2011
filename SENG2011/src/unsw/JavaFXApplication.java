package unsw;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TextField;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.scene.text.Text;
import javafx.stage.Stage;

public class JavaFXApplication extends Application {
	
	private Emulator em = new Emulator();
	
	public static void main(String[] args) {
		launch(args);
	}

	@Override
    public void start(Stage primaryStage) throws Exception{
        primaryStage.setTitle("Vampire System");
        em.loadDonors();
    	System.out.println("Added donors");
    	em.loadHospitals();
    	System.out.println("Added hospitals");
    	em.loadPathCentres();
    	System.out.println("Added path centres");
    	em.loadInventory();
    	System.out.println("Added inventory");
    	em.printDonors();
		loginScreen(primaryStage);
    }
	
	public void loginScreen(Stage primaryStage) throws Exception {
		
		GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));

        // Standard Login Text
        Text scenetitle = new Text("Login");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.NORMAL, 20));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        // User's type
        Label userType = new Label("User Type:");
        grid.add(userType, 0, 3);
        ChoiceBox<String> choiceBox = new ChoiceBox<String>();
        choiceBox.getItems().add("Donor");
        choiceBox.getItems().add("Vampire");
        choiceBox.getItems().add("Hospital");
        choiceBox.getItems().add("Pathology Centre");
        grid.add(choiceBox, 1, 3);
        
        // User's name
        Label userName = new Label("User ID:");
        grid.add(userName, 0, 4);
        TextField userTextField = new TextField();
        grid.add(userTextField, 1, 4);

        // User's password
        Label pw = new Label("Password:");
        grid.add(pw, 0, 5);
        PasswordField pwBox = new PasswordField();
        grid.add(pwBox, 1, 5);
        
        // Confirmation button
        Button btn = new Button("LOGIN");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	
                String type = (String) choiceBox.getValue();
                if (type.equals("Pathology Centre")) {
                	type = "PATH_CENTRE";
                }
                int name = Integer.parseInt(userTextField.getText());
                String pass = pwBox.getText();
                System.out.println(type + " " + name + " " + pass);
                
                User u = em.getMainSystem().login(type,name,pass);
                
        		if (u != null) {
        			em.setUser(u);
        			em.setUserType(type);
        			
        			if (type.equalsIgnoreCase("Donor")) {
        				DonorPage(primaryStage);
        			} else if (type.equalsIgnoreCase("Vampire")) {
        				// change stage to vampire page
        			} else if (type.equalsIgnoreCase("Hospital")) {
        				HospitalPage(primaryStage);
        			} else if (type.equalsIgnoreCase("PATH_CENTRE")) {
        				PathologyPage(primaryStage);
        			}
        			
        		} else {
        			System.out.println("Invalid credentials");
        		}

            }
        });
        
        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().add("text.css"); // this doesn't work so far
        
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	public void DonorPage(Stage primaryStage) {
		GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // get the user's full name
        Donor d = (Donor) em.getMainSystem().getDonorDB().search(em.getUser().getId());
		String firstName = d.getFirstName();
		String lastName = d.getLastName();
        
        Text scenetitle = new Text(firstName + " " +lastName);
        scenetitle.setFont(Font.font("Tahoma", FontWeight.NORMAL, 20));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        // Back button
        Button btn = new Button("Signout");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	em.setUser(null);
            	em.setUserType("");
            	try {
					loginScreen(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	public void HospitalPage(Stage primaryStage) {
		GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // get the user's full name
        Hospital h = (Hospital) em.getMainSystem().getHospitalDB().search(em.getUser().getId());
		String hospitalName = h.getName();

        Text scenetitle = new Text(hospitalName);
        scenetitle.setFont(Font.font("Tahoma", FontWeight.NORMAL, 20));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        // Requested Blood Type
        Label userType = new Label("Blood Type:");
        grid.add(userType, 0, 3);
        ChoiceBox<String> blood = new ChoiceBox<String>();
        blood.getItems().add("A-");
        blood.getItems().add("A+");
        blood.getItems().add("B-");
        blood.getItems().add("B+");
        blood.getItems().add("O-");
        blood.getItems().add("O+");
        blood.getItems().add("AB+");
        blood.getItems().add("AB-");
        grid.add(blood, 1, 3);
        
        // number of packets
        Label numPackets = new Label("# Packets Requested:");
        grid.add(numPackets, 0, 4);
        TextField numberOfPackets = new TextField();
        grid.add(numberOfPackets, 1, 4);

        // User's password
        Label exp = new Label("Expirary Date:");
        grid.add(exp, 0, 5);
        TextField expBox = new TextField();
        grid.add(expBox, 1, 5);
        
        Button req = new Button("Request Blood");
        HBox reqBtn = new HBox(10);
        reqBtn.setAlignment(Pos.BOTTOM_RIGHT);
        reqBtn.getChildren().add(req);
        grid.add(reqBtn, 0, 6);
        
        req.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		String bloodType = (String) blood.getValue();
            		int bt = convertBloodType(bloodType);
                    int numPack = Integer.parseInt(numberOfPackets.getText());
                    int expDay = Integer.parseInt(expBox.getText());
                    em.requestBlood(bt, numPack, expDay);
                	HospitalPage(primaryStage);     	
				} catch (IOException e1) {
					System.out.println("can't request blood packet");
				}
            }
        });
 
        // Back button
        Button btn = new Button("Signout");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	em.setUser(null);
            	em.setUserType("");
            	try {
					loginScreen(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	public void PathologyPage(Stage primaryStage) {
		GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // get the user's full name
        PathCentre p = (PathCentre) em.getMainSystem().getPathDB().search(em.getUser().getId());
		String pathName = p.getName();
        
        Text scenetitle = new Text(pathName);
        scenetitle.setFont(Font.font("Tahoma", FontWeight.NORMAL, 20));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        // Donate Date
        Label id = new Label("Donor ID:");
        grid.add(id, 0, 3);
        TextField DonorID = new TextField();
        grid.add(DonorID, 1, 3);
        
        // Requested Blood Type
        Label bloodType = new Label("Blood Type:");
        grid.add(bloodType, 0, 4);
        ChoiceBox<String> blood = new ChoiceBox<String>();
        blood.getItems().add("A-");
        blood.getItems().add("A+");
        blood.getItems().add("B-");
        blood.getItems().add("B+");
        blood.getItems().add("O-");
        blood.getItems().add("O+");
        blood.getItems().add("AB+");
        blood.getItems().add("AB-");
        grid.add(blood, 1, 4);
        
        // Donate Date
        Label donateDate = new Label("Donation Date:");
        grid.add(donateDate, 0, 5);
        TextField donation = new TextField();
        grid.add(donation, 1, 5);

        // Expiry Date
        Label expDate = new Label("Expirary Date:");
        grid.add(expDate, 0, 6);
        TextField expiratory = new TextField();
        grid.add(expiratory, 1, 6);
        
        Button add = new Button("Add Blood");
        HBox addBtn = new HBox(10);
        addBtn.setAlignment(Pos.BOTTOM_RIGHT);
        addBtn.getChildren().add(add);
        grid.add(addBtn, 0, 7);
        
        add.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		int ID = Integer.parseInt(DonorID.getText());
            		String bloodType = (String) blood.getValue();
            		int bt = convertBloodType(bloodType);
                    int dDate = Integer.parseInt(donation.getText());
                    int eDate = Integer.parseInt(expiratory.getText());
                    em.addBlood(ID, bt, dDate, eDate);
                    PathologyPage(primaryStage);     	
				} catch (IOException e1) {
					System.out.println("can't request blood packet");
				}
            }
        });
        
        // Back button
        Button btn = new Button("Signout");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 7);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	em.setUser(null);
            	em.setUserType("");
            	try {
					loginScreen(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	public int convertBloodType(String bloodType) {
		if (bloodType.equals("O-")) return 0;
		else if (bloodType.equals("O+")) return 1;
		else if (bloodType.equals("A-")) return 2;
		else if (bloodType.equals("A+")) return 3;
		else if (bloodType.equals("B-")) return 4;
		else if (bloodType.equals("B+")) return 5;
		else if (bloodType.equals("AB-")) return 6;
		else if (bloodType.equals("AB+")) return 7;			
		else return -1;
	}
}
