
/***********************************************************************

    Program:        upgrade/upg-2017-05-01.p
   
    Purpose:        Upgrade
    
    Notes:
    
    
    When        Who         What
    30/04/2017  phoski      Initial
   
***********************************************************************/


FOR EACH Customer EXCLUSIVE-LOCK:
    
    
    RUN cust/lib/mainsite.p ( ROWID(customer)).
    

        
END.



