/***********************************************************************

    Program:        batch/scheduleaction.p
    
    Purpose:        Batch program thats run every 5 mins
    
    Notes:
    
    
    When        Who         What
    01/03/2016  phoski      Initial
    17/06/2016  phoski      EmailTimeReport flag on user and total time
                            on the email and send even if no activity
   
***********************************************************************/
{lib/common.i}
{iss/issue.i}

DEFINE VARIABLE li-time         AS INTEGER      NO-UNDO.
DEFINE VARIABLE ld-date         AS DATE         NO-UNDO.
DEFINE VARIABLE ldt-now         AS DATETIME     NO-UNDO.
DEFINE VARIABLE lc-SchedCode    AS CHARACTER    NO-UNDO.
DEFINE VARIABLE li-PreMins      AS INTEGER      NO-UNDO.
DEFINE VARIABLE li-DayNo        AS INTEGER      NO-UNDO.
DEFINE VARIABLE li-idx          AS INTEGER      NO-UNDO.
DEFINE VARIABLE lc-time         AS CHARACTER    NO-UNDO.
DEFINE VARIABLE li-EODTime      AS INTEGER      NO-UNDO.
DEFINE VARIABLE lc-FileName     AS CHARACTER    NO-UNDO.
DEFINE VARIABLE li-tot-seconds  AS INTEGER      NO-UNDO.


{rep/englogtt.i}


DEFINE STREAM rp.


FUNCTION fnTotalTime RETURNS CHARACTER 
    (  ) FORWARD.

FUNCTION HasScheduledBeenDone RETURNS LOGICAL 
    (pd-Date AS DATE,
    pc-loginid AS CHARACTER,
    pc-sheduleCode AS CHARACTER) FORWARD.


FUNCTION MarkScheduledBeenDone RETURNS LOGICAL 
    (pd-Date AS DATE,
    pc-loginid AS CHARACTER,
    pc-sheduleCode AS CHARACTER) FORWARD.



ASSIGN
    li-time = TIME
    ld-date = TODAY
    ldt-now = NOW
    li-preMins = 30
    li-DayNo = WEEKDAY(ld-date).
    

FOR EACH Company NO-LOCK:

    ASSIGN
        lc-global-company = Company.CompanyCode.
    /*
    ***
    *** End of day engineer time email   
    ***
    */
    FOR EACH WebUser NO-LOCK
        WHERE WebUser.CompanyCode = Company.CompanyCode
        AND WebUser.UserClass = "internal"
        AND WebUser.EmailTimeReport = TRUE
        :
        
        ASSIGN
            lc-SchedCode = "EndOfDayLog".
            
        IF DYNAMIC-FUNCTION("HasScheduledBeenDone",ld-date,webuser.loginid,lc-schedCode) THEN NEXT.
        
        FIND WebStdTime
            WHERE WebStdTime.CompanyCode = Company.CompanyCode
            AND WebStdTime.LoginID = webuser.loginid
            AND WebStdTime.StdWkYear = year(ld-date) NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebStdTime THEN NEXT.
            
        IF li-dayno = 1
            THEN li-idx = 7.
        ELSE 
            IF li-dayno = 7
                THEN li-idx = 6.
            ELSE li-idx = li-dayno - 1.
        
        ASSIGN
            lc-Time =  STRING(WebStdTime.StdPMEndTime[li-idx],'9999').
        
        ASSIGN
            li-EODTime = int(substr(lc-time,1,2)) * 60 + int(substr(lc-time,3,2))
            li-EODTime =  li-EODTime * 60.
        
      
        
        IF li-Time < ( li-EODTime - (li-PreMins * 60 )) THEN NEXT.
        
        
        
        EMPTY TEMP-TABLE tt-ilog.

        RUN rep/englogbuild.p (
            Company.CompanyCode,
            WebUser.LoginID,
            WebUser.LoginID,
            WebUser.LoginID,
            TRUE,
            ld-date,
            ld-date,
            REPLACE(lc-global-iclass-code,'|',','),
            OUTPUT TABLE tt-ilog
            ).
        
        /* 
        FIND FIRST tt-ilog NO-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-ilog THEN NEXT.
        */
        
        
        DYNAMIC-FUNCTION("MarkScheduledBeenDone",ld-date,webuser.loginid,lc-schedCode).
             
                    
        RUN ip-ExportReport (OUTPUT lc-filename).
          
         
        mlib-SendAttEmail 
            ( Company.CompanyCode,
            "",
            "End Of Day HelpDesk Engineer Log Report ",
            "Please find attached your report covering the period "
            + string(ld-date,"99/99/9999")
            + ". The time recorded for this period was " + dynamic-function("fnTotalTime")
             ,
            webuser.email,
            "",
            "",
            lc-filename).
        OS-DELETE value(lc-filename).
        
      
              
    END.
    
    /*
    ***
    *** Yesterday Engineer email 
    ***
    */
    
    FOR EACH WebUser NO-LOCK
        WHERE WebUser.CompanyCode = Company.CompanyCode
        AND WebUser.UserClass = "internal"
        AND WebUser.EmailTimeReport = TRUE
        :
        
        ASSIGN
            lc-SchedCode = "PrevEngDayLog".
            
        IF DYNAMIC-FUNCTION("HasScheduledBeenDone",ld-date,webuser.loginid,lc-schedCode) THEN NEXT.

       
        EMPTY TEMP-TABLE tt-ilog.

        RUN rep/englogbuild.p (
            Company.CompanyCode,
            WebUser.LoginID,
            WebUser.LoginID,
            WebUser.LoginID,
            TRUE,
            ld-date - 1,
            ld-date - 1,
            REPLACE(lc-global-iclass-code,'|',','),
            OUTPUT TABLE tt-ilog
            ).
        
        /*
        FIND FIRST tt-ilog NO-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-ilog THEN NEXT.
        */
        
        DYNAMIC-FUNCTION("MarkScheduledBeenDone",ld-date,webuser.loginid,lc-schedCode).
       
        RUN ip-ExportReport (OUTPUT lc-filename).
          
         
        mlib-SendAttEmail 
            ( Company.CompanyCode,
            "",
            "Yesterdays HelpDesk Engineer Log Report ",
            "Please find attached your report covering the period "
            + string(ld-date - 1,"99/99/9999")  
            + ". The time recorded for this period was " + dynamic-function("fnTotalTime") ,
            webuser.email,
            "",
            "",
            lc-filename).
        OS-DELETE value(lc-filename).
        
       
              
    END.
    
