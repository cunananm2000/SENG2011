package unsw;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import javax.swing.JOptionPane;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Group;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.Label;
import javafx.scene.control.PasswordField;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
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
		grid.setId("pane");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // User's type
        Label userType = new Label("User Type:");
        userType.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        userType.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(userType, 0, 15);
        ChoiceBox<String> choiceBox = new ChoiceBox<String>();
        choiceBox.getItems().add("Donor");
        choiceBox.getItems().add("Vampire");
        choiceBox.getItems().add("Hospital");
        choiceBox.getItems().add("Pathology Centre");
        grid.add(choiceBox, 1, 15);
        
        // User's name
        Label userName = new Label("User ID:");
        userName.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        userName.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(userName, 0, 16);
        TextField userTextField = new TextField();
        grid.add(userTextField, 1, 16);

        // User's password
        Label pw = new Label("Password:");
        pw.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        pw.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(pw, 0, 17);
        PasswordField pwBox = new PasswordField();
        grid.add(pwBox, 1, 17);
        
        // Confirmation button
        Button btn = new Button("LOGIN");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 18);
        
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
        				VampirePage(primaryStage);
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
        
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	// --------------------------------------------------------------
	// -------------------- DONOR PAGE ------------------------------
	// --------------------------------------------------------------
	public void DonorPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // get the user's full name
        Donor d = (Donor) em.getMainSystem().getDonorDB().search(em.getUser().getId());
		String firstName = d.getFirstName();
		String lastName = d.getLastName();
                
        Label pw = new Label(firstName + " " +lastName);
        pw.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 45px;");
        pw.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(pw, 0, 10);
        
        // Back button
        Button btn = new Button("Signout");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 18);
        
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
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	// --------------------------------------------------------------
	// ------------------- HOSPITAL PAGE ----------------------------
	// --------------------------------------------------------------
	public void HospitalPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("pane");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // get the user's full name
        Hospital h = (Hospital) em.getMainSystem().getHospitalDB().search(em.getUser().getId());
		String hospitalName = h.getName();
        
        Label scenetitle = new Label(hospitalName);
        scenetitle.setStyle("-fx-text-fill: #bf0d0d; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(scenetitle, 0, 12);
        
        // Requested Blood Type
        Label userType = new Label("Blood Type:");
        userType.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        userType.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(userType, 0, 13);
        ChoiceBox<String> blood = new ChoiceBox<String>();
        blood.getItems().add("A-");
        blood.getItems().add("A+");
        blood.getItems().add("B-");
        blood.getItems().add("B+");
        blood.getItems().add("O-");
        blood.getItems().add("O+");
        blood.getItems().add("AB+");
        blood.getItems().add("AB-");
        grid.add(blood, 1, 13);
        
        // number of packets
        Label numPackets = new Label("# Packets Requested:");
        numPackets.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        numPackets.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(numPackets, 0, 14);
        TextField numberOfPackets = new TextField();
        grid.add(numberOfPackets, 1, 14);

        Label exp = new Label("Expirary Date:");
        exp.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        exp.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(exp, 0, 15);
        TextField expBox = new TextField();
        grid.add(expBox, 1, 15);
        
        Button req = new Button("Request Blood");
        HBox reqBtn = new HBox(10);
        reqBtn.setAlignment(Pos.BOTTOM_RIGHT);
        reqBtn.getChildren().add(req);
        grid.add(reqBtn, 0, 16);
        
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
        grid.add(hbBtn, 1, 16);
        
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
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	// --------------------------------------------------------------
	// ----------------- PATHOLOGY PAGE -----------------------------
	// --------------------------------------------------------------
	public void PathologyPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("pane");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        // get the user's full name
        PathCentre p = (PathCentre) em.getMainSystem().getPathDB().search(em.getUser().getId());
		String pathName = p.getName();
        
        Label scenetitle = new Label(pathName);
        scenetitle.setStyle("-fx-text-fill: #bf0d0d; -fx-font-size: 40px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(scenetitle, 0, 14);
        
        // Donate Date
        Label id = new Label("Donor ID:");
        id.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        id.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(id, 0, 15);
        TextField DonorID = new TextField();
        grid.add(DonorID, 1, 15);
        
        // Requested Blood Type
        Label bloodType = new Label("Blood Type:");
        bloodType.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        bloodType.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(bloodType, 0, 16);
        ChoiceBox<String> blood = new ChoiceBox<String>();
        blood.getItems().add("A-");
        blood.getItems().add("A+");
        blood.getItems().add("B-");
        blood.getItems().add("B+");
        blood.getItems().add("O-");
        blood.getItems().add("O+");
        blood.getItems().add("AB+");
        blood.getItems().add("AB-");
        grid.add(blood, 1, 16);
        
        // Donate Date
        Label donateDate = new Label("Donation Date:");
        donateDate.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        donateDate.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(donateDate, 0, 17);
        TextField donation = new TextField();
        grid.add(donation, 1, 17);

        // Expiry Date
        Label expDate = new Label("Expiry Date:");
        expDate.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        expDate.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(expDate, 0, 18);
        TextField expiratory = new TextField();
        grid.add(expiratory, 1, 18);
        
        Button add = new Button("Add Blood");
        HBox addBtn = new HBox(10);
        addBtn.setAlignment(Pos.BOTTOM_RIGHT);
        addBtn.getChildren().add(add);
        grid.add(addBtn, 0, 19);
        
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
        grid.add(hbBtn, 1, 19);
        
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
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	// --------------------------------------------------------------
	// ------------------- VAMPIRE PAGE -----------------------------
	// --------------------------------------------------------------
	public void VampirePage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        Label scenetitle = new Label("Vampire");
        scenetitle.setStyle("-fx-text-fill: #9e0d0d; -fx-font-size: 50px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(scenetitle, 1, 1);
        
        // Back button
        Button signout = new Button("Signout");
        signout.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        signout.setMinSize(150, 35);
        HBox signoutBtn = new HBox(10);
        signoutBtn.setAlignment(Pos.BOTTOM_RIGHT);
        signoutBtn.getChildren().add(signout);
        grid.add(signoutBtn, 2, 7);
        
        // Add donor button
        Button addDonor = new Button("Add donor");
        addDonor.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        addDonor.setMinSize(150, 35);
        HBox addDonorBtn = new HBox(10);
        addDonorBtn.setAlignment(Pos.BOTTOM_RIGHT);
        addDonorBtn.getChildren().add(addDonor);
        grid.add(addDonorBtn, 0, 2);
        
        // clean up button
        Button cleanUp = new Button("Clean Up");
        cleanUp.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        cleanUp.setMinSize(150, 35);
        HBox cleanUpBtn = new HBox(10);
        cleanUpBtn.setAlignment(Pos.BOTTOM_RIGHT);
        cleanUpBtn.getChildren().add(cleanUp);
        grid.add(cleanUpBtn, 1, 2);
        
        // print Inventory
        Button printI = new Button("Inventory");
        printI.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printI.setMinSize(150, 35);
        HBox printIBtn = new HBox(10);
        printIBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printIBtn.getChildren().add(printI);
        grid.add(printIBtn, 0, 3);
        
        // print notifications
        Button printN = new Button("Notifications");
        printN.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printN.setMinSize(150, 35);
        HBox printNBtn = new HBox(10);
        printNBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printNBtn.getChildren().add(printN);
        grid.add(printNBtn, 0, 7);
        
        // print levels
        Button printL = new Button("Levels");
        printL.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printL.setMinSize(150, 35);
        HBox printLBtn = new HBox(10);
        printLBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printLBtn.getChildren().add(printL);
        grid.add(printLBtn, 1, 7);
        
        // print donors
        Button printD = new Button("Donors");
        printD.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printD.setMinSize(150, 35);
        HBox printDBtn = new HBox(10);
        printDBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printDBtn.getChildren().add(printD);
        grid.add(printDBtn, 1, 3);
        
        // print hospitals
        Button printH = new Button("Hospitals");
        printH.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printH.setMinSize(150, 35);
        HBox printHBtn = new HBox(10);
        printHBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printHBtn.getChildren().add(printH);
        grid.add(printHBtn, 0, 4);
        
        // print pathology centres
        Button printP = new Button("Pathology Centres");
        printP.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printP.setMinSize(150, 35);
        HBox printPBtn = new HBox(10);
        printPBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printPBtn.getChildren().add(printP);
        grid.add(printPBtn, 1, 4);
        
     	// print blooddatabase
        Button printBD = new Button("Blood Database");
        printBD.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printBD.setMinSize(150, 35);
        HBox printBDBtn = new HBox(10);
        printBDBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printBDBtn.getChildren().add(printBD);
        grid.add(printBDBtn, 0, 5);
        
        // print levels
        Button printS = new Button("Search Database");
        printS.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printS.setMinSize(150, 35);
        HBox printSBtn = new HBox(10);
        printSBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printSBtn.getChildren().add(printS);
        grid.add(printSBtn, 1, 5);
        
        // set low level of blood
        Button printSL = new Button("Set Low-Level");
        printSL.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printSL.setMinSize(150, 35);
        HBox printSLBtn = new HBox(10);
        printSLBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printSLBtn.getChildren().add(printSL);
        grid.add(printSLBtn, 0, 6);
        
        // set warning buffer 
        Button printSB = new Button("Set Buffer");
        printSB.setStyle("-fx-border-color: #8b0000; -fx-border-width: 2px;");
        printSB.setMinSize(150, 35);
        HBox printSBBtn = new HBox(10);
        printSBBtn.setAlignment(Pos.BOTTOM_RIGHT);
        printSBBtn.getChildren().add(printSB);
        grid.add(printSBBtn, 1, 6);
        
        signout.setOnAction(new EventHandler<ActionEvent>() {
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

        addDonor.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	addDonorStage(primaryStage);
            }
        });
        
        cleanUp.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	em.getMainSystem().cleanUp();
            	JOptionPane.showMessageDialog(null, "successfully removed all bad blood packets");
            }
        });
        
        printI.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	InventoryPage(primaryStage);
            }
        });
        
        printN.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	NotificationsPage(primaryStage);
            }
        });
        
        printL.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	LevelPage(primaryStage);
            }
        });
        
        printD.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	printDonorPage(primaryStage);
            }
        });
        
        printH.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	printHospitalPage(primaryStage);
            }
        });
        
        printP.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	printPathologyPage(primaryStage);
            }
        });
        
        printBD.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	printBloodDatabase(primaryStage);
            }
        });
        
        printS.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	searchPage(primaryStage);
            }
        });
        
        printSB.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	setBufferPage(primaryStage);
            }
        });
        
        printSL.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	setLowLevelPage(primaryStage);
            }
        });
        
        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	}
	
	
	// --------------------------------------------------------------
	// ------------------- VAMPIRE COMMANDS -------------------------
	// --------------------------------------------------------------
	protected void searchPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));

        Label scenetitle = new Label("Select Search Criteria");
        scenetitle.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        grid.add(scenetitle, 0, 1);
        // number of packets
        Label search = new Label("			Search:");
        search.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        search.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(search, 0, 3);
        
        ChoiceBox<String> options = new ChoiceBox<String>();
        options.getItems().add("ID");
        options.getItems().add("BLOOD_TYPE");
        options.getItems().add("DONATE_DATE");
        options.getItems().add("DONATE_LOC");
        options.getItems().add("EXPIRY_DATE");
        options.getItems().add("DONOR_ID");
        options.getItems().add("FIRST_NAME");
        options.getItems().add("LAST_NAME");
        options.getItems().add("CURR_LOC");
        options.getItems().add("STATUS");
        grid.add(options, 1, 3);
        
     // User's password
        Label q = new Label("			Search Term:");
        q.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        q.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
       
        grid.add(q, 0, 4);
        TextField query = new TextField();
        grid.add(query, 1, 4);
        
        Button req = new Button("search");
        HBox reqBtn = new HBox(10);
        reqBtn.setAlignment(Pos.BOTTOM_RIGHT);
        reqBtn.getChildren().add(req);
        grid.add(reqBtn, 0, 6);
        
        req.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	
        		String option = (String) options.getValue();
        		if (option.equals("DONATE_LOC") ||
    				option.equals("FIRST_NAME") || 
    				option.equals("LAST_NAME")  || 
    				option.equals("CURR_LOC")) {
        			String value = (String) query.getText();	
        			SearchResultsStr(primaryStage, option, value);
        		}	else {
        			int value = Integer.parseInt(query.getText());
        			SearchResultsInt(primaryStage, option, value);
        		}
            }
        });
 
        // Back button
        Button btn = new Button("Back");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					loginScreen(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	}

	protected void SearchResultsInt(Stage primaryStage, String option, int value) {
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
       
        final Label label = new Label("Blood Packet Database (" + option + ")");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        
        label.setFont(new Font("Arial", 20));
        table.setEditable(true);

        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("id"));   
        
        TableColumn bloodType = new TableColumn("Blood Type");
        bloodType.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("bloodType"));
        
        TableColumn donateDate = new TableColumn("Donation Date");
        donateDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateDate"));
        
        TableColumn donateLoc = new TableColumn("Donation Location");
        donateLoc.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateLoc"));
        
        TableColumn expiryDate = new TableColumn("Expiration Date");
        expiryDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("expiryDate"));
        
        TableColumn donorID = new TableColumn("Donor ID");
        donorID.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donorID"));
        
        TableColumn firstName = new TableColumn("First Name");
        firstName.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("firstName"));
        
        TableColumn lastName = new TableColumn("Surname");
        lastName.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("lastName"));
        
        BloodPacket[] packets = em.getMainSystem().searchBloodInt(option,value);
        ObservableList<BloodPacket> data = FXCollections.observableArrayList();
        
        System.out.println(packets);
        
        int i = 0;
	    while (i < packets.length) {
	    	BloodPacket bp = new BloodPacket(packets[i].getID(),packets[i].getBloodType(),packets[i].getDonateDate(),
	    			packets[i].getDonateLoc(), packets[i].getExpiryDate(), packets[i].getDonorID(),
	    			packets[i].getFirstName(), packets[i].getLastName());
	    	data.add(bp);
	    	System.out.println(packets[i].getFirstName());
	    	i += 1;
	    }
        
        
        table.setItems(data);
        table.getColumns().addAll(id,bloodType, donateDate, donateLoc, expiryDate, donorID,firstName,lastName);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		primaryStage.setHeight(405);
					primaryStage.setWidth(650);
					VampirePage(primaryStage);
					
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}

	protected void SearchResultsStr(Stage primaryStage, String option, String value) {
		
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Blood Packet Database (" + option + ")");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        label.setFont(new Font("Arial", 20));
        table.setEditable(true);

        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("id"));   
        
        TableColumn bloodType = new TableColumn("Blood Type");
        bloodType.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("bloodType"));
        
        TableColumn donateDate = new TableColumn("Donation Date");
        donateDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateDate"));
        
        TableColumn donateLoc = new TableColumn("Donation Location");
        donateLoc.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateLoc"));
        
        TableColumn expiryDate = new TableColumn("Expiration Date");
        expiryDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("expiryDate"));
        
        TableColumn donorID = new TableColumn("Donor ID");
        donorID.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donorID"));
        
        TableColumn firstName = new TableColumn("First Name");
        firstName.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("firstName"));
        
        TableColumn lastName = new TableColumn("Surname");
        lastName.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("lastName"));
        
        BloodPacket[] packets = em.getMainSystem().searchBloodString(option,value);
        ObservableList<BloodPacket> data = FXCollections.observableArrayList();
        
        System.out.println(packets);
        
        int i = 0;
	    while (i < packets.length) {
	    	BloodPacket bp = new BloodPacket(packets[i].getID(),packets[i].getBloodType(),packets[i].getDonateDate(),
	    			packets[i].getDonateLoc(), packets[i].getExpiryDate(), packets[i].getDonorID(),
	    			packets[i].getFirstName(), packets[i].getLastName());
	    	data.add(bp);
	    	System.out.println(packets[i].getFirstName());
	    	i += 1;
	    }
        
        
        table.setItems(data);
        table.getColumns().addAll(id,bloodType, donateDate, donateLoc, expiryDate, donorID,firstName,lastName);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		primaryStage.setHeight(405);
					primaryStage.setWidth(650);
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
	}

	protected void printBloodDatabase(Stage primaryStage) {
		
	    GridPane grid = new GridPane();
        grid.setAlignment(Pos.CENTER);
        grid.setId("background");
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
                
        Label scenetitle = new Label("Select Blood Type:");
        scenetitle.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        grid.add(scenetitle, 0, 13);
        
        Label bloodType = new Label("Blood Type:");
        bloodType.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        bloodType.setFont(Font.font("Tahoma", FontWeight.BOLD, 20));
        grid.add(bloodType, 0, 14);
        ChoiceBox<String> blood = new ChoiceBox<String>();
        blood.getItems().add("ID");
        blood.getItems().add("BLOOD_TYPE");
        blood.getItems().add("DONATE_DATE");
        blood.getItems().add("DONATE_LOC");
        blood.getItems().add("EXPIRY_DATE");
        blood.getItems().add("DONOR_ID");
        blood.getItems().add("FIRST_NAME");
        blood.getItems().add("LAST_NAME");
        blood.getItems().add("CURR_LOC");
        blood.getItems().add("STATUS");
        grid.add(blood, 1, 14);
    
        Button sortB = new Button("Select");
        HBox sortBtn = new HBox(10);
        sortBtn.setAlignment(Pos.BOTTOM_RIGHT);
        sortBtn.getChildren().add(sortB);
        grid.add(sortBtn, 0, 16);
        
        sortB.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					// add show the inventory
            		String search = (String) blood.getValue();	
            		displayBlood(primaryStage, search);
				} catch (Exception e1) {
					System.out.println("can't change stage");
				}
            }
        });
        
        Button btn = new Button("Back");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 16);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vamppire screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	    
		
	}

	protected void displayBlood(Stage primaryStage, String search) {

		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Blood Packet Database");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        
        table.setEditable(true);
        
        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("id"));   
        
        TableColumn bloodType = new TableColumn("Blood Type");
        bloodType.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("bloodType"));
        
        TableColumn donateDate = new TableColumn("Donation Date");
        donateDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateDate"));
        
        TableColumn donateLoc = new TableColumn("Donation Location");
        donateLoc.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateLoc"));
        
        TableColumn expiryDate = new TableColumn("Expiration Date");
        expiryDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("expiryDate"));
        
        TableColumn donorID = new TableColumn("Donor ID");
        donorID.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donorID"));
        
        TableColumn firstName = new TableColumn("First Name");
        firstName.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("firstName"));
        
        TableColumn lastName = new TableColumn("Surname");
        lastName.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("lastName"));
        
        BloodPacket[] packets = em.getMainSystem().getBloodDatabase(search);
        ObservableList<BloodPacket> data = FXCollections.observableArrayList();
        
        int i = 0;
	    while (i < packets.length) {
	    	BloodPacket bp = new BloodPacket(packets[i].getID(),packets[i].getBloodType(),packets[i].getDonateDate(),
	    			packets[i].getDonateLoc(), packets[i].getExpiryDate(), packets[i].getDonorID(),
	    			packets[i].getFirstName(), packets[i].getLastName());
	    	data.add(bp);
	    	i += 1;
	    }
        
        
	    System.out.println(data);
        table.setItems(data);
        table.getColumns().addAll(id,bloodType, donateDate, donateLoc, expiryDate, donorID,firstName,lastName);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}
	
	protected void printPathologyPage(Stage primaryStage) {
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Pathology Centres");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        table.setEditable(true);
        
        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<PathCentre, String>("id"));
        id.setMinWidth(100);
        TableColumn name = new TableColumn("Pathology Centre Name");
        name.setCellValueFactory(new PropertyValueFactory<PathCentre, String>("name"));
        name.setMinWidth(250);

        User[] users = em.getMainSystem().getPathCentres();
        ObservableList<PathCentre> data = FXCollections.observableArrayList();
        
        int i = 0;
        while (i < users.length) {
        	if (users[i] != null) {
        		PathCentre d = new PathCentre(users[i].getId(), ((PathCentre) users[i]).getName(), users[i].getPassword());
        		data.add(d);
        	}
        	i += 1;
        }
        
	    System.out.println(data);
        table.setItems(data);
        table.getColumns().addAll(id,name);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}

	protected void printHospitalPage(Stage primaryStage) {
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Hospitals");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        table.setEditable(true);

        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<Hospital, String>("id"));
        id.setMinWidth(100);
        TableColumn name = new TableColumn("Hospital Name");
        name.setCellValueFactory(new PropertyValueFactory<Hospital, String>("name"));
        name.setMinWidth(200);

        User[] users = em.getMainSystem().getHospitals();
        ObservableList<Hospital> data = FXCollections.observableArrayList();
        
        int i = 0;
        while (i < users.length) {
        	if (users[i] != null) {
        		Hospital d = new Hospital(users[i].getId(), ((Hospital) users[i]).getName(), users[i].getPassword());
        		data.add(d);
        	}
        	i += 1;
        }
        
	    System.out.println(data);
        table.setItems(data);
        table.getColumns().addAll(id,name);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}

	protected void printDonorPage(Stage primaryStage) {
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Donors");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        table.setEditable(true);

        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<Donor, String>("id"));
        id.setMinWidth(100);
        TableColumn first = new TableColumn("First Name");
        first.setCellValueFactory(new PropertyValueFactory<Donor, String>("firstName"));
        first.setMinWidth(180);
        TableColumn last = new TableColumn("Surname");
        last.setCellValueFactory(new PropertyValueFactory<Donor, String>("lastName"));
        last.setMinWidth(250);

        User[] users = em.getMainSystem().getDonors();
        ObservableList<Donor> data = FXCollections.observableArrayList();
        
        int i = 0;
        while (i < users.length) {
        	if (users[i] != null) {
        		Donor d = new Donor(users[i].getId(), users[i].getPassword(), ((Donor) users[i]).getFirstName(), ((Donor) users[i]).getLastName());
        		data.add(d);
        	}
        	i += 1;
        }
        
	    System.out.println(data);
        table.setItems(data);
        table.getColumns().addAll(id,first,last);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}

	protected void LevelPage(Stage primaryStage) {
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Blood Level");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        table.setEditable(true);

        TableColumn bloodType = new TableColumn("Type");
        bloodType.setCellValueFactory(new PropertyValueFactory<Level, String>("bloodType"));
        bloodType.setMinWidth(100);
        TableColumn capacity = new TableColumn("Amount of Blood Packets");
        capacity.setCellValueFactory(new PropertyValueFactory<Level, String>("capacity"));
        capacity.setMinWidth(180);
        TableColumn warning = new TableColumn("Low on Packets");
        warning.setCellValueFactory(new PropertyValueFactory<Level, String>("warning"));
        warning.setMinWidth(250);
        int[][] level = em.getMainSystem().getLevels();
        ObservableList<Level> data = FXCollections.observableArrayList();
        
        int i = 0;
		while (i < level[0].length) {
			if (level[0][i] <= 1) {
				String cap = level[0][i]+"/"+level[1][i];
				Level l = new Level(i, cap, "*WARNING: CRITICALLY LOW*");
				data.add(l);
			} 
			else if (level[0][i] <= 3) {
				String cap = level[0][i]+"/"+level[1][i];
				Level l = new Level(i, cap, "*WARNING: GETTING LOW*");
				data.add(l);
			} 
			else {
				String cap = level[0][i]+"/"+level[1][i];
				Level l = new Level(i, cap, " ");
				data.add(l);
			}
			i += 1;	
		}
        
        
	    System.out.println(data);
        table.setItems(data);
        table.getColumns().addAll(bloodType, capacity, warning);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}

	protected void NotificationsPage(Stage primaryStage) {
		
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Notifications");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        table.setEditable(true);

        TableColumn type = new TableColumn("Type");
        type.setCellValueFactory(new PropertyValueFactory<Notification, String>("type"));
        
        TableColumn priority = new TableColumn("Priority");
        priority.setCellValueFactory(new PropertyValueFactory<Notification, String>("priority"));
        
        TableColumn desc = new TableColumn("Description");
        desc.setCellValueFactory(new PropertyValueFactory<Notification, String>("desc"));
        desc.setMinWidth(400);
        
        TableColumn date = new TableColumn("Date");
        date.setCellValueFactory(new PropertyValueFactory<Notification, String>("date"));
        
        TableColumn things = new TableColumn("Things?");
        things.setCellValueFactory(new PropertyValueFactory<Notification, String>("things"));
      
        
        Notification[] notify = em.getMainSystem().getNotifs();
        ObservableList<Notification> data = FXCollections.observableArrayList();
        int i = 0;
	    while (i < notify.length) {
	    	Notification n = new Notification(notify[i].getType(), notify[i].getPriority(),
	    			notify[i].getDesc(), notify[i].getDate(), notify[i].getThings());
	    	data.add(n);
	    	i += 1;
	    }
	    System.out.println(data);
        table.setItems(data);
        table.getColumns().addAll(type, priority, desc, date, things);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(600);
        btn.setLayoutY(10);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
 
        primaryStage.setScene(scene);
        primaryStage.show();
	}

	protected void setLowLevelPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        Label scenetitle = new Label("Set Low Level");
        scenetitle.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
 
        // Requested Blood Type
        Label bloodType = new Label("Blood Type:");
        bloodType.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        bloodType.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(bloodType, 0, 3);
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
        
        // Buffer Date
        Label minP = new Label("Minimum Packets:");
        minP.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        minP.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(minP, 0, 4);
        TextField minimum = new TextField();
        grid.add(minimum, 1, 4);
        
        Button lvl = new Button("Set Level");
        HBox lvlBtn = new HBox(10);
        lvlBtn.setAlignment(Pos.BOTTOM_RIGHT);
        lvlBtn.getChildren().add(lvl);
        grid.add(lvlBtn, 0, 6);
        
        lvl.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		int nPackets = Integer.parseInt(minimum.getText());
            		String bloodType = (String) blood.getValue();
            		int bt = convertBloodType(bloodType);
            		em.getMainSystem().setLowLevel(bt,nPackets);	
            		JOptionPane.showMessageDialog(null, "successfully set low level");
				} catch (Exception e1) {
					System.out.println("can't change stage to aaa screen");
				}
            }
        });
        
        // Back button
        Button btn = new Button("Back");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);   
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}

	protected void setBufferPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        Label scenetitle = new Label("Set warning buffer (days)");
        scenetitle.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        // Buffer Date
        Label expDate = new Label("Amount of Days:");
        expDate.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        expDate.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(expDate, 0, 3);
        TextField expiratory = new TextField();
        grid.add(expiratory, 1, 3);
          
        Button buf = new Button("Set Buffer");
        HBox bufBtn = new HBox(10);
        bufBtn.setAlignment(Pos.BOTTOM_RIGHT);
        bufBtn.getChildren().add(buf);
        grid.add(bufBtn, 0, 6);
        
        buf.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		int expDays = Integer.parseInt(expiratory.getText());
            		em.getMainSystem().setWarning(expDays);
            		JOptionPane.showMessageDialog(null, "successfully set buffer");
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });
        
        // Back button
        Button btn = new Button("Back");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to login screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);  
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
	}

	protected void InventoryPage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
                
        Label scenetitle = new Label("Inventory Page");
        scenetitle.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        Label sort = new Label("Sort By:");
        sort.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        sort.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(sort, 0, 4);
        ChoiceBox<String> sortBox = new ChoiceBox<String>();
        sortBox.getItems().add("ID");
        sortBox.getItems().add("BLOOD_TYPE");
        sortBox.getItems().add("DONATE_DATE");
        sortBox.getItems().add("DONATE_LOC");
        sortBox.getItems().add("EXPIRY_DATE");
        sortBox.getItems().add("DONOR_ID");
        sortBox.getItems().add("FIRST_NAME");
        sortBox.getItems().add("LAST_NAME");
        sortBox.getItems().add("CURR_LOC");
        sortBox.getItems().add("STATUS");
        grid.add(sortBox, 1, 4);
           
        Button sortB = new Button("Sort");
        HBox sortBtn = new HBox(10);
        sortBtn.setAlignment(Pos.BOTTOM_RIGHT);
        sortBtn.getChildren().add(sortB);
        grid.add(sortBtn, 0, 6);
        
        sortB.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					// add show the inventory
            		String sortBy = (String) sortBox.getValue();
            		displayInventory(primaryStage, sortBy);
				} catch (Exception e1) {
					System.out.println("can't change stage");
				}
            }
        });
        
        Button btn = new Button("Back");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vamppire screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
        primaryStage.setScene(scene);
        primaryStage.show();
		
	}
	
	protected void displayInventory(Stage primaryStage, String sortBy) {
		Scene scene = new Scene(new Group());
        primaryStage.setWidth(700);
        primaryStage.setHeight(500);
        TableView table = new TableView();
        final Label label = new Label("Inventory (" + sortBy + ")");
        label.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        label.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        table.setEditable(true);
        
 
        TableColumn id = new TableColumn("ID");
        id.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("id"));
        
        TableColumn bloodType = new TableColumn("Blood Type");
        bloodType.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("bloodType"));
        
        TableColumn donDate = new TableColumn("Donation Date");
        donDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateDate"));
        
        TableColumn donLoc = new TableColumn("Donation Location");
        donLoc.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donateLoc"));
        
        TableColumn expDate = new TableColumn("Expiry Date");
        expDate.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("expiryDate"));
        
        TableColumn DonorID = new TableColumn("Donor ID");
        DonorID.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("donorID"));
        
        TableColumn DonorFirst = new TableColumn("Donor Firstname");
        DonorFirst.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("firstName"));
        
        TableColumn DonorLast = new TableColumn("Donot Surname");
        DonorLast.setCellValueFactory(new PropertyValueFactory<BloodPacket, String>("lastName"));
        
        BloodPacket[] packets = em.getMainSystem().getInventory(sortBy);
        ObservableList<BloodPacket> data = FXCollections.observableArrayList();
        int i = 0;
	    while (i < packets.length) {
	    	BloodPacket bld = new BloodPacket(packets[i].getID(),packets[i].getBloodType(),packets[i].getDonateDate(),
	    			packets[i].getDonateLoc(), packets[i].getExpiryDate(), packets[i].getDonorID(),
	    			packets[i].getFirstName(), packets[i].getLastName());
	    	data.add(bld);
	    	i += 1;
	    }
	    System.out.println(data);
	    
        table.setItems(data);
        table.getColumns().addAll(id, bloodType, donDate, donLoc, expDate, DonorID, DonorFirst, DonorLast);
 
        final VBox vbox = new VBox();
        vbox.setSpacing(5);
        vbox.setPadding(new Insets(10, 0, 0, 10));
        vbox.getChildren().addAll(label, table);
 
        // Back button
        Button btn = new Button("Back");
        btn.setLayoutX(650);
        btn.setLayoutY(30);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        ((Group) scene.getRoot()).getChildren().addAll(vbox, btn);
 
        primaryStage.setScene(scene);
        primaryStage.show();
	}

	protected void addDonorStage(Stage primaryStage) {
		GridPane grid = new GridPane();
		grid.setId("background");
        grid.setAlignment(Pos.CENTER);
        grid.setHgap(10);
        grid.setVgap(10);
        grid.setPadding(new Insets(25, 25, 25, 25));
        
        Label scenetitle = new Label("Add Donor");
        scenetitle.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 32px;");
        scenetitle.setFont(Font.font("Tahoma", FontWeight.BOLD, 50));
        grid.add(scenetitle, 0, 0, 2, 2);
        
        // firstname
        Label Username = new Label("First Name:");
        Username.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        Username.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(Username, 0, 2);
        TextField Usernametext = new TextField();
        grid.add(Usernametext, 1, 2);

        // last name
        Label lastN = new Label("Last Name:");
        lastN.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        lastN.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(lastN, 0, 3);
        TextField lastName = new TextField();
        grid.add(lastName, 1, 3);
        
        // password
        Label pss = new Label("Password:");
        pss.setStyle("-fx-text-fill: #8b0000; -fx-font-size: 22px;");
        pss.setFont(Font.font("Tahoma", FontWeight.BOLD, 35));
        grid.add(pss, 0, 4);
        TextField password = new TextField();
        grid.add(password, 1, 4);
        
        Button add = new Button("Add");
        HBox addBtn = new HBox(10);
        addBtn.setAlignment(Pos.BOTTOM_RIGHT);
        addBtn.getChildren().add(add);
        grid.add(addBtn, 1, 5);
        
        add.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
            		String first = (String) Usernametext.getText();
            		String last = (String) lastName.getText();
            		String pass = (String) password.getText();
                    em.getMainSystem().addDonor(pass, first, last);
                    JOptionPane.showMessageDialog(null, "successfully added donor");
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });
        
        // Back button
        Button btn = new Button("Back");
        HBox hbBtn = new HBox(10);
        hbBtn.setAlignment(Pos.BOTTOM_RIGHT);
        hbBtn.getChildren().add(btn);
        grid.add(hbBtn, 1, 6);
        
        btn.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent e) {
            	try {
					VampirePage(primaryStage);
				} catch (Exception e1) {
					System.out.println("can't change stage to vampire screen");
				}
            }
        });

        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().addAll(this.getClass().getResource("text.css").toExternalForm());
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