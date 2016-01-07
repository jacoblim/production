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

public with sharing class ImageViewerExtender {
    Private ID recID;
    Private Customer_Stories__c myStory;
    Private List<Attachment> myAttachments {get; set;}
    public ImageViewerExtender(ApexPages.StandardController controller) {

        
        if (recID == null ) {
            recID = controller.getID();
        }
        
        this.myStory = [select id, Video_ID__c, Video_Host__c from Customer_Stories__c where id = :recID][0];
    }
    
    public list<Attachment> getStoryFiles() {
     return [SELECT id, ContentType, Name FROM Attachment WHERE ParentId = :recID  ];
    }
    
    
    
    public ID getRecID() {
        return recID;
    }
    
    public string getVideo() {
        if (myStory.Video_ID__c != null) {
            return myStory.Video_ID__c;
        } else {
            return '';
        }
    // string videoID = '';
    // myStory = [Select Video_ID__c from Customer_Stories__c where id = :recID];
    // // videoURL = 'Test: ' + myStory.Video_ID__c ;
  
    // if (myStory != null) {
    //  videoID = myStory.Video_ID__c;      
    // }
  
    // return videoID;
    
    }
    
    public string getVideoHost() {
    
    if (myStory.Video_Host__c != null) {
        return myStory.Video_Host__c;
    } else {
        return '';
    }
    
    //    string vidHost = '';
    //    myStory = [Select Video_Host__c from Customer_Stories__c where id = :recID];
    //    if (myStory != null) {
    //      vidHost = myStory.Video_Host__c;      
    //    }
  
 //      return vidHost;
    
    }

}