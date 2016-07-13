/***********************************************************************

    Program:        iss/addproject.p
    
    Purpose:        Add New Project
    
    Notes:
    
    
    When        Who         What
    02/04/2015  phoski      Initial
    15/08/2015  phoski      Default user change 
    
***********************************************************************/
CREATE WIDGET-POOL.


DEFINE VARIABLE lc-error-field      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg        AS CHARACTER NO-UNDO.

/* Fields */

DEFINE VARIABLE lc-accountnumber    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-briefdescription AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-longdescription  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submitsource     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-raisedlogin      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-AreaCode         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-currentassign    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-projeng          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-date             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ProjCode         AS CHARACTER NO-UNDO.



/* Vars */

DEFINE VARIABLE lc-list-number      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-name        AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-login       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-lname       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-area        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-aname       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-assign      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-assname     AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-list-ProjCode    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-list-ProjDesc    AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-issue            AS INT       NO-UNDO.




{iss/issue.i}
{lib/project.i}

{src/web2/wrap-cgi.i}
{lib/htmlib.i}

RUN process-web-request.


FUNCTION format-Select-Account RETURNS CHARACTER 
    (pc-htm AS CHARACTER) FORWARD.

/* **********************  Internal Procedures  *********************** */

PROCEDURE ip-AreaSelect:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    {&out}  skip
            '<select id="areacode" name="areacode" class="inputfield">' skip.
    {&out}
    '<option value="' DYNAMIC-FUNCTION("htmlib-Null") '" ' 
    IF lc-AreaCode = dynamic-function("htmlib-Null") 
        THEN "selected" 
    ELSE "" '>Select Area</option>' skip
            '<option value="" ' if lc-AreaCode = ""
                then "selected" else "" '>Not Applicable/Unknown</option>' skip        
    .
    FOR EACH webIssArea NO-LOCK
        WHERE webIssArea.CompanyCode = lc-Global-Company 
        BREAK BY webIssArea.GroupID
        BY webIssArea.AreaCode:

        IF FIRST-OF(webissArea.GroupID) THEN
        DO:
            FIND webissagrp
                WHERE webissagrp.companycode = webissArea.CompanyCode
                AND webissagrp.Groupid     = webissArea.GroupID NO-LOCK NO-ERROR.
            {&out}
            '<optgroup label="' html-encode(IF AVAILABLE webissagrp THEN webissagrp.description ELSE "Unknown") '">' skip.
        END.

        {&out}
        '<option value="' webIssArea.AreaCode '" ' 
        IF lc-AreaCode = webIssArea.AreaCode  
            THEN "selected" 
        ELSE "" '>' html-encode(webIssArea.Description) '</option>' skip.

        IF LAST-OF(WebIssArea.GroupID) THEN {&out} '</optgroup>' skip.
    END.

    {&out} '</select>'.
END PROCEDURE.

