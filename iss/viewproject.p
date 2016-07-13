/***********************************************************************

    Program:        iss/viewproject.p
    
    Purpose:        View Project
    
    Notes:
    
    
    When        Who         What
    04/04/2015  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

DEFINE VARIABLE lc-error-field      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg        AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-issue            AS INT       NO-UNDO.




{iss/issue.i}
{lib/project.i}

{src/web2/wrap-cgi.i}
{lib/htmlib.i}

RUN process-web-request.




PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.
    

END PROCEDURE.

PROCEDURE ip-ProjectPage:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/

    DEFINE BUFFER issue     FOR Issue.
    DEFINE BUFFER issPhase  FOR issPhase.
    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER Customer  FOR Customer.
    
    DEFINE BUFFER b-phase FOR Issphase.
    DEFINE BUFFER b-task  FOR IssAction.
    DEFINE VARIABLE li-last  LIKE ptp_phase.PhaseID NO-UNDO.
    
    
    FIND Issue 
        WHERE Issue.CompanyCode = lc-global-company
          AND Issue.IssueNumber = li-issue
          NO-LOCK NO-ERROR.
    FIND Customer OF Issue NO-LOCK NO-ERROR.
          
    RUN outputHeader.
    
    {&out} htmlib-Header("View Project") skip.
  

    {&out} htmlib-StartForm("mainform","post", appurl + '/iss/viewproject.p' ) skip.
    
    
    {&out} htmlib-ProgramTitle("Project " + string(li-issue)) 
    htmlib-hidden("issue",STRING(li-issue)) skip.

    {&out} htmlib-StartInputTable() skip.
    
    
    {&out}
         htmlib-SimpleTableRow("Issue Number",STRING(Issue.IssueNumber),"")
         htmlib-SimpleTableRow("Customer",Customer.Name,"")
         htmlib-SimpleTableRow("Raised By",com-UserName(Issue.RaisedLoginID),"")
         htmlib-SimpleTableRow("Raised By",com-AreaName(Issue.CompanyCode,Issue.AreaCode),"")
         htmlib-SimpleTableRow("Senior Engineer",com-UserName(Issue.AssignTo),"")
         htmlib-SimpleTableRow("Project Engineer",com-UserName(Issue.prj-eng),"")
         htmlib-SimpleTableRow("Project Start",STRING(Issue.prj-start,'99/99/9999'),"")
         htmlib-SimpleTableRow("Brief Description",Issue.BriefDescription,"")
         htmlib-SimpleTableRow("Details",Issue.LongDescription,"")
         .
    {&out} htmlib-EndTable() skip.

   
    {&out}
           skip
           htmlib-StartMntTable()
            htmlib-TableHeading(
            "Phase^left|Action^left|Date|Start Day^right|Estimated Duration^right|Ignore Weekend|Action Group^right|Responsibility|Billable"
            ) skip.
    
    FOR EACH b-phase NO-LOCK
        WHERE b-phase.CompanyCode = Issue.CompanyCode
          AND b-phase.issueNumber = Issue.issueNumber
        ,
        EACH b-task NO-LOCK 
            WHERE b-task.CompanyCode = Issue.CompanyCode
             AND b-task.issueNumber = Issue.IssueNumber
             AND b-task.phaseid = b-phase.phaseid
        BY b-phase.DisplayOrder
        BY b-task.displayOrder
         :
    
        {&out}
            skip
            tbar-tr(rowid(b-phase))
            skip
            htmlib-MntTableField(html-encode(IF li-last = b-phase.phaseid THEN "" ELSE b-phase.descr),'left')
            htmlib-MntTableField(html-encode(b-task.actdescription),'left')
            htmlib-MntTableField(string(b-task.actiondate,'99/99/9999'),'left')
            htmlib-MntTableField(string(b-task.StartDay),'right')
              htmlib-MntTableField(com-TimeToString(b-task.PlanDuration),'right') 
            htmlib-MntTableField(IF b-task.IgnoreWeekend THEN "Yes" ELSE "No",'left')
            htmlib-MntTableField(string(b-task.ActionGroup),'right') 
            htmlib-MntTableField(html-encode(
            com-DecodeLookup(b-task.Responsibility,lc-global-taskResp-code,lc-global-taskResp-desc)
            ),'left')
            htmlib-MntTableField(IF b-task.Billable THEN "Yes" ELSE "No",'left')
                    
            '</tr>' SKIP.
         ASSIGN
            li-last = b-phase.phaseid.
            
     END.       
     
    {&out} skip 
           htmlib-EndTable()
           skip.
    
    
           
    {&out} htmlib-EndForm() skip.

   

    {&OUT} htmlib-Footer() skip.
   
   

END PROCEDURE.


PROCEDURE outputHeader:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    output-content-type ("text/html":U).
        
END PROCEDURE.

PROCEDURE process-web-request:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
    {lib/checkloggedin.i}
    
 
    ASSIGN 
        li-issue = int(get-value("issue")).
        

    RUN ip-ProjectPage.
      
	
	   	
END PROCEDURE.

