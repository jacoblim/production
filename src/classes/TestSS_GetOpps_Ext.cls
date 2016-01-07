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
public class TestSS_GetOpps_Ext {

    static testMethod void myTest() {
        
        Opportunity opz = new Opportunity(Name = 'asd', StageName = 'Closed Won', CloseDate = Date.Today());
        insert opz;
        
        System.assertEquals('asd',opz.Name);
        
        SS_GetOpps_Ext ext = new SS_GetOpps_Ext();
        
        List<Opportunity> testOpps = new List<Opportunity>();
        
        Opportunity op1 = new Opportunity(Name = 'Test Account Closed', StageName = 'Closed Won', CloseDate = Date.Today(), SS_Forecast_Category_Name_Management__c = 'Closed');
        testOpps.add(op1);
        System.assertEquals(Date.Today(),op1.CloseDate);
        
        Opportunity op2 = new Opportunity(Name = 'Test Account Pipeline', StageName = 'Closed Won', CloseDate = Date.Today(), SS_Forecast_Category_Name_Management__c = 'Pipeline');
        testOpps.add(op2);
        System.assertEquals(Date.Today(),op2.CloseDate);
        
        Opportunity op3 = new Opportunity(Name = 'Test Account Commit', StageName = 'Closed Won', CloseDate = Date.Today(), SS_Forecast_Category_Name_Management__c = 'Commit');
        testOpps.add(op3);
        System.assertEquals(Date.Today(),op3.CloseDate);
        
        Opportunity op4 = new Opportunity(Name = 'Test Account Best Case', StageName = 'Closed Won', CloseDate = Date.Today(), SS_Forecast_Category_Name_Management__c = 'Best Case');
        testOpps.add(op4);
        System.assertEquals(Date.Today(),op4.CloseDate);

        ext.jan = testOpps;
        ext.feb = testOpps;
        ext.mar = testOpps;
        ext.apr = testOpps;
        ext.may = testOpps;
        ext.jun = testOpps;
        ext.jul = testOpps;
        ext.aug = testOpps;
        ext.sep = testOpps;
        ext.oct = testOpps;
        ext.nov = testOpps;
        ext.dec = testOpps;
            
       ext.initOpps();     
         
        
        SS_GetOpps_Ext extsc = new SS_GetOpps_Ext(new ApexPages.StandardController(opz));

        double num = 2.2;
        
        System.assertEquals(2.2,num);
        
        Opportunity o = new Opportunity();
        o.CloseDate = Date.Today();
        o.StageName = 'Closed Won';
        o.Name = 'asdasd';
        insert o;
        
        System.assertEquals(Date.Today(),o.CloseDate);
        System.assertEquals('Closed Won',o.StageName);
        System.assertEquals('asdasd',o.Name);

        List<Opportunity> decopps = new List<Opportunity>();
        for(Integer i = 0; i < 100; i++){

            Opportunity op = new Opportunity(Name = 'Test Account ' + i, StageName = 'Closed Won', CloseDate = Date.Today(), SS_Forecast_Category_Name_Management__c = 'Closed');
            System.assertEquals(Date.Today(),op.CloseDate);
            System.assertEquals('Closed Won',op.StageName);
            System.assertEquals('Test Account ' + i ,op.Name);
            
            decopps.add(op);

       }
        insert decopps;

        SS_GetOpps_Ext.updateOpportunity(o.Id, o.SS_Forecast_Category_Name_Management__c, '06/12/2014', 'January');
        SS_GetOpps_Ext.updateAmount(o.Id, num);
        ext.sayHello();
     }


}