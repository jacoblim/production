public with sharing class microPageController {
  
  public String        microId             {get; set;}
  public Micro_Site__c microSite           {get; set;}
  public String        msName              {get; set;}
  public String        msTitle             {get; set;}
  public String        msEmail             {get; set;}
  public String        msBiography         {get; set;}
  public String        msPersonalInfo      {get; set;}
  public String        msPhone             {get; set;}
  public String        msOID               {get; set;}
  public String        imageLink           {get; set;}
  public String        userId              {get; set;}
  public String        yuiDepend           {get; set;}
  public String        msExtension         {get; set;}
  public Boolean       renderForm          {get; set;}
  public String        pathVar             {get; set;}
  public Boolean       testing             {get; set;}
  
  //contsructor
  public  microPageController(){
   microId = Apexpages.currentPage().getParameters().get('id');
   try{
   	setupPathVar();
   }catch(Exception e){
   	Apexpages.addMessages(e);
   }
   if(microId != null & microId !='')
     setupObjects();      
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
        currentSite = 'http://microsite-developer-edition.na7.force.com/micropage?id='+userId;
      }
      Integer i;
      List <String> currentSiteSplit = currentSite.split('/');
      
      for(i=0; i<currentSiteSplit.size(); i++){
        if(currentSiteSplit[i].startsWith('micropage'))
          break;
      }
      
      i=i-1;
      if(currentSiteSplit[i].endsWith('com')&&testing)
        pathVar=currentSiteSplit[i];
      while(i>=0 && currentSiteSplit[i] !=null && !currentSiteSplit[i].endsWith('com')){
        pathVar=currentSiteSplit[i]+'/'+pathVar;
        i=i-1;
      }
      if(pathVar.length()>0)
        pathVar=pathVar.substring(0, pathVar.length()-1);
    }
  }
  
  //get and set all the object properties needed  
  private void setupObjects(){
    try{
      microSite = [Select Photo_ID__c, Name, User_Phone__c, User_Extension__c, Id, User__r.Id, User__r.Email, User__r.Title, User__c, Biography__c, Personal_Information__c 
                   From Micro_Site__c 
                   where Id = :microId];
    }catch(Exception e){
      Apexpages.addMessages(e);
    }
      if(microSite != null){
        microId=microSite.Id;
        msName = microSite.Name;
        msTitle = microSite.User__r.Title;
        msEmail = microSite.User__r.Email;
        msBiography = microSite.Biography__c;
        msPersonalInfo = microSite.Personal_Information__c;
        msPhone = microSite.User_Phone__c;
        userId = microSite.User__r.Id;
        if(userId!=null && userId!='')
         renderForm=true;
        else
         renderForm=false;
        msExtension = microSite.User_Extension__c;
        if(msExtension!=null && msExtension !='')
         msPhone= msPhone+' x'+msExtension;
    }
    msOID=System.Userinfo.getOrganizationId();
    imageLink ='/servlet/servlet.ImageServer?id='+microSite.Photo_ID__c+'&oid='+msOID+'&lastMod=1263330074000';
  }
  
  static testMethod void testMicroPageController(){
  	micrositeTestingUtil mtu = new micrositeTestingUtil();
  	microPageController mpc = new microPageController();
    Apexpages.currentPage().getParameters().put('id',mtu.micrositeId);
    mpc = new microPageController();
    mpc.testing = true;
    mpc.setupPathVar();
    System.assert(mpc.pathVar.length()>0);
  }

}