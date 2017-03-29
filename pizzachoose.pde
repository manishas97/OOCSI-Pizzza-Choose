import processing.core.PApplet;
import nl.tue.id.oocsi.*;
import nl.tue.id.oocsi.client.services.*;

import java.util.*;   

    
    OOCSI oocsi;

    //Global variables
    ArrayList<Pizza> toOrder = new ArrayList<Pizza>(); //Stores the pizzas which need to be ordered
    int userId = 1; //Stores the user id of the sender of the event
    boolean pizzaAdded = false; //Tracks wheter a new pizza was added to the order to be able to reset the counter
    boolean waitingForNext = false; //Stores whether we are already collecting an order
    ArrayList<ArrayList<Pizza>> ordered = new ArrayList<ArrayList<Pizza>>(); //Stores past orders
    HashMap<String,ArrayList<Pizza>> ordersTracker = new HashMap<String, ArrayList<Pizza>>(); //Connects an id to past order

    
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

    public void setup() {

        //Setup oocsi using the variables set in settings
        oocsi = new OOCSI(this, feedbackChannel, oocsiServer);
        oocsi.subscribe(feedbackChannel, "feedbackEvent");
        oocsi.subscribe(choosePizzaChannel, "choosePizzaEvent");
        System.out.println("Start");
        
<<<<<<< HEAD
        // Actually define available Pizzas and Pizzerias
        definePizzas();
        definePizzerias();
=======
        // Settings
        oocsiServer = "oocsi.id.tue.nl"; //The OOCSI server you want to listen on. For example: "oocsi.id.tue.nl".
        feedbackChannel = "choosePizzaService"; //The channel on which we will receive feedback from the email module.
        choosePizzaChannel = "choosePizza"; //The channel you want to be listening on for calls to this module. For example: "choosePizza".
        address = null; //The address where the pizzas will have to be delivered. For example: streetname 99 Eindhoven
        twitterAccount = null; //The Twitter account to which the feedback will be sent. 
        allergies.add(""); //A list of allergies. The following allergies can be specified: Gluten, Milk, Soy and Seafood. Note that allergies should be specified including the capitals. Only one allergy can be added per add function.
       
>>>>>>> d9b9dd17578577902c22eff3ef2fb14746b04558
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
      if(event.has("allergies")){
          for (String allergy : event.getString("allergies").split(" ")) {
             allergies.clear();
             allergies.add(allergy);
          }
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
            oocsi.channel("tweetBot").data("tweet", "Hi @" + twitterAccount + ", your pizza(s) were ordered sucssesfully. Time to get ready for your pizza adventure :D").send();
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