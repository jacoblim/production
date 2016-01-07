trigger time_off_request_delete_trig on Time_Off_Request__c bulk (before delete) {
	
	Map<Integer,Time_Off_Request__c> time_off_request_old_map = new Map<Integer,Time_Off_Request__c>();
	Time_Off_Request__c time_off_request;
	System.assert(System.Trigger.old.size() > 0);
	
	if (System.Trigger.old.size() > 0) {
		Time_Off_Request__c[] tors_to_delete = new Time_Off_Request__c[0];
		for (Integer i=0; i< System.Trigger.old.size(); i++){
			time_off_request = System.Trigger.old[i];
			time_off_request_old_map.put(i,time_off_request);
			// You can only delete Time Off Requests that are in the 'Not Submitted' state.
			if (time_off_request.Status__c != 'Not Submitted') {
				time_off_request.Status__c.addError('You cannot delete a Time Off Request unless its status is \'Not Submitted\'.');
			} else {
				tors_to_delete.add(time_off_request);
			}
		} 
		
		// Remove the PTO balance from the Requestor's pending balance
		if (tors_to_delete.size() > 0) {
			Map<Id, Time_Off_Info__c> tois = ptoPackage.get_requestor_time_off_info(tors_to_delete);
			 
			Map<Integer,Integer> time_off_request_map = ptoPackage.compute_number_of_days_off(time_off_request_old_map,false);
			
			// Get Time Off Balance Info for the user
			for(Integer i =0; i< tors_to_delete.size(); i++){
    			time_off_request = tors_to_delete.get(i);
				Time_Off_Info__c toi = tois.get(time_off_request.Requestor__c);
				System.assert((toi != null) && (toi.Pending_PTO_Balance_Hours__c != null));
				Integer number_of_days_off = time_off_request_map.get(i);
				System.assert(number_of_days_off >= 0);
				toi.Pending_PTO_Balance_Hours__c -= (number_of_days_off * 8);
			}
			update tois.values();
		}
	}
}