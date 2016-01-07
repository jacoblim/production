@isTest(SeeAllData=true)

public class TestSS_QuoteCreator {

    static testMethod void testCreator() {

                
            Pricebook2 pb = [select id from Pricebook2 where isStandard=true limit 1];

            Product2 p2 = new Product2(Name='Test Product',isActive=true);
            insert p2;
            p2 = [SELECT Name FROM Product2 WHERE Id =: p2.Id];
            System.assertEquals('Test Product', p2.Name);


            PricebookEntry pbe = new PricebookEntry(Pricebook2Id=pb.Id, Product2Id=p2.Id, UnitPrice=99, isActive=true);
            insert pbe;
            pbe = [SELECT Name, UnitPrice FROM PricebookEntry WHERE Id =: pbe.Id];
            System.assertEquals(99, pbe.UnitPrice);

            Opportunity opp = new Opportunity(Name='My Opportunity', StageName='Prospecting', CloseDate=Date.today());
            insert opp;
            opp = [select Name from Opportunity where id =: opp.Id];
            System.assertEquals('My Opportunity', opp.Name);


            Quote nQuote = new Quote(PriceBook2Id = pb.Id, Name = 'Demo Quote',OpportunityId = opp.Id);
            insert nQuote;
            nQuote = [select Name from Quote where id =: nQuote.Id];
            System.assertEquals('Demo Quote', nQuote.Name);

            QuoteLineItem oli = new QuoteLineItem(PriceBookEntryId=pbe.Id, QuoteId=nQuote.Id, Quantity=1,UnitPrice=101);
            insert oli;
            oli = [select TotalPrice from QuoteLineItem where id=: oli.Id];
            System.assertEquals(101, oli.TotalPrice);

    
            ApexPages.StandardController controller = new ApexPages.standardController(opp);

            
            // addProduct(String pBeId, Integer quant, String oppId) {

            Test.startTest();

                SS_QuoteCreatorExt classInstance = new SS_QuoteCreatorExt(controller);
                classInstance.theQuote = nQuote;

                List<SelectOption> selOpt = classInstance.getFamList();
                // Call remote methos cannot use an instance as it's static

                // Test for NO UPDATE,NO INSERT
                String statusA = SS_QuoteCreatorExt.addProduct(pBe.Id, 3, nQuote.Id);
                System.assertEquals(statusA,'');
                // Test for NO UPDATE
                String statusB = SS_QuoteCreatorExt.updateLineItem(oli.Id,3,23.0, 1234);
                System.assertEquals(statusB,'');
                // Test for NO DELETE
                String statusC = SS_QuoteCreatorExt.deleteLineItem(oli.Id);
                System.assertEquals(statusC,'');

            Test.stopTest();
    }
}