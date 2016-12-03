
/***********************************************************************

    Program:        upgrade/upg-2016-12-03.p
   
    Purpose:        Upgrade
    
    Notes:
    
    
    When        Who         What
    03/12/2016  phoski      Initial
   
***********************************************************************/

FOR EACH op_master EXCLUSIVE-LOCK:
    
    RUN crm/lib/final-op.p ( ROWID(op_master)).
    
END.

/* CRM.NextStep -> CRM.Stage*/

 FOR EACH GenTab EXCLUSIVE-LOCK BY GenTab.descr:
     
    
     
     IF GenTab.gType = "CRM.NextStep"
     THEN 
     DO:
       
        GenTab.gType = "CRM.Stage".
      
    END. 
 END.
       
        
        


