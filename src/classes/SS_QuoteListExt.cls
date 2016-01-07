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

global with sharing class SS_QuoteListExt {

    public List<Quote> oppQuotes {get; set;}
    public Opportunity opp {get; set;}

    public Quote nQuote {get; set;}
    public String pB {get; set;}

    global SS_QuoteListExt(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        oppQuotes = [select id,Name, isSyncing,GrandTotal,Discount from Quote where OpportunityId =: opp.Id Order By CreatedDate DESC];
        nQuote = new Quote();
        nQuote.OpportunityId = opp.Id;
        nQuote.ExpirationDate = Date.today();
    }
    
    public void createQ() {
        
        nQuote.PriceBook2Id = pB;
        //PageReference ref= new PageReference('/apex/SSEQuoteCreator?id='+opp.Id+'&qId='+nQuote.Id)
  
        try {  
            if (Schema.sObjectType.Quote.isCreateable()) {
                insert nQuote;
            }else {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Insert Quote')); 
            }
            nQuote = new Quote();
            nQuote.OpportunityId = opp.Id;
            nQuote.ExpirationDate = Date.today();
        } catch(System.DMLException e) {  
            ApexPages.addMessages(e);  
        }
    }

    @remoteAction
    global static String sync(String oppId,String qId) {

        String status='';

        Opportunity opp = [select id,SyncedQuoteId from Opportunity where id =: oppId];
        opp.SyncedQuoteId = qId;
        if (Schema.sObjectType.Opportunity.isUpdateable()) {
            update opp;
        }else {
            status='NO UPDATE';
        }
        return status;
    }
    
    public void blah() {
        oppQuotes = [select id,Name, isSyncing,GrandTotal,Discount from Quote where OpportunityId =: opp.Id Order By CreatedDate DESC];
    }
    
    public List<SelectOption> getPriceBooks() {
        List<SelectOption> theFams = new List<SelectOption>();
        List<PriceBook2> pBList = [select name, id from PriceBook2 where isActive = true];
        
        for(PriceBook2 pBTemp : pBList ) {
            theFams.add(new SelectOption(pBTemp.Id,pBTemp.Name));
        }
        
        return theFams;
    }
}