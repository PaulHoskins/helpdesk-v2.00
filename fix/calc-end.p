
/*------------------------------------------------------------------------
    File        : calc-end.p
    Purpose     : 

    Syntax      :

    Description : Calc & update end date/time on an activity

    Author(s)   : paul
    Created     : Thu Mar 19 07:30:06 GMT 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

{lib/common.i}


DEFINE BUFFER b-act FOR issActivity.

DEFINE VARIABLE LC AS CHARACTER FORMAT 'x(20)'.
    
OUTPUT TO c:\temp\calc-end.txt PAGED.

FOR EACH b-act EXCLUSIVE-LOCK
/*
    WHERE b-act.CompanyCode = "OURITDEPT"
    AND b-act.issueNumber = 76678
   */
    WITH DOWN STREAM-IO WIDTH 255:
    
    ASSIGN
        b-act.endDate = b-act.StartDate
        b-act.endtime = b-act.StartTime.
        
    IF b-act.Duration = 0 
    OR b-act.StartDate = ? THEN NEXT.
 
    RUN com-EndTimeCalc
        (
        b-act.StartDate,
        b-act.StartTime,
        b-act.Duration,
        OUTPUT b-act.EndDate,
        OUTPUT b-act.EndTime
        ).
        
    DISPLAY 
        b-act.startDate
        STRING(b-act.StartTime,"hh:mm")
        com-TimeToString(b-act.Duration)
        b-act.Duration
        b-act.endDate
        STRING(b-act.EndTime,"hh:mm")
        
        .
                
    
    
        

END.
/**
PROCEDURE com-EndTimeCalc:
    DEFINE INPUT PARAMETER pd-start AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER pi-start AS INT          NO-UNDO.
    DEFINE INPUT PARAMETER pi-duration AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER pd-end  AS DATE         NO-UNDO.
    DEFINE OUTPUT PARAMETER pi-end  AS INTEGER      NO-UNDO.
    
    DEFINE VARIABLE lc-dt   AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE ldt     LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE ldt2    LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE li-hour AS INTEGER              NO-UNDO.
    DEFINE VARIABLE li-min  AS INTEGER              NO-UNDO.
    
    

    ASSIGN
        pd-end = ?
        pi-end = 0.
           
    lc-dt = STRING(pd-Start,"99/99/9999") + " " + STRING(pi-Start,"HH:MM").
    ldt = DATETIME(lc-dt) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN.
    
    ldt2 = ldt + (pi-Duration * 1000 ).         
    
    pd-end = DATE(ldt2).
    lc-dt = TRIM(ENTRY(2,STRING(ldt2)," ")).
    
    ASSIGN 
        li-hour = int(ENTRY(1,lc-dt,":"))
        li-min  = int(ENTRY(2,lc-dt,":")) 
        li-min  = li-min + ( li-hour * 60 )
        pi-end = li-min * 60.
           
        
 
END PROCEDURE.
**/