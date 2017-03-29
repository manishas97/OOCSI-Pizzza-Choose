import processing.core.PApplet;
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

import java.util.*;   

    
    OOCSI oocsi;

    //Settings
    String oocsiServer = "oocsi.id.tue.nl";
    String feedbackChannel = "choosePizzaService"; //Channel on which we receive feedback from the email module
    String choosePizzaChannel = "choosePizza"; //Channel on which we listen for the button
    String address = null;
    String twitterAccount = null;
    

    //Global variables
    ArrayList<Pizza> toOrder = new ArrayList<Pizza>(); //Stores the pizzas which need to be ordered
    int userId = 1; //Stores the user id of the sender of the event
    boolean pizzaAdded = false; //Tracks wheter a new pizza was added to the order to be able to reset the counter
    boolean waitingForNext = false; //Stores whether we are already collecting an order
    ArrayList<ArrayList<Pizza>> ordered = new ArrayList<ArrayList<Pizza>>(); //Stores past orders
    HashMap<String,ArrayList<Pizza>> ordersTracker = new HashMap<String, ArrayList<Pizza>>(); //Connects an id to past order
    ArrayList<Pizza> pizzas = new ArrayList<Pizza>();
    
    public void settings() {
        size(500, 500);
    }

    public void setup() {

        //Setup oocsi using the variables set in settings
        oocsi = new OOCSI(this, feedbackChannel, oocsiServer);
        oocsi.subscribe(feedbackChannel, "feedbackEvent");
        oocsi.subscribe(choosePizzaChannel, "choosePizzaEvent");
        System.out.println("Start");
        
        // Actually define available Pizza's
    }

    //Event listener to receive the button presses and setting changes
    void choosePizzaEvent(OOCSIEvent event){
        //Splits button presses from setting changes. 
        //buttonPressed is called when the variable buttonPress is in the event
        if (event.has("buttonPress")) {
          buttonPressed();
        }
        //modifySettings is called when the variable settings is in the event.
        if (event.has("settings")) {
           modifySettings(event); 
        }

    }
    
    // Modifies the settings as specified in the event
    void modifySettings(OOCSIEvent event){
      if(event.has("address")){
         address = event.getString("address");
      }
      if(event.has("twitterAccount")){
         twitterAccount = event.getString("twitterAccount");
      }
      if(event.has("feedbackChannel")){
         feedbackChannel = event.getString("feedbackChannel");
      }
      if(event.has("choosePizzaChannel")){
         choosePizzaChannel = event.getString("choosePizzaChannel");
      }
    }
    
    // Adds a pizza to the order or creates a new order if no order exists.
    void buttonPressed(){
         //Select a pizza at random from the array pizzas
        Random rand = new Random();
        int random = rand.nextInt(pizzas.size());

        System.out.println("Adding pizza to the toOrder list.");
        //Stores the chosen pizza in the array toOrder
        toOrder.add(pizzas.get(random));
        //Recorders that a new pizza was added to allow the counter to be resetted
        pizzaAdded = true;

        //If there is no counter running start the counter
        if (!waitingForNext){
            thread("waitForNext");
        }
    }
    
    // Countdown as long ass pizzas are being added, else send the order
    //While there are pizzas being added to the toOrder array we keep resetting the counter
    //When the counter is done we sent the complete order (this prevents sending every pizza in a different order)
    void waitForNext(){
        waitingForNext = true;
        System.out.println("waitingForNext set to true");
        for (int i = 0; i <= 100; i++){
            delay(100);
            System.out.println(i);
            i++;
            if (pizzaAdded == true){
                i = 0;
                pizzaAdded = false;
            }
        }
        //Place the order
        System.out.println("Placing the order");
        order();

        waitingForNext = false;
    }

    
    // Sends the order to the pizza delevery guys
    void order(){
        //Read the pizza names from the toOrder array
        String pizzaNames = "";
        for (int i = 0; i < toOrder.size(); i++){
            pizzaNames = pizzaNames + ", " + toOrder.get(i).getName();
        }
        System.out.println(pizzaNames);

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
        if (orderCall.hasResponse()){
            OOCSIEvent response = orderCall.getFirstResponse();
            if(response.getBoolean("success", false) == true){
                System.out.println("The email was sent!");
                ArrayList<Pizza> copy = new ArrayList<Pizza>(toOrder);
                ordersTracker.put(response.getString("id"), copy);
                System.out.println("Id in order: " + response.getString("id") + " OrdersTracker to string: " + ordersTracker.toString());
            }
            else {
                System.out.println("The mail could not be send:" + response);
            }
        }

        //Record that we sent the order and clear the toOrder array.
        toOrder.clear();
        System.out.println("toOrder is cleared since the order has been placed");
    }

    //Receive the feedback from the pizzaMail module.
    void feedbackEvent(OOCSIEvent event) {
        String id = event.getString("id");
        System.out.println("A response has been received with id: " + id);
        // When the order is accepted we notify the user
        if (event.getString("reply").toLowerCase().indexOf("true")!= -1){
            oocsi.channel(choosePizzaChannel).data("success", "Order accepted").send();
            System.out.println("Order accepted");
            oocsi.channel("tweetBot").data("tweet", "Hi user " + id + ", your pizza was ordered sucssesfully.").send();
        }
        // When the order is not exepted we try again at a different pizza place
        else {
            oocsi.channel(choosePizzaChannel).data("success", "Order failed, trying somehwere else").send();
            System.out.println("Order failed");
            System.out.println("Id in feedbackEvent" + id);
            System.out.println("ordersTracker tostring: " + ordersTracker.toString());
            System.out.println(ordersTracker.containsKey(id));
            toOrder = ordersTracker.get(id);
            System.out.println("ToOrder size: "+ toOrder.size());
            System.out.println(toOrder.toString());
            order();
        }

    }



    public void draw(){
        background(255);
        fill(0);
    }