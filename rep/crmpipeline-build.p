/***********************************************************************

    Program:        rep/crmpipeline-build.p
    
    Purpose:        CRM Pipeline Report
    
    Notes:
    
    
    When        Who         What
    
    23/12/2016  phoski      Initial
    
***********************************************************************/

{rep/crmpipelinett.i}

DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid       AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pi-Month         AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER pi-Year          AS INTEGER      NO-UNDO.
DEFINE INPUT PARAMETER pc-Rep           AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pc-OpStatus      AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER TABLE FOR tt-pipe.

{lib/common.i}

DEFINE VARIABLE ld-Start AS DATE     EXTENT 12 NO-UNDO.
DEFINE VARIABLE ld-End   AS DATE     EXTENT 12 NO-UNDO.
DEFINE VARIABLE li-loop  AS INTEGER  NO-UNDO.
DEFINE VARIABLE li-month AS INTEGER  NO-UNDO.
DEFINE VARIABLE li-year  AS INTEGER  NO-UNDO.
DEFINE VARIABLE ldt-lo   AS DATETIME NO-UNDO.
DEFINE VARIABLE ldt-hi   AS DATETIME NO-UNDO.




DEFINE TEMP-TABLE tt1 NO-UNDO LIKE op_status.

DEFINE BUFFER op_status    FOR op_status.
DEFINE BUFFER op_master    FOR op_master.
DEFINE BUFFER customer     FOR Customer.
DEFINE BUFFER b1_op_status FOR op_status.
 

ASSIGN
    li-month = pi-month
    li-year  = pi-year.
  
    
DO li-loop = 1 TO 12:
   
    
    ASSIGN
        ld-start[li-loop] = DATE(li-month,1,li-year)
        ld-end[li-loop]   = DYNAMIC-FUNCTION("com-MonthEnd",ld-start[li-loop]).
    
    ASSIGN
        li-month = li-month + 1.
    IF li-month > 12
        THEN ASSIGN li-year  = li-year + 1
            li-month = 1.
    
        
END.

