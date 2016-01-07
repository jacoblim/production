@isTest(SeeAllData=true)
public class TestSS_QuoteList {

    static testMethod void testList() {

        Opportunity opp = new Opportunity(Name='My Opportunity', StageName='Prospecting', CloseDate=Date.today());
        insert opp;
        opp = [select Name from Opportunity where id =: opp.Id];
        System.assertEquals('My Opportunity', opp.Name);

        Pricebook2 pb = [select id from Pricebook2 where isStandard=true limit 1];

        Quote nQuote = new Quote(PriceBook2Id = pb.Id, Name = 'Demo Quote',OpportunityId = opp.Id);
        insert nQuote;
        nQuote = [select Name from Quote where id =: nQuote.Id];
        System.assertEquals('Demo Quote', nQuote.Name);


        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('qId', nQuote.Id);

        ApexPages.StandardController controller = new ApexPages.standardController(opp);

        Test.startTest();

            SS_QuoteListExt classInstance = new SS_QuoteListExt(controller);
            classInstance.createQ();

            // Test for NO UPDATE
            String statusA = SS_QuoteListExt.sync(opp.Id,nQuote.Id);
            System.assertEquals(statusA,'');
            List<SelectOption> selOpt = classInstance.getPriceBooks();

        Test.stopTest();

    }
}