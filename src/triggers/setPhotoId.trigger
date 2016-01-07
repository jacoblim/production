trigger setPhotoId on Micro_Site__c (before insert) {
	
	//this sets each new microsite to a default photo
	list <Document> d;
	
	String defaultPhotoName = 'no_photo_available.jpg';
	
	try{
		d = [select Name, id from Document where Name=:defaultPhotoName];
	}catch(Exception e){
		System.debug(e);
	}
	
	for(Micro_Site__c ms : Trigger.new){
	 ms.Photo_ID__c = d[0].id;
	}

}