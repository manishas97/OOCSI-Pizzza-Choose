

# oocsi-pizzaChoose (WORK IN PROGRESS)
Chooses a random pizza and orders it using the pizzaMail service 🍕

A new instance of this serice has to be ran for every household/location

## Setting up the service
To use the service, make a local copy of this repository. Then open up the "pizzachoose.pde" Processing file and make sure you set the following settings:

* **oocsiServer** (String): The OOCSI server you want to listen on. For example: "oocsi.id.tue.nl".
* **choosePizzaChannel** (String): The channel you want to be listening on for calls to this module. For example: "choosePizza".
* **feedBackChannel** (String): The channel on which we will receive feedback from the email module.
* **address** (String): The address where the pizzas will have to be delivered. For example: streetname 99 Eindhoven
* **twitterAccount** (String): The Twitter account to which the feedback will be sent. 
* **Allergies** (ArrayList`<String>`): A list of allergies. The following allergies can be specified: Gluten, Milk, Soy and Seafood. Note that allergies should be specified including the capitals. Only one allergy can be added per add function. For example: "allergies.add("Soy");".

Alternatively these settings can be set over OOCSI once the service is running. For allergies multiple allergies seperated by a spacebar can be specified at once over OOCSI.
To change these settings over OOCSI sent the following command where SETTING is one of the above defined settings and VALUE is the corresponding value for this setting:

```java
oocsi.channel("choosePizza").data("settings", "").data(SETTING, VALUE).send();
``` 

Also make sure you have installed the [OOCSI-processing](https://github.com/iddi/oocsi-processing) package.



## Ordering some pizzas
Ordering pizza(s) is done using the following command:

```java
oocsi.channel("choosePizza").data("buttonPress", "").send();
```

Ordering multiple pizzas can be done by pressing the button multiple times with a maximum time interval of 100 seconds. When the 100 seconds have passed since the last button press the order will be placed.