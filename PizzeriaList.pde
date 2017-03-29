// Define global pizzeria list
ArrayList<Pizzeria> pizzerias = new ArrayList<Pizzeria>();

// Define available pizzerias
void definePizzerias(){
  // Each pizzeria is defined as follows: Pizzeria(name, email, availablePizzas[])
  pizzerias.add(new Pizzeria("Domino's", "lei.nelissen94@gmail.com", new String[]{
      "Hawai",
      "Salami",
      "Funghi",
      "Americana",
      "Chicken Kebab",
      "Four Cheese",
      "Margaritha",
      "Shoarma",
      "Tonno"
  }));

  pizzerias.add(new Pizzeria("Domino's 2", "lei.nelissen94@gmail.com", new String[]{
      "Hawai",
      "Salami",
      "Funghi",
      "Americana",
      "Chicken Kebab",
      "Four Cheese",
      "Margaritha",
      "Shoarma",
      "Tonno"
  }));

  pizzerias.add(new Pizzeria("Domino's 3", "lei.nelissen94@gmail.com", new String[]{
      "Hawai",
      "Salami",
      "Funghi",
      "Americana",
      "Chicken Kebab",
      "Four Cheese",
      "Margaritha",
      "Shoarma",
      "Tonno"
  }));
}

// An object class to encapsulate the Pizzerias
public class Pizzeria{
    // Define class variables
    String name;
    String email;
    ArrayList<Pizza> availablePizzas;

    // Initialise Pizzeria object
    public Pizzeria(String name, String email, String[] suppliedPizzas){
        this.name = name;
        this.email = email;
        this.availablePizzas = new ArrayList<Pizza>();

        // Loop through supplied pizzalist
        for (String pizzaName : Arrays.asList(suppliedPizzas)){
           // Loop through global pizza list
           for(Pizza pizzaObject : pizzas){
             // Check if a match exists
             if(pizzaObject.getName() == pizzaName){
                 // Add pizza to pizzeria list
                 this.availablePizzas.add(pizzaObject);
             }
           }
        }
    }
  
    // Return pizzeria name
    public String getName(){
        return name;
    }

    // Return pizzeria email
    public String getEmail(){
        return email;
    }
    
    // Return a list of pizzas available at the Pizzeria, constrained by allergens
    public ArrayList<Pizza> pizzas(ArrayList<String> allergens){
        // Initialise return list
        ArrayList<Pizza> pizzaList = new ArrayList<Pizza>();

        // Loop through available pizzas
        for(Pizza pizza : availablePizzas){
            // If pizza does not has allergens, add it to the list!
            if(!pizza.hasAllergens(allergens)){
                pizzaList.add(pizza);
            }
        }
        
        // Return the list
        return pizzaList;
    }
}

// A function to generate a random pizzeria from the global list
Pizzeria getRandomPizzeria(){
    Random rand = new Random();
    int random = rand.nextInt(pizzerias.size());

    return pizzerias.get(random);
}