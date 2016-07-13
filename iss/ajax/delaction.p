/***********************************************************************

    Program:        iss/ajax/delaction.p
    
    Purpose:        Delete action 
    
    Notes:
    
    
    When        Who         What
    22/04/2006  phoski      Initial
    07/05/2015  phoski      Remove esched records ( Complex Projects )
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
         WIDTH              = 60.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ipResetLastActivity) = 0 &THEN

PROCEDURE ipResetLastActivity :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pr-issue      AS ROWID            NO-UNDO.

    DEFINE BUFFER issue        FOR issue.
    DEFINE BUFFER b-query      FOR issAction.
    DEFINE BUFFER IssActivity  FOR IssActivity.

    DEFINE VARIABLE ldt LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE LC  AS CHARACTER FORMAT 'x(20)'.

    DO TRANSACTION:
    
        FIND issue WHERE ROWID(issue) = pr-issue EXCLUSIVE-LOCK.


        ldt = ?.
        LC = "".

        FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode = issue.companyCode
            AND b-query.IssueNumber = issue.IssueNumber
            , EACH IssActivity NO-LOCK
            WHERE issActivity.CompanyCode = b-query.CompanyCode
            AND issActivity.IssueNumber = b-query.IssueNumber
            AND IssActivity.IssActionId = b-query.IssActionID
            AND IssActivity.StartDate <> ?

            BY IssActivity.StartDate DESCENDING
            BY IssActivity.StartTime DESCENDING

            :
            /*
            ldt = DATETIME(IssActivity.StartDate,STRING(IssActivity.StartTime,"HH:MM").
            */

            LC = STRING(IssActivity.StartDate,"99/99/9999") + " " + STRING(IssActivity.StartTime,"HH:MM").
            ldt = DATETIME(LC).

            LEAVE.
        END.
        issue.LastActivity = ldt.


    END.



END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      Notes:       In the event that this Web object is state-aware, this is
                   a good place to set the webState and webTimeout attributes.
    ------------------------------------------------------------------------------*/

    /* To make this a state-aware Web object, pass in the timeout period 
     * (in minutes) before running outputContentType.  If you supply a timeout 
     * period greater than 0, the Web object becomes state-aware and the 
     * following happens:
     *
     *   - 4GL variables webState and webTimeout are set
     *   - a cookie is created for the broker to id the client on the return trip
     *   - a cookie is created to id the correct procedure on the return trip
     *
     * If you supply a timeout period less than 1, the following happens:
     *
     *   - 4GL variables webState and webTimeout are set to an empty string
     *   - a cookie is killed for the broker to id the client on the return trip
     *   - a cookie is killed to id the correct procedure on the return trip
     *
     * Example: Timeout period of 5 minutes for this Web object.
     *
     *   setWebState (5.0).
     */
    
    /* 
     * Output additional cookie information here before running outputContentType.
     *      For more information about the Netscape Cookie Specification, see
     *      http://home.netscape.com/newsref/std/cookie_spec.html  
     *   
     *      Name         - name of the cookie
     *      Value        - value of the cookie
     *      Expires date - Date to expire (optional). See TODAY function.
     *      Expires time - Time to expire (optional). See TIME function.
     *      Path         - Override default URL path (optional)
     *      Domain       - Override default domain (optional)
     *      Secure       - "secure" or unknown (optional)
     * 
     *      The following example sets cust-num=23 and expires tomorrow at (about) the 
     *      same time but only for secure (https) connections.
     *      
     *      RUN SetCookie IN web-utilities-hdl 
     *        ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
     */ 
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
    DEFINE VARIABLE lc-rowid AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-rowid = get-value("actionid").
   
    RUN outputHeader.
    
    FIND issAction WHERE issAction.issActionID = dec(lc-rowid) EXCLUSIVE-LOCK NO-ERROR.
    IF AVAILABLE issAction THEN
    DO:
        FIND Issue 
            WHERE Issue.CompanyCode = issAction.CompanyCode
            AND Issue.IssueNumber = issAction.IssueNumber
            EXCLUSIVE-LOCK.
        FOR EACH IssActivity EXCLUSIVE-LOCK
            WHERE issActivity.CompanyCode = issAction.CompanyCode
            AND issActivity.IssueNumber = issAction.IssueNumber
            AND IssActivity.IssActionId = issAction.IssActionID:

            DELETE IssActivity.
        END.
        FOR EACH eSched EXCLUSIVE-LOCK
            WHERE eSched.IssActionID = IssAction.IssActionID:
            DELETE eSched.
        END.
        DELETE issAction.

        RUN ipResetLastActivity ( ROWID(issue)).
       
    END.
    
END PROCEDURE.


&ENDIF

