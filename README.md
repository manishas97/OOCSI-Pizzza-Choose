# oocsi-pizzaChoose (WORK IN PROGRESS)
Chooses a random pizza and orders it using the pizzaMail service 🍕

## Setting up the bot
To use the interface, open up the Processing file and make sure you set the following settings:

* **oocsiServer**: The OOCSI server you want to listen on 
* **choosePizzaChannel**: The channel you want to be listening on for calls to this module
* **feedBackChannel**: The channel on which we will receive feedback from the email module (this can be freely chosen).
* **pizzaButtonId**: The id of the button which will interact with this instance of the pizzachoose module.

Also make sure you have installed the [OOCSI-processing](https://github.com/iddi/oocsi-processing) package.

Lastly defnine the pizzas from which a pizza can be chosen.
This is done by creating a pizza object and adding it to the list of pizzas. This is done within the event handler. For example:

```java
pizzas.add(new Pizza("Hawai"));
```

Where hawai is the name of the pizza.



Once you have done so, the interface will listen for events on the specified channel. Once an event is received, it will check the incoming data. If the incomming data is correct, a pizza will be chosen at random out of the predefined pizzas. This pizza will then be ordered using the pizzaMail service. When a the order can not be met by the current pizza place, the same order will be placed at a different venue.

## Picking a pizza
You need to specify one parameter to choose a pizza:
* **User id (int)**: The id of the user/button for which whom the pizza will be ordered

If your data is correct and pizzaChoose is listening the name of the pizza will be returned on the choosePizzaChannel.
* **pizza (string)**: The name of the pizza which was chosen.

When the pizzas get ordered the full order gets returned on the channel.
* **pizzas (string)**: The order which was placed

Also a boolean gets returned to indicate whether we managed to find a place which can deliver the pizza.
* **Order accepted (boolean)**: Whether or not the order was accepted by some pizza place.


Calling the pizzaChoose module multiple times in a small time window will create one big order of pizza's where the amount of pizza's ordered is equal to the amount of times the pizzaChoose module was called.



### Example code
```java
oocsi.channel("choosePizza").data("user", 4).send();
```