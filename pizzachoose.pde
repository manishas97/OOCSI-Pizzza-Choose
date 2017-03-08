import nl.tue.id.oocsi.*;


OOCSI oocsi;

//Settings
String oocsiServer = "oocsi.id.tue.nl";
String feedbackChannel = "choosePizzaService"; //Channel on which we receive feedback from the email module
String choosePizzaChannel = "choosePizza"; //Channel on which we listen for the button
int pizzaButtonId = 5; //Unique id of the button we listen to

//Global variables
ArrayList<Pizza> toOrder = new ArrayList<Pizza>(); //Stores the pizzas which need to be ordered
int userId; //Stores the user id of the sender of the event
boolean pizzaAdded = false; //Tracks wheter a new pizza was added to the order to be able to reset the counter
boolean waitingForNext = false; //Stores whether we are already collecting an order
ArrayList<ArrayList<Pizza>> ordered = new ArrayList<ArrayList<Pizza>>(); //Stores past orders
HashMap<String,Integer> ordersTracker = new HashMap<String, Integer>(); //Connects an id to past orders


void setup() {
  
  size(600, 600);
  background(120);

  //Setup oocsi using the variables set in settings
  oocsi = new OOCSI(this, "choosePizzaService", oocsiServer);
  oocsi.subscribe(feedbackChannel, "feedbackEvent");  
  oocsi.subscribe(choosePizzaChannel, "choosePizzaEvent");  
}

//Event listener to receive the button presses
void choosePizzaEvent(OOCSIEvent event) {
  // Expects to receive the buttonId represented as an integer in the variable user.\
  // user:id(int)

  userId = event.getInt("user", 0);
  if(!event.has("user")){
    // Check if event contins the user id
    // If that is not the case, return error and exit execution
    System.out.println("The user id was not specified");
    oocsi.channel("choosePizza").data("pizza", "The user id was not specified").send();
    return;
  }
  if(userId != pizzaButtonId) {
    // Check if event contins the correct user id
    // If that is not the case, return error and exit execution
    System.out.println("The user id was not correct");
    oocsi.channel("choosePizza").data("pizza", "The user id was not correct").send();
    return;
  }
 
  //List of possible pizzas (has to be set manually)
  ArrayList<Pizza> pizzas = new ArrayList<Pizza>();
  pizzas.add(new Pizza("Hawai"));
  pizzas.add(new Pizza("Salami"));
  pizzas.add(new Pizza("Fungi"));
  
  //Select a pizza at random from the array pizzas
  int random = int(random(pizzas.size()));
  
  //Stores the chosen pizza in the array toOrder
  toOrder.add(pizzas.get(random));
  //Recorders that a new pizza was added to allow the counter to be resetted
  pizzaAdded = true;
  
  //If there is no counter running start the counter
  if (!waitingForNext){
    thread("waitForNext");
  }
  
}

//While there are pizzas being added to the toOrder array we keep resetting the counter
//When the counter is done we sent the complete order (this prevents sending every pizza in a different order)
void waitForNext(){
  waitingForNext = true;
  for (int i = 0; i <= 100; i++){
     delay(10);
     i++;
     if (pizzaAdded == true){
         i = 0;
     }
  }
  //Place the order
  order();
  
  //Record that we sent the order and clear the toOrder array.
  ordered.add(toOrder);  
  toOrder.clear();
   
}

void order(){
  //Read the pizza names from the toOrder array
  String pizzaNames = "";
  for (int i = 0; i < toOrder.size(); i++){
    pizzaNames = pizzaNames + ", " + toOrder.get(i).getName();
  }
  
  //Order the pizza using the pizzaMail module
  oocsi
  .channel("PizzaMail")
    // to address
   .data("to", "pizza@delivery.com")
     // email subject
       .data("subject", "Pizza order")
       // email content
         .data("content", "User id " + userId + "want to order a the following pizzas: " + pizzaNames)
           // send the email 🍕
           .send();
}


//Receive the feedback from the pizzaMail module.
//NOTE: At this point we are not able to math the sent order with the email response from the pizza person. 
//This response is needed in order to be able to reorder a failed order at a different pizza place.
void feedbackEvent(OOCSIEvent event) {
    if (event.getString("status") == "sent" && event.getString("success") == "true") {
        oocsi.channel(choosePizzaChannel).data("success", "Order sent").send();
        
    }
    if (event.getString("reply") == "true"){
       oocsi.channel(choosePizzaChannel).data("success", "Order accepted").send();
    }
    if (event.getString("reply") == "false"){
       //We need to order the pizzas at a different pizza place. For this we first need to be able to track the order.
       oocsi.channel(choosePizzaChannel).data("success", "Order was not accepted, trying at a different pizza place").send();
    }
}

// Object type to store information about pizzas.
// More variables can be added forf when we want to change the probabilities based on emotions
public class Pizza {
  String name; //Unique name of the pizza
  
  public Pizza(String name) {
    this.name = name; 
  }
  
  public String getName(){
     return name;
  }
}


void draw() {
  background(255);
  fill(0);
  
}