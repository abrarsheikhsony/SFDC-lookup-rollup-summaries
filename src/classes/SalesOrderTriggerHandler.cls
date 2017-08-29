/*----------------------------------------------------------------------
Name: 		SalesOrderTriggerHandler.cls
Purpose: 	Trigger Handler of SalesOrder__c object
------------------------------History----------------------------------
Version 	Author 		Date 				Detail Description 
-------		-------		-------------- 		------------------
1.0 		Abrar 		25-August-2017		Initial Development	
----------------------------------------------------------------------*/
public with sharing class SalesOrderTriggerHandler{

	// Execute on After Insert
    public void OnAfterInsert(List<SalesOrder__c> newSalesOrders, Map<Id, SalesOrder__c> newSalesOrdersMap){
        RollUpSummaryHelper.calculateRollUpSummary(ApplicationConstant.TRIGGER_CONTEXT.AFTER_INSERT, newSalesOrders, newSalesOrdersMap);
    }

	// Execute on After Update
    public void OnAfterUpdate(List<SalesOrder__c> updatedSalesOrders, List<SalesOrder__c> oldSalesOrders, Map<Id, SalesOrder__c> updatedSalesOrdersMap, Map<Id, SalesOrder__c> oldSalesOrdersMap){
        RollUpSummaryHelper.calculateRollUpSummary(ApplicationConstant.TRIGGER_CONTEXT.AFTER_UPDATE, updatedSalesOrders, oldSalesOrdersMap);
    }

	// Execute on After Delete
    public void OnAfterDelete(List<SalesOrder__c> oldSalesOrders, Map<Id, SalesOrder__c> oldSalesOrdersMap){
        RollUpSummaryHelper.calculateRollUpSummary(ApplicationConstant.TRIGGER_CONTEXT.AFTER_DELETE, oldSalesOrders, oldSalesOrdersMap);
    }

}