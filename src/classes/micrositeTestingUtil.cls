public with sharing class micrositeTestingUtil {

  public String micrositeId   {get; set;}
  public String userId        {get; set;}
 
  public micrositeTestingUtil(){
	 	Micro_Site__c m = new Micro_Site__c();
	 	m.Name = 'Test tester';
	 	m.User__c=Userinfo.getUserId();
	 	m.Name = Userinfo.getName();
	 	m.Publish_Status__c = 'Active';
	 	m.Start_Zip_Postal_Code_Range__c = '00000';
	 	m.End_Zip_Postal_Code_Range__c='99999';
	 	insert m;
	  micrositeId = m.Id;
	  userId = Userinfo.getUserId();
	 }

}