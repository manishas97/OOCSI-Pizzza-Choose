import processing.core.PApplet;
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

import java.util.*;


OOCSI oocsi;

//Global variables
boolean pizzaAdded = false;     //Tracks wheter a new pizza was added to the order to be able to reset the counter
boolean waitingForNext = false;     //Stores whether we are already collecting an order
int pizzaQueue = 0;

//Setting variables, to be set in the setup method
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
    // Settings
    oocsiServer = "oocsi.id.tue.nl"; //The OOCSI server you want to listen on. For example: "oocsi.id.tue.nl".
    feedbackChannel = "choosePizzaService"; //The channel on which we will receive feedback from the email module.
    choosePizzaChannel = "choosePizza"; //The channel you want to be listening on for calls to this module. For example: "choosePizza".
    address = null; //The address where the pizzas will have to be delivered. For example: streetname 99 Eindhoven
    twitterAccount = null; //The Twitter account to which the feedback will be sent.
    allergies.add(""); //A list of allergies. The following allergies can be specified: Gluten, Milk, Soy and Seafood. Note that allergies should be specified including the capitals. Only one allergy can be added per add function.


    //Setup oocsi using the variables set in settings
    oocsi = new OOCSI(this, feedbackChannel, oocsiServer);
    oocsi.subscribe(feedbackChannel, "feedbackEvent");
    oocsi.subscribe(choosePizzaChannel, "choosePizzaEvent");
    System.out.println("Start");

    // Actually define available Pizzas and Pizzerias
    definePizzas();
    definePizzerias();
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
        buttonPressed();
    }
    //modifySettings is called when the variable settings is in the event.
    if (event.has("settings")) {
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
        for (String allergy : event.getString("allergies").split(" ")) {
            allergies.clear();
            allergies.add(allergy);
        }
    }
}

/**
*  ===================================================
*  Button is pressed!
*  ===================================================
*/

// Adds a pizza to the order or creates a new order if no order exists.
void buttonPressed(){
    // Add a pizza to the queue
    pizzaQueue++;

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

// Countdown as long ass pizzas are being added, else send the order
//While there are pizzas being added to the toOrder array we keep resetting the counter
//When the counter is done we sent the complete order (this prevents sending every pizza in a different order)
void waitForNext(){
    waitingForNext = true;
    for (int i = 0; i <= 100; i++) {
        delay(100);
        System.out.print(i + " - ");
        i++;
        if (pizzaAdded == true) {
            i = 0;
            pizzaAdded = false;
        }
    }
    //Place the order
    System.out.println("Placing the order");
    order();

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
    // to address
    .data("to", "lei.nelissen94@gmail.com")
    // email subject
    .data("subject", "Pizza order")
    // email content
    .data("content", "Location " + address + "want to order a the following pizzas: " + pizzaNames);
    // Send the email
    System.out.println("Sending the mail containing the order and waiting for a response from the mail module");
    orderCall.sendAndWait();
    // Wait for response
    if (orderCall.hasResponse()) {
        OOCSIEvent response = orderCall.getFirstResponse();
        if(response.getBoolean("success", false) == true) {
            System.out.println("The email was sent!");
            System.out.println("Id in order: " + response.getString("id"));
        }
        else {
            System.out.println("The mail could not be send:" + response);
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
    String id = event.getString("id");
    System.out.println("A response has been received with id: " + id);
    // When the order is accepted we notify the user
    if (event.getString("reply").toLowerCase().indexOf("true") != -1) {
        oocsi.channel(choosePizzaChannel).data("success", "Order accepted").send();
        System.out.println("Order accepted");
        pizzaQueue = 0;
        oocsi.channel("tweetBot").data("tweet", "Hi @" + twitterAccount + ", your pizza(s) were ordered sucssesfully. Time to get ready for your pizza adventure :D").send();
    }
    // When the order is not exepted we try again at a different pizza place
    else {
        oocsi.channel(choosePizzaChannel).data("success", "Order failed, trying somehwere else").send();
        System.out.println("Order failed, trying again.");
        order();
    }

}

public void draw(){
    background(255);
    fill(0);
}