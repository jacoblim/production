public class  tom_test_bulk_tors{

    public static testMethod void test_bulk_ops_on_time_off_requests() {
        // Delete any left over requests from previous tests
        pto_tests_common.clean_data('TEST');
        pto_tests_common.create_core_test_objects();

        Map<String, User> test_users = pto_tests_common.get_test_user_ids();
        User user = test_users.get('Subordinate');
        System.assert(user.Id != null);
        System.assert(user.Manager_PTO__c != null);

        // Give the subordinate some vacation time
        pto_tests_common.set_pto_balance(user.Id, 320);
        pto_tests_common.validate_balances(user.Id, 320, 0);
        
        Id[] user_ids = new Id[]{user.Id, user.Id};

        Time_Off_Request__c[] tors = new Time_Off_Request__c[2];
        tors[0] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 2, 16), Date.newInstance(2007, 2, 26), false);
        tors[1] = pto_tests_common.build_unsubmitted_request(user.Id, Date.newInstance(2007, 3, 16), Date.newInstance(2007, 3, 23), false);
        
    }

}