/**
* Utility class to create the necessary data to 
* used in the test classes.
*/
public class pto_tests_common {
    
    static Payroll_System__c test_payroll_system = null;
    
    static User u = null;
    
    /**
    * Get the payroll system given its name.
    *
    * @param payroll_system_name 	the payroll's name
    * @return 						a payroll 
    */
    public static Payroll_System__c get_test_payroll_system(String payroll_system_name) {
        if (test_payroll_system == null) {
            Payroll_System__c[] payroll_system = [select Id, Name, Enabled_For_Time_Off_Manager__c, Max_Negative_PTO_Balance__c from Payroll_System__c where Name = :payroll_system_name];
            System.assert((payroll_system.size() == 0) || (payroll_system.size() == 1));
            if (payroll_system.size() == 1) {
                test_payroll_system = payroll_system[0];
            }
        }
        return test_payroll_system;
    }
    
    /**
    * Set null to test_payroll_system variable to null.
    */
    public static void clear_test_payroll_system() {
        test_payroll_system = null; 
    }
    
    /**
    * Given the payroll's name, clean whole the data related to it such as time-off request, pay cycle,
    * holiday calendar and the same payroll.
    *
    * @param payroll_system_name 	the payroll's name
    */
    public static void clean_data(String payroll_system_name) 
    {        
        ptoPackage.clear_user_time_off_info(); 
        ptoPackage.clear_holidays_cache();
        ptoPackage.clear_payroll_system_cache();
        ptoPackage.clear_payroll_queue_cache();
        ptoPackage.clear_record_type_id_cache();
        ptoPackage.clear_user_and_manager_cache();
        
        Payroll_System__c payroll_system = get_test_payroll_system(payroll_system_name);
        if (payroll_system != null) {
            // Sometimes the test payroll system is cleaned up between test runs, but the cache isn't
            // cleared. If that happens, clear the cache.
            if ( [select count() from Payroll_System__c where Name = :payroll_system_name] == 0 ) {
                clear_test_payroll_system();
            } else {
                System.assert( payroll_system.Id != null );
                
                Time_Off_Request__c[] tors = [select Id from Time_Off_Request__c where Payroll_System__c = :payroll_system.Id];
                delete tors;
                
                Pay_Cycle__c[] cycles = [select Id from Pay_Cycle__c where Payroll_System__c = :payroll_system.Id];
                delete cycles;
                
                Time_Off_Info__c[] tois = [select Id, User__c from Time_Off_Info__c where Payroll_System__c = :payroll_system.Id];
                if (tois.size() > 0) {
                    for (Time_Off_Info__c toi : tois) {
                        ptoPackage.remove_user_time_off_info(toi.User__c); 
                    }
                    delete tois;
                }
                
                Holiday_Calendar__c[] test_holidays = [select Id from Holiday_Calendar__c where Payroll_System__c = :payroll_system.Id];
                delete test_holidays;
                
                delete payroll_system;
                clear_test_payroll_system();
            }
        }
    }
    
    /**
    * Create a payroll and holiday calendar.
    */
    public static void create_core_test_objects() 
    {
        System.assert(test_payroll_system == null);
        test_payroll_system = new Payroll_System__c();
        test_payroll_system.Name = 'TEST';
        test_payroll_system.Enabled_For_Time_Off_Manager__c = true;
        test_payroll_system.Record_Type_Prefix__c = 'US';
        test_payroll_system.Max_Negative_PTO_Balance__c = -40;
        test_payroll_system.Max_Days_in_a_Single_Request__c = 40;
        insert test_payroll_system;
        System.assert(test_payroll_system.Id != null);
        
        Holiday_Calendar__c test_holiday = new Holiday_Calendar__c();
        test_holiday.Name = 'Steve\' Day';
        test_holiday.Date__c = Date.newInstance(2007, 2, 20);
        test_holiday.Payroll_System__c = test_payroll_system.Id;
        insert test_holiday;
        System.assert(test_holiday.Id != null);
    }
    
    
    
