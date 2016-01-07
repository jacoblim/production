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
global with sharing class SS_ForecastGraphsContV3 {

	// Opps by forecast Month
	public List<Opportunity> janOpps { get; set; }
	public List<Opportunity> febOpps { get; set; }
	public List<Opportunity> marOpps { get; set; }
	public List<Opportunity> aprOpps { get; set; }
	public List<Opportunity> mayOpps { get; set; }
	public List<Opportunity> junOpps { get; set; }
	public List<Opportunity> julOpps { get; set; }
	public List<Opportunity> augOpps { get; set; }
	public List<Opportunity> sepOpps { get; set; }
	public List<Opportunity> octOpps { get; set; }
	public List<Opportunity> novOpps { get; set; }
	public List<Opportunity> decOpps { get; set; }

	// Forecast Opps by Unit and Vol (JSON.serialize on Map<obj, obj>) - String is JSON obj for VF page
	public Map<String, Double> janOpptys { get; set;}
	public Map<String, Double> febOpptys { get; set;}
	public Map<String, Double> marOpptys { get; set;}
	public Map<String, Double> aprOpptys { get; set;}
	public Map<String, Double> mayOpptys { get; set;}
	public Map<String, Double> junOpptys { get; set;}
	public Map<String, Double> julOpptys { get; set;}
	public Map<String, Double> augOpptys { get; set;}
	public Map<String, Double> sepOpptys { get; set;}
	public Map<String, Double> octOpptys { get; set;}
	public Map<String, Double> novOpptys { get; set;}
	public Map<String, Double> decOpptys { get; set;}

	public Map<String, Double> forecastOptsMapDefault { get; set; } 

	public List<String> forecastOpts { get; set; }

	// Targets for plotting on graph
	public SS_Forecast_Target__c forecastTarget { get; set; }
    public Double targetUnit { get; set; }
    public Double targetVolume { get; set; }
    
    public boolean doDML = false;

    public SS_ForecastGraphsContV3() {

   		//forecastOpts = getForecastPicklistOpts();

		List<SS_Forecast_Target__c> fTList = [SELECT Id, Name, SS_Target_Units__c, SS_Target_Volume__c 
                                              FROM SS_Forecast_Target__c 
                                              WHERE Name = 'Opportunity Forecast Targets'
                                              LIMIT 1];     
        if(!fTList.isEmpty()) {
            System.debug('forecastTarget alredy exists');
            forecastTarget = fTList[0];
            System.debug('forecastTarget exists ' + forecastTarget.Id);
        }
        else {
            System.debug('Need to doDML,  doDML = true');
            doDML = true;
            
            //System.debug('forecastTarget created');
            //forecastTarget = initTarget();
            //System.debug('forecastTarget created ' + forecastTarget.Id);
        }

        // instaniate forecast Opps
        janOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 1];
		
		febOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 1 ];
		
		marOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1];
		
		aprOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE  CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 4 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
		
		mayOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 5 OR CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 4 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
   
		junOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
           
		julOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 7 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
          
		augOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 8 OR CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 7 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ]; 
        
		sepOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 3 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2  OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
         
		octOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 10 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 3 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
       
		novOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 11 OR CALENDAR_MONTH(SS_Close_Date_Forecast__c) = 10 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 3 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ];
     
		decOpps = [SELECT Id,SS_Amount_Forecast__c,SS_Close_Date_Forecast__c,SS_Forecast_Category_Name_Management__c 
                        FROM Opportunity 
                        WHERE CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 4 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 3 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 2 OR CALENDAR_QUARTER(SS_Close_Date_Forecast__c) = 1 ]; 
       

        forecastOptsMapDefault = createOppMap();

		// Calculate Units and Vol
		janOpptys = processOpps(janOpps);
		febOpptys = processOpps(febOpps);
		marOpptys = processOpps(marOpps);
		aprOpptys = processOpps(aprOpps);
		mayOpptys = processOpps(mayOpps);
		junOpptys = processOpps(junOpps);
		julOpptys = processOpps(julOpps);
		augOpptys = processOpps(augOpps);
		sepOpptys = processOpps(sepOpps);
		octOpptys = processOpps(octOpps);
		novOpptys = processOpps(novOpps);
		decOpptys = processOpps(decOpps);
    }

    public PageReference updateTargets() {
        if(Schema.sObjectType.SS_Forecast_Target__c.isUpdateable()) {
            update forecastTarget;
        }else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update SS_Forecast_Target__c'));
        }
        return null;
    }
    
    public PageReference initTarget(){
        if(doDML){
            SS_Forecast_Target__c target = new SS_Forecast_Target__c();
            target.Name = 'Opportunity Forecast Targets';
            target.SS_Target_Units__c = 10;
            target.SS_Target_Volume__c = 1000000;
            
            insert target;

            forecastTarget = target;
            
            return null;
        }
        return null;
    }
    
    // Create initial map for cloning at each step 
    public Map<String, Double> createOppMap() {
    	Map<String, Double> forecastOptsMap = new Map<String, Double>();

        forecastOptsMap.put('Closed Num', 0);
        forecastOptsMap.put('Pipeline Num', 0);
        forecastOptsMap.put('Best Case Num', 0);
        forecastOptsMap.put('Commit Num', 0);
        forecastOptsMap.put('Omitted Num', 0);
        
		forecastOptsMap.put('Closed Vol', 0);
        forecastOptsMap.put('Pipeline Vol', 0);
        forecastOptsMap.put('Best Case Vol', 0);
        forecastOptsMap.put('Commit Vol', 0);
        forecastOptsMap.put('Omitted Vol', 0);

        return forecastOptsMap;
    }


    // for forecast Opps
    public Map<String, Double> processOpps(List<Opportunity> monthOpps) { 

        String oppsUnitsJSON;
        Map<String, Double> forecastOptsMap = forecastOptsMapDefault.clone();

        System.debug('forecastOptsMap start = ' + forecastOptsMap);


        for (Opportunity o : monthOpps) {
            String status = o.SS_Forecast_Category_Name_Management__c;
            if (status != null) {
                System.debug('Forecast Stage: ' + status);
                Double tempNum = forecastOptsMap.get(status + ' Num');
                tempNum++;
                forecastOptsMap.put(status + ' Num', tempNum);

                Double tempVol = forecastOptsMap.get(status + ' Vol');
                Double newVol = o.SS_Amount_Forecast__c;

                if (newVol == null){
                	tempVol = tempVol + 0;
                }
                else {
                	tempVol = tempVol + newVol;
                }             
                forecastOptsMap.put(status + ' Vol', tempVol);
            }
            else {
                /*Integer otherNum = forecastOptsMap.get('Other');
                otherNum++;
                forecastOptsMap.put('Other', otherNum);*/
            }
        }

        System.debug('forecastOptsMap after exe = ' + forecastOptsMap);
        
        //oppsUnitsJSON = JSON.serialize(forecastOptsMap);        
        //return oppsUnitsJSON;
        return forecastOptsMap;
    }

}