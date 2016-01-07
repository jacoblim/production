@isTest()
public class TestSS_SalesTeam {

    static testMethod void testTeam() {


        Account acc = new Account(name='Demo Account');
        insert acc;
        acc = [select id, Name from Account where id=: acc.Id];
        System.assertEquals('Demo Account', acc.Name);

        Date toDay = Date.today();

        Opportunity opp = new Opportunity(name='Demo Opp',AccountId=acc.Id,CloseDate = toDay, StageName='Closed Won');
        insert opp;
        opp = [select Name from Opportunity where id =: opp.Id];
        System.assertEquals('Demo Opp', opp.Name);


        ApexPages.StandardController controller = new ApexPages.standardController(opp);

        Test.startTest();

            SS_SalesTeamExt classInstance = new SS_SalesTeamExt(controller);

            classInstance.access = 'Read';
            classInstance.filter ='None';
            classInstance.addMember();
            classInstance.getTheValues();

            // Test for NO DELETE
            String statusA = SS_SalesTeamExt.removeMember('777');
            System.assertEquals('',statusA);
            // Test for NO ACCESS
            String statusB = SS_SalesTeamExt.getPic('Dummy Namexyz');
            System.assertEquals(null,statusB);

            List<SelectOption> options = classInstance.getAccessList();

        Test.stopTest();
        
    }
}