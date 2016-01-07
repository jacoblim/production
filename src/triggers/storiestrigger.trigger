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
trigger storiestrigger on Customer_Stories__c (after update, after insert) {

if(checkRecursive.runOnce()) {
    string keywords ='';
    List <Product2> thisproduct = new List<Product2>();
    Customer_Stories__c storytoupdate = New Customer_Stories__c();
    
        
    LIST <Asset> acc_assets = NEW LIST<Asset>();
    LIST <Customer_Stories__c> storiestoupdate = NEW LIST<Customer_Stories__c>();
    storiestoupdate = [select Id, Product_Keywords__c,Account__c from Customer_Stories__c where Id IN :Trigger.new];    
    LIST <Id> temp = new LIST<Id>();
    for (Customer_Stories__c c : storiestoupdate) {
        temp.add(c.Account__c); }
    
    LIST <Asset> assetsloop = [select Id, AccountId, Product2Id, Name from Asset where AccountId IN :temp];    
    
    LIST <Id> temp2 = new LIST<Id>();
    
    for (Asset a : assetsloop) {
        temp2.add(a.Product2Id); }
     
    LIST <Product2> acc_products = [select Name from Product2 where Id IN :temp2];
    
    if (acc_products != null) {
        if (acc_products.size() > 0) {
    
        Integer count=0;
        for (Customer_Stories__c c : storiestoupdate) {
            
         
            
                    keywords = keywords + acc_products.get(count).Name + ' ';
                    System.debug(logginglevel.INFO,'** ' + keywords);      
                
                    c.Product_Keywords__c = keywords;
                    
                    
            }   // cust stories loop
        update storiestoupdate;
        }// if 
    } // if
    
    } //check recursive
    
    
} // end of trigger