FOR EACH op_master NO-LOCK WHERE op_master.CompanyCode = pc-companyCode,
    FIRST Customer NO-LOCK
    WHERE Customer.CompanyCode = op_master.CompanyCode
    AND  Customer.AccountNumber = op_master.AccountNumber:
    
    
    IF pc-rep <> "ALL" AND pc-rep <> Customer.SalesManager THEN NEXT.
    
    EMPTY TEMP-TABLE tt1.
    FOR EACH op_status NO-LOCK 
        WHERE op_status.CompanyCode = op_master.CompanyCode
        AND op_status.op_id = op_master.op_id
        BREAK BY op_status.ToOpStatus
        BY op_status.ChangeDate:
        /*
        *** The FIRST Open
        */
        IF op_status.ToOpStatus = "OP" THEN
        DO:
            IF FIRST-OF(op_status.ToOpStatus) THEN
            DO:
                CREATE tt1.
                BUFFER-COPY op_status TO tt1.
            END.    
        END.    
        ELSE
        /*
        *** And the LAST of all other Types
        */
        DO:
            IF LAST-OF(op_status.ToOpStatus) THEN
            DO:
                FIND FIRST b1_op_status
                    WHERE b1_op_status.CompanyCode = op_status.CompanyCode
                    AND b1_op_status.op_id = op_status.op_id
                    AND b1_op_status.ChangeDate > op_status.ChangeDate
                    NO-LOCK NO-ERROR.
                IF NOT AVAILABLE b1_op_status THEN
                DO:
                    CREATE tt1.
                    BUFFER-COPY op_status TO tt1.
                
                END.
            END.           
                
        END.  
                
    
    END. 
    
    FIND FIRST tt1 
        WHERE tt1.CompanyCode = op_master.CompanyCode
        AND tt1.op_id = op_master.op_id
        AND lookup(tt1.ToOpStatus,pc-opStatus) > 0
        NO-LOCK NO-ERROR.
           
    IF NOT AVAILABLE tt1 THEN NEXT.
    
    DO li-loop = 1 TO 12:
                      
        ASSIGN
            ldt-lo = DATETIME(ld-start[li-loop])
            ldt-hi = DATETIME(ld-end[li-loop] + 1).
            
        FOR EACH tt1 NO-LOCK
            WHERE tt1.CompanyCode = op_master.CompanyCode
            AND tt1.op_id = op_master.op_id
            AND tt1.ChangeDate >= ldt-lo
            AND tt1.ChangeDate < ldt-hi
            AND lookup(tt1.ToOpStatus,pc-opStatus) > 0:
                
            DEFINE VARIABLE iCount     AS INTEGER NO-UNDO.
            DEFINE VARIABLE lf-gpProf  AS DECIMAL NO-UNDO.
            DEFINE VARIABLE lf-projRev AS DECIMAL NO-UNDO.
            DEFINE VARIABLE lf-projGP  AS DECIMAL NO-UNDO.
            DEFINE VARIABLE lc-key     AS CHAR    NO-UNDO.
            
            ASSIGN
                lf-gpProf  = op_master.Revenue - op_master.CostOfSale
                lf-projRev = ROUND(op_master.Revenue * (op_master.Probability / 100),2)
                lf-projGP  = ROUND(op_master.costofsale * (op_master.Probability / 100),2).  
                
            DO iCount = 1 TO 2:
              
                IF icount = 1 
                THEN  ASSIGN lc-key = "Total".
                    
                ELSE
                DO:
                    IF Customer.SalesManager = ""
                        THEN ASSIGN lc-key = "<None>".
                    ELSE ASSIGN lc-key = DYNAMIC-FUNCTION("com-UserName",Customer.SalesManager).
                               
                END.
               
                FIND tt-pipe WHERE tt-pipe.loginid = lc-key
                    AND tt-pipe.opstatus = tt1.ToOpStatus NO-ERROR.
                IF NOT AVAILABLE tt-pipe THEN
                DO:
                    CREATE tt-pipe.
                    ASSIGN 
                        tt-pipe.loginid  = lc-key
                        tt-pipe.opstatus = tt1.ToOpStatus
                        tt-pipe.opDesc   = com-DecodeLookup(tt1.ToOpStatus,lc-global-opStatus-Code,lc-global-opStatus-Desc ).
                        
                  
                  
                END.    
               
                ASSIGN
                    tt-pipe.oCount[li-loop]  = tt-pipe.oCount[li-loop] + 1
                    tt-pipe.Rev[li-loop]     = tt-pipe.Rev[li-loop] + op_master.Revenue
                    tt-pipe.Cost[li-loop]    = tt-pipe.Cost[li-loop] + op_master.CostOfSale
                    tt-pipe.gpProf[li-loop]  = tt-pipe.gpProf[li-loop] + lf-gpProf
                    tt-pipe.projRev[li-loop] = tt-pipe.projRev[li-loop] + lf-projRev
                    tt-pipe.projGP[li-loop]  = tt-pipe.projGP[li-loop] + lf-projGP
                    .
                    
                    
                 ASSIGN
                    tt-pipe.oCount[13]  = tt-pipe.oCount[13] + 1
                    tt-pipe.Rev[13]     = tt-pipe.Rev[13] + op_master.Revenue
                    tt-pipe.Cost[13]    = tt-pipe.Cost[13] + op_master.CostOfSale
                    tt-pipe.gpProf[13]  = tt-pipe.gpProf[13] + lf-gpProf
                    tt-pipe.projRev[13] = tt-pipe.projRev[13] + lf-projRev
                    tt-pipe.projGP[13]  = tt-pipe.projGP[13] + lf-projGP    
                    .
            END.              
        END.
          
    END.
    
    
END. 

           