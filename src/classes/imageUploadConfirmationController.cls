public with sharing class imageUploadConfirmationController {
  public string message         {get; set;}
  public string imageAddress    {get; set;}
  public string microId         {get; set;}
  public boolean renderMicre    {get; set;}
  
  public imageUploadConfirmationController(){
  	String mSiteId=Apexpages.currentPage().getParameters().get('id');
  	
  	if(mSiteId==null){
  		message = 'ERROR THE IMAGE WAS NOT UPDATED OR SAVED';
  	  imageAddress='';
  	  microId='';
  	}
  	else{
  		Micro_Site__c ms = [Select Photo_ID__c, Id From Micro_Site__c where id = :mSiteId];
  		message = 'IMAGE WAS SUCCESSFULLY SAVED, YOU MAY NEED TO REFRESH YOU CURRENT PAGE(S) TO SEE CHANGES';
  		imageAddress='servlet/servlet.ImageServer?id='+ms.Photo_ID__c+'&oid='+System.Userinfo.getOrganizationId();
  	}
  }
  static testMethod void testImageUpload() {
  	micrositeTestingUtil mtu = new micrositeTestingUtil();
  	imageUploadConfirmationController iucc = new imageUploadConfirmationController();
  	System.assertEquals(iucc.message, 'ERROR THE IMAGE WAS NOT UPDATED OR SAVED');
  	ApexPages.currentPage().getParameters().put('id', mtu.micrositeId);
  	iucc =  new imageUploadConfirmationController();
  	System.assertEquals(iucc.message, 'IMAGE WAS SUCCESSFULLY SAVED, YOU MAY NEED TO REFRESH YOU CURRENT PAGE(S) TO SEE CHANGES');
  }
}