    /**
    * Create users in the system, deleting whatever time-off request 
    * associated to these users and inserting new ones.
    * 
    * @return 	a users's map with time-off request associated.
    */
    public static Map<String, User> get_test_user_ids() {

	    List<Profile> profId = [Select p.UserLicense.Id, p.UserLicenseId, p.Name, p.Id From Profile p where Name = 'System Administrator']; 
	    List<User> usersAux = new List<User>();
	    usersAux.add( createTestUser( profId[0] ) );
	    usersAux.add( createTestUser( profId[0] ) );
	    usersAux.add( createTestUser( profId[0] ) );
	    insert usersAux;
    
        Map<String, User> result = new Map<String, User>();
        
        User[] users = [select Id, Employee_Number__c, Manager_PTO__c, LastName from User  where isActive = true limit 3];
        if (users.size() != 3) {
            throw new ptoPackage.Time_Off_Exception('There must be at least 3 users in order to test the Time Off Manager application.');
        }

        users[0].FirstName 			= 'Test';
        users[0].LastName 			= 'Manager';
        users[0].Manager_PTO__c 	= null;
        users[0].Employee_Number__c = 'TEST 21';
        users[1].FirstName 			= 'Test';
        users[1].LastName 			= 'Subordinate';
        users[1].Manager_PTO__c 	= users[0].Id;
        users[1].Employee_Number__c = 'TEST 22';
        users[2].FirstName 			= 'Test';
        users[2].LastName 			= 'Subordinate2';
        users[2].Manager_PTO__c 	= users[0].Id;
        users[2].Employee_Number__c = 'TEST 23';
        update users;
        
        Set<Id> user_ids = new Set<Id>();
        for (User user : users) {
            user_ids.add(user.Id);
        }
        System.assert( user_ids.size() == 3 );
        
        Time_Off_Info__c[] old_tois = [select Id from Time_Off_Info__c where User__c in :user_ids];
        if ((old_tois != null) && (old_tois.size() > 0)) {
            delete old_tois;
        }
        
        Time_Off_Info__c[] new_tois = new Time_Off_Info__c[0];
        
        for (User user : users) {
            Time_Off_Info__c new_toi = ptoPackage.build_time_off_info(user, 0, 'TEST');
            new_tois.add(new_toi);
            result.put(user.LastName, user);
            if (user.LastName == 'Manager') {
                System.assert(user.Manager_PTO__c == null);
            } else {
                System.assert(user.Manager_PTO__c != null);
            }
        }
        
        System.runAs(users[0]){
        	createQueue();	
        }
        
        insert new_tois;
        
        return result;
    }