PROCEDURE ip-BuildPage:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    RUN outputHeader.
    
    {&out} htmlib-Header("Add Project") skip.
    

    {&out} htmlib-StartForm("mainform","post", appurl + '/iss/addproject.p' ) skip.
    {&out} htmlib-ProgramTitle("Add Project") 
    htmlib-hidden("submitsource","") skip.

    {&out} htmlib-StartInputTable() skip.
    
    DEFINE BUFFER bcust FOR customer.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account")
        ELSE htmlib-SideLabel("Account"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    format-Select-Account(htmlib-Select("accountnumber",lc-list-number,lc-list-name,
        lc-accountnumber) )
    '</TD></TR>' skip. 
 
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("raisedlogin",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Raised By")
        ELSE htmlib-SideLabel("Raised By"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-Select("raisedlogin",lc-list-login,lc-list-lname,lc-raisedlogin)
    '</TD></TR>' skip. 
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("areacode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Area")
        ELSE htmlib-SideLabel("Area"))
    '</TD>' 
    '<TD VALIGN="TOP" ALIGN="left">'
    SKIP(4).

    RUN ip-AreaSelect.

    {&out}
    '</TD></TR>' skip. 
    
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("currentassign",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Senior Engineer")
        ELSE htmlib-SideLabel("Senior Engineer"))
    '</td>' 
    '<td valign="top" align="left">'
    htmlib-Select("currentassign",lc-list-assign,lc-list-assname,
        lc-currentassign)
    '</td></tr>' skip. 
       
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("projeng",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Project Engineer")
        ELSE htmlib-SideLabel("Project Engineer"))
    '</td>' 
    '<td valign="top" align="left">'
    htmlib-Select("projeng",lc-list-assign,lc-list-assname,
        lc-projeng)
    '</td></tr>' skip. 
    
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("projcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Project Template")
        ELSE htmlib-SideLabel("Project Template"))
    '</td>' 
    '<td valign="top" align="left">'
    htmlib-Select("projcode",lc-list-Projcode,lc-list-ProjDesc,
        lc-projeng)
    '</td></tr>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("date",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Project Start")
        ELSE htmlib-SideLabel("Project Start"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("date",10,lc-date) 
    htmlib-CalendarLink("date")
    '</TD>' skip.
    {&out} '</TR>' skip.
        
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("briefdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Brief Description")
        ELSE htmlib-SideLabel("Brief Description"))
    '</TD>'
    '<TD VALIGN="TOP" ALIGN="left">'
    htmlib-InputField("briefdescription",50,lc-briefdescription) 
    '</TD>' skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("longdescription",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Details")
        ELSE htmlib-SideLabel("Details"))
    '</TD>' skip
        '<TD VALIGN="TOP" ALIGN="left">'
         htmlib-TextArea("longdescription",lc-longdescription,10,45)
        '</TD>' skip
        skip.
            
       
    {&out} htmlib-EndTable() skip.

    IF lc-error-msg <> "" THEN
    DO:
        {&out} '<br><br><center>' 
        htmlib-MultiplyErrorMessage(lc-error-msg) '</center>' skip.
    END.
       
    
    {&out} '<center>' htmlib-SubmitButton("submitform","Create Project") 
    '</center>' skip.
    

    {&out}  htmlib-CalendarScript("date") SKIP.

    {&out} htmlib-EndForm() skip.

   

    {&OUT} htmlib-Footer() skip.
   

END PROCEDURE.

PROCEDURE ip-CreateProject:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    DO TRANSACTION ON ERROR UNDO, LEAVE:
         
        REPEAT:
            FIND LAST issue 
                WHERE issue.companycode = lc-global-company
                NO-LOCK NO-ERROR.
            ASSIGN
                li-issue = IF AVAILABLE issue THEN issue.issueNumber + 1 ELSE 1.
            LEAVE.
        END.
                
        CREATE issue.
        ASSIGN 
            issue.IssueNumber      = li-issue
            issue.BriefDescription = lc-BriefDescription
            issue.LongDescription  = lc-LongDescription
            issue.AccountNumber    = lc-accountnumber
            issue.CompanyCode      = lc-global-company
            issue.CreateDate       = TODAY
            issue.CreateTime       = TIME
            issue.CreateBy         = lc-global-user
            issue.IssueDate        = DATE(lc-date)
            issue.IssueTime        = TIME
            issue.areacode         = lc-areacode
            issue.CatCode          = 'Project'
            issue.Ticket           = NO
            issue.SearchField      = issue.BriefDescription + " " + issue.LongDescription
            issue.ActDescription   = ""
            Issue.ContractType     = ""   
            Issue.Billable         = YES
            issue.RaisedLoginid    = lc-raisedlogin
            issue.iclass           = lc-global-iclass-complex.
                    
        ASSIGN 
            Issue.link-SLAID = 0
            Issue.SLAStatus  = "OFF".
        
        ASSIGN
            Issue.AssignTo   = lc-CurrentAssign
            Issue.AssignDate = TODAY
            Issue.AssignTime = TIME
            .
     
        ASSIGN
            Issue.isProject = TRUE
            Issue.prj-eng   = lc-projeng
            issue.projCode = lc-projCode    
            Issue.prj-start = DATE(lc-date)
            .   
        
        ASSIGN 
            issue.StatusCode = htmlib-GetAttr("System","DefaultStatus").
        RUN islib-StatusHistory(
            issue.CompanyCode,
            issue.IssueNumber,
            lc-global-user,
            "",
            issue.StatusCode ).
                    
        islib-DefaultActions(lc-global-company,Issue.IssueNumber).
                
        RUN prjlib-NewProject (lc-global-user, lc-global-company,Issue.IssueNumber ).
            
                       
    END.
                        
END PROCEDURE.

PROCEDURE ip-GetAccountNumbers:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-user          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-AccountNumber AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name          AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER b-cust FOR Customer.
 
    DEFINE VARIABLE ll-Steam AS LOG NO-UNDO.
    
    FIND b-user WHERE b-user.LoginID = pc-user NO-LOCK NO-ERROR.
    
    ll-Steam = CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-user NO-LOCK).



    ASSIGN 
        pc-AccountNumber = htmlib-Null()
        pc-Name          = "Select Account".


    FOR EACH b-cust NO-LOCK
        WHERE b-cust.CompanyCode = b-user.CompanyCode
        AND  b-cust.isActive = TRUE   
        BY b-cust.name:

        /*
        *** if user is in teams then customer must be in 1 of the users teams
        *** or they have been assigned to the an issue for the customer
        */
        IF ll-steam
            AND NOT CAN-FIND(FIRST webUsteam 
            WHERE webusteam.loginid = pc-user
            AND webusteam.st-num = b-cust.st-num NO-LOCK) THEN NEXT. 

        ASSIGN 
            pc-AccountNumber = pc-AccountNumber + '|' + b-cust.AccountNumber
            pc-Name          = pc-Name + '|' + b-cust.name.

    END.