END.



/* **********************  Internal Procedures  *********************** */



PROCEDURE ip-ExportReport:

    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-filename AS CHARACTER NO-UNDO.
    

    DEFINE BUFFER customer     FOR customer.
    DEFINE BUFFER issue        FOR issue.
    

    DEFINE VARIABLE lc-GenKey     AS CHARACTER NO-UNDO.

   
    ASSIGN
        lc-genkey = STRING(NEXT-VALUE(ReportNumber)).
    
        
    pc-filename = SESSION:TEMP-DIR + "/EngLog-" + lc-GenKey
        + ".csv".

    OUTPUT STREAM rp TO VALUE(pc-filename).

    PUT STREAM rp UNFORMATTED
                
        '"Engineer","Customer","Issue Number","Description","Issue Type","Raised By","System","SLA Level","' +
        'Date Raised","Time Raised","Date Completed","Time Completed","Activity Duration","SLA Achieved","SLA Comment","' +
        '"Closed By' SKIP.


    FOR EACH tt-ilog NO-LOCK
        BREAK BY tt-ilog.Eng
        BY tt-ilog.IssueNumber
        :
            
        FIND customer WHERE customer.CompanyCode = lc-global-company
            AND customer.AccountNumber = tt-ilog.AccountNumber
            NO-LOCK NO-ERROR.


        EXPORT STREAM rp DELIMITER ','
            ( DYNAMIC-FUNCTION("com-UserName",tt-ilog.eng))
            ( customer.AccountNumber + " " + customer.NAME )
            tt-ilog.issuenumber
            tt-ilog.briefDescription
            tt-ilog.iType
            tt-ilog.RaisedLoginID
            tt-ilog.AreaCode
            tt-ilog.SLALevel
            tt-ilog.CreateDate
            STRING(tt-ilog.CreateTime,"hh:mm")
      
            IF tt-ilog.CompDate = ? THEN "" ELSE STRING(tt-ilog.CompDate,"99/99/9999")

            IF tt-ilog.CompTime = 0 THEN "" ELSE STRING(tt-ilog.CompTime,"hh:mm")
       
            tt-ilog.ActDuration
            tt-ilog.SLAAchieved
            tt-ilog.SLAComment
            tt-ilog.ClosedBy

            . 
           
    END.

    OUTPUT STREAM rp CLOSE.
    

END PROCEDURE.





/* ************************  Function Implementations ***************** */


FUNCTION fnTotalTime RETURNS CHARACTER 
    (  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE lc-time     AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE li-seconds  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-min      AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-hr       AS INTEGER      NO-UNDO.
    	
    FOR EACH tt-ilog NO-LOCK:
        li-seconds = li-seconds + tt-ilog.iseconds.
    END.
 
    IF li-seconds > 0 THEN
    DO:
        li-seconds = ROUND(li-seconds / 60,0).

        li-min = li-seconds MOD 60.

        IF li-seconds - li-min >= 60 THEN
            ASSIGN
                li-hr = ROUND( (li-seconds - li-min) / 60 , 0 ).
        ELSE li-hr = 0.

        ASSIGN
            lc-time = STRING(li-hr) + ":" + STRING(li-min,'99')
            .

    END.
    ELSE lc-time = "0:00".
        
    RETURN lc-time.
	


		
END FUNCTION.

FUNCTION HasScheduledBeenDone RETURNS LOGICAL 
    ( pd-Date AS DATE,
    pc-loginid AS CHARACTER ,
    pc-sheduleCode AS CHARACTER  ):

    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    RETURN CAN-FIND(FIRST schedLog WHERE schedLog.Loginid = pc-loginid AND schedLog.SchedDate = pd-date
        AND schedlog.SchedCode = pc-sheduleCode NO-LOCK).

		
END FUNCTION.


FUNCTION MarkScheduledBeenDone RETURNS LOGICAL 
    ( pd-Date AS DATE,
    pc-loginid AS CHARACTER ,
    pc-sheduleCode AS CHARACTER  ):


    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    CREATE schedLog .
    ASSIGN 
        schedLog.Loginid = pc-loginid 
        schedLog.SchedDate = pd-date
        schedlog.SchedCode = pc-sheduleCode.
         
         
    RETURN TRUE.
    
    
    

		
END FUNCTION.