	/**
	* Create a queue including holiday calendar, pay cycle, payroll system, 
	* time-off info and time-off request custom objects.
	*/
	public static void createQueue(){

		Group testQueue = new Group();
		testQueue.Type = 'Queue';
		testQueue.Name = 'Time_Off_Manager_Payroll';
       	upsert testQueue;
       
       	// ### Allow SObjects to be managed by recently created queues ###
       	List<QueueSobject> sobjectsQueueAllowed = new List<QueueSobject>();
       	sobjectsQueueAllowed.add( new QueueSobject( SobjectType = Schema.SObjectType.Holiday_Calendar__c.getName() ,QueueId = testQueue.Id ) );
       	sobjectsQueueAllowed.add( new QueueSobject( SobjectType = Schema.SObjectType.Pay_Cycle__c.getName() ,QueueId = testQueue.Id ) );
       	sobjectsQueueAllowed.add( new QueueSobject( SobjectType = Schema.SObjectType.Payroll_System__c.getName() ,QueueId = testQueue.Id ) );
       	sobjectsQueueAllowed.add( new QueueSobject( SobjectType = Schema.SObjectType.Time_Off_Info__c.getName() ,QueueId = testQueue.Id ) );
       	sobjectsQueueAllowed.add( new QueueSobject( SobjectType = Schema.SObjectType.Time_Off_Request__c.getName() ,QueueId = testQueue.Id ) );
       
       	upsert sobjectsQueueAllowed; 
       
       	System.debug('\n\n\n\n\n\n\n\n\n\n\n\n\n'+ sobjectsQueueAllowed +'\n\n\n\n\n\n\n\n\n\n\n\n\n');	       
	}

    
    /**
    * A random user is useful for testing in order to be 
    * sure that you are able to see data across posts regardless
    * of follow status.
    * 
    * @param profile	the profile associated to the new user.
    * @return 			a new user is created
    */
    public static User createTestUser( Profile profile ) {
        String namePrefix           = createRandomWord();
        User testUser               = new User();
        testUser.Email              = 'test@test.com';
        testUser.Username           = namePrefix+'@testuser.com';
        testUser.LastName           = namePrefix+'test';
        testUser.Alias              = 'thetest';
        testUser.ProfileId          = profile.Id;
        testUser.LanguageLocaleKey  = 'en_US';
        testUser.LocaleSidKey       = 'en_US';
        testUser.TimeZoneSidKey     = 'America/Chicago';
        testUser.EmailEncodingKey   = 'UTF-8';
        testUser.EmployeeNumber     = namePrefix+'-Test';
        testUser.Manager_PTO__c     = null;
        testUser.Employee_Number__c = namePrefix+'-Test';
        testUser.UserRoleId         = null;
        testUser.IsActive           = true;
        return testUser;
    }
    
    /**
    * Random words are required for testing 
    * as you will likely run into any word I can insert
    * during a test class and produce false test results.
    * 
    * @return	a randomized string
    */   
    public static String createRandomWord() {
        
        String ret = 'word' + math.rint(math.random() * 100000);
        
        return ret;
        
    }
    
    
    /**
    * Build a unsubmitted time-off request.
    * 
    * @param	an owner id
    * @param	a start date
    * @param	a end date
    * @param	a balance correction
    * @return	a time-off request with status set to 'Not Submitted'
    */
    public static Time_Off_Request__c build_unsubmitted_request(Id owner_id, Date start_date, Date end_date, Boolean balance_correction) {
        Time_Off_Request__c tor = new Time_Off_Request__c();
        tor.OwnerId = owner_id;
        tor.Start_Date__c = start_date;
        tor.End_Date__c = end_date;
        tor.Balance_Correction__c = balance_correction;
        
        tor.Status__c = 'Not Submitted';
        tor.I_accept_terms__c = true;
        
        return tor;
    }

	/**
    * Build a time-off request.
    * 
    * @param owner_id			an owner id
    * @param status				a status
    * @param start_date			a start date
    * @param end_date			a end date
    * @param balance_correction	a balance correction
    * @return					a time-off request
    */
    public static Time_Off_Request__c insert_request(Id owner_id, String status, Date start_date, Date end_date, Boolean balance_correction) {
        Time_Off_Request__c tor = build_unsubmitted_request(owner_id, start_date, end_date, balance_correction);
        insert_requests(new Time_Off_Request__c[]{tor}, new Id[]{owner_id}, new String[]{status});
        return tor;
    }
    
    /**
    * Insert time-off requests's collection.
    * 
    * @param tors			a time-off requests's collection
    * @param owners_ids		a collection of owners' ids
    * @param status			a collection of status
    */
    public static void insert_requests(Time_Off_Request__c[] tors, Id[] owner_ids, String[] status) {
        System.assert(tors != null);
        System.assert(status != null);
        System.assert(tors.size() > 0);
        System.assert(tors.size() == status.size());
        
        insert tors;
        
        Time_Off_Request__c[] tors_to_update = new Time_Off_Request__c[0];
        for (Integer i = 0; i < tors.size(); i++) {
            if ((status[i] != null) && (status[i] != 'Not Submitted')) {
                tors[i].Status__c = status[i];
                tors_to_update.add(tors[i]);
            }
    
            if (status[i] == null) {
                status[i] = 'Not Submitted';
            }
        }
        
        if (tors_to_update.size() > 0) {
            update tors_to_update;
        }
        
        Id[] ids = new Id[tors.size()];
        for (Integer i = 0; i < tors.size(); i++) {
            ids[i] = tors[i].Id;
        }
        
        validate_time_off_requests_status(ids, owner_ids, status);
    }
    