END PROCEDURE.

PROCEDURE ip-GetArea:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE OUTPUT PARAMETER pc-AreaCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Description  AS CHARACTER NO-UNDO.

    
    DEFINE BUFFER b-cust FOR WebIssArea.

   
    ASSIGN 
        pc-AreaCode    = htmlib-Null() + '|'
        pc-Description = "Select Area|Not Applicable/Known".


    FOR EACH b-cust NO-LOCK
        WHERE b-cust.CompanyCode = lc-global-company
        :

        ASSIGN 
            pc-AreaCode    = pc-AreaCode + '|' + b-cust.AreaCode
            pc-Description = pc-Description + '|' + b-cust.Description.

    END.
    

END PROCEDURE.

PROCEDURE ip-GetOwner:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-Account       AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Login         AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name          AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-user FOR WebUser.
    DEFINE BUFFER cu     FOR Customer.
     

    IF pc-Account <> "" THEN
    DO: 
        FIND cu WHERE cu.CompanyCode   = lc-global-company      
            AND cu.AccountNumber = pc-Account           
           NO-LOCK NO-ERROR.
                                                                      
        FIND FIRST b-user NO-LOCK                                  
            WHERE b-user.CompanyCode   = lc-global-company      
            AND b-user.AccountNumber = pc-Account             
            AND b-user.Disabled      = FALSE                  
            AND b-user.LoginID = cu.def-iss-loginid                
            NO-ERROR.                  
           
        IF AVAILABLE b-user THEN                                       
            ASSIGN pc-login = b-user.loginid                   
                pc-Name  = b-user.name.  
        ELSE
            ASSIGN pc-login = htmlib-Null() 
                pc-Name  = "Select Person".
      
         
        FOR EACH b-user NO-LOCK
            WHERE b-user.CompanyCode   = lc-global-company
            AND b-user.AccountNumber = pc-Account
            AND b-user.Disabled      = FALSE               
            AND b-user.loginid   <>  cu.def-iss-loginid            
            BY b-user.name:
  
            ASSIGN 
                pc-login = pc-login  + '|' + b-user.loginid
                pc-Name  = pc-Name + '|' + b-user.name.
  
        END.
    END.                                                        /* 3667 */  
    ELSE
    DO:
        ASSIGN 
            pc-login = htmlib-Null() + '|'
            pc-Name  = "Select Person|Not Applicable".
    END.

END PROCEDURE.

PROCEDURE ip-HeaderInclude-Calendar:
/*------------------------------------------------------------------------------
        Purpose:  																	  
        Notes:  																	  
------------------------------------------------------------------------------*/


