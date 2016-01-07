public with sharing class imageUpload {
    
    public Blob           file       {get; set;}
    public String         fileName   {get; set;}
    public Document       newDoc     {get; set;}
    public Micro_Site__c  microSite  {get; set;}
    public Folder         microFolder{get; set;}

    //constructor
    public imageUpload() {
      String mSiteId=Apexpages.currentPage().getParameters().get('id');
      try{
      	microSite = [Select m.Publish_Status__c, m.Photo__c, m.Photo_ID__c, m.Name, m.Id, m.CreatedById From Micro_Site__c m where m.id =:mSiteId]; 
      }catch(Exception e){
      	Apexpages.addMessages(e);
      }      
    }
    
    private static testMethod void testImageUploadConstructor(){
    	micrositeTestingUtil mtu = new micrositeTestingUtil();
    	ApexPages.currentPage().getParameters().put('id', mtu.micrositeId);
    	imageUpload iu =  new imageUpload();
    	system.assert(iu.microSite.Name.length()>0);
    }
    
    //verifies an image then saves
    public Pagereference save(){
    	if(notAnImage(fileName)){
    		return new Pagereference('/apex/imageUploadConfirmation');
    	}
    	
    	//initializing variables
    	Document oldDoc;
    	newDoc = new Document();
    	String userId= System.Userinfo.getUserId();
    	String folderName = 'Micro Site Photos';
    	
    	//get the old Photo_ID used
    	//set the Documents folder you want to use
    	try{
    		oldDoc = [Select Name, Id from Document where Id =:microSite.Photo_ID__c];
    		microFolder=[Select f.Name, f.Id From Folder f where name =:folderName];
    	}catch(Exception e){
        Apexpages.addMessages(e);
      }       
    	
    	     
      //set values and insert new file
      newDoc.Body=file;
      newDoc.Name=fileName;
      newDoc.AuthorId=userId;
      newDoc.IsPublic=true;
      newDoc.IsInternalUseOnly=false;
    	newDoc.FolderId=microFolder.Id;
    	insert newDoc;
    	
    	//update MicroSite
    	microSite.Photo_ID__c=newDoc.Id;
    	update microSite;
    	
    	//delete old file unless it is the default image
    	if(oldDoc !=null && !oldDoc.Name.equals('no_photo_available.jpg'))
    	 delete oldDoc;
    	 
    	return new Pagereference('/'+microSite.Id);
    }               
    
    //make sure the file is an image
    public boolean notAnImage(String picName){
    	if(picName==null)
    	 return true;
    	String fileType;
    	set <String> endings = new set<String>{'png', 'jpg','jpeg','gif'};	
    	if(picName.length()<4)
    	 return true;    	
    	fileType = picName.subString(picName.length()-4, picName.length());
    	for(String ending : endings){
    		if(fileType.toLowerCase().contains(ending))
    		  return false;
    	}
    	return true;
    }  

  static testMethod void testImageUpload() {
      micrositeTestingUtil mtu = new micrositeTestingUtil();
      ApexPages.currentPage().getParameters().put('id', mtu.micrositeId);
      imageUpload iu =  new imageUpload();
      iu.save();
      iu.fileName = 'test';
      iu.save();
      iu.fileName='arf.pdf';
      iu.save();
      iu.fileName='test.gif';
      Document d = [select Body from Document where Name = 'no_photo_available.jpg'];
      iu.file = d.Body;
      iu.save();
      System.assert(iu.notAnImage('thisShouldReturnTrue'));
      System.assert(iu.notAnImage('q'));
      system.debug('TESTS ENDED');
  
  }
}