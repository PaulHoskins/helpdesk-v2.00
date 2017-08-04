/***********************************************************************

    Program:        lib/slaprocess.p
    
    Purpose:        SLA Processing
    
    Notes:
    
    
    When        Who         What
    12/05/2006  phoski      Initial
    04/08/2017  phoski      Customer Non Standard SLA

***********************************************************************/

DEFINE INPUT PARAMETER  pc-companyCode          AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  pc-AccountNumber        AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER  pd-baseDate             AS DATETIME     NO-UNDO.
DEFINE INPUT PARAMETER  pi-minutes              AS INTEGER      NO-UNDO.
DEFINE OUTPUT PARAMETER pd-Amber                AS DATETIME     NO-UNDO.

DEFINE BUFFER Company  FOR Company.
DEFINE BUFFER Customer FOR Customer.


DEFINE VARIABLE li-Balance AS INT       NO-UNDO.
DEFINE VARIABLE ld-Base    AS DATETIME  NO-UNDO.
DEFINE VARIABLE ld-date1   AS DATETIME  NO-UNDO.
DEFINE VARIABLE li-time1   AS INT       NO-UNDO. 
DEFINE VARIABLE LD-LO      AS DATETIME  NO-UNDO.
DEFINE VARIABLE LD-HI      AS DATETIME  NO-UNDO.
DEFINE VARIABLE ld-nowdt   AS DATE      NO-UNDO.
DEFINE VARIABLE lc-temp    AS CHARACTER NO-UNDO.
DEFINE VARIABLE ld-temp    AS DATETIME  NO-UNDO.


FIND Company WHERE Company.CompanyCode = pc-companycode NO-LOCK NO-ERROR.
FIND Customer WHERE customer.CompanyCode = pc-companycode
    AND Customer.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.

ASSIGN 
    li-balance = (  pi-minutes * 60 ) * 1000  /*  Milliseconds */
    ld-Base    = pd-BaseDate.
    
ASSIGN
    ld-date1 = ld-base
    li-time1 = MTIME(ld-base).
    
    
IF Company.SLABeginHour = 0
    OR Company.SLAEndHour = 0 THEN
DO:
    ld-date1 = ld-date1 - li-balance.
    pd-amber = ld-date1.
    RETURN.
END.
    
    
DO WHILE li-balance > 0:
    ASSIGN
        ld-nowdt = DATE(ld-date1)
        lc-temp  = STRING(ld-nowdt,"99/99/9999") + ' ' +
              string(Company.SLABeginHour,'99') + ":" +
              string(Company.SLABeginMin,'99').
    IF Customer.nonStandardSLA
        THEN  lc-temp  = STRING(ld-nowdt,"99/99/9999") + ' ' +
            string(Customer.SLABeginHour,'99') + ":" +
            string(Customer.SLABeginMin,'99').           
              
              
              
    ASSIGN 
        ld-lo = DATETIME(lc-temp).
    ASSIGN 
        ld-temp = ld-date1 - li-balance.
    
    IF ld-temp < ld-lo THEN
    DO:
        ASSIGN
            ld-nowdt = ld-nowdt - 1.
        IF WEEKDAY(ld-nowdt) = 1
            THEN ASSIGN 
                ld-nowdt = ld-nowdt - 2.
        IF WEEKDAY(ld-nowdt) = 7 
            THEN ASSIGN 
                ld-nowdt = ld-nowdt - 1.
        
         
        ASSIGN 
            li-balance = li-balance - ( MTIME(ld-date1) - MTIME(ld-lo)).
              
        lc-temp = STRING(ld-nowdt,"99/99/9999") + ' ' +
            string(Company.SLAEndHour,'99') + ":" +
            string(Company.SLAEndMin,'99').
            
        IF Customer.nonStandardSLA 
            THEN lc-temp  = STRING(ld-nowdt,"99/99/9999") + ' ' +
                string(Customer.SLAEndHour,'99') + ":" +
                string(Customer.SLAEndMin,'99').           
                  
        ASSIGN
            ld-date1 = DATETIME(lc-temp).
        NEXT.      
    END.
         
    ASSIGN
        ld-date1   = ld-temp
        li-balance = 0.              
END.

ASSIGN
    pd-amber = ld-date1.




