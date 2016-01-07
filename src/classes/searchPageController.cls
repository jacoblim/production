public with sharing class searchPageController {

  public list <Micro_Site__c>    msList               {get; set;}
  public list <MsClass>          smallMsClassList     {get; set;}
  public list <MsClass>          masterMsClassList    {get; set;}
  public list <list <MsClass>>   msClassLists         {get; set;}
  public String                  searchPhrase         {get; set;}
  public String                  pathVar              {get; set;}
  public Boolean                 testing              {get; set;}
  //constructor 
  public searchPageController(){
  	testing = false;
    setupPathVar();
    searchPhrase=Apexpages.currentPage().getParameters().get('search');
    msList = [Select ID, Start_Zip_Postal_Code_Range__c, Photo_ID__c,
             Name, End_Zip_Postal_Code_Range__c, User_Phone__c, User_Extension__c,
             User__r.Email, User__r.Title, User__r.FirstName, User__r.LastName, User__c 
             From Micro_Site__c where Publish_Status__c = 'Active'];
    setupMasterMsClassList();
    if(searchPhrase!=null)
      doSearch();
    else
     setupSmallMsClassList();
      
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
        currentSite = 'http://microsite-developer-edition.na7.force.com/searchpage';
      }
      Integer i;
      
      if(currentSite==null){
      	return;
      }
      
      List <String> currentSiteSplit = currentSite.split('/');
      
      if(currentSiteSplit == null)
        return;
      
      for(i=0; i<currentSiteSplit.size(); i++){
        if(currentSiteSplit[i].startsWith('searchpage'))
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
  
  //returns a searchpage with search
  public pageReference micropageSearch(){
    PageReference pageRef = new PageReference('/searchpage?search='+searchPhrase);
    return pageRef;
  }
  
  //performs search of either zip code or name
  private void doSearch(){
    smallMsClassList=new list<MsClass>();
    zipCodeSearch();
    nameSearch();
  }
  
  //ensures search is made up of letters and
  //searches for name on all possible name fields
  private void nameSearch(){
    String phrase=SearchPhrase.toLowerCase();
    for(MsClass ms:masterMSClassList){
      if(ms.firstName.toLowerCase().startsWith(SearchPhrase.toLowerCase()))
        smallMsClassList.add(ms);
      else if(ms.lastName.toLowerCase().startsWith(SearchPhrase.toLowerCase()))
        smallMsClassList.add(ms);
      else{
       List <String> splitName = ms.name.split(' ');
       for (String s: splitName){
          if(s.toLowerCase().startsWith(SearchPhrase.toLowerCase()))
            smallMsClassList.add(ms);
       }
      }
    } 
    
  }
  
  //searches for zip code
  //within microsite ranges
  private void zipCodeSearch(){
    if(isZipCode(searchPhrase)){
      for(MsClass ms:masterMsClassList){
        if(searchPhrase>=ms.startZip && searchPhrase<=ms.endZip)
          smallMsClassList.add(ms);
      }
    }
  }
  
  //ensures that content is a zip code
  private boolean isZipCode(String phrase){
    if(phrase.length()!=5)
     return false;
    List<String> nums = searchPhrase.split('');
    String numbers='0123456789';
    for(String s:nums){
      if(!numbers.contains(s))
       return false;
    }
    return true;  
  }
  
  //sets up list used in page
  private void setupSmallMsClassList(){ 
    smallMsClassList = new list<MsClass>();
    
    //if less than 8 just add the list
    if(masterMsClassList.size()<8){
      for(MsClass mc:masterMsClassList)
       smallMsClassList.add(mc);
    }
    else{
      //get 8 random
      for (Integer i=0;i<8;i++)
        smallMsClassList.add(masterMsClassList.remove(Math.round((masterMsClassList.size()-1)*Math.random())));
      //add the 8 back to master list
      for(MsClass mc:smallMsClassList)
       masterMsClassList.add(mc);       
    }
  }
  
  //inner class of objects to display on the page
  private void setupMasterMsClassList(){
    masterMsClassList=new list<MsClass>();
    for (Micro_Site__c ms : msList)
     masterMsClassList.add(new MsClass(ms));
  }

  public Class MsClass{
    public String id             {get; set;}
    public String startZip       {get; set;}
    public String photoId        {get; set;}
    public String phone          {get; set;} 
    public String name           {get; set;}
    public String endZip         {get; set;}
    public String email          {get; set;}
    public String firstName      {get; set;}
    public String lastName       {get; set;}
    public String photoLink      {get; set;}
    public String title          {get; set;}
    public String Ext            {get; set;}
    
    public MsClass(Micro_Site__c ms){
      title       =nullCheck(ms.User__r.Title);
      id          =nullCheck(ms.ID);
      startZip    =nullCheck(ms.Start_Zip_Postal_Code_Range__c);
      photoId     =nullCheck(ms.Photo_ID__c);
      phone       =nullCheck(ms.User_Phone__c);
      name        =nullCheck(ms.Name);
      endZip      =nullCheck(ms.End_Zip_Postal_Code_Range__c);
      email       =nullCheck(ms.User__r.Email);
      firstName   =nullCheck(ms.User__r.FirstName);
      lastName    =nullCheck(ms.User__r.LastName);
      photoLink   =nullCheck('/servlet/servlet.ImageServer?id='+ms.Photo_ID__c+'&oid='+System.Userinfo.getOrganizationId()+'&lastMod=1263330074000');
      if(ms.User_Extension__c!=null)
       phone=phone+' x'+ms.User_Extension__c;
    }
  public String nullCheck(String val){
    if(val==null)
     return '.';
    else 
     return val;
  }
 }

  static testMethod void testSearchPageController(){
  	micrositeTestingUtil mtu = new micrositeTestingUtil();
    searchPageController spc = new searchPageController();
    spc.searchPhrase='t';
    spc.micropageSearch();
    System.assert(spc.smallMsClassList.size()>0);
    Apexpages.currentPage().getParameters().put('search', 't');
    spc = new searchPageController();
    spc.searchPhrase = '94123';
    spc.doSearch();
    System.assert(spc.smallMsClassList.size()>0);
    spc.testing = true;
    spc.setupPathVar();
    spc.searchPhrase = '9412S';
    spc.doSearch();
    System.debug('TESTS ENDED');
  }
}