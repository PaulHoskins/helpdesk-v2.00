/***********************************************************************

    Program:        rep/manrepbuild.p
    
    Purpose:        Management Report - Build Data       
    
    Notes:
    
    
    When        Who         What
    10/07/2006  phoski      Initial   
    03/05/2014  phoski      Read activity nolock
***********************************************************************/

{rep/manreptt.i}


&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-companycode      AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pd-Date             AS DATE         NO-UNDO.
DEFINE INPUT PARAMETER pi-Days             AS INTEGER          NO-UNDO.
DEFINE OUTPUT PARAMETER table              FOR tt-mrep.

&ELSE

DEFINE VARIABLE pc-companycode AS CHARACTER NO-UNDO.
DEFINE VARIABLE pd-date        AS DATE      NO-UNDO.
DEFINE VARIABLE pi-days        AS INTEGER   NO-UNDO.

ASSIGN
    pc-companycode = "MICAR"
    pd-date        = TODAY
    pi-days        = 7.

&ENDIF

{iss/issue.i}


DEFINE VARIABLE ld-lo-date      AS DATE     NO-UNDO.
DEFINE VARIABLE ld-hi-date      AS DATE     NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */

ASSIGN
    ld-lo-date = pd-date - pi-days
    ld-hi-date = pd-date.

RUN ip-BuildData.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildData) = 0 &THEN

PROCEDURE ip-BuildData :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE ld-CloseDate        AS DATE     NO-UNDO.

    /*
    ***
    *** All issues created before the hi date
    ***
    */    
    FOR EACH issue NO-LOCK
        WHERE issue.CompanyCode = pc-companyCode
        AND issue.IssueDate <= ld-hi-date
        AND Issue.CatCode   > ""
        :

        IF NOT CAN-FIND(customer OF Issue NO-LOCK) THEN NEXT.
                        
        /*
        ***
        *** If the job is completed then ignore if outside period
        ***
        */
        IF DYNAMIC-FUNCTION("islib-IssueIsOpen",ROWID(Issue)) = FALSE THEN
        DO:
            ASSIGN
                ld-CloseDate = DYNAMIC-FUNCTION("islib-CloseDate",ROWID(Issue)).
            IF ld-CloseDate < ld-lo-Date 
                OR ld-CloseDate = ? THEN NEXT.
            
        END.
        ELSE ld-CloseDate = ?.

        FIND tt-mrep 
            WHERE tt-mrep.AccountNumber = Issue.AccountNumber
            AND tt-mrep.CatCode       = Issue.CatCode
            EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-mrep THEN
        DO:
            CREATE tt-mrep.
            ASSIGN 
                tt-mrep.AccountNumber = Issue.AccountNumber
                tt-mrep.CatCode       = Issue.CatCode.
        END.

        /*
        ***
        *** If the issue was created before the period then bfwd,
        *** otherwise opened in period
        ***
        */
        IF Issue.IssueDate < ld-lo-date 
            THEN ASSIGN tt-mrep.Bfwd = tt-mrep.Bfwd + 1.
        ELSE ASSIGN tt-mrep.OpenPer = tt-mrep.OpenPer + 1.

        /*
        ***
        *** Closed in the period?
        ***
        */
        IF ld-CloseDate <> ? THEN
        DO:
            IF ld-CloseDate <= ld-hi-date
                THEN ASSIGN tt-mrep.ClosePer = tt-mrep.ClosePer + 1.
        END.

        /*
        ***
        *** Time spent in the period
        ***
        */
        FOR EACH IssActivity OF Issue 
            WHERE IssActivity.ActDate >= ld-lo-date
            AND IssActivity.ActDate <= ld-hi-date NO-LOCK:

            ASSIGN 
                tt-mrep.Duration = tt-mrep.Duration + IssActivity.Duration.

        END.

        ASSIGN
            tt-mrep.OutSt = ( tt-mrep.Bfwd + tt-mrep.OpenPer ) - tt-mrep.ClosePer.
                            

    END.
END PROCEDURE.


&ENDIF

