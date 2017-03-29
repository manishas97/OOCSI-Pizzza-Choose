import processing.core.PApplet;
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

import java.util.*;


OOCSI oocsi;

// Global variables
// Tracks wheter a new pizza was added to the order to be able to reset the counter
boolean pizzaAdded = false;  

// Stores whether we are already collecting an order
boolean waitingForNext = false;    

// Stores the amount of times the button is pressed
int pizzaQueue = 0;

// Setting variables, to be set in the setup method
String oocsiServer;
String feedbackChannel;
String choosePizzaChannel;
String address;
String twitterAccount;
ArrayList<String> allergies = new ArrayList<String>();


public void settings() {
    size(500, 500);
}

/**
*  ===================================================
*  Setup Processing
*  ===================================================
*/

public void setup() {
    // SETTINGS
    // The OOCSI server you want to listen on. For example: "oocsi.id.tue.nl".
    oocsiServer = "oocsi.id.tue.nl"; 
    
    // The channel on which we will receive feedback from the email module.
    feedbackChannel = "choosePizzaService";
    
    // The channel you want to be listening on for calls to this module. For example: "choosePizza".
    choosePizzaChannel = "choosePizza"; 
    
    // The address where the pizzas will have to be delivered. For example: streetname 99 Eindhoven
    address = null; 
    
    // The Twitter account to which the feedback will be sent.
    twitterAccount = null;
    
    //A list of allergies. The following allergies can be specified: Gluten, Milk, Soy and Seafood. Note that allergies should be specified including the capitals. Only one allergy can be added per add function.
    allergies.add(""); 
    
    // SETUP
    // Setup oocsi using the variables set in settings
    oocsi = new OOCSI(this, feedbackChannel, oocsiServer);
    oocsi.subscribe(feedbackChannel, "feedbackEvent");
    oocsi.subscribe(choosePizzaChannel, "choosePizzaEvent");
    System.out.println("Start");

    // Actually define available Pizzas and Pizzerias
    definePizzas();
    definePizzerias();
	
	oocsi.channel(choosePizzaChannel).data("response", "Setup of the pizzaChoose service is complete, waiting for events to happen.").send();
}

/**
*  ===================================================
*  Seperate incoming OOCSI calls in settings and button presses
*  ===================================================
*/

//Event listener to receive the button presses and setting changes
void choosePizzaEvent(OOCSIEvent event){
    // Splits button presses from setting changes.
    
    // buttonPressed is called when the variable buttonPress is in the event
    if (event.has("buttonPress")) {
		oocsi.channel(choosePizzaChannel).data("response", "The button has been pressed.").send();
        buttonPressed();
    }
    
    //modifySettings is called when the variable settings is in the event.
    if (event.has("settings")) {
		oocsi.channel(choosePizzaChannel).data("response", "Settings will be updated").send();
        modifySettings(event);
    }

}

/**
*  ===================================================
*  Settings are modified from app
*  ===================================================
*/

// Modifies the settings as specified in the event
void modifySettings(OOCSIEvent event){
    if(event.has("address")) {
        address = event.getString("address");
    }
    
    if(event.has("twitterAccount")) {
        twitterAccount = event.getString("twitterAccount");
    }
    
    if(event.has("allergies")) {
        // Convert comma-seperated string to list
        for (String allergy : event.getString("allergies").split(" ")) {
            allergies.clear();
            allergies.add(allergy);
        }
    }
	
	oocsi.channel(choosePizzaChannel).data("response", "Settings have been updated. Address: " + address + " twitterAccount: " + twitterAccount + " allergies: " allergies.toString()).send();
}

/**
*  ===================================================
*  Button is pressed!
*  ===================================================
*/

void buttonPressed(){
    // Increase the pizzaqueue by one pizza
    pizzaQueue++;
    
    // Set flag, in order to reset countdown
    pizzaAdded = true;

    // If there is no counter running start the counter
    if (!waitingForNext) {
        thread("waitForNext");
    }
}

/**
*  ===================================================
*  Wait until timeout completes
*  ===================================================
*/

void waitForNext(){
    // Prevent the spawning of new threads
    waitingForNext = true;
    
    // Count to 10, before the order is actually placed
    for (int i = 0; i <= 100; i++) {
        delay(300);
        System.out.print(i + " - ");

        // Keep tracking if pizza's are being added to the queue
        if (pizzaAdded == true) {
            // If they are, reset the flag and reset the timer
            i = 0;
            pizzaAdded = false;
        }
    }
    
    // Place the order when the timer completes
    System.out.println("Placing the order! \n");
	oocsi.channel(choosePizzaChannel).data("response", "The order has been collected and will now be placed").send();
    order();

    // Allow new threads to be spawned
    waitingForNext = false;
}

