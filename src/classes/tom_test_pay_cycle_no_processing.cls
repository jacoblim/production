public class tom_test_pay_cycle_no_processing {
	
	public static testMethod void tom_test_pay_cycle_no_processing() {
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

		// Give the subordinates some vacation time
		pto_tests_common.set_pto_balance(subordinate.Id, 200);
		pto_tests_common.validate_balances(subordinate.Id, 200, 0);


	}
}