    /**
    * Update a balance of a time-off 
    */
    public static void set_pto_balance(Id user_id, Double pto_hours) {
        set_pto_balance(new Id[]{user_id}, new Double[]{pto_hours});
    }
    
    /**
    * Updates the balances of time-off info given a collection of users.
    *
    * @param user_ids	a collection of user's ids
    * @param pto_hours	a collection of hours
    */
    public static void set_pto_balance(Id[] user_ids, Double[] pto_hours) {
        System.assert(user_ids != null);
        System.assert(pto_hours != null);
        System.assert(user_ids.size() == pto_hours.size());
         
        Map<Id, Time_Off_Info__c> tois = ptoPackage.get_user_time_off_info(user_ids);
        for (Integer i = 0; i < user_ids.size(); i++) {
            Time_Off_Info__c toi = tois.get(user_ids[i]);
            System.assert(toi != null);
            toi.Total_PTO_Hours_Accrued_2__c = pto_hours[i];
        }
        update tois.values();
        ptoPackage.remove_user_time_off_info(user_ids);
    }
    
    /**
    * Validate a request day.
    *
    * @param day					a request's day
    * @param requested_day			a date of request day
    * @param time_off_request		a time-off request id
    * @param month					a month
    * @param hours					a hours
    * @param employee_number		an employee number
    * @param status					a status
    * @param pay_cycle_processed	a boolean to check if the pay clyce is processed.
    */
    public static void validate_requested_day(Requested_Day__c day, Date requested_day, Id time_off_request, String month, Double hours, 
    											String employee_number, String status, Boolean pay_cycle_processed) {
        System.assert(day.Requested_Day__c == requested_day);
        System.assert(day.Time_Off_Request__c == time_off_request);
        System.assert(day.Month_of_Request__c == month);
        System.assert(day.Hours__c == hours);
        //XXX
        System.assert(day.Employee_Number__c == employee_number);
        System.assert(day.Time_Off_Request__r.Status__c == status);
        if (pay_cycle_processed) {
            System.assert(day.Pay_Cycle__r.Processed__c != null);
        } else {
            System.assert(day.Pay_Cycle__r.Processed__c == null);
        }
    }
    
    /**
    * Validate the balance's fields.
    *
    * @param user_id					an id respect to a time-off info 
    * @param pto_hours_from_payroll		the hours of the payroll 	
    * @param pending_pto_hours			the hours substracting to hours of the payroll
    */
    public static void validate_balances(Id user_id, Double pto_hours_from_payroll, Double pending_pto_hours) {
        ptoPackage.remove_user_time_off_info(user_id);
        Time_Off_Info__c toi = ptoPackage.get_user_time_off_info(user_id);
        System.assert(toi.Pending_PTO_Balance_Hours__c == pending_pto_hours);
        System.assert(toi.Total_PTO_Hours_Accrued_2__c == pto_hours_from_payroll);
        System.assert(toi.PTO_Balance_Days__c == toi.PTO_Balance_Hours__c / 8);
        Double auxtest= pto_hours_from_payroll - pending_pto_hours;
        System.assert(toi.PTO_Balance_Hours__c == pto_hours_from_payroll - pending_pto_hours);
    }
    
