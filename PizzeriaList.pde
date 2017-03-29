ArrayList<Pizzeria> pizzerias = new ArrayList<Pizzeria>();

void definePizzerias(){
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
    
    public ArrayList<Pizza> pizzas(){
        return availablePizzas;  
    }
    
    public Pizza randomPizza(){
        Random rand = new Random();
        int random = rand.nextInt(availablePizzas.size());  
        
        return availablePizzas.get(random);
    }
}