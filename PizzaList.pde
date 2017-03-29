void definePizzas(){
        pizzas.add(new Pizza("Hawai"));
        pizzas.add(new Pizza("Salami"));
        pizzas.add(new Pizza("Fungi"));
}

// Object type to store information about pizzas.
// More variables can be added for when we want to change the probabilities based on emotions
public class Pizza {
    String name; //Unique name of the pizza

    public Pizza(String name) {
        this.name = name;
    }

    public String getName(){
        return name;
    }
}