END PROCEDURE.

PROCEDURE ip-HTM-Header:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-return       AS CHARACTER NO-UNDO.
    
    
    pc-return = '~n<script language="JavaScript" src="/asset/page/addproject.js?v=1.0.0"></script>~n'.
    

END PROCEDURE.

PROCEDURE ip-Validate:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    DEFINE VARIABLE ld-date   AS DATE    NO-UNDO.

    DEFINE VARIABLE li-int    AS INTEGER NO-UNDO.
    DEFINE BUFFER b FOR webuser.
    

    IF NOT CAN-FIND(customer WHERE customer.accountnumber 
        = lc-accountnumber 
        AND customer.companycode = lc-global-company
        NO-LOCK) 
        THEN RUN htmlib-AddErrorMessage(
            'accountnumber', 
            'You must select the account',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    IF pc-error-field = "" 
        AND ( lc-raisedlogin = htmlib-Null() OR lc-raisedLogin = "" )
        THEN RUN htmlib-AddErrorMessage(
            'raisedlogin', 
            'Select the person who raised the project',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
                          
    IF lc-areacode = htmlib-Null() 
        THEN RUN htmlib-AddErrorMessage(
            'areacode', 
            'Select the issue area',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
     
    ASSIGN 
        ld-date = DATE(lc-date) no-error.
    IF ERROR-STATUS:ERROR
        OR ld-date = ? 
        THEN RUN htmlib-AddErrorMessage(
            'date', 
            'You must enter the date',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    IF lc-briefdescription = ""
        THEN RUN htmlib-AddErrorMessage(
            'briefdescription', 
            'You must enter a brief description for the project',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF lc-longdescription = ""
        THEN RUN htmlib-AddErrorMessage(
            'longdescription', 
            'You must enter the details for the project',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
     
     
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
    
    RUN ip-GetAccountNumbers ( INPUT lc-user,OUTPUT lc-list-number,OUTPUT lc-list-name ).
    
    ASSIGN
        lc-accountNumber = get-value("accountnumber")
        lc-raisedlogin  = get-value("raisedlogin")
        lc-submitsource = get-value("submitsource")
        lc-AreaCode     = get-value("areacode")
        lc-currentassign = get-value("currentassign")
        lc-projeng = get-value("projeng")
        lc-briefdescription = get-value("briefdescription")
        lc-longdescription = get-value("longdescription")
        lc-date             = get-value("date")
        lc-ProjCode         = get-value("projcode")
        .

    IF request_method = "GET" THEN 
        ASSIGN 
            lc-currentassign = lc-user
            lc-projeng       = lc-user
            lc-date          = STRING(TODAY,"99/99/9999").
            
    RUN ip-GetOwner ( INPUT lc-accountnumber,OUTPUT lc-list-login,OUTPUT lc-list-lname ).
    RUN ip-GetArea ( OUTPUT lc-list-area,OUTPUT lc-list-aname ).
    RUN com-GetAssignList ( lc-global-company , OUTPUT lc-list-assign , OUTPUT lc-list-assname ).
    RUN com-GetProjectTemplateList ( lc-global-company , OUTPUT lc-list-ProjCode , OUTPUT lc-list-ProjDesc ).
     
    
    
    IF REQUEST_method = "POST" AND lc-submitsource <> "AccountChange" THEN
    DO:
        
        RUN ip-Validate( OUTPUT lc-error-field,OUTPUT lc-error-msg ).
        
        IF lc-error-msg = "" THEN
        DO:
            REQUEST_method = "GET".
            
            RUN ip-CreateProject.
                       
            set-user-field("mode","view").
            set-user-field("source","addproject").
            set-user-field("issue",STRING(li-issue)).
            RUN run-web-object IN web-utilities-hdl ("iss/viewproject.p").
            RETURN.
           
        END.
        
        
    END.
         
    RUN ip-BuildPage.
       
	
	   	
END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION format-Select-Account RETURNS CHARACTER 
    ( pc-htm AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<select',
        '<select onChange="ChangeAccount()"'). 


    RETURN lc-htm.

		
END FUNCTION.
