ArrayList<Pizzeria> pizzerias = new ArrayList<Pizzeria>();

void definePizzerias(){
  pizzerias.add(new Pizzeria("Domino's", "eindhoven@dominospizza.nl", new String[]{"Margeritha"}));
  pizzerias.add(new Pizzeria("Domino's", "eindhoven@dominospizza.nl", new String[]{"Margeritha", "Fungi", "Americana", "Hawaii"}));
  pizzerias.add(new Pizzeria("Domino's", "eindhoven@dominospizza.nl", new String[]{"Margeritha"}));
}

public class Pizzeria{
    // Define class variables
    String name;
    String email;
    ArrayList<Pizza> availablePizzas;
  
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
    
    public String getName(){
        return name;  
    }
    
    public String getEmail(){
        return email;  
    }
    
    public ArrayList<Pizza> pizzas(ArrayList<String> allergens){
        ArrayList<Pizza> pizzaList = new ArrayList<Pizza>();
        
        for(Pizza pizza : availablePizzas){
            if(!allergens.contains(pizza.getName())){
                pizzaList.add(pizza);  
            }
        }
        return pizzaList;  
    }
    
    public Pizza randomPizza(){
        Random rand = new Random();
        int random = rand.nextInt(availablePizzas.size());  
        
        return availablePizzas.get(random);
    }

}

Pizzeria getRandomPizzeria(){
    Random rand = new Random();
    int random = rand.nextInt(pizzerias.size());  
    
    return pizzerias.get(random);    
}