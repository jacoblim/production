public with sharing class testMicroTrigger {
  public Micro_Site__c ms;
  public testMicroTrigger(){
  }
  
  static testMethod void testTestMicroTrigger(){
  	testMicroTrigger tmt = new testMicroTrigger();
  	tmt.ms=new Micro_Site__c();
  	tmt.ms.Name='Test tester';
  	insert tmt.ms;
  	System.assert(tmt.ms.Name.length()>0);
  	system.debug('END TEST');
  }
  
}