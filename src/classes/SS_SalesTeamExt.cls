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
global with sharing class SS_SalesTeamExt {

    User loggedInUser = [Select id,contactId,Contact.AccountId from User where id = :UserInfo.getUserId()];
    public Opportunity opp {get; set;}
    public OpportunityTeamMember oppMem {get; set;}
    public String access {get; set;}
    public List<OpportunityTeamMember> oppTeamList {get; set;}

/* LOOKUP */
    public String lookupValue {get;set;}
    public String filter {get;set;}
    public List<Item> myValues {get;set;}

    public class Item
    {
        public String value {get;set;}
        public String label {get;set;}
    
        public Item(String v, String l)
        {
          value = v;
          label = l;
        }
    }

/* END */
    global SS_SalesTeamExt(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        getTeamList();
        oppMem = new OpportunityTeamMember();
    }

    public void getTeamList() {
        oppTeamList = [SELECT OpportunityId,TeamMemberRole,OpportunityAccessLevel, User.SmallPhotoUrl, User.Name from OpportunityTeamMember where OpportunityId =: opp.Id Order By CreatedDate DESC];
    }

    @remoteAction 
    global static String removeMember(String memId) {
        String status='';
        try{
            OpportunityTeamMember tempMem = [select id from OpportunityTeamMember where id =: memId];
            if(Schema.sObjectType.OpportunityTeamMember.isDeletable()) {
                delete(tempMem); 
            }else {
                status='NO DELETE';
            }

        } catch (QueryException e) {}
          catch (DMLException e){}  

        return status;
    }
    @remoteAction
    global static String getPic(String name) {
        try{
            if (Schema.sObjectType.User.fields.SmallPhotoUrl.isAccessible()) {
                User u = [select id, SmallPhotoUrl from User where name =: name limit 1];
                return u.SmallPhotoUrl;
            }else {
                return 'NO ACCESS';
            }
        }
        catch (QueryException e) {}
        return null;
    }

    public void addMember() {

        /* TODO Check if member is already on the team */

        oppMem.OpportunityId = opp.Id;
        
        try{
            if (Schema.sObjectType.OpportunityTeamMember.isCreateable()) {
                insert oppMem;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to insert OpportunityTeamMember'));
            }
        } catch (DMLException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Add Member Error');
            ApexPages.addMessage(myMsg);
        } 

        System.debug('Access Level = '+access);
        /* Now grant Access Level */
        if(access != 'Read') {
            OpportunityShare oS = [select id, OpportunityAccessLevel, RowCause,UserOrGroupId from OpportunityShare where UserOrGroupId =: oppMem.UserId AND RowCause = 'Team'];
            oS.OpportunityAccessLevel = access;
            if(Schema.sObjectType.OpportunityShare.isUpdateable()) {
                update oS;
            }else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to update OpportunityAccessLevel'));
            }
        }
        oppMem = new OpportunityTeamMember();
        getTeamList();
    }
    public List<SelectOption> getAccessList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Read','Read Only'));
        options.add(new SelectOption('Edit','Read/Write'));
        return options;
    }

/* LOOKUP */

    public void getTheValues() {

       Schema.DescribeSObjectResult objDescribe;
        try{
            myValues = new List<Item>();
            filter = escapeReservedCharacters(filter);
            filter  = '%' + filter + '%';

            List<SObject> recList = [Select Id, Name From User where Name Like :filter AND IsActive = true AND UserType = 'Standard'];

            for (SObject rec : recList) {
                myValues.add(new Item((String)rec.get('Id'), (String)rec.get('Name')));
            }
        }catch(exception e){

        }
    } 
  
    private String escapeReservedCharacters(String s) {
        String reservedCharacters = '—&|!{}[]()^~:\\\"\'+-';
        for (Integer i = 0; i < reservedCharacters.length()-1; i++) s = s.replace(reservedCharacters.substring(i,i+1), '\\' + reservedCharacters.substring(i,i+1));
        return s;
    }
}