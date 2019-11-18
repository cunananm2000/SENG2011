package unsw;

import java.io.File;
import java.io.IOException;
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

public class LoginApplication extends Application {
	
	private  MainSystem mainSystem = new MainSystem();
	private  BloodTypeTable bloodTypes = new BloodTypeTable();
	
	public static void main(String[] args) {
		launch(args);
	}

	@Override
    public void start(Stage primaryStage){
        primaryStage.setTitle("Vampire System");
        try {
			loginScreen(primaryStage);
		} catch (Exception e) {
			System.out.println("error");
		}
        
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
            	User user = null;
            	
                String type = (String) choiceBox.getValue();
                int name = Integer.parseInt(userTextField.getText());
                String pass = pwBox.getText();
                System.out.println(type + " " + name + " " + pass);
                
                User u = mainSystem.login(type,name,pass);
        		if (u != null) {
        			user = u;
        			System.out.println("Hello "+name+", a "+type);
        		} else {
        			System.out.println("Bad login");
        		}
            }
        });
        
        Scene scene = new Scene(grid, 650, 405);
        scene.getStylesheets().add("text.css"); // this doesn't work so far
        
        primaryStage.setScene(scene);
        primaryStage.show();
	}
}
