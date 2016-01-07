public class tom_test_pay_cycle_mgmt{

    public static testMethod void test_pay_cycle_management() {
        // Delete any left over requests from previous tests
        pto_tests_common.clean_data('TEST');
        pto_tests_common.create_core_test_objects();
        
        // First create two pay cycles. Make them different from the standard US 2 week cycles, just
        // to make sure there's nothing special about "2 weeks" in the code.
        Pay_Cycle__c c1 = pto_tests_common.insert_pay_cycle('TEST 2007-FEB', Date.newInstance(2007, 2, 28), '2007', 'TEST'); 
        Pay_Cycle__c c2 = pto_tests_common.insert_pay_cycle('TEST 2007-MAR', Date.newInstance(2007, 3, 30), '2007', 'TEST');
        
        Map<String, User> test_users = pto_tests_common.get_test_user_ids();

        User subordinate = test_users.get('Subordinate');
        System.assert(subordinate.Id != null);
        System.assert(subordinate.Employee_Number__c != null);

        User subordinate2 = test_users.get('Subordinate2');
        System.assert(subordinate.Id != null);
        System.assert(subordinate.Employee_Number__c != null);

        // Give the subordinates some vacation time
        pto_tests_common.set_pto_balance(subordinate.Id, 200);
        pto_tests_common.validate_balances(subordinate.Id, 200, 0);
        pto_tests_common.set_pto_balance(subordinate2.Id, 200);
        pto_tests_common.validate_balances(subordinate2.Id, 200, 0);

        // Now create 8 requests: 
        //      1) An approved request before both pay cycles
        //      2) An approved request in the first pay cycle
        //      3) An approved request overlapping the two pay ctycles
        //      4) An approved request in the second pay cycle
        //      5) An approved request ending beyond the second pay cycle (but having some days in that cycle)
        //      6) An approved request beyond the second pay cycle
        //      7) A request not yet submitted, in the first pay cycle
        Time_Off_Request__c[] tors = new Time_Off_Request__c[9];
        tors[0] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 1, 31), Date.newInstance(2007, 1, 31), false);      // 1/31/07
        tors[1] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 1), Date.newInstance(2007, 2, 1), false);        // 2/1/07
        tors[2] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 28), Date.newInstance(2007, 3, 1), false);       // 2/28/07, 3/1/07
        tors[3] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 3, 2), Date.newInstance(2007, 3, 2), false);        // 3/2/07
        tors[4] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 3, 30), Date.newInstance(2007, 4, 2), false);       // 3/30/07, 4/2/07
        tors[5] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 4, 3), Date.newInstance(2007, 4, 3), false);        // 4/3/07
        tors[6] = pto_tests_common.build_unsubmitted_request(subordinate.Id, Date.newInstance(2007, 2, 2), Date.newInstance(2007, 2, 2), false);        // 2/2/07
        tors[7] = pto_tests_common.build_unsubmitted_request(subordinate2.Id, Date.newInstance(2007, 2, 28), Date.newInstance(2007, 3, 1), false);      // 2/28/07, 3/1/07
        tors[8] = pto_tests_common.build_unsubmitted_request(subordinate2.Id, Date.newInstance(2007, 2, 28), Date.newInstance(2007, 3, 1), true);       // 2/28/07, 3/1/07

        Id[] owner_ids = new Id[tors.size()];
        for (Integer i = 0; i < owner_ids.size(); i++) {
            owner_ids[i] = subordinate.Id;
        }
        owner_ids[7] = subordinate2.Id;
        owner_ids[8] = subordinate2.Id;
        
        String[] status = new String[tors.size()];
        for (Integer i = 0; i < status.size(); i++) {
            status[i] = 'Approved';
        }
        status[6] = 'Not Submitted';
        
     
    }

}