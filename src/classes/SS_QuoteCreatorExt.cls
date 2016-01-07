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
global with sharing class SS_QuoteCreatorExt {

    public Opportunity opp {get; set;}

    public List<PricebookEntry> bookEntryList {get; set;}
    public Map<String, PricebookEntry> prodMap {get; set;}
    public List<QuoteLineItem> lineList {get; set;}
    public String fam {get; set;}
    public String priceBookId {get; set;}
    
    public String qId {get; set;}
    
    public Quote theQuote {get; set;}

    global SS_QuoteCreatorExt() {

    }

    global SS_QuoteCreatorExt(ApexPages.StandardController stdController) {

        this.opp = (Opportunity)stdController.getRecord();
        theQuote = new Quote();
        opp = [select id, Pricebook2Id,Pricebook2.Name  from Opportunity where id =: opp.Id];
        fam='All';
        List<Quote> qList = [select id, PriceBook2Id,Pricebook2.Name from Quote where id =: ApexPages.currentPage().getParameters().get('qId') limit 1]; 
        if(!qList.isEmpty()) {
            theQuote = qList[0];
            qId=theQuote.Id;
        }
        // AND PriceBook2Id =: theQuote.PriceBook2Id
        bookEntryList = [Select Id, UnitPrice, Product2Id,Product2.Name,Product2.Description, Product2.SS_URL_Image__c,Product2.Family from PricebookEntry where PriceBook2Id =: theQuote.PriceBook2Id];

        prodMap =  new Map<String, PricebookEntry>();
        for(PricebookEntry e : bookEntryList) {
            prodMap.put(e.Product2Id,e);
        }
        getProducts();
        getLineItems(); 
    }
    public void getLineItems() {
        lineList = [Select id, ListPrice, PricebookEntry.Product2Id,PricebookEntry.Name,Discount, UnitPrice, Quantity, TotalPrice from QuoteLineItem where QuoteId =: theQuote.Id Order By PricebookEntry.Name];
    }

    @remoteAction
    global static String addProduct(String pBeId, Integer quant, String qId) {
        String status='';

        Boolean hasItem=false;    
        PricebookEntry pEnt = [Select Id, UnitPrice from PricebookEntry where id =: pBeId];
        for(QuoteLineItem ol:[Select Id, PriceBookEntryId, Quantity from QuoteLineItem where QuoteId =: qId]){
            if(ol.PriceBookEntryId == pBeId){
                ol.Quantity += quant;
                if(Schema.sObjectType.QuoteLineItem.isUpdateable()) {
                    update ol;
                }else {
                    status = 'NO UPDATE';
                }
                hasItem=true;
                break;
            }
        }
        if(!hasItem) {
            QuoteLineItem oppitem = new QuoteLineItem();
            oppitem.QuoteId = qId;
            oppitem.PriceBookEntryId = pBeId;
            oppitem.Quantity = quant;
            oppItem.UnitPrice = pEnt.UnitPrice;
            if(Schema.sObjectType.QuoteLineItem.isCreateable()) {
                insert oppitem;
            }else {
                status='NO INSERT';
            }
        }

        return status;
    }

    @remoteAction
    global static String updateLineItem(String itemId,Integer qty,Decimal dis, Decimal uP) {

        String status='';

        QuoteLineItem oppItem = [select id, UnitPrice, Quantity, Discount from QuoteLineItem where id =: itemId];
        if(dis == 0.0)
            oppItem.Discount = null;
        else {
            oppItem.Discount = dis;
        }   
        oppItem.Quantity = qty;
        oppItem.UnitPrice = uP;

        if(Schema.sObjectType.QuoteLineItem.isUpdateable()) {    
            update oppItem;
        }else {
            status = 'NO UPDATE';
        }
        return status;
    }

    @remoteAction
    global static String deleteLineItem(String itemId) {
        String status='';
        if (Schema.sObjectType.QuoteLineItem.isDeletable()) {
            Database.delete(itemId);
        }else {
            status='NO DELETE';
        }
        return status;
    }
    // Taken this out Pricebook2Id =: opp.Pricebook2Id
    public void getProducts() {
        
        if(fam.equalsIgnoreCase('All')) {
            bookEntryList = [Select Id, UnitPrice, Product2Id,Product2.Name,Product2.Description,Product2.SS_URL_Image__c,Product2.Family from PricebookEntry where PriceBook2Id =: theQuote.PriceBook2Id Order By Name];
        }else {
            bookEntryList = [Select Id, UnitPrice,Product2.Name,Product2.Description,Product2.SS_URL_Image__c,Product2.Family from PricebookEntry where Product2.Family =: fam AND PriceBook2Id =: theQuote.PriceBook2Id Order By Name];
        }
    }


    public List<SelectOption> getFamList() {
        List<SelectOption> theFams = new List<SelectOption>();
        Schema.SObjectType sobject_type = Product2.getSObjectType(); 
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Family').getDescribe().getPickListValues(); 
        theFams.add(new SelectOption('All','All'));
        for (Schema.PicklistEntry a : pick_list_values) {
            theFams.add(new SelectOption(a.getValue(),a.getValue()));
        }
        return theFams;
    }
}