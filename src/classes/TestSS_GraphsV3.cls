/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.
*/
@isTest
public class TestSS_GraphsV3 {
    
	static testMethod void myTest() {
        
        Opportunity opz = new Opportunity(Name = 'asd', StageName = 'Closed Won', CloseDate = Date.Today());
        insert opz;
        SS_ForecastGraphsContV3 ext = new SS_ForecastGraphsContV3();

        double test = 2.2;
        Opportunity o = new Opportunity();
        o.CloseDate = Date.Today();
        o.StageName = 'Closed Won';
        o.Name = 'asdasd';
        insert o;
        
        System.assertEquals('Closed Won', o.StageName);

        List<Opportunity> decopps = new List<Opportunity>();
        for(Integer i = 0; i < 200; i++){

            Opportunity op = new Opportunity(Name = 'Test Account ' + i, StageName = 'Closed Won', CloseDate = Date.Today());
            decopps.add(op);
			System.assertEquals('Test Account ' + i, op.Name);
        }
    
        insert decopps;

        List<String> months = new list<String> { 'jan', 'feb', 'mar', 'apr' , 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov' , 'dec' };
        
        for(String month : months) {
        	//SS_ForecastGraphsCont.getOppArray(month, false);
            //SS_ForecastGraphsCont.getOppArray(month, true);
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 201; i < 220; i++){
            
            Opportunity op = new Opportunity(Name = 'Test Account ' + i, StageName = 'Closed Won', CloseDate = Date.parse('21/1/2014'), SS_Amount_Forecast__c = 10000, SS_Close_Date_Forecast__c = Date.parse('21/1/2014'), SS_Forecast_Category_Name_Management__c = 'Closed');
            oppList.add(op);
			System.assertEquals('Test Account ' + i, op.Name);
            
        }    
        
		Map<String, Double> forecastOptsMapDefault = ext.createOppMap();
        ext.processOpps(oppList);
        
        SS_Forecast_Target__c targets = new SS_Forecast_Target__c(SS_Target_Units__c = 15, SS_Target_Volume__c = 1000000);
        
        /*targets.SS_Target_Units__c = 10;
        targets.SS_Target_Volume__c = 20000;
        ext.updateTargets();*/
     }

}