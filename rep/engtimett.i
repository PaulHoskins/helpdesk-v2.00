/***********************************************************************

    Program:        rep/engtimett.i
    
    Purpose:        Enqineer Time Management Temp Table
    
    Notes:
    
    
    When        Who         What
    
    04/12/2014  phoski      Initial
           
***********************************************************************/

DEFINE TEMP-TABLE tt-engtime NO-UNDO
    FIELD loginid       LIKE WebUser.LoginID
    FIELD startdate     LIKE issActivity.startdate    
    FIELD StdMins       AS INTEGER
    FIELD AdjTime       AS INTEGER
    FIELD AdjReason     AS CHARACTER
    FIELD AvailTime     AS INTEGER 
    FIELD BillAble      LIKE issActivity.Duration
    FIELD NonBillAble   LIKE issActivity.Duration
    
        
    INDEX pr loginid startdate
    .
    