/***********************************************************************

    Program:        rep/englogbuild.p
    
    Purpose:        Enqineer Log - Build Data       
    
    Notes:
    
    
    When        Who         What
    24/01/2015  phoski      Initial  
    29/03/2015  phoski      Class Code/Desc
    
    
***********************************************************************/

{rep/englogtt.i}


&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-companycode          AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid              AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-FromEng    AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-ToEng      AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pl-allcust              AS LOG               NO-UNDO.
DEFINE INPUT PARAMETER pd-FromDate             AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pd-ToDate               AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pc-ClassList            AS CHARACTER         NO-UNDO.

DEFINE OUTPUT PARAMETER table              FOR tt-ilog.

&ELSE

DEFINE VARIABLE pc-companycode       AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-loginid           AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-FromEng AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-ToEng   AS CHARACTER NO-UNDO.
DEFINE VARIABLE pl-allcust           AS LOGICAL   NO-UNDO.
DEFINE VARIABLE pd-FromDate          AS DATE      NO-UNDO.
DEFINE VARIABLE pd-ToDate            AS DATE      NO-UNDO.



&ENDIF

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
    
    DEFINE BUFFER issue        FOR issue.
    DEFINE BUFFER IssStatus    FOR IssStatus.
    DEFINE BUFFER IssActivity  FOR IssActivity.
    DEFINE BUFFER issnote      FOR issnote.
    DEFINE BUFFER customer     FOR Customer.
    DEFINE BUFFER bAct         FOR issActivity.
    

    
    DEFINE VARIABLE li-seconds  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-min      AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-hr       AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-work     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE ldt-Comp    AS DATETIME NO-UNDO.

  
    /*
    ***
    *** All issues created before the hi date
    ***
    */  
    FOR EACH bAct NO-LOCK
        WHERE bact.CompanyCode = pc-companyCode
          AND bact.ActivityBy >= pc-FromEng
          AND bact.ActivityBy <= pc-ToEng
          AND bact.ActDate >= pd-fromDate
          AND bact.ActDate <= pd-toDate
          ,           
        FIRST issue NO-LOCK
        WHERE issue.CompanyCode = pc-companyCode
        AND Issue.IssueNumber = bAct.issueNumber
        AND CAN-DO(pc-classList,issue.iClass)
        :

        FIND customer OF Issue NO-LOCK NO-ERROR.
        IF NOT AVAILABLE Customer THEN NEXT.
        
        IF pl-allcust = NO
        AND Customer.IsActive = NO THEN NEXT.
                       
        FIND FIRST tt-ilog
            WHERE tt-ilog.eng = bact.ActivityBy
              AND tt-ilog.issueNumber = Issue.IssueNumber
              EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-ilog
        THEN CREATE tt-ilog.
        
        BUFFER-COPY issue TO tt-ilog.
        
       
        ASSIGN  
            tt-ilog.eng = bact.ActivityBy
            tt-ilog.iType = com-DecodeLookup(Issue.iClass,lc-global-iclass-code,lc-global-iclass-desc).


        ASSIGN
            tt-ilog.isClosed =  NOT DYNAMIC-FUNCTION("islib-IssueIsOpen",ROWID(Issue)).

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

        ASSIGN 
            tt-ilog.AreaCode = DYNAMIC-FUNCTION("com-AreaName",pc-companyCode,issue.AreaCode)
            tt-ilog.RaisedLoginID = DYNAMIC-FUNCTION("com-UserName",tt-ilog.RaisedLoginID).


        /*
        ***
        *** Time spent 
        ***
        */
        ASSIGN 
            tt-ilog.iSeconds = tt-ilog.iSeconds + bact.Duration
            
            li-seconds = tt-ilog.iSeconds.
            
        /*
        FOR EACH IssActivity OF Issue NO-LOCK:
   

            ASSIGN 
                li-seconds = li-seconds + IssActivity.Duration.

        END.
        */
        li-work = li-seconds.

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

