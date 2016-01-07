@isTest(SeeAllData=true)
public class TestSS_ProductAdder {


    static testMethod void testAdder() {

        String pricebookid;

        // Using data from Org
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


        OpportunityLineItem oli = new OpportunityLineItem(PriceBookEntryId=pbe.Id, OpportunityId=opp.Id, Quantity=1, TotalPrice=99);
        insert oli;
        oli = [select TotalPrice from OpportunityLineItem where id=: oli.Id];
        System.assertEquals(99, oli.TotalPrice);

        ApexPages.StandardController controller = new ApexPages.standardController(opp);

        
        // addProduct(String pBeId, Integer quant, String oppId) {

        Test.startTest();

            SS_ProductAdderExt classInstance = new SS_ProductAdderExt(controller);

            List<SelectOption> selOpt = classInstance.getFamList();
            // Call remote methos cannot use an instance as it's static

            // Test for NO UPDATE,NO INSERT
            String statusA = SS_ProductAdderExt.addProduct(pbe.Id, 3, opp.Id);
            System.assertEquals(statusA,'');
            // Test for NO UPDATE
            String statusB = SS_ProductAdderExt.updateLineItem(oli.Id,3,23.0, 1234);
            System.assertEquals(statusB,'');
            // Test for NO DELETE
            String statusC = SS_ProductAdderExt.deleteLineItem(oli.Id);
            System.assertEquals(statusC,'');

        Test.stopTest();
   
    }
}