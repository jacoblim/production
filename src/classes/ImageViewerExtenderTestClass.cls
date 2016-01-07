@isTest
    
private class ImageViewerExtenderTestClass {
            static testMethod void validateImageViewerExtender() {
                 
                
                // setup 
                
                Product2 p = new Product2(Name='FancyProduct');
                Account acc = new Account(Name='Arcsoft');
                insert p;
                insert acc;
                System.debug('** Product Id ' + p.Id);
                System.debug('** Account Id ' + acc.Id);
                
                
                System.debug('Product and Account created');
                //Asset a = new Asset(Name='MyAsset',Product2=p,Account=acc.Id);
                //insert a; 
                Asset a = new Asset();
                a.Name = 'My Asset';
                a.Product2Id = p.Id;
                a.AccountId = acc.Id;
                insert a;
                
                System.debug('**Asset Id ' + a.Id);
                
                //System.debug('Book' + b.Name + b.Price__c);
                
                Customer_Stories__c c = new Customer_Stories__c();
                c.Name='MyStory';
                c.Account__c=acc.Id;
                
                //
                insert c;
                
                //create an attachment againste the customer story                                
                
                Customer_Stories__c c1 = [SELECT Id, Product_Keywords__c FROM Customer_Stories__c WHERE Id =:c.Id];
                
                System.debug('** Customer Story Id' + c1.Id);
                System.debug('** Customer Story Keywords' + c1.Product_Keywords__c);

                String bodyStr='Testing File Attachments' + '\n';
                bodyStr+='\n\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n';
             
                bodyStr+='\n\n\n' + 
                System.now(); 

                Attachment att=new Attachment();
                att.Body=Blob.valueOf(bodyStr);
                att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
                att.parentId=c1.id;
                insert att;
                
                // Data setup complete - now to test the page
                
                ApexPages.StandardController sc = new ApexPages.standardController(c);
                ImageViewerExtender e = new ImageViewerExtender(sc);
				
				ID myId = e.getRecID();  
                String test = e.getVideo();
                List<attachment> myList = e.getStoryFiles();
                
                // Check some stuff
                System.assertEquals(1, myList.size());
                //System.assertEquals('firstlast@acme.com', leads[0].email);                
                
                

                

                //System.debug('After Trigger'+b.Price__c);
                
                //System.assertEquals('FancyProduct', c1.Product_Keywords__c);
            }
            
            
        }