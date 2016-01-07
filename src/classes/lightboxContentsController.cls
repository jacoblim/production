public with sharing class lightboxContentsController {
  
  public String userId        {get; set;}
  public String pathVar       {get; set;}
  public String firstName     {get; set;}
  public String lastName      {get; set;}
  public String company       {get; set;}
  public String phone         {get; set;}
  public String email         {get; set;}
  public Boolean showforms    {get; set;}
  public Boolean showThankYou {get; set;}
  public Boolean testing      {get; set;}
  
  public lightboxContentsController(){
   showForms = true;
   showThankYou = false;
   testing = false;
   try{
    setupPathVar();
   }catch(Exception e){
    Apexpages.addMessages(e);
   }
    userId=Apexpages.currentPage().getParameters().get('id');   
  }
  
  //create a new lead  
  public Pagereference makeNewLead(){
  	leadSubmitController lsc = new leadSubmitController();
  	if(lsc.createLead(userID, firstName, lastName, company, phone, email, pathVar)){
      showForms = false;
      showThankYou = true;
  	}
  	return null;
  }

  //setup pathVar for any extra path variables
  private void setupPathVar(){
    String Url=Site.getDomain();
    String prefix=Site.getPrefix();
    if(prefix==null)
     prefix='';
    pathVar ='http://'+Url+prefix;
    if(Site.getDomain()==null){
      pathVar='';
      String currentSite = Apexpages.currentPage().getUrl();
      if (testing){
        currentSite = 'http://microsite-developer-edition.na7.force.com/lightboxContents?id='+userId;
      }
      Integer i;
      List <String> currentSiteSplit = currentSite.split('/');
      
      for(i=0; i<currentSiteSplit.size(); i++){
        if(currentSiteSplit[i].startsWith('lightboxContents'))
          break;
      }
      
      i=i-1;
      
      while(i>=0 && currentSiteSplit[i] !=null && !currentSiteSplit[i].endsWith('com')){
        pathVar=currentSiteSplit[i]+'/'+pathVar;
        i=i-1;
      }
      if(pathVar.length()>0)
        pathVar=pathVar.substring(0, pathVar.length()-1);
    }
  }
	
	static testMethod void testLightboxContentsControllerConstructor() {
		 micrositeTestingUtil mtu = new micrositeTestingUtil();
		 Apexpages.currentPage().getParameters().put('id', mtu.userId);
	   lightboxContentsController lcc = new lightboxContentsController();	   
	   System.assert(!lcc.showThankYou);
	   System.assert(lcc.showForms);
	}

  static testMethod void testSetupPathVar(){
  	 micrositeTestingUtil mtu = new micrositeTestingUtil();
     Apexpages.currentPage().getParameters().put('id', mtu.userId);
     lightboxContentsController lcc = new lightboxContentsController();
     lcc.testing = true;
     lcc.setupPathVar();
     System.assert(lcc.userId == mtu.userId);
  }
  
  static testMethod void testmakeNewLead() {
     micrositeTestingUtil mtu = new micrositeTestingUtil();
     Apexpages.currentPage().getParameters().put('id', mtu.userId);
     lightboxContentsController lcc = new lightboxContentsController();
     lcc.firstName = 'Test';
     lcc.lastName = 'Testing';
     lcc.company = 'testing inc';
     lcc.phone = '123-456-7890';
     lcc.email='test@test.com';
     lcc.makeNewLead();
     system.assert(lcc.showThankYou);
     System.assert(!lcc.showForms);
  }
}