/***********************************************************************

    Program:        rep/clientrepbuild.p
    
    Purpose:        ClientRep - Build Data       
    
    Notes:
    
    
    When        Who         What
    05/08/2017  phoski      Initial  
  
    
***********************************************************************/

{rep/clientreptt.i}


DEFINE INPUT PARAMETER pc-companycode          AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid              AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-AccountNumber        AS CHARACTER         NO-UNDO.

DEFINE INPUT PARAMETER pd-FromDate             AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pd-ToDate               AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pc-ClassList            AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-dtype                AS CHARACTER         NO-UNDO.

DEFINE OUTPUT PARAMETER table              FOR tt-ilog.

{lib/common.i}
{iss/issue.i}


RUN ip-BuildData.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildData) = 0 &THEN

PROCEDURE ip-BuildData :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER issue       FOR issue.
    DEFINE BUFFER IssStatus   FOR IssStatus.
    DEFINE BUFFER IssActivity FOR IssActivity.
    DEFINE BUFFER issnote     FOR issnote.
    DEFINE BUFFER customer    FOR Customer.
    

    
    DEFINE VARIABLE li-seconds AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-min     AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-hr      AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-work    AS INTEGER  NO-UNDO.
    DEFINE VARIABLE ldt-Comp   AS DATETIME NO-UNDO.
    
    DEFINE VARIABLE ldt-st     AS DATETIME NO-UNDO.
    DEFINE VARIABLE ldt-en     AS DATETIME NO-UNDO.
    DEFINE VARIABLE ldt-day    AS DATETIME NO-UNDO.
    
    

    

    /*
    ***
    *** All issues created before the hi date
    ***
    */    
    FOR EACH issue NO-LOCK
        WHERE issue.CompanyCode = pc-companyCode
        AND issue.AccountNumber = pc-AccountNumber
            
        AND CAN-DO(pc-classList,issue.iClass)
        :

        IF pc-dType  = "ISS"
            OR pc-dType = "ISSACT" THEN
        DO:
            IF  issue.IssueDate < pd-fromDate
                OR  issue.IssueDate > pd-ToDate THEN NEXT.

        END.
        
        FIND customer OF Issue NO-LOCK NO-ERROR.
        IF NOT AVAILABLE Customer THEN NEXT.
        
         
        
                        
        CREATE tt-ilog.
        BUFFER-COPY issue TO tt-ilog.

      
        ASSIGN 
            tt-ilog.Period = INTERVAL(pd-ToDate,issueDate,"Months") + 1
            tt-ilog.iType = com-DecodeLookup(Issue.iClass,lc-global-iclass-code,lc-global-iclass-desc).


        ASSIGN
            tt-ilog.isClosed = NOT DYNAMIC-FUNCTION("islib-IssueIsOpen",ROWID(Issue)).

       
        
        IF tt-ilog.SLALevel = ?
            THEN tt-ilog.SLALevel = 0.

        ASSIGN 
            tt-ilog.SLAAchieved = TRUE.


        IF tt-ilog.isClosed THEN
        DO: 
            FIND FIRST IssStatus OF Issue NO-LOCK NO-ERROR.

            IF AVAILABLE issStatus THEN
            DO:
                ASSIGN 
                    tt-ilog.Compdate = issStatus.ChangeDate
                    tt-ilog.CompTime = issStatus.ChangeTime
                    tt-ilog.ClosedBy = DYNAMIC-FUNCTION("com-UserName",issStatus.loginID).
            END.

            FIND FIRST issnote OF issue 
                WHERE issnote.notecode =  'SYS.MISC'
                USE-INDEX IssueNumber
                NO-LOCK NO-ERROR.
            IF AVAILABLE IssNote
                THEN ASSIGN tt-ilog.SLAComment = issnote.CONTENTS.     
                
            IF issue.slaTrip <> ? THEN
            DO:
                ldt-comp = ?.
                IF tt-ilog.Compdate <> ? THEN
                DO:
                    ldt-Comp = DATETIME(
                        STRING(tt-ilog.CompDate,"99/99/9999") + " " + 
                        STRING(tt-ilog.CompTime,"hh:mm")
                        ).
                    ASSIGN
                        tt-ilog.SLAAchieved = ldt-Comp <= issue.SLATrip.


                END.
                
            END.
        END.
        
        FIND slahead WHERE slahead.SLAID = Issue.link-SLAID NO-LOCK NO-ERROR.
        IF AVAILABLE slahead THEN
        DO: 
            
            tt-ilog.SLADesc = slahead.SLACode + "/" + string(tt-ilog.SLALevel).
        END.
        ELSE tt-ilog.SLADesc = "".
        

        ASSIGN 
            tt-ilog.AreaCode      = DYNAMIC-FUNCTION("com-AreaName",pc-companyCode,issue.AreaCode)
            tt-ilog.RaisedLoginID = DYNAMIC-FUNCTION("com-UserName",tt-ilog.RaisedLoginID).
        IF tt-ilog.AreaCode = ""
            THEN tt-ilog.AreaCode = "Not defined".
        

        /*
        ***
        *** Time spent 
        ***
        */
        ASSIGN 
            li-seconds = 0.

        FOR EACH IssActivity OF Issue NO-LOCK
            BY issActivity.StartDate
            BY issActivity.StartTime:

            IF pc-dType = "ACT"
                OR pc-dType = "ISSACT" THEN
            DO:
                IF issActivity.StartDate < pd-fromDate
                    OR issActivity.StartDate > pd-ToDate THEN NEXT.
                           
            END.
            IF tt-ilog.fActDate = ?
                THEN ASSIGN tt-ilog.fActDate = issActivity.StartDate
                    tt-ilog.fActTime = issActivity.StartTime.  

            ASSIGN 
                li-seconds = li-seconds + IssActivity.Duration.

        END.
        IF pc-dType = "ACT" AND tt-ilog.fActDate = ? THEN
        DO:
            DELETE tt-iLog.
            NEXT.
        END.

        li-work = li-seconds.
        ASSIGN
            tt-ilog.iActDuration = li-Seconds.

        IF li-seconds > 0 THEN
        DO:
            li-seconds = ROUND(li-seconds / 60,0).

            li-min = li-seconds MOD 60.

            IF li-seconds - li-min >= 60 THEN
                ASSIGN
                    li-hr = ROUND( (li-seconds - li-min) / 60 , 0 ).
            ELSE li-hr = 0.

            ASSIGN
                tt-ilog.ActDuration = STRING(li-hr) + ":" + STRING(li-min,'99')
                .

        END.
        
        
    END.

  
END PROCEDURE.


&ENDIF

