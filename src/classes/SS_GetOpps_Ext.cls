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
global with sharing class SS_GetOpps_Ext {

    public List<Opportunity> jan {get;set;}
    public List<Opportunity> feb {get;set;}
    public List<Opportunity> mar {get;set;}
    public List<Opportunity> apr {get;set;}
    public List<Opportunity> may {get;set;}
    public List<Opportunity> jun {get;set;}
    public List<Opportunity> jul {get;set;}
    public List<Opportunity> aug {get;set;}
    public List<Opportunity> sep {get;set;}
    public List<Opportunity> oct {get;set;}
    public List<Opportunity> nov {get;set;}
    public List<Opportunity> dec {get;set;}
    
    public List<Opportunity> opps {get;set;}
    public List<Opportunity> Closedopps {get;set;}
    public List<Opportunity> BestCaseopps {get;set;}
    public List<Opportunity> Pipelineopps {get;set;}
    public List<Opportunity> Omittedopps {get;set;}

    
    public List<Opportunity> fopps {get;set;}
    public List<Opportunity> fClosedopps {get;set;}
    public List<Opportunity> fBestCaseopps {get;set;}
    public List<Opportunity> fPipelineopps {get;set;}
    public List<Opportunity> fOmittedopps {get;set;}
    
    public List<Opportunity> mopps {get;set;}
    public List<Opportunity> mClosedopps {get;set;}
    public List<Opportunity> mBestCaseopps {get;set;}
    public List<Opportunity> mPipelineopps {get;set;}
    public List<Opportunity> mOmittedopps {get;set;}
    
    public List<Opportunity> aopps {get;set;}
    public List<Opportunity> aClosedopps {get;set;}
    public List<Opportunity> aBestCaseopps {get;set;}
    public List<Opportunity> aPipelineopps {get;set;}
    public List<Opportunity> aOmittedopps {get;set;}
    
    public List<Opportunity> mayopps {get;set;}
    public List<Opportunity> mayClosedopps {get;set;}
    public List<Opportunity> mayBestCaseopps {get;set;}
    public List<Opportunity> mayPipelineopps {get;set;}
    public List<Opportunity> mayOmittedopps {get;set;}
    
    public List<Opportunity> juneopps {get;set;}
    public List<Opportunity> juneClosedopps {get;set;}
    public List<Opportunity> juneBestCaseopps {get;set;}
    public List<Opportunity> junePipelineopps {get;set;}
    public List<Opportunity> juneOmittedopps {get;set;}
    
    public List<Opportunity> julyopps {get;set;}
    public List<Opportunity> julyClosedopps {get;set;}
    public List<Opportunity> julyBestCaseopps {get;set;}
    public List<Opportunity> julyPipelineopps {get;set;}
    public List<Opportunity> julyOmittedopps {get;set;}
    
    public List<Opportunity> augopps {get;set;}
    public List<Opportunity> augClosedopps {get;set;}
    public List<Opportunity> augBestCaseopps {get;set;}
    public List<Opportunity> augPipelineopps {get;set;}
    public List<Opportunity> augOmittedopps {get;set;}
    
    public List<Opportunity> septopps {get;set;}
    public List<Opportunity> septClosedopps {get;set;}
    public List<Opportunity> septBestCaseopps {get;set;}
    public List<Opportunity> septPipelineopps {get;set;}
    public List<Opportunity> septOmittedopps {get;set;}
    
    public List<Opportunity> octopps {get;set;}
    public List<Opportunity> octClosedopps {get;set;}
    public List<Opportunity> octBestCaseopps {get;set;}
    public List<Opportunity> octPipelineopps {get;set;}
    public List<Opportunity> octOmittedopps {get;set;}
    
    public List<Opportunity> novopps {get;set;}
    public List<Opportunity> novClosedopps {get;set;}
    public List<Opportunity> novBestCaseopps {get;set;}
    public List<Opportunity> novPipelineopps {get;set;}
    public List<Opportunity> novOmittedopps {get;set;}
    
    public List<Opportunity> decopps {get;set;}
    public List<Opportunity> decClosedopps {get;set;}
    public List<Opportunity> decBestCaseopps {get;set;}
    public List<Opportunity> decPipelineopps {get;set;}
    public List<Opportunity> decOmittedopps {get;set;}
    
    public Date currentDate = Date.today();
    
    public void initOpps(){
        Closedopps = new List<Opportunity>();
        opps = new List<Opportunity>();
        BestCaseopps = new List<Opportunity>();
        Pipelineopps = new List<Opportunity>();
        Omittedopps = new List<Opportunity>();

        
       for(Opportunity oTemp : jan) {
           if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               Closedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               opps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               BestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               Pipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               Omittedopps.add(oTemp);
           }        
       }  
       
       fClosedopps = new List<Opportunity>();
       fopps = new List<Opportunity>();
       fBestCaseopps = new List<Opportunity>();
       fPipelineopps = new List<Opportunity>();
       fOmittedopps = new List<Opportunity>();
       
       
       for(Opportunity oTemp : feb) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               fClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               fopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               fBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               fPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               fOmittedopps.add(oTemp);
           }         
       }  
       
       mClosedopps = new List<Opportunity>();
       mopps  = new List<Opportunity>();
       mBestCaseopps   = new List<Opportunity>();
       mPipelineopps    = new List<Opportunity>();
       mOmittedopps     = new List<Opportunity>();
       
       
       for(Opportunity oTemp : mar) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               mClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               mopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               mBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               mPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               mOmittedopps.add(oTemp);
           }         
       }  
       
       
      aClosedopps = new List<Opportunity>();
      aopps = new List<Opportunity>();
      aBestCaseopps = new List<Opportunity>();
      aPipelineopps = new List<Opportunity>();
      aOmittedopps = new List<Opportunity>();
       
       for(Opportunity oTemp : apr) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               aClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               aopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               aBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               aPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               aOmittedopps.add(oTemp);
           }         
       }  
       
      mayClosedopps = new List<Opportunity>();
      mayopps = new List<Opportunity>();
      mayBestCaseopps = new List<Opportunity>();
      mayPipelineopps = new List<Opportunity>();
      mayOmittedopps = new List<Opportunity>();
       
       
       
       for(Opportunity oTemp : may) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               mayClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               mayopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               mayBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               mayPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               mayOmittedopps.add(oTemp);
           }        
       }
       
       juneClosedopps = new List<Opportunity>();
        juneopps = new List<Opportunity>();
         juneBestCaseopps = new List<Opportunity>();
         junePipelineopps  = new List<Opportunity>();
         juneOmittedopps   = new List<Opportunity>();
       
       for(Opportunity oTemp : jun) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               juneClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               juneopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               juneBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               junePipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               juneOmittedopps.add(oTemp);
           }        
       }
       
       julyClosedopps = new List<Opportunity>();
        julyopps = new List<Opportunity>();
        julyBestCaseopps  = new List<Opportunity>();
         julyPipelineopps  = new List<Opportunity>();
         julyOmittedopps   = new List<Opportunity>();
       
       for(Opportunity oTemp : jul) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               julyClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               julyopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               julyBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               julyPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               julyOmittedopps.add(oTemp);
           }        
       }
       
       augClosedopps = new List<Opportunity>();
      augopps  = new List<Opportunity>();
      augBestCaseopps = new List<Opportunity>();
      augPipelineopps = new List<Opportunity>();
       augOmittedopps = new List<Opportunity>();
       
       for(Opportunity oTemp : aug) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               augClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               augopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               augBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               augPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               augOmittedopps.add(oTemp);
           }        
       }
       
      septClosedopps = new List<Opportunity>();
      septopps = new List<Opportunity>();
       septBestCaseopps= new List<Opportunity>();
     septPipelineopps  = new List<Opportunity>();
      septOmittedopps = new List<Opportunity>();
       
       
       for(Opportunity oTemp : sep) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               septClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               septopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               septBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               septPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               septOmittedopps.add(oTemp);
           }        
       }
       
       octClosedopps= new List<Opportunity>();
       octopps= new List<Opportunity>();
      octBestCaseopps = new List<Opportunity>();
       octPipelineopps= new List<Opportunity>();
       octOmittedopps = new List<Opportunity>();
       
       for(Opportunity oTemp : oct) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               octClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               octopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               octBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               octPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               octOmittedopps.add(oTemp);
           }        
       }
       
       novClosedopps= new List<Opportunity>();
       novopps= new List<Opportunity>();
       novBestCaseopps= new List<Opportunity>();
       novPipelineopps= new List<Opportunity>();
       novOmittedopps = new List<Opportunity>();
       
       
       for(Opportunity oTemp : nov) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               novClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               novopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               novBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               novPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               novOmittedopps.add(oTemp);
           }        
       } 
       
      decClosedopps = new List<Opportunity>();
      decopps = new List<Opportunity>();
      decBestCaseopps = new List<Opportunity>();
      decPipelineopps = new List<Opportunity>();
      decOmittedopps = new List<Opportunity>();
       
       for(Opportunity oTemp : dec) {
            if(oTemp.SS_Forecast_Category_Name_Management__c == 'Closed') {
               decClosedopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Commit') {
               decopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Best Case') {
               decBestCaseopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Pipeline') {
               decPipelineopps.add(oTemp);
           }else if(oTemp.SS_Forecast_Category_Name_Management__c == 'Omitted') {
               decOmittedopps.add(oTemp);
           }        
       }          
    }

    
    public SS_GetOpps_Ext(ApexPages.StandardController controller) {
    
        
       jan = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 1 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       feb = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 2 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       mar = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 3 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       apr = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 4 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       may = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 5 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       jun = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 6 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       jul = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 7 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       aug = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 8 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       sep = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 9 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       oct = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 10 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       nov = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 11 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];
       dec = [SELECT Id, Owner.Name, Account.Name, Product__c, CloseDate, Amount,SS_Amount_Forecast__c,  ForecastCategoryName, SS_Forecast_Category_Name_Management__c, SS_Close_Date_Forecast__c  FROM Opportunity WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 12 AND  SS_Close_Date_Forecast__c = THIS_YEAR ];

       initOpps(); 
    }
   

    public SS_GetOpps_Ext () {

    }
    
    public PageReference sayHello () {
        return null;
    
    }
    
    @RemoteAction
    global static String updateOpportunity(String id, String status, String d, String month) {
    //Date mydate = Date.valueOf(d);
    List<String> s = d.split('/');
    String day = s[0];
    String mont = s[1];
    String year = s[2];
    
    Integer newMonthNum = 0;
    if (month == 'January') {  newMonthNum = 1; }
    if (month == 'February') {  newMonthNum = 2; }
    if (month == 'March') {  newMonthNum = 3; }
    if (month == 'April') {  newMonthNum = 4; }
    if (month == 'May') {  newMonthNum = 5; }
    if (month == 'June') {  newMonthNum = 6; }
    if (month == 'July') {  newMonthNum = 7; }
    if (month == 'August') {  newMonthNum = 8; }
    if (month == 'September') {  newMonthNum = 9; }
    if (month == 'October') {  newMonthNum = 10; }
    if (month == 'November') {  newMonthNum = 11; }
    if (month == 'December') {  newMonthNum = 12; }
    
    System.Debug(month + day + mont + year );
    Integer daye = Integer.valueOf(day);
    System.Debug('This is the day: ' + daye);
    Integer yeare = Integer.valueOf(year);
    System.Debug('This is the yeare: ' + yeare);
    Date dat = Date.newinstance(yeare, newMonthNum, daye);
    System.Debug('This is the dat: ' + dat);
    System.Debug(dat);
    
    System.Debug('Status: ' + status + ' ID = ' + id);
        if (status == 'BestCase') { status = 'Best Case'; }
        
        Opportunity o = [SELECT Id, ForecastCategoryName, SS_Close_Date_Forecast__c, SS_Forecast_Category_Name_Management__c FROM Opportunity WHERE Id =: id];
        System.Debug('Close Date Forecast: '+o.SS_Close_Date_Forecast__c);
        String former =  o.ForecastCategoryName;
        o.SS_Forecast_Category_Name_Management__c = status;
        o.SS_Close_Date_Forecast__c = dat;
        
        if(Schema.sObjectType.Opportunity.isUpdateable()) {
          update o;
        }else {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update Opportunity'));
        }
        
        return 'Old status: ' + former + ' New status: ' + status;  
    }
    
    @RemoteAction
    global static String updateAmount(String id, Double amount) {  
        String status='';
        Opportunity o = [SELECT Id FROM Opportunity WHERE Id =: id];
        o.SS_Amount_Forecast__c = amount;
        if(Schema.sObjectType.Opportunity.isUpdateable()) {
          update o;  
        }else {
          status='NO UPDATE';
        }
        return status;
    }
    
  /*  public void getFields() {
    
         Schema.DescribeFieldResult fieldResult = Opportunity.ForecastCategoryName.getDescribe();
    }
    
    */

}