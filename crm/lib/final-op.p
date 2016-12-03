/***********************************************************************

    Program:        crm/lib/final-op.p
   
    Purpose:        CRM Last Update on op_master
    
    Notes:
    
    
    When        Who         What
    03/12/2016  phoski      Initial
   
***********************************************************************/

DEFINE INPUT PARAMETER pr-rowid AS ROWID        NO-UNDO.

DEFINE BUFFER op_activity FOR op_Activity.
DEFINE BUFFER op_master   FOR op_master.
DEFINE BUFFER customer    FOR Customer.



FIND op_master WHERE ROWID(op_master) = pr-rowid EXCLUSIVE-LOCK.

FIND Customer OF op_master NO-LOCK NO-ERROR.



ASSIGN
    op_master.cu_name = Customer.Name
    op_master.salesManager = Customer.salesManager
    op_master.last_act = ?.
    
    
FOR EACH op_activity NO-LOCK
    WHERE op_activity.CompanyCode = op_master.CompanyCode
    AND op_activity.op_id = op_master.op_id
    BY op_activity.startDate 
    BY op_activity.startTime:
        
    ASSIGN
        op_master.last_act = DATETIME(
        STRING(op_activity.startDate,'99/99/9999') + ' ' +
        string(op_activity.startTime,"hh:mm:ss")).
                
END.
 
    

 