/*----------------------------------------------------------------------
Name: 		RollUpSummaryHelper.cls
Purpose: 	A helper/utility class of Roll Up Summary in Lookup Relationships
------------------------------History----------------------------------
Version 	Author 		Date 				Detail Description 
-------		-------		-------------- 		------------------
1.0 		Abrar 		26-August-2017		Initial Development	
----------------------------------------------------------------------*/
public with sharing class RollUpSummaryHelper{

	/*----------------------------------------------------------------------
	Purpose: 	Build a functionality of Roll Up Summary in Lookup Relationship between 2 objects
	(0) Account and SalesOrder__c has a Lookup Relationship (e.g. an Account can have one "or" many SalesOrder__c records)
	(1) Field on Account object = Total Sales Amount (TotalSalesAmount__c) Currency(16, 2)				
	(2) Field on SalesOrder__c object = Sales Amount (SalesAmount__c) Currency(16, 2)
	(3) Field on SalesOrder__c object = Customer (Customer__c) Lookup(Account)
	(4) Sum SalesAmount__c of all SalesOrder__c records in TotalSalesAmount__c field on Account
	(5) Handle exceptions "or" errors related to Validation Rules on SalesOrder__c and Account.
	(a) Validation Rules on SalesOrder__c object will not be a problem because Roll Up trigger fires on After Insert/Update/Delete context
	(b) Validation Rules on Account need to be handled gracefully to show user friendly error on each record of SalesOrder__c.
	Parameters: list of SalesOrder__c
	Returns:	None
	------------------------------History----------------------------------
	Version 	Author 		Date 				Detail Description 
	-------		-------		-------------- 		------------------
	1.0 		Abrar 		26-August-2017		Initial Development
	----------------------------------------------------------------------*/
	public static void calculateRollUpSummary(ApplicationConstant.TRIGGER_CONTEXT triggerContext, List<SalesOrder__c> lstSalesOrders, Map<Id, SalesOrder__c> mapSalesOrders){
		if( lstSalesOrders.size() > 0 ){
			Set<Id> setCustomerIds = new Set<Id>();
			Map<Id, Account> mapAccountsToUpdate = new Map<Id, Account>();
			List<Account> lstAccountsToUpdate = new List<Account>();
			Map<Id, String> mapAccountIdANDErrors = new Map<Id, String>();
            String errorLogDescription = '';

			for(SalesOrder__c salesOrder : lstSalesOrders){
				// Execute on After Insert and After Delete
				if(
					triggerContext == ApplicationConstant.TRIGGER_CONTEXT.AFTER_INSERT ||
					triggerContext == ApplicationConstant.TRIGGER_CONTEXT.AFTER_DELETE					
				){
					setCustomerIds.add(salesOrder.Customer__c);
				}
				// Execute on After Update
				else if(triggerContext == ApplicationConstant.TRIGGER_CONTEXT.AFTER_UPDATE){
					if( 
						salesOrder.Customer__c <> mapSalesOrders.get(salesOrder.Id).Customer__c ||
						salesOrder.SalesAmount__c <> mapSalesOrders.get(salesOrder.Id).SalesAmount__c 
					){
						if(salesOrder.Customer__c <> null){
							setCustomerIds.add(salesOrder.Customer__c);
						}
						if( mapSalesOrders.get(salesOrder.Id).Customer__c <> null ){
							setCustomerIds.add( mapSalesOrders.get(salesOrder.Id).Customer__c );
						}
					}
				}
			}

			if( setCustomerIds.size() > 0 ){
				List<AggregateResult> lstSalesOrdersAggregateResult = 
				[SELECT Customer__c customer, SUM(SalesAmount__c) totalSalesAmount FROM SalesOrder__c WHERE Customer__c IN :setCustomerIds group by Customer__c];

				for(AggregateResult aggResult : lstSalesOrdersAggregateResult){
					Id customerId = (Id)aggResult.get('customer');
					Decimal sumSalesOrdersSalesAmountByCustomer = (Decimal)aggResult.get('totalSalesAmount');
					Account accountRecord = new Account(Id = customerId, TotalSalesAmount__c = sumSalesOrdersSalesAmountByCustomer);
					mapAccountsToUpdate.put(customerId, accountRecord);
				}

				for(Id customerId : setCustomerIds){
					if(mapAccountsToUpdate.get(customerId) == null){
						Account accountRecord = new Account(Id = customerId, TotalSalesAmount__c = 0);
						mapAccountsToUpdate.put(customerId, accountRecord);
					}
				}

				if( mapAccountsToUpdate <> null && mapAccountsToUpdate.size() > 0 ){
					// Normal DML operation
					// (a) This DML line of code does not handle errors gracefully and user-friendly manner
					// (b) It will throw an exception on each record of SalesOrder__c
					// (c) This operation will roll-back the complete batch (200 records in a batch) if at least one of the record would have an exception
					//update mapAccountsToUpdate.values();
					
					// Database DML operation
					// (a) The below snippet of code will handle all errors gracefully and in a user-friendly manner
					// (b) It will show proper error(s) on each record
					// (c) This will perform Partial DML. Which means it will not fail/roll-back the complete batch (200 records in a batch). It will show errors only on buggy records and rest of the records will be saved successfully.
					lstAccountsToUpdate = mapAccountsToUpdate.values();

                    Database.SaveResult[] lstUpdatedAccounts = Database.update(lstAccountsToUpdate, false);

                    // Process all updated Account records
                    for(Integer i=0; i<lstUpdatedAccounts.size(); i++){
                    	// The result will have both Success and Error records
                        Database.SaveResult result = lstUpdatedAccounts[i];
                        // Get Success record here
                        if(lstUpdatedAccounts.get(i).isSuccess()){
                            System.Debug('>>Success Record Id<<'+lstUpdatedAccounts.get(i).getId());
                        }
                        else{
                        	// Here you will get records which have errors
                        	// A single SalesOrder__c record can have one "or" many errors
                        	errorLogDescription = '';
                            List<Database.Error> lstErrors = result.getErrors();
                            for(Integer j=0; j< lstErrors.size(); j++){        
                                System.Debug('>>Failed Record Id<<'+lstAccountsToUpdate.get(i).Id);
                                System.Debug('>>Error Message<<'+lstErrors.get(j).getMessage());
                                // Show all errors for a record
                                errorLogDescription += lstErrors.get(j).getMessage() + '\n';                              
                            }
							mapAccountIdANDErrors.put( lstAccountsToUpdate.get(i).Id, 'Errors: '+errorLogDescription);
                        }
                    }

                    // Show the errors (from Validation Rules, Apex triggers of Account/Parent record) on each SalesOrder__c/Child record
                    if( mapAccountIdANDErrors <> null && mapSalesOrders <> null ){
						for(SalesOrder__c salesOrder : lstSalesOrders){
							if( mapAccountIdANDErrors.containsKey(salesOrder.Customer__c) ){
								salesOrder.addError( mapAccountIdANDErrors.get(salesOrder.Customer__c) );
							}
						}
                    }
				}
			}
		}
	}

}