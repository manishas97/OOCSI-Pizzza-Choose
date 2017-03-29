ArrayList<Pizza> pizzas = new ArrayList<Pizza>();

void definePizzas(){
    pizzas.add(new Pizza("Hawai", "Sad", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Salami", "Neutral",new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Funghi", "Neutral", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Americana", "Sad", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Chicken Kebab", "Sad", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Four Cheese", "Happy", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Margaritha", "Neutral", new String[] {"Gluten", "Milk"}));
    pizzas.add(new Pizza("Shoarma", "Sad", new String[] {"Gluten", "Milk", "Soy"}));
    pizzas.add(new Pizza("Tonno", "Happy", new String[] {"Gluten", "Milk", "Seafood"}));
}

// Object type to store information about pizzas.
// More variables can be added for when we want to change the probabilities based on emotions
public class Pizza {
    // Define object variables
    String name;
    String mood;
    List<String> allergens;

    // Initialise Pizza object
    public Pizza(String name, String mood, String[] allergens) {
        this.name = name;
        this.mood = mood;
        this.allergens = Arrays.asList(allergens);
    }

    // Return Pizza name
    public String getName(){
        return name;
    }
    
    // Return Pizza mood
    public String getMood(){
        return "Sad";  
    }

    // Return Pizza allergens
    public String[] getAllergens(){
        return allergens.toArray(new String[allergens.size()]);
    }

    // Check if Pizza contains one or multiple of supplied allergenes
    public boolean hasAllergens(List<String> suppliedAllergens){
        if(!Collections.disjoint(allergens, suppliedAllergens)) {
            return true;
        }
        return false;
    }
}