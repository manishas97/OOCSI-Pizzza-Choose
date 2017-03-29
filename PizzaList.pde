ArrayList<Pizza> pizzas = new ArrayList<Pizza>();

void definePizzas(){
    pizzas.add(new Pizza("Hawai", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Salami", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Fungi", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Americana", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Chicken Kebab", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Four Cheese", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Margaritha", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Shoarma", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Tonno", new String[] {"Gluten", "Milk", "Seafood"}));
}

// Object type to store information about pizzas.
// More variables can be added for when we want to change the probabilities based on emotions
public class Pizza {
    // Define object variables
    String name;
    List<String> allergens;

    // Initialise Pizza object
    public Pizza(String name, String[] allergens) {
        this.name = name;
        this.allergens = Arrays.asList(allergens);
    }

    // Return Pizza name
    public String getName(){
        return name;
    }
    
    public String getMood(){
        return "Sad";  
    }

    // Return Pizza allergens
    public String[] getAllergens(){
        return allergens.toArray(new String[allergens.size()]);
    }

    // Check if Pizza contains a single allergen
    public boolean hasAllergen(String suppliedAllergen){
        if(allergens.contains(suppliedAllergen)) {
            return true;
        }
        return false;
    }

    // Check if Pizza contains one or multiple of supplied allergenes
    public boolean hasAllergenes(String[] suppliedAllergens){
        if(!Collections.disjoint(allergens, Arrays.asList(suppliedAllergens))) {
            return true;
        }
        return false;
    }
}