    /**
    * Check if the time-off request share's collection contains an user or group id with a specific access level.
    *
    * @param shares				a collection of time-off request share
    * @param user_or_group_id	an id identifying an user or group
    * @param access_level		an access level
    */
    private static Boolean shares_contain_user_or_group(Time_Off_Request__Share[] shares, Id user_or_group_id, String access_level) {
        Boolean result = false;
        
        for (Time_Off_Request__Share share : shares) {
            if ((share.UserOrGroupId == user_or_group_id) && (share.AccessLevel == access_level)) {
                result = true;
                break;
            }
        }
        
        return result;
    }

    /**
    * Validate the time-off request's status.
    *
    * @param tor_id					an id respect to a time-off request 
    * @param expected_requestor		an id expected_requestor 	
    * @param expected_status		an time-off request's status
    * @return						an time_off request with a validated status.
    */
    public static Time_Off_Request__c validate_time_off_request_status(Id tor_id, Id expected_requestor, String expected_status) {
        Time_Off_Request__c[] tors = validate_time_off_requests_status(new Id[]{tor_id}, new Id[]{expected_requestor}, new String[]{expected_status});
        System.assert(tors.size() == 1);
        return tors[0];
    }
    
    /**
    * Validate the time-off request's status.
    *
    * @param tor_ids				a collection of time-off request id 
    * @param expected_requestor		a collection of expected requestor 	
    * @param expected_status		a collection of time-off request's status
    * @return						a collection of time_off request with a validated status.
    */
    public static Time_Off_Request__c[] validate_time_off_requests_status(Id[] tor_ids, Id[] expected_requestor, String[] expected_status) {
        System.assert(tor_ids != null);
        System.assert(expected_requestor != null);
        System.assert(expected_status != null);
        System.assert(tor_ids.size() == expected_requestor.size());
        System.assert(tor_ids.size() == expected_status.size());
        
        for (Integer i = 0; i < tor_ids.size(); i++) {
            System.assert(tor_ids[i] != null);
            System.assert(expected_requestor[i] != null);
            System.assert(expected_status[i] != null);
        }
        
        Time_Off_Request__c[] tors = [select Id, OwnerId, Status__c, RecordTypeId, Requestor__c, Pending_Approval__c from Time_Off_Request__c where Id in :tor_ids];
        System.assert(tors != null);
        System.assert(tors.size() == tor_ids.size());
        
        // Load in all the shares to the Time Off Requests, and then map then from the Time Off Request ID
        Map<Id, List<Time_Off_Request__Share>> tor_share_map = new Map<Id, List<Time_Off_Request__Share>>();
        for (Time_Off_Request__Share share : [select UserOrGroupId, AccessLevel, ParentId from Time_Off_Request__Share where (RowCause = 'Manual') and (ParentId in :tor_ids)]) {
            System.assert(share.ParentId != null);
            if (tor_share_map.containsKey(share.ParentId)) {
                List<Time_Off_Request__Share> shares = tor_share_map.get(share.ParentId);
                shares.add(share);
            } else {
                List<Time_Off_Request__Share> shares = new List<Time_Off_Request__Share>();
                shares.add(share);
                tor_share_map.put(share.ParentId, shares);
            }
        }
        
        for (Integer i = 0; i < tors.size(); i++) {
            // Validate the Status__c
            System.assert(tors[i].Status__c != null);
            System.assert(tors[i].Status__c == expected_status[i]);
            System.assert(tors[i].Pending_Approval__c == (tors[i].Status__c == 'Pending Approval'));
            
            // Validate the Requestor__c
            System.assert(tors[i].Requestor__c != null);
            System.assert(tors[i].Requestor__c == expected_requestor[i]);
            
            User requestor = ptoPackage.get_user_and_manager(tors[i].Requestor__c);
            System.assert(requestor != null);
            System.assert(requestor.Id != null);
            
            Time_Off_Info__c toi = ptoPackage.get_user_time_off_info(requestor.Id);
            System.assert(toi.Payroll_System__c != null);
            System.assert(toi.Payroll_System__r.Enabled_For_Time_Off_Manager__c == true);
            System.assert(toi.Payroll_System__r.Max_Negative_PTO_Balance__c == -40);
            System.assert(toi.Payroll_System__r.Name == 'TEST');
            System.assert(toi.Payroll_System__r.Record_Type_Prefix__c == 'US');
            
            // Make sure the record type is set
            System.assert(tors[i].RecordTypeId != null);
            
            // Validate ownership, sharing, and record type
            Group payroll_queue = ptoPackage.get_payroll_queue(); 
            System.assert(payroll_queue != null);
            System.assert(payroll_queue.Id != null);
            
            System.assert(tors[i].OwnerId != null);
            if (tors[i].Status__c == 'Not Submitted') {
                System.assert(tors[i].OwnerId == requestor.Id);
                System.assert(!tor_share_map.containsKey(tors[i].Id)); 
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Not Submitted'));
            } else if (tors[i].Status__c == 'Pending Approval') {
                if (requestor.Manager_PTO__c != null) {
                    System.assert(tors[i].OwnerId == requestor.Manager_PTO__c);
                } else {
                    System.assert(tors[i].OwnerId == payroll_queue.Id);
                }
                System.assert(tor_share_map.get(tors[i].Id).size() == 1);
                System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Id, 'Read'));
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Pending Approval'));
            } else if (tors[i].Status__c == 'Approved') {
                System.assert(tors[i].OwnerId == payroll_queue.Id);
                if (requestor.Manager_PTO__c != null) {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 2);
                    System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Manager_PTO__c, 'Read'));
                } else {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 1);
                }
                System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Id, 'Edit'));
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Approved'));
            } else if (tors[i].Status__c == 'Processed') {
                System.assert(tors[i].OwnerId == payroll_queue.Id);
                if (requestor.Manager_PTO__c != null) {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 2);
                    System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Manager_PTO__c, 'Read'));
                } else {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 1);
                }
                System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Id, 'Read'));
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Processed'));
            } else if (tors[i].Status__c == 'Rejected') {
                System.assert(tors[i].OwnerId == requestor.Id);
                if (requestor.Manager_PTO__c != null) {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 1);
                    System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Manager_PTO__c, 'Read'));
                } else {
                    System.assert(!tor_share_map.containsKey(tors[i].Id));
                }
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Rejected'));
            } else if (tors[i].Status__c == 'Canceled') {
                System.assert(tors[i].OwnerId == requestor.Id);
                System.assert(!tor_share_map.containsKey(tors[i].Id));
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Canceled'));
            } else {
                System.assert(tors[i].Status__c == 'Requires Re-Approval');
                System.assert(tors[i].OwnerId == requestor.Id);
                if (requestor.Manager_PTO__c != null) {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 2);
                    System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), requestor.Manager_PTO__c, 'Read'));
                } else {
                    System.assert(tor_share_map.get(tors[i].Id).size() == 1);
                }
                System.assert(shares_contain_user_or_group(tor_share_map.get(tors[i].Id), payroll_queue.Id, 'Edit'));
                System.assert(tors[i].RecordTypeId == ptoPackage.get_record_type_id('US', 'Requires Re-Approval'));
            }
        }
        return tors;
    }
	
	/**
	* Inserts a pay cycle.
	*
	* @param name					a pay cycle's name
	* @param end_date				an pay cycle's end date
	* @param year					a pay cycle's year
	* @param payroll_system_name	a payroll system for pay cycle.
	* @return 						a pay cycle with fields mentioned above.
	*/
    public static Pay_Cycle__c insert_pay_cycle(String name, Date end_date, String year, String payroll_system_name) {
        Pay_Cycle__c c1 = new Pay_Cycle__c();
        c1.Name = name;
        c1.End_Date__c = end_date;
        Payroll_System__c payroll_system = get_test_payroll_system(payroll_system_name);
        System.assert(payroll_system != null);
        System.assert(payroll_system.Id != null);
        c1.Payroll_System__c = payroll_system.Id;
        insert c1;
        
        return c1;
    }
    
}