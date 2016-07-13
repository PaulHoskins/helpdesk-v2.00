/***********************************************************************

    Program:        iss/ajax/ganttupd.p
    
    Purpose:        Issue Update/Build Gantt    
    
    Notes:
    
    
    When        Who         What
    16/04/2015  phoski      Initial
    

***********************************************************************/
CREATE WIDGET-POOL.


DEFINE VARIABLE lc-rowid    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-mode     AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-parent   AS INT64     NO-UNDO.
DEFINE VARIABLE lc-text     AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-duration AS INTEGER   NO-UNDO.
DEFINE VARIABLE ld-start    AS DATE      NO-UNDO.
DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-field    AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-Count    AS INTEGER   EXTENT 2 NO-UNDO.
DEFINE VARIABLE li-This     AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-string   AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-PhaseID  AS INT64     NO-UNDO.
DEFINE VARIABLE li-TaskID   AS INT64     NO-UNDO.
DEFINE VARIABLE li-GoTo     AS INT64     NO-UNDO.
DEFINE VARIABLE lc-msg      AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-h        AS INTEGER NO-UNDO.
    
DEFINE BUFFER b-table FOR issue.





/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{iss/issue.i}
{lib/ticket.i}
{lib/project.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      objtargets:       In the event that this Web object is state-aware, this is
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
  objtargets:       
------------------------------------------------------------------------------*/
    
    {lib/checkloggedin.i} 

    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER issActivity FOR issActivity.
    DEFINE BUFFER IssAction FOR IssAction.
    
  
   
    ASSIGN
        lc-rowid = get-value("rowid")
        lc-mode = get-value("mode")
        li-parent = int(get-value("parent"))
        lc-text   = get-value("text")
        li-duration = int(get-value("duration")) /* In days */
                
        .
    IF  get-value("start_date") <> "" 
    THEN ASSIGN ld-start = DYNAMIC-FUNCTION("com-ConvertJSDate",get-value("start_date")).
    
    
    FIND b-table WHERE ROWID(b-table) = to-rowid(lc-rowid) NO-LOCK.
    
    IF lc-mode <> "BUILD" THEN
    DO:
        IF lc-mode = "ADD" THEN
        DO:
            /* 
            ***
            *** New Phase 
            ***
            */
            IF li-parent = 0 THEN
            DO:
                RUN prjlib-AddNewPhase 
                    (
                    lc-global-user,
                    b-table.companyCode,
                    b-table.IssueNumber,
                    lc-text,
                    OUTPUT li-phaseid
                    ).
                ASSIGN li-goto = li-phaseid.
            
            
            END.
            ELSE
            /*
            ***
            *** It's got a parent link, so:-
            *** if parent is a phase then add FIRST task (displayOrder = 1) and ripple all others down
            *** if its a task then add as next and ripple all existings others down 
            *** 
            */
            DO:
                FIND issPhase
                    WHERE IssPhase.CompanyCode = b-table.companyCode
                    AND IssPhase.IssueNumber = b-table.IssueNumber 
                    AND issPhase.PhaseID = li-parent NO-LOCK NO-ERROR.
                IF AVAILABLE issPhase THEN
                DO:
                    RUN  prjlib-AddNewTask
                        (
                        lc-global-user,
                        b-table.companyCode,
                        b-table.IssueNumber,
                        li-parent,
                        1,
                        lc-text,
                        ld-start,
                        li-duration,
                        OUTPUT li-taskid
                        ).
            
                    ASSIGN li-goto = li-taskid.
                
                END. 
                ELSE
                DO:
                    FIND FIRST IssAction
                        WHERE issAction.CompanyCode = b-table.companyCode
                        AND IssAction.IssueNumber = b-table.IssueNumber
                        AND IssAction.TaskID = li-parent 
                        NO-LOCK NO-ERROR. 
                
                    IF NOT AVAILABLE IssAction THEN
                    DO:
                        lc-msg = "missing action "  + string(li-parent).
                    END.
                    ELSE
                    DO:  
                        RUN  prjlib-AddNewTask
                            (
                            lc-global-user,
                            b-table.companyCode,
                            b-table.IssueNumber,
                            IssAction.phaseID,
                            IssAction.DisplayOrder + 1,
                            lc-text,
                            ld-start,
                            li-duration,
                            OUTPUT li-taskid
                            ).
                        ASSIGN li-goto = li-taskid.
                    END.
                
                
                
                END.               
            END.
        END. /* ADD mode */
        ELSE
            IF lc-mode = "DELETE" THEN
            DO:
            
                ASSIGN 
                    li-taskid = int(get-value("id")).
            
                FIND FIRST IssAction
                    WHERE issAction.CompanyCode = b-table.companyCode
                    AND IssAction.IssueNumber = b-table.IssueNumber
                    AND IssAction.TaskID = li-taskid NO-LOCK NO-ERROR.
                         
                IF NOT AVAILABLE IssAction THEN 
                DO:
                    ASSIGN 
                        lc-msg = "Missing Action Record " + string(li-taskid).
                END.
                ELSE
                IF CAN-FIND( FIRST IssActivity NO-LOCK
                    WHERE issActivity.CompanyCode = b-table.CompanyCode
                    AND issActivity.IssueNumber = b-table.IssueNumber
                    AND IssActivity.IssActionId = issAction.IssActionID) THEN
                DO:
                    ASSIGN 
                        lc-msg = "Delete not allowed, this action has activity"     
                        li-goto = li-taskid.
                END.
                ELSE
                DO:
                    RUN prjlib-DeleteTask (
                        lc-global-user,
                        b-table.companyCode,
                        b-table.IssueNumber,
                        IssAction.phaseID,
                        IssAction.TaskID
                        ).
            
                    ASSIGN
                        lc-msg = "Deleted project action".
            
                END.      
            
            
            END. /* DELETE */
            ELSE
            IF lc-mode = "UPDATE" THEN
            DO:
            
                ASSIGN 
                    li-taskid = int(get-value("id"))
                    li-goto = li-taskid.
            
                FIND FIRST IssAction
                    WHERE issAction.CompanyCode = b-table.companyCode
                    AND IssAction.IssueNumber = b-table.IssueNumber
                    AND IssAction.TaskID = li-taskid NO-LOCK NO-ERROR.
                         
                IF AVAILABLE IssAction THEN 
                DO:
                    
                    RUN prjlib-UpdateTask (
                        lc-global-user,
                        b-table.companyCode,
                        b-table.IssueNumber,
                        IssAction.phaseID,
                        IssAction.TaskID,
                        lc-text,
                        ld-start,
                        li-duration
                        
                        ).
                    
                END.

            END. /* UPDATE */
    END. /* NOT BUILD */
    
    RUN prjlib-BuildGanttData (
        lc-global-user,
        b-table.companyCode,
        b-table.IssueNumber,
        OUTPUT TABLE tt-proj-tasks
        ).
    
    ASSIGN
        li-Count = 0
        li-This = 0.
        
    FOR EACH tt-proj-tasks NO-LOCK:
        ASSIGN
            li-count[1] = li-count[1] + 1.
        IF tt-proj-tasks.parentID > 0 
            THEN ASSIGN li-count[2] = li-count[2] + 1.
        
        
    END.    
       
    RUN outputHeader.
     
   
    {lib/gantt-build-js.i}

    /*
    ***
    *** Send thru info to redraw the gantt container
    *** 24 = row height
    *** 60 = Title bar height
    ***
    */
        
    ASSIGN
        li-h = ( max(li-count[1]+ 2 ,5) * 24 ) + 60 .
        
    
    {&out} SKIP 'var igoto = "' li-goto '";' SKIP
           'GanttContainer(' li-count[1] ',' li-h ');' skip.
    
    IF lc-msg <> "" THEN
        {&out} skip 'dhtmlx.alert("' lc-msg '");' SKIP.


            
END PROCEDURE.


&ENDIF

