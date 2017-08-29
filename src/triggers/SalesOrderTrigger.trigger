trigger SalesOrderTrigger on SalesOrder__c (after insert, after update, after delete) {

    SalesOrderTriggerHandler handler = new SalesOrderTriggerHandler();

    if( Trigger.isAfter ){
        // Execute on After Insert
        if( Trigger.isInsert ){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }
        // Execute on After Update
        if( Trigger.isUpdate ){
            handler.OnAfterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
        // Execute on After Delete
        if( Trigger.isDelete ){
            handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        }
    }

}