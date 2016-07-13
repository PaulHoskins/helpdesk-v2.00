/***********************************************************************

    Program:        lib/translatetemplate.p
    
    Purpose:        Email Template Merge
    
    Notes:
    
    
    When        Who         What
    02/06/2014  phoski      Initial      
***********************************************************************/

DEFINE INPUT PARAMETER pc-companyCode  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER pc-tmpCode      AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER pi-IssueNumber  AS INTEGER      NO-UNDO.

DEFINE INPUT PARAMETER pl-test         AS LOG      NO-UNDO.
DEFINE INPUT PARAMETER pc-TxtIn        AS CHARACTER     NO-UNDO.

DEFINE OUTPUT PARAMETER pc-TxtOut      AS CHARACTER     NO-UNDO.
DEFINE OUTPUT PARAMETER pc-Erc         AS CHARACTER     NO-UNDO.


DEFINE BUFFER issue    FOR issue.
DEFINE BUFFER assigned FOR webuser.
DEFINE BUFFER raised   FOR webuser.
DEFINE BUFFER customer FOR customer.
DEFINE BUFFER istatus  FOR webstatus.
DEFINE BUFFER iArea    FOR WebIssArea.


DEFINE VARIABLE lc-bList AS CHARACTER INITIAL 'issue,assigned,customer,raised,istatus,iArea'
    NO-UNDO.
DEFINE VARIABLE li-b     AS INTEGER   NO-UNDO.
DEFINE VARIABLE hb       AS HANDLE    EXTENT 20 NO-UNDO.
DEFINE VARIABLE lc-TimeL AS CHARACTER INITIAL
    'AssignTime,CompTime,CreateTime,IssueTime'
    NO-UNDO.


DEFINE TEMP-TABLE tt-mf NO-UNDO
    FIELD mf   AS CHARACTER 
    FIELD val  AS CHARACTER
    FIELD isOk AS LOG       INITIAL FALSE
    INDEX mf mf.




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


FIND issue WHERE issue.companyCode = pc-companyCode
    AND issue.issuenumber = pi-IssueNumber NO-LOCK NO-ERROR.

hb[1] = BUFFER issue:HANDLE.

FIND assigned WHERE ASSIGNed.loginid = issue.assignto  NO-LOCK NO-ERROR.
hb[2] = BUFFER assigned:HANDLE.

FIND customer OF issue NO-LOCK NO-ERROR.
hb[3] = BUFFER customer:HANDLE.

FIND raised WHERE raised.loginid = issue.RaisedLogin  NO-LOCK NO-ERROR.
hb[4] = BUFFER raised:HANDLE.


FIND iStatus OF issue NO-LOCK NO-ERROR.
hb[5] = BUFFER iStatus:HANDLE.

FIND iArea OF issue NO-LOCK NO-ERROR.
hb[6] = BUFFER iArea:HANDLE.




RUN ipBuildMergeFields.

RUN ipMergeFields ( pc-TxtIn, OUTPUT pc-TxtOut ).

FIND FIRST tt-mf WHERE tt-mf.isOK = FALSE NO-ERROR.
IF AVAILABLE tt-mf 
    THEN pc-erc = "Not all merge fields completed".



IF pl-test THEN
DO:
    
    pc-TxtOut = '<b>Formatted</b> =~n<i>' + pc-TxtOut + '</i>~n~n<b>Merged Variables</b> = '.
    FOR EACH tt-mf NO-LOCK
        BY tt-mf.isOK BY tt-mf.mf :
        pc-txtOut = pc-txtOut + '~n' + 
            ( IF NOT tt-mf.isOK
            THEN '<span style="color:red;">' ELSE ''
            )
            +
            tt-mf.mf + ' ' + tt-mf.val
            + 
            ( IF NOT tt-mf.isOK
            THEN '</span>' ELSE ''
            )
            .

    END.
END.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ipBuildMergeFields) = 0 &THEN

PROCEDURE ipBuildMergeFields :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE VARIABLE lc-part AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-this AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lh      AS HANDLE    NO-UNDO.
    DEFINE VARIABLE lf      AS HANDLE    NO-UNDO.
    DEFINE VARIABLE lc-val  AS CHARACTER NO-UNDO.

    
    DO li-loop = 1 TO NUM-ENTRIES(pc-TxtIn,"<%") - 1:
        lc-part = ENTRY(li-Loop + 1,pc-TxtIn,"<%").

        lc-this = REPLACE(ENTRY(1,lc-part,">%"),"%",'').

        FIND tt-mf
            WHERE tt-mf.mf = lc-this NO-LOCK NO-ERROR.
        IF AVAILABLE tt-mf THEN NEXT.


        CREATE tt-mf.
        ASSIGN 
            tt-mf.mf = lc-this.


    END.

    DEFINE VARIABLE lc-bname  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-bfield AS CHARACTER NO-UNDO.

    FOR EACH tt-mf EXCLUSIVE-LOCK:
        IF NUM-ENTRIES(tt-mf.mf,".") <> 2 THEN
        DO:
            tt-mf.val = "Invalid format table.field".
            NEXT.
        END.
        ASSIGN
            lc-bname  = ENTRY(1,tt-mf.mf,".")
            lc-bfield = ENTRY(2,tt-mf.mf,".")
            .

        li-b = LOOKUP(lc-bname,lc-blist).

        IF li-b <= 0 THEN
        DO:
            tt-mf.val = "Unknown table " + lc-bname.
            NEXT.
        END.
            
        ASSIGN
            lh = hb[li-b]
            lf = ?.

        IF NOT lh:AVAILABLE THEN
        DO:
            ASSIGN 
                tt-mf.val  = "NOT AVAILABLE"
                tt-mf.isOK = TRUE.
            NEXT.
        END.
        lf = lh:BUFFER-FIELD(lc-bfield) NO-ERROR.
        IF ERROR-STATUS:ERROR OR lf = ? THEN
        DO:
            tt-mf.val = "Unknown table.field " + lc-bname + "." + lc-bfield.
            NEXT.
        END.

        ASSIGN
            lc-val = lf:BUFFER-VALUE NO-ERROR.
        ASSIGN
            tt-mf.val = lc-val.

        CASE lf:DATA-TYPE:
            WHEN "DATE" THEN
                DO:
                    tt-mf.val = STRING( DATE(lc-val),"99/99/9999") NO-ERROR.

                END.
            WHEN "INTEGER" THEN
                DO:         
                    IF LOOKUP(lc-bfield,lc-TimeL) > 0 
                        THEN ASSIGN tt-mf.val = STRING(INT(lc-val),"hh:mm") NO-ERROR.
                END.
            OTHERWISE 
            tt-mf.val = lc-val.
        END CASE.
        IF tt-mf.val = ?
            THEN tt-mf.val = "".

        ASSIGN 
            tt-mf.ISOK = TRUE.


    END.
    

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ipMergeFields) = 0 &THEN

PROCEDURE ipMergeFields :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pcin        AS CHARACTER     NO-UNDO.
    DEFINE OUTPUT PARAMETER pcout       AS CHARACTER     NO-UNDO.


    pcout = pcin.

    FOR EACH tt-mf WHERE tt-mf.isOK NO-LOCK:
        pcout = REPLACE(pcout,"<%" + tt-mf.mf + "%>",tt-mf.val).
        pcout = REPLACE(pcout,"<%" + tt-mf.mf + ">",tt-mf.val).

    END.
END PROCEDURE.


&ENDIF

