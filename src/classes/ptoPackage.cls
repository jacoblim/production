public class ptoPackage {
  
    public class Time_Off_Exception extends Exception {}
    
    private static Map<Id, Set<Date>> holidays = new Map<Id, Set<Date>>(); 
    private static Map<Id, User> requestors = new Map<Id, User>();
    private static Group payroll_queue = null;
    private static Map<String, Id> record_type_ids = new Map<String, Id>();
    private static Map<Id, Time_Off_Info__c> user_time_off_info_map = new Map<Id, Time_Off_Info__c>();
    private static Map<String, Payroll_System__c> payroll_system_map = new Map<String, Payroll_System__c>();
    
    public static final Integer max_records_to_process_for_pay_cycle = 10;
    public static final Integer max_number_of_days_off_in_one_request_default = 50;
    
    public static Set<Date> get_holidays(Id payroll_system_id) {
        Set<Date> result = holidays.get(payroll_system_id);
        if (result == null) {
            result = new Set<Date>();
            for (Holiday_Calendar__c holiday : [select Date__c from Holiday_Calendar__c where (Payroll_System__c = :payroll_system_id) and (IsDeleted = false)]) {
                result.add(holiday.Date__c);
            }
            holidays.put(payroll_system_id, result);
        }
        return result;
    }
    
    public static void clear_holidays_cache() {
        holidays.clear();
    }
    
    public static Payroll_System__c get_payroll_system(String payroll_system_name) {
        Payroll_System__c result = payroll_system_map.get(payroll_system_name);
        if (result == null) {
            Payroll_System__c[] systems = [select Id, Name, Enabled_For_Time_Off_Manager__c, Max_Negative_PTO_Balance__c, Record_Type_Prefix__c from Payroll_System__c where Name = :payroll_system_name];
            if (systems.size() != 1) {
                throw new ptoPackage.Time_Off_Exception('There must be exactly one Payroll System named \'' + payroll_system_name + '\'.');
            }
            payroll_system_map.put(payroll_system_name, systems[0]);
            result = systems[0];
        }
        return result;
    }
    
    public static void clear_payroll_system_cache() {
        payroll_system_map.clear();
    }
    
    public static User get_user_and_manager(Id user_id) {
        Map<Id, User> result = get_user_and_manager(new Id[]{user_id});
        return result.get(user_id);
    }
    
    public static Map<Id, User> get_user_and_manager(Id[] user_ids) {
        Set<Id> user_id_set = new Set<Id>();
        
        for (Integer i = 0; i < user_ids.size(); i++) {
            user_id_set.add(user_ids[i]);
        }
        
        return get_user_and_manager(user_id_set);
    }
    
    public static Map<Id, User> get_user_and_manager(Set<Id> user_ids) {
        Map<Id, User> result = new Map<Id, User>();
        Map<Id, User> uncached_users = new Map<Id, User>();
        
        for (Id id : user_ids) {
            User user = requestors.get(id);
            if (user != null) {
                result.put(id, user);
            } else {
                uncached_users.put(id, null);
            }
        }
        
        if (uncached_users.size() > 0) {
            for (User user : [select Id, Manager_PTO__c, Manager_PTO__r.IsActive, IsActive, Employee_Number__c, FirstName, LastName from User where (Id in :uncached_users.keySet())]) {
                System.assert(uncached_users.containsKey(user.Id));
                result.put(user.Id, user);
                requestors.put(user.Id, user);
                uncached_users.remove(user.Id);
            }
        }
        
        if (uncached_users.size() > 0) {
            String error_message = 'User records could not be found for the following IDs: ';
            for (Id id : uncached_users.keySet()) {
                error_message += id;
                error_message += ' ';
            }
            throw new ptoPackage.Time_Off_Exception(error_message);
        }

        System.assert(result.size() == user_ids.size());
        return result;
    }
    
    public static void clear_user_and_manager_cache() {
        requestors.clear();
    }
    
    public static Group get_payroll_queue() {
        Group result = payroll_queue;
        if (result == null) {
            Group[] payroll_queues = [select Id from Group where (Name = 'Time_Off_Manager_Payroll') and (Type = 'Queue')];
            if (payroll_queues.size() < 1) {
                throw new ptoPackage.Time_Off_Exception('Exactly one Queue named Time_Off_Manager_Payroll must exist, and instead ' + payroll_queues.size() + ' were found.');
            }
            result = payroll_queues[0];
            payroll_queue = result;
        }
        
        System.assert(result != null);
        System.assert(result.Id != null);
        
        return result;
    }
    
    public static void clear_payroll_queue_cache() {
        payroll_queue = null;
    }
    
    public static Id get_record_type_id(String payroll_system_record_type_prefix, String status) {
        String name = payroll_system_record_type_prefix + '-' + status;
        Set<String> names = new Set<String>();
        names.add(name);
        Map<String, Id> record_type_id = get_record_type_ids(names);
        return record_type_id.get(name);
    }
    
    public static Map<String, Id> get_record_type_ids(Set<String> names) {
        Map<String, Id> result = new Map<String, Id>();
        Set<String> names_to_load = new Set<String>();
        for (String name : names) {
            Id id = record_type_ids.get(name);
            if (id == null) {
                names_to_load.add(name);
            } else {
                result.put(name, id);
            }
        }
        
        if (names_to_load.size() > 0) {
            RecordType[] record_types = [select Id, Name from RecordType where (Name in :names_to_load) and (IsActive = true)];
            for (RecordType record_type : record_types) {
                result.put(record_type.Name, record_type.id);
                record_type_ids.put(record_type.Name, record_type.Id);
            }
        }
    
    return result;
    }
    
    public static void clear_record_type_id_cache() {
        record_type_ids.clear();
    }
    
    public static Time_Off_Info__c get_user_time_off_info(Id user_id) {
        Map<Id, Time_Off_Info__c> result = get_user_time_off_info(new Id[]{user_id});
        System.assert(result.get(user_id) != null, 'Cannot locate user in Time Off Info map.');
        return result.get(user_id);
    }

    public static Map<Id, Time_Off_Info__c> get_requestor_time_off_info(Time_Off_Request__c[] tors) {
        Id[] ids = new Id[tors.size()];
        for (Integer i = 0; i < tors.size(); i++) {
            ids[i] = tors[i].Requestor__c;
        }
        Map<Id, Time_Off_Info__c> result = get_user_time_off_info(ids);
        return result;
    }

    public static Map<Id, Time_Off_Info__c> get_user_time_off_info(Id[] user_ids) {
        Set<Id> user_id_set = new Set<Id>();
        
        for (Integer i = 0; i < user_ids.size(); i++) {
            user_id_set.add(user_ids[i]);
        }
        
        return get_user_time_off_info(user_id_set);
    }
    
    public static Time_Off_Info__c build_time_off_info(User user, Double pto_balance, String payroll_system_name) {
        Time_Off_Info__c toi = new Time_Off_Info__c();
        System.assert(user != null, 'User cannot be null.');
        System.assert(user.Id != null, 'User Id cannot be null.');
        
        toi.Total_PTO_Hours_Accrued_2__c = pto_balance;
        toi.User__c = user.Id;
        Payroll_System__c default_payroll_system = get_payroll_system(payroll_system_name);
        System.assert(default_payroll_system != null, 'Default payroll system cannot be null.');
        System.assert(default_payroll_system.Id != null, 'Default payroll system id cannot be null.');
        toi.Payroll_System__c = default_payroll_system.Id;
        
        return toi;
    }
    
    public static Map<Id, Time_Off_Info__c> get_user_time_off_info(Set<Id> user_ids) {
        Map<Id, Time_Off_Info__c> result = new Map<Id, Time_Off_Info__c>();
        Map<Id, Time_Off_Info__c> uncached_tois = new Map<Id, Time_Off_Info__c>();
        
        for (Id id : user_ids) {
            Time_Off_Info__c toi = user_time_off_info_map.get(id);
            if (toi != null) {
                result.put(id, toi);
            } else {
                uncached_tois.put(id, null);
            }
        }
        
        if (uncached_tois.size() > 0) {
            for (Time_Off_Info__c toi : [select Id, User__c, PTO_Balance_Hours__c, Pending_PTO_Balance_Hours__c, Total_PTO_Hours_Accrued_2__c, PTO_Balance_Days__c, Payroll_System__c, Employee_Number__c, Payroll_System__r.Name, Payroll_System__r.Enabled_For_Time_Off_Manager__c, Payroll_System__r.Max_Negative_PTO_Balance__c, Payroll_System__r.Record_Type_Prefix__c, Payroll_System__r.Max_Days_in_a_Single_Request__c, Disable_time_off_requests__c from Time_Off_Info__c where (User__c in :uncached_tois.keySet()) and (IsDeleted = false)]) {
                System.assert(uncached_tois.containsKey(toi.User__c));
                uncached_tois.put(toi.User__c, toi);
            }

            for (Id id : uncached_tois.keySet()) {
                System.assert(user_time_off_info_map.get(id) == null);
                if (uncached_tois.get(id) != null) {
                    user_time_off_info_map.put(id, uncached_tois.get(id));
                    result.put(id, uncached_tois.get(id));
                }
            }
        }



        return result;
    }
    
    public static void remove_user_time_off_info(Id user_id) {
        user_time_off_info_map.remove(user_id);
    }
    
    public static void remove_user_time_off_info(Time_Off_Info__c[] tois) {
        for (Time_Off_Info__c toi : tois) {
            System.assert(toi.User__c != null, 'User is unexpectedly null');
            System.assert(user_time_off_info_map.get(toi.User__c) != null, 'Time Off Info map does not contain the user.');
            user_time_off_info_map.remove(toi.User__c);
        }
    }
    
    public static void remove_user_time_off_info(Id[] user_ids) {
        for (Id id : user_ids) {
            user_time_off_info_map.remove(id);
        }
    }
    
    public static void clear_user_time_off_info() {
        user_time_off_info_map.clear();
    }
    
    public static void set_owner_based_on_status(Time_Off_Request__c tor, User requestor, boolean isInsert) {
        System.assert(requestor != null, 'Requestor cannot be null.');
        System.assert(tor.Requestor__c == requestor.Id, 'Requestor must be equal.');
        System.assert(tor.Status__c != null, 'Status cannot be null.');
        
        if (isInsert || (tor.Status__c == 'Not Submitted') || (tor.Status__c == 'Rejected') || (tor.Status__c == 'Canceled') || (tor.Status__c == 'Requires Re-Approval')) {
            tor.OwnerId = tor.Requestor__c;
        } else if ((tor.Status__c == 'Pending Approval') && (requestor.Manager_PTO__c != null)) {
            tor.OwnerId = requestor.Manager_PTO__c;
        } else {
            Group payroll = get_payroll_queue();
            System.assert(payroll != null, 'Payroll must not be null.');
            tor.OwnerId = payroll.Id;
        }
    }
    
    public static void manage_sharing_based_on_status(Map<Id, Time_Off_Request__c> requests, Map<Id, User> requestors_and_managers, boolean isInsert) {
        Group payroll = get_payroll_queue();

        // Delete any old manual shares 
        if (!isInsert) {
            for (Time_Off_Request__Share[] old_shares : [select Id, ParentId, UserOrGroupId, AccessLevel from Time_Off_Request__Share where (ParentId in :requests.keySet()) and (RowCause = 'Manual')]) {
                delete old_shares;
            }
        }

        Time_Off_Request__Share[] shares = new Time_Off_Request__Share[0];
        for (Id id : requests.keySet()) {
            Time_Off_Request__c tor = requests.get(id);
            System.assert(tor.Id != null);
            System.assert(tor.Requestor__c != null);
            System.assert(tor.Status__c != null);
            User requestor = requestors_and_managers.get(tor.Requestor__c);
            System.assert(requestor != null);
            System.assert(requestor.Id != null);
            System.assert(requestor.Id == tor.Requestor__c);
            System.assert(requestor.IsActive != null);
            System.assert((requestor.Manager_PTO__c == null) || (requestor.Manager_PTO__r.IsActive != null));

            if ((requestor.Manager_PTO__c != null) && requestor.Manager_PTO__r.IsActive && ((tor.Status__c == 'Approved') || (tor.Status__c == 'Processed') || (tor.Status__c == 'Rejected') || (tor.Status__c == 'Requires Re-Approval'))) {
                Time_Off_Request__Share share = new Time_Off_Request__Share(UserOrGroupId = requestor.Manager_PTO__c, ParentId = tor.Id, AccessLevel = 'Read');
                shares.add(share);
            }
                
            if ((requestor.IsActive) && ((tor.Status__c == 'Pending Approval') || (tor.Status__c == 'Approved') || (tor.Status__c == 'Processed'))) {
                String access = 'Read';
                if (tor.Status__c == 'Approved') {
                    access = 'Edit';
                }
                Time_Off_Request__Share share = new Time_Off_Request__Share(UserOrGroupId = requestor.Id, ParentId = tor.Id, AccessLevel = access);
                shares.add(share); 
            }
            
            if (tor.Status__c == 'Requires Re-Approval') {
                Time_Off_Request__Share share = new Time_Off_Request__Share(UserOrGroupId = payroll.Id, ParentId = tor.Id, AccessLevel = 'Edit');
                shares.add(share); 
            }
        }
            
        if (shares.size() > 0) {
            insert shares;
        }
    }
    
    public static Requested_Day__c[] compute_requested_days_for_requests(Time_Off_Request__c tor) {
        Requested_Day__c[] days = new Requested_Day__c[0];
        
        Integer num_hours_per_day = 8;
        if ((tor.Balance_Correction__c != null) && tor.Balance_Correction__c) {
            num_hours_per_day *= -1;
        }
        
        for (Date curr_date = tor.Start_Date__c; curr_date <= tor.End_Date__c; curr_date = curr_date.addDays(1)) {
            System.assert(tor.Payroll_System__c != null);
            if (!get_holidays(tor.Payroll_System__c).contains(curr_date) && !is_weekend(curr_date)) {
                Requested_Day__c day = new Requested_Day__c();
                day.Time_Off_Request__c = tor.Id;
                day.Employee_Number__c = tor.Employee_Number__c;
                day.Requested_Day__c = curr_date;
                day.Hours__c = num_hours_per_day;
                days.add(day);
            }
        }
        
        return days;
    }

    public static Boolean is_weekend(Date d) {
        Date known_saturday = Date.newInstance(1901, 1, 5);
        return Math.mod(known_saturday.daysBetween(d), 7) < 2;
    }
    
    public static Map<Integer,Integer> compute_number_of_days_off(Map<Integer,Time_Off_Request__c> tors, Boolean include_balance_corrections){
    	Map<Integer,Integer> number_of_days_off_map = new Map<Integer,Integer>();
    	Integer result;
    	Map<String,Integer> 	holidays_maps = new Map<String,Integer>();
    	Map<Integer,Id>			payrolls_system_map = new Map<Integer,Id>();
    	Map<Id,Set<Date>>	tor_holidays_map = new Map<Id,Set<Date>>();
    	Set<Date> tor_holidays; 
    	Boolean[] passed_condition= new Boolean[tors.size()];
    	Time_Off_Request__c time_off_request;
    	List<Time_Off_Request__c> time_off_request_list = tors.values();
    	for(Integer i =0; i< time_off_request_list.size(); i++){
    		time_off_request = time_off_request_list.get(i);
    		passed_condition[i] = (time_off_request != null) && (include_balance_corrections || 
    								((time_off_request.Balance_Correction__c == null) ||
    							 	!time_off_request.Balance_Correction__c));
	        if (passed_condition[i]) {
	            System.assert(time_off_request.Start_Date__c != null, 'Start date is null but required');
	            System.assert(time_off_request.End_Date__c != null, 'End date is null but required');
	            System.assert(time_off_request.Payroll_System__c != null, 'Payroll System is null but required');
	            payrolls_system_map.put(i,time_off_request.Payroll_System__c);
	        }else{
	        	number_of_days_off_map.put(i,0);
	        }
	    }
        
        tor_holidays_map = get_holidays_map(payrolls_system_map);
        
        for(Integer i =0; i< time_off_request_list.size(); i++){
        	time_off_request = time_off_request_list.get(i);
        	result = 0;
        	if (passed_condition[i]){
        		tor_holidays = tor_holidays_map.get(time_off_request.Payroll_System__c);
        		for (Date curr_date = time_off_request.Start_Date__c; curr_date <= time_off_request.End_Date__c; curr_date = curr_date.addDays(1)) {
	            	if (!tor_holidays.contains(curr_date) && !is_weekend(curr_date)) {
	                	result += 1;
	            	}
	        	}	
        	}
	        
	        number_of_days_off_map.put(i,result);
        }
            
        return number_of_days_off_map;
    }
    
     public static Map<Id,Set<Date>> get_holidays_map(Map<Integer,Id> payrolls_system_map) {
        Set<Date> holidayDates;
        Map<Id,Set<Date>> holidays_map = new Map<Id,Set<Date>>() ;
        Set<Id> payroll_system_set = new Set<Id>();
        for (Id payroll_system_id : payrolls_system_map.values()){
        	payroll_system_set.add(payroll_system_id);
        	holidays_map.put(payroll_system_id,new Set<Date>());
        }
        for (Holiday_Calendar__c holiday : [select Date__c,Payroll_System__c from Holiday_Calendar__c where (Payroll_System__c in : payroll_system_set) and (IsDeleted = false)]) {
            holidays_map.get(holiday.Payroll_System__c).add(holiday.Date__c);
        }
        for (Id payroll_system_id : holidays_map.keySet()){
        	holidayDates = holidays.get(payroll_system_id);
        	if(holidayDates == null){
        		holidays.put(payroll_system_id,holidayDates);
        	}
        }
        return holidays_map;
    }
    
    public static Time_Off_Info__c adjust_pending_time_off(Map<Id, Time_Off_Info__c> tor_toi_map, Time_Off_Request__c old_request,
    														 Time_Off_Request__c new_request, Boolean isInsert,Integer old_num_pto_days,
    														 Integer new_num_pto_days) {
        Time_Off_Info__c toi = null;
        
        if (isInsert || 
                ((((old_request.Status__c == 'Canceled') || (old_request.Status__c == 'Rejected')) &&
                        (new_request.Status__c != 'Canceled') && (new_request.Status__c != 'Rejected')) ||
                    (((new_request.Status__c == 'Canceled') || (new_request.Status__c == 'Rejected')) &&
                        (old_request.Status__c != 'Canceled') && (old_request.Status__c != 'Rejected')) ||
                    (old_request.Start_Date__c != new_request.Start_Date__c) ||
                    (old_request.End_Date__c != new_request.End_Date__c))) {

            toi = tor_toi_map.get(new_request.Requestor__c);
            if ((toi != null) && (toi.Payroll_System__c != null)) {
                System.assert(toi.Pending_PTO_Balance_Hours__c != null);
                
                Double original_pto_balance = toi.PTO_Balance_Days__c;
                
                if (isInsert) {
                    // If the request is new, then add the PTO balance
                    // from the Request's pending balance
                    toi.Pending_PTO_Balance_Hours__c += (new_num_pto_days * 8);
                } else if ((new_request.Status__c != 'Canceled') && (new_request.Status__c != 'Rejected') && 
                            ((old_request.Status__c == 'Canceled') || (old_request.Status__c == 'Rejected') ||
                            (old_request.Start_Date__c != new_request.Start_Date__c) || 
                            (old_request.End_Date__c != new_request.End_Date__c))) {
                    if ((old_request.Status__c == 'Canceled') || (old_request.Status__c == 'Rejected')) {
                        toi.Pending_PTO_Balance_Hours__c += (new_num_pto_days * 8);
                    } else {
                        toi.Pending_PTO_Balance_Hours__c += ((new_num_pto_days * 8) - (old_num_pto_days * 8));
                    }
                } else if (((new_request.Status__c == 'Canceled') || (new_request.Status__c == 'Rejected')) && 
                                (old_request.Status__c != 'Canceled') && 
                                (old_request.Status__c != 'Rejected')) {
                    // If the request was cancelled or rejected, then the number of days should not have changed
                    
                    System.assert(old_request.Number_of_Days__c == new_request.Number_of_Days__c);
                    
                    // If the request has just become Canceled or Rejected, then remove the PTO balance
                    // from the Request's pending balance
                    toi.Pending_PTO_Balance_Hours__c -= (new_num_pto_days * 8);
                }
                
                // If Request is more than current PTO balance plus the permitted deficit, reject.
                System.assert(toi.Payroll_System__r != null, 'Payroll System is null and shouldn\'t be.');
                System.assert(toi.Payroll_System__r.Max_Negative_PTO_Balance__c != null, 'Payroll System negative balance isn\'t configured.');
                System.assert(toi.Total_PTO_Hours_Accrued_2__c != null, 'Total PTO Hours accrued is null.');
                System.assert(toi.Pending_PTO_Balance_Hours__c != null, 'Pending PTO Balance is null.');
                
                if ((new_num_pto_days > 0) && (toi.Total_PTO_Hours_Accrued_2__c - toi.Pending_PTO_Balance_Hours__c < toi.Payroll_System__r.Max_Negative_PTO_Balance__c)) {
                    new_request.addError('You may not exceed your available PTO Balance (' + original_pto_balance + ' days) by more than ' + Math.round(Math.abs(toi.Payroll_System__r.Max_Negative_PTO_Balance__c / 8)) + ' days.');
                }
            }
        }
        
        return toi;
    }
    
    public static Time_Off_Request__c cancel_request_without_commit(Id request_id) {
        Time_Off_Request__c[] tors  = [select Id, Status__c from Time_Off_Request__c where (Id = :request_id) and (IsDeleted = false)];
        if (tors.size() == 0) {
            throw new Time_Off_Exception('There is no Time Off Request with ID \'' + request_id + '\', so it cannot be canceled.');
        }
        System.assert(tors.size() == 1);
        if ((tors[0].Status__c != 'Approved') && (tors[0].Status__c != 'Rejected') && (tors[0].Status__c != 'Requires Re-Approval')) {
            throw new Time_Off_Exception('A Time Off Request cannot be closed if it is in the ' + tors[0].Status__c + ' state.');
        }
        tors[0].Status__c = 'Canceled';
        update tors;
        return tors[0];
    }
    
    public static Integer process_pay_cycle_without_commit(Id pay_cycle_id) {
        if (pay_cycle_id == null) {
            throw new Time_Off_Exception('process_pay_cycle called with NULL ID.');
        }
        Pay_Cycle__c[] cycles = [select Id, Processed__c, End_Date__c, Payroll_System__c from Pay_Cycle__c where (Id = :pay_cycle_id) and (IsDeleted = false) for update];
        if (cycles.size() == 0) {
            throw new Time_Off_Exception('The pay cycle with ID \'' + pay_cycle_id + '\' does not exist.');
        } 
        if (cycles[0].Processed__c != null) {
            throw new Time_Off_Exception('This Pay Cycle has already been processed, and must be reset before it can be processed again.');
        } 
        System.assert(cycles[0].Id != null);
        System.assert(cycles[0].End_Date__c != null);
        System.assert(cycles[0].Payroll_System__c != null);
        
        Map<Id, Time_Off_Request__c> requests_to_update = new Map<Id, Time_Off_Request__c>();
        Integer record_count = 0;
        Boolean processed_all_records = true;
        for (Requested_Day__c[] days : [select Id, Hours__c, Pay_Cycle__c, Requested_Day__c, Time_Off_Request__r.Status__c, Time_Off_Request__r.Requestor__c from Requested_Day__c where (Pay_Cycle__c = null) and ((Time_Off_Request__r.Status__c = 'Approved') or (Time_Off_Request__r.Status__c = 'Processed')) and (Time_Off_Request__r.Payroll_System__c = :cycles[0].Payroll_System__c) and (Requested_Day__c <= :cycles[0].End_Date__c) and (Do_not_include_in_Pay_Cycle__c = false) and (IsDeleted = false) limit :(max_records_to_process_for_pay_cycle + 1)]) {
            if (days.size() == max_records_to_process_for_pay_cycle + 1) {
                days.remove(max_records_to_process_for_pay_cycle);
                processed_all_records = false;
            }
            record_count += days.size();
            requests_to_update.clear();
            for (Requested_Day__c day : days) {
                System.assert(day.Id != null);
                System.assert(day.Pay_Cycle__c == null);
                System.assert(day.Requested_Day__c <= cycles[0].End_Date__c);
                System.assert(day.Time_Off_Request__r != null);
                System.assert(day.Time_Off_Request__r.Id != null);
                System.assert(day.Time_Off_Request__r.Requestor__c != null);
                System.assert((day.Time_Off_Request__r.Status__c == 'Approved') || (day.Time_Off_Request__r.Status__c == 'Processed'));
                
                day.Pay_Cycle__c = cycles[0].Id;
                if (day.Time_Off_Request__r.Status__c != 'Processed') {
                    day.Time_Off_Request__r.Status__c = 'Processed';
                    requests_to_update.put(day.Time_Off_Request__r.Id, day.Time_Off_Request__r);
                }
            }
            update days;
            update requests_to_update.values();
        }
        
        if (processed_all_records) {
            cycles[0].Processed__c = System.now();
            update cycles;
        }
        
        return record_count;
    }
    
    public static Integer reset_pay_cycle_without_commit(Id pay_cycle_id) {
        if (pay_cycle_id == null) {
            throw new Time_Off_Exception('reset_pay_cycle called with NULL ID.');
        }
        Pay_Cycle__c[] cycles = [select Id, Processed__c from Pay_Cycle__c where (Id = :pay_cycle_id) and (IsDeleted = false) for update];
        if (cycles.size() == 0) {
            throw new Time_Off_Exception('The pay cycle with ID \'' + pay_cycle_id + '\' does not exist.');
        }
        if (cycles[0].Processed__c == null) {
            throw new Time_Off_Exception('This Pay Cycle has not yet been processed, and so it cannot be reset.');
        } 
        System.assert(cycles[0].Id != null);
        Map<Id, Time_Off_Request__c> requests_to_update = new Map<Id, Time_Off_Request__c>();
        Integer record_count = 0;
        Boolean processed_all_records = true;
        for (Requested_Day__c[] days : [select Id, Pay_Cycle__c, Time_Off_Request__r.Status__c from Requested_Day__c where (Pay_Cycle__c = :pay_cycle_id) and (IsDeleted = false) limit :(max_records_to_process_for_pay_cycle + 1)]) {
            if (days.size() == max_records_to_process_for_pay_cycle + 1) {
                days.remove(max_records_to_process_for_pay_cycle);
                processed_all_records = false;
            }
            record_count += days.size();
            requests_to_update.clear();
            for (Requested_Day__c day : days) {
                System.assert(day.Id != null);
                System.assert(day.Pay_Cycle__c == cycles[0].Id);
                System.assert(day.Time_Off_Request__r != null);
                System.assert(day.Time_Off_Request__r.Id != null);
                System.assert(day.Time_Off_Request__r.Status__c != null);
               
                day.Pay_Cycle__c = null;
                
                day.Time_Off_Request__r.Status__c = 'Approved';
                requests_to_update.put(day.Time_Off_Request__r.Id, day.Time_Off_Request__r);
            }
            update days;
            
            // Unfortunately, some of the Time Off Requests that were just moved from Processed to Approved may still
            // have some other Request_Day__c objects that actually have been processed, and so these should not actually
            // be set to Approved.
            for (Time_Off_Request__c tor : [select Id, Status__c, (select Id, Pay_Cycle__c from Time_Off_Request_Payroll_Transactions__r where Pay_Cycle__c != null) from Time_Off_Request__c where (Id in :requests_to_update.keySet()) and (IsDeleted = false)]) {
                if ((tor.Time_Off_Request_Payroll_Transactions__r != null) && (tor.Time_Off_Request_Payroll_Transactions__r.size() > 0)) {
                    requests_to_update.remove(tor.Id);
                }
            }
            
            update requests_to_update.values();
        
        }
        
        if (processed_all_records) {
            cycles[0].Processed__c = null;
            update cycles;
        }
        
        return record_count;
    }

    public static Set<Id> determine_time_off_requests_with_days_to_delete(Boolean isUpdate, Time_Off_Request__c[] old_tors, Time_Off_Request__c[] new_tors) {
        Set<Id> requests_with_days_to_delete = new Set<Id>();
        if (isUpdate) {
            for (Integer i = 0; i < new_tors.size(); i++) {
                if ((old_tors[i].Start_Date__c != new_tors[i].Start_Date__c) || (old_tors[i].End_Date__c != new_tors[i].End_Date__c)) {
                    requests_with_days_to_delete.add(new_tors[i].Id);
                }
            }
        }
        return requests_with_days_to_delete;
    }
}