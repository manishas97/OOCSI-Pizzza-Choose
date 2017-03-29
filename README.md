

# oocsi-pizzaChoose
Chooses a random pizza and orders it using the pizzaMail service 🍕

A new instance of this service has to be ran for every household/location.


## Ordering some pizzas
Ordering pizza(s) is done using the following command:

```java
oocsi.channel("choosePizza").data("buttonPress", "").send();
```

Ordering multiple pizzas can be done by pressing the button multiple times with a maximum time interval of 30 seconds. When the 30 seconds have passed since the last button press the order will be placed.

### How it works

Ordering a pizza will result in an email being sent to one of the pizzarias defined in the Pizzeria.pde file. This pizza will be randomly chosen from the pizzas available at one of these pizza places. The pizzaria can responde with 'true' to this email to indicate that your order has been accepted. Otherwise the pizzaplace can response with 'false' after which a new order will be placed at a different pizzaria. One we are able to use the mood module we will have the mood influence the likelyhood of ordering a certain pizza. Feedback of this procces will be provided over the same oocsi channel as you sent the button press. When the order is accepted a tweet will be sent out metioning your twitter handle.

### Feedback

Subscribe to the `"choosePizza"` channel to receive feedback on the ongoing Process of ordering Pizza. All feedback will be put into the `response` key - note that this will be a String.

## Setting up the service
To use the service, make a local copy of this repository. Then open up the "pizzachoose.pde" Processing file and make sure you set the following settings:

* **oocsiServer** (String): The OOCSI server you want to listen on. For example: "oocsi.id.tue.nl".
* **choosePizzaChannel** (String): The channel you want to be listening on for calls to this module. For example: "choosePizza".
* **feedBackChannel** (String): The channel on which we will receive feedback from the email module.
* **address** (String): The address where the pizzas will have to be delivered. For example: streetname 99 Eindhoven
* **twitterAccount** (String): The Twitter account to which the feedback will be sent.
* **allergies** (ArrayList`<String>`): A list of allergies. The following allergies can be specified: Gluten, Milk, Soy and Seafood. Note that allergies should be specified including the capitals. Only one allergy can be added per add function. For example: "allergies.add("Soy");".

Alternatively the settings for allergies, address and twitter account can also set over OOCSI once the service is running. For allergies multiple allergies seperated by a spacebar can be specified at once over OOCSI.
To change these settings over OOCSI sent the following command where SETTING is one of the above defined settings and VALUE is the corresponding value for this setting:

```java
oocsi.channel("choosePizza").data("settings", "").data(SETTING, VALUE).send();
```

Note that this module requires the oocsi-pizzamail service to be running. This service can be found at https://github.com/leinelissen/oocsi-pizzamail.

Also make sure you have installed the [OOCSI-processing](https://github.com/iddi/oocsi-processing) package.

## Example code

``` java
import nl.tue.id.oocsi.*;

// ******************************************************
// Example code for using the pizzaChoose service
// ******************************************************

OOCSI oocsi;

//Settings, these need to match the settings in the pizzaChoose service
String oocsiServer = "oocsi.id.tue.nl"; // Your oocsi server
String oocsiChannel = "choosePizza";    // The channel on which the pizzaChoose service is listening

void setup() {
  
  size(200, 200);
  background(120);
  frameRate(10);

  // Initializing OOCSI
  oocsi = new OOCSI(this, "yourName", oocsiServer);
  // Subscribe to the responses send by the pizzaChoose module
  oocsi.subscribe(oocsiChannel, "responseEvent");
  
  // Change a setting of the pizzaChoose module. In this case the twitter account.
  oocsi.channel("choosePizza").data("settings", "").data("twitterAccount" , "yourTwitter").send();
  
  // Simulate a buttonpress to order a pizza
  oocsi.channel(oocsiChannel).data("buttonPress", "").send();
  
}


// The event listener that listens to a response from the pizzaChoose service
void responseEvent(OOCSIEvent event){

    // If we receive a response we print it
    if (event.has("response")) {
      System.out.println(event.getString("response"));
    }
}

void draw() {

}
```