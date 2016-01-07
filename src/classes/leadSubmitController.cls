public with sharing class leadSubmitController {
  public String firstName;
  public String lastName;
  public String phone;
  public String email;
  public String userId;
  public String company;
  public String pathVar;
  //constructor
  public leadSubmitController(){}
  
  //gets all properties off post then makes new lead
  public Boolean createLead(String LBuserID, String LBfirstName, String LBlastName, String LBcompany, String LBphone, String LBemail, String LBpathVar){
    firstName= LBfirstName; 
    lastName=LBlastName;    
    phone=LBphone;         
    email=LBemail;         
    userId=LBuserId;       
    company=LBcompany;     
    if(inputsOk()){
     makeNewLead();
     return true;
    }
    else
      return false;
  }
  
  //makes and inserts new lead
  private void makeNewLead(){
   Lead l = new Lead();
   l.OwnerId=userId;
   l.FirstName=firstName;
   l.LastName=lastName;
   l.Email=email;
   l.Phone=phone;
   l.Company=company;
   Insert l;
  }
  
  //check for valid inputs
  private boolean inputsOk(){
    Set <String> inputs = new Set <String>{firstName, lastName, phone, email, userId};
    for (String input:inputs){
      if(input==null||input=='')
       return false;
    }
    return true;
  }
  
  
  static testMethod void testCreateLead() {
    	micrositeTestingUtil mtu = new micrositeTestingUtil();
    	leadSubmitController lcs = new leadSubmitController();
    	Boolean t2 = lcs.createLead(mtu.userId, '', null, null, null, null, null);
    	Boolean t1 =lcs.createLead(mtu.userId, 'test', 'testing', 'testing inc', '123-456-7890', 'test@test.com', 'microsite-developer-edition.na7.force.com');
      System.assert(t1);
      System.assert(!t2);
  }
}