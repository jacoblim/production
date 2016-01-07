@isTest
    
private class StorriesTriggerTestClass {
            static testMethod void validateStoriesTrigger() {
                 
                
                // setup before trigger fires
                
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
                
                insert c;
                
                //post trigger
                
                Customer_Stories__c c1 = [SELECT Id, Product_Keywords__c FROM Customer_Stories__c WHERE Id =:c.Id];
                
                System.debug('** Customer Story Id' + c1.Id);
                System.debug('** Customer Story Keywords' + c1.Product_Keywords__c);

                //System.debug('After Trigger'+b.Price__c);
                
                System.assertEquals('FancyProduct', c1.Product_Keywords__c);
            }
        }