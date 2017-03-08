# oocsi-pizzamail
Chooses a random pizza and orders it using the pizzaMail service 🍕

## Setting up the bot
To use the interface, open up the Processing file and make sure you set the following settings:

* **oocsiServer**: The OOCSI server you want to listen on
* **oocsiChannel**: The channel you want to be listening on

Also make sure you have installed the [OOCSI-processing](https://github.com/iddi/oocsi-processing) package.

Lastly defnine the pizzas from which a pizza can be chosen.
This is done by creating a pizza object and adding it to the list of pizzas. This is done within the event handler. For example:

```java   pizzas.add(new Pizza("Hawai"));```

Where hawai is the name of the pizza.



Once you have done so, the interface will listen for events on the specified channel. Once an event is received, it will check the incoming data. If the incomming data is correct, a pizza will be chosen at random out of the predefined pizzas. This pizza will then be ordered using the pizzaMail service.

## Picking a pizza
You need to specify one parameter to choose a pizza:
* **User id (int)**: The id of the user for which whom the pizza will be ordered


If your data is correct and pizzaChoose is listening the name of the pizza will be returned on the same channel.
* **pizza (string)**: The name of the pizza which was chosen.



### Example code
```java
oocsi.channel("choosePizza").data("user", 4).send();
```