/**
*  ===================================================
*  Actually order the pizza!
*  ===================================================
*/

// Sends the order to the pizza delevery guys
void order(){
    // Create list with pizza's that are to be ordered
    HashMap<Pizza, Integer> order = new HashMap<Pizza, Integer>();
    
    // Select a pizzeria by random
    Pizzeria pizzeria = getRandomPizzeria();
    
    // Get constrained pizzalist from pizzeria
    ArrayList<Pizza> pizzaList = pizzeria.pizzas(allergies);
    
    // Get mood
    String mood = "Happy";
    
    // Create a list with weighted pizza options
    ArrayList<Pizza> pizzaOptions = new ArrayList<Pizza>();
    for(Pizza pizza : pizzaList){
        pizzaOptions.add(pizza);
        if(pizza.getMood() == mood){
            pizzaOptions.add(pizza);
        }
    }
    
    // Order all pizzas
    for(int i = 0; i < pizzaQueue; i++){
        // Retrieve random pizza
        Random rand = new Random();
        int random = rand.nextInt(pizzaOptions.size());
        Pizza pizza = pizzaOptions.get(random);
        
        if(order.get(pizza) == null){
            // If key does not exist, set it to 1
            order.put(pizza, 1);
        } else{
            // If key does exist, increase it by 1
            order.put(pizza, order.get(pizza) + 1);
        }
    }
    
    // Initialise email message
    String pizzaNames = "\n";
   
    // Count up all pizza's
    for(Pizza pizza : order.keySet()){
        pizzaNames += "- " + order.get(pizza) + "x " + pizza.getName() + "\n";  
    }
	
    
    //Order the pizza using the pizzaMail module
    OOCSICall orderCall = oocsi.call("PizzaMail", 20000)
        .data("to", pizzeria.getEmail())
        .data("subject", "Pizza order")
        .data("content", "Location " + address + "wants to order the following pizzas: " + pizzaNames + "\n\n Kind regards,\n The PizzaButton Team");
    
    // Send the email and wait for response
	oocsi.channel(choosePizzaChannel).data("response", "The pizza is ordered now, waiting for a response from the pizza place").send();
    System.out.println("Sending the mail containing the order and waiting for a response from the mail module... \n");
    orderCall.sendAndWait();
    
    // If response is completed, seperate it
    if (orderCall.hasResponse()) {
        // Retrieve response
        OOCSIEvent response = orderCall.getFirstResponse();
        
        if(response.getBoolean("success", false) == true) {
            // Email was sent!
            System.out.println("The email was sent!");
            System.out.println("Id in order: " + response.getString("id") + "\n");
			oocsi.channel(choosePizzaChannel).data("response", "The following pizzas have been ordered " + pizzaNames).send();
        }
        else {
            // PizzaMail threw an error whilst sending, let us try again
            System.out.println("The mail could not be sent:" + response + "\n");
			oocsi.channel(choosePizzaChannel).data("response", "Sorry, something is going wrong while sending the email, please check whether your oocsi-pizzamail is configured correctly" + pizzaNames).send();
        }
    }
}

/**
*  ===================================================
*  Listen for feedback from PizzaMail
*  ===================================================
*/

//Receive the feedback from the pizzaMail module.
void feedbackEvent(OOCSIEvent event) {
    // Get email id
    String id = event.getString("id");
    System.out.println("A response has been received with id: " + id);
    
    // Check the response
    if (event.getString("reply").toLowerCase().indexOf("true") != -1) {
        // If true is replied, the order is completed, and we wait for the pizza!
        oocsi.channel(choosePizzaChannel).data("response", "Order accepted :D").send();
        System.out.println("Order accepted");
        
        // Also let the user know via Twitter that Pizza is imminent
        oocsi.channel("tweetBot").data("tweet", "Hi @" + twitterAccount + ", your pizza(s) were ordered sucssesfully. Time to get ready for your pizza adventure :D").send();        
        
        // Also reset the Pizza queue for the next Pizza party
        pizzaQueue = 0;
    }
    else {
        // If false is returned, we forward that message to the feedback channel
        oocsi.channel(choosePizzaChannel).data("response", "Order failed, trying somehwere else").send();
        System.out.println("Order failed, trying again.");
        
        // Also, we place the order again
        order();
    }

}

public void draw(){
    background(255);
    fill(0);
}