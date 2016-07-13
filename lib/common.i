/***********************************************************************

    Program:        lib/common.i
    
    Purpose:             
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      Initial
    
    03/08/2010  DJS         Clarified ambiguous buffer names.
    01/05/2014  phoski      New functions
    03/12/2014  phoski      Eng Type 
    20/03/2015  phoski      com-EndTimeCalc
    27/03/2015  phoski      project stuff
    18/04/2015  phoski      com-ConvertJSDate 
    10/05/2015  phoski      Read/Write User Params 
    15/05/2015  phoski      JQuery var
    07/06/2015  phoski      Delete 'Contract' check
    15/08/2015  phoski      com-GetUserListForAccount
    19/10/2015  phoski      com-LimitCustomerName - To stop 32k errors
    20/10/2015  phoski      com-GetHelpDeskEmail
    22/10/2015  phoski      com-AllowCustomerAccess - take into account
                            AllowAllTeams customer flag
    23/02/2016  phoski      com-GetCustomerAccountActiveOnly
    18/06/2016  phoski      Survey Question Types
    25/06/2016  phoski      webAction.ActionClass Types
    01/07/2016  phoski      com-GetAssignList/com-GetAssignIssue
                            - only active users
    02/07/2016  phoski      com-GetActivityByType 
  
***********************************************************************/

{lib/attrib.i}
{lib/slatt.i}

&global-define INTERNAL INTERNAL
&global-define CUSTOMER CUSTOMER
&global-define CONTRACT CONTRACT

DEFINE VARIABLE lc-global-selcode             AS CHARACTER 
    INITIAL "WALESFOREVER" NO-UNDO.
DEFINE VARIABLE lc-global-seldesc             AS CHARACTER
    INITIAL "None" NO-UNDO.

DEFINE VARIABLE lc-global-company             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-user                AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-secure              AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-internal            AS CHARACTER 
    INITIAL "INTERNAL,CONTRACT" NO-UNDO.

DEFINE VARIABLE lc-global-dtype               AS CHARACTER
    INITIAL "Text|Number|Date|Note|Yes/No" NO-UNDO.

DEFINE VARIABLE lc-global-respaction-code     AS CHARACTER
    INITIAL "None|Email|EmailPage|Page|Web" NO-UNDO.
DEFINE VARIABLE lc-global-respaction-display  AS CHARACTER
    INITIAL "None|Send Email|Send Email & SMS|Send SMS|Web Alert" NO-UNDO.

DEFINE VARIABLE lc-global-tbase-code          AS CHARACTER
    INITIAL "OFF|REAL" NO-UNDO.
DEFINE VARIABLE lc-global-tbase-display       AS CHARACTER
    INITIAL "Office Hours|24 Hours" NO-UNDO.

DEFINE VARIABLE lc-global-abase-code          AS CHARACTER
    INITIAL "ISSUE|ALERT" NO-UNDO.
DEFINE VARIABLE lc-global-abase-display       AS CHARACTER
    INITIAL "Issue Date/Time|Previous Alert Date/Time"         
    NO-UNDO.

DEFINE VARIABLE lc-global-respunit-code       AS CHARACTER
    INITIAL "None|Minute|Hour|Day|Week" NO-UNDO.
DEFINE VARIABLE lc-global-respunit-display    AS CHARACTER
    INITIAL "None|Minute|Hour|Day|Week" NO-UNDO.

DEFINE VARIABLE lc-global-action-code         AS CHARACTER
    INITIAL "OPEN|CLOSED" NO-UNDO.
DEFINE VARIABLE lc-global-action-display      AS CHARACTER
    INITIAL "Open|Closed" NO-UNDO.

DEFINE VARIABLE lc-global-hour-code           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-hour-display        AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-min-code            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-min-display         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-System-KB-Code             AS CHARACTER
    INITIAL "SYS.ISSUE" NO-UNDO.
DEFINE VARIABLE lc-System-KB-Desc             AS CHARACTER
    INITIAL "Completed Issues" NO-UNDO.

DEFINE VARIABLE lc-System-Note-Code           AS CHARACTER
    INITIAL 'SYS.ACCOUNT,SYS.EMAILCUST,SYS.ASSIGN,SYS.SLA,SYS.MISC,SYS.SLAWARN,SYS.SLAMISSED' NO-UNDO.
DEFINE VARIABLE lc-System-Note-Desc           AS CHARACTER
    INITIAL 'System - Account Changed,System - Customer Emailed,System - Issue Assignment,System - SLA Assigned,System - Misc Note,System - SLA Warning,System - SLA Missed'
    NO-UNDO.

DEFINE VARIABLE lc-global-GT-Code             AS CHARACTER INITIAL
    'Asset.Type,Asset.Manu,Asset.Status' NO-UNDO.

DEFINE VARIABLE lc-global-iclass-complex      AS CHARACTER INITIAL
    'ComplexProject' NO-UNDO.   
DEFINE VARIABLE lc-global-iclass-code         AS CHARACTER INITIAL
    'Issue|Admin|Project|ComplexProject' NO-UNDO.
DEFINE VARIABLE lc-global-iclass-desc         AS CHARACTER INITIAL
    'Issue|Administration|Simple Project|Complex Project' NO-UNDO.    
/*
*** 
*** Minus complex porjects as you can't add or amend these as part of issue add/amend
***
*/

DEFINE VARIABLE lc-global-iclass-Add-code     AS CHARACTER INITIAL
    'Issue|Admin|Project' NO-UNDO.
DEFINE VARIABLE lc-global-iclass-Add-desc     AS CHARACTER INITIAL
    'Issue|Administration|Simple Project' NO-UNDO. 
    
DEFINE VARIABLE lc-global-SupportTicket-Code  AS CHARACTER
    INITIAL 'NONE|YES|BOTH' NO-UNDO.
DEFINE VARIABLE lc-global-SupportTicket-Desc  AS CHARACTER
    INITIAL 'Standard Support Only|Ticket Support Only|Standard And Ticket Support'
                                     
    NO-UNDO.
DEFINE VARIABLE lc-global-Allow-TicketSupport AS CHARACTER
    INITIAL 'YES|BOTH' NO-UNDO.
DEFINE VARIABLE lc-global-sms-username        AS CHARACTER
    INITIAL 'tomcarroll' NO-UNDO.
DEFINE VARIABLE lc-global-sms-password        AS CHARACTER
    INITIAL 'cr34tion' NO-UNDO.

DEFINE VARIABLE lc-global-excludeType         AS CHARACTER
    INITIAL "exe,vbs" NO-UNDO.
DEFINE VARIABLE lc-global-teamassign          AS CHARACTER 
    INITIAL '[TeamAssign]' NO-UNDO.

DEFINE VARIABLE lc-global-engType-Code        AS CHARACTER 
    INITIAL '|FIELD|REMOTE|Project' NO-UNDO.

DEFINE VARIABLE lc-global-engType-desc        AS CHARACTER 
    INITIAL 'Not Applicable|Field|Remote|Project' NO-UNDO.
DEFINE VARIABLE lc-global-taskResp-code       AS CHARACTER 
    INITIAL 'E|C|3' NO-UNDO.
DEFINE VARIABLE lc-global-taskResp-desc       AS CHARACTER 
    INITIAL 'Engineer|Customer|3rd Party' NO-UNDO.
                        
DEFINE VARIABLE lc-global-sq-code             AS CHARACTER 
    INITIAL 'RANGE1-10|LOG|COM|FIELD|PARA|NUMBER'  NO-UNDO.                        
DEFINE VARIABLE lc-global-sq-desc           AS CHARACTER 
    INITIAL 'Range (1-10)|Yes/No|Comment Box|Text Input|Text Only|Number'  NO-UNDO.
    
DEFINE VARIABLE lc-global-webActionClass-code             AS CHARACTER 
    INITIAL 'ENG|ACC'  NO-UNDO.                        
DEFINE VARIABLE lc-global-WebActionClass-desc           AS CHARACTER 
    INITIAL 'Engineer|Account'  NO-UNDO.
        
DEFINE VARIABLE li-global-sla-fail            AS INTEGER   INITIAL 10 NO-UNDO.
DEFINE VARIABLE li-global-sla-amber           AS INTEGER   INITIAL 20 NO-UNDO.
DEFINE VARIABLE li-global-sla-ok              AS INTEGER   INITIAL 30 NO-UNDO.
DEFINE VARIABLE li-global-sla-na              AS INTEGER   INITIAL 99 NO-UNDO.


DEFINE VARIABLE li-global-sched-days-back     AS INTEGER   INITIAL 100 NO-UNDO.

DEFINE VARIABLE lc-global-jquery              AS CHARACTER 
    INITIAL 
    '<script type="text/javascript" src="/asset/jquery/jquery-1.11.3.min.js"></script>~n'
    NO-UNDO.
   
DEFINE VARIABLE lc-global-jquery-ui           AS CHARACTER 
    INITIAL 
    '<script type="text/javascript" src="/asset/jquery-easyui-1.4.2/jquery.easyui.min.js"></script>~n'
    NO-UNDO.
    
/* ********************  Preprocessor Definitions  ******************** */





/* ************************  Function Prototypes ********************** */

FUNCTION com-AllowCustomerAccess RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER,
    pc-LoginID AS CHARACTER,
    pc-AccountNumber AS CHARACTER )  FORWARD.


FUNCTION com-AllowTicketSupport RETURNS LOGICAL
    ( pr-rowid AS ROWID )  FORWARD.


FUNCTION com-AreaName RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER ,
    pc-AreaCode    AS CHARACTER )  FORWARD.


FUNCTION com-AskTicket RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-AccountNumber      AS CHARACTER )  FORWARD.


FUNCTION com-AssignedToUser RETURNS INTEGER
    ( pc-CompanyCode AS CHARACTER,
    pc-LoginID     AS CHARACTER )  FORWARD.


FUNCTION com-BelongsToATeam RETURNS LOGICAL 
    (  ) FORWARD.

FUNCTION com-CanDelete RETURNS LOGICAL
    ( pc-loginid  AS CHARACTER,
    pc-table    AS CHARACTER,
    pr-rowid    AS ROWID )  FORWARD.


FUNCTION com-CatName RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER,
    pc-Code AS CHARACTER
    )  FORWARD.


FUNCTION com-CheckSystemSetup RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER )  FORWARD.


FUNCTION com-ContractDescription RETURNS CHARACTER 
    (pc-companyCode AS CHARACTER,
    pc-ContractType AS CHARACTER) FORWARD.

FUNCTION com-ConvertJSDate RETURNS DATE 
    (pc-date AS CHARACTER) FORWARD.

FUNCTION com-CookieDate RETURNS DATE
    ( pc-user AS CHARACTER )  FORWARD.


FUNCTION com-CookieTime RETURNS INTEGER
    ( pc-user AS CHARACTER )  FORWARD.


FUNCTION com-CustomerAvailableSLA RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER,
    pc-AccountNumber AS CHARACTER )  FORWARD.


FUNCTION com-CustomerName RETURNS CHARACTER
    ( pc-Company AS CHARACTER,
    pc-Account  AS CHARACTER )  FORWARD.


FUNCTION com-CustomerOpenIssues RETURNS INTEGER
    ( pc-CompanyCode AS CHARACTER,
    pc-accountNumber AS CHARACTER )  FORWARD.


FUNCTION com-DayName RETURNS CHARACTER 
    (pd-Date AS DATE,
    pc-Format AS CHARACTER) FORWARD.

FUNCTION com-DayOfWeek RETURNS INTEGER 
    (INPUT pd-Date AS DATE,
    INPUT pi-base AS INTEGER) FORWARD.

FUNCTION com-DecodeLookup RETURNS CHARACTER
    ( pc-code AS CHARACTER,
    pc-code-list AS CHARACTER,
    pc-code-display AS CHARACTER )  FORWARD.


FUNCTION com-DescribeTicket RETURNS CHARACTER
    ( pc-TxnType AS CHARACTER )  FORWARD.


FUNCTION com-EngineerSelection RETURNS CHARACTER 
    (  ) FORWARD.

FUNCTION com-GenTabDesc RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER,
    pc-GType AS CHARACTER,
    pc-Code AS CHARACTER
    )  FORWARD.


FUNCTION com-GetActivityByType RETURNS CHARACTER 
	(pc-companyCode AS CHARACTER,
	 pi-TypeID      AS INTEGER) FORWARD.

FUNCTION com-GetDefaultCategory RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER )  FORWARD.


FUNCTION com-GetHelpDeskEmail RETURNS CHARACTER 
    (pc-mode        AS CHARACTER,
    pc-companyCode AS CHARACTER,
     pc-accountNumber AS CHARACTER) FORWARD.

FUNCTION com-GetTicketBalance RETURNS INTEGER 
	(pc-companyCode AS CHARACTER,
	 pc-accountNumber   AS CHARACTER) FORWARD.

FUNCTION com-GetTicketBalanceWithAdmin RETURNS INTEGER 
	(pc-companyCode AS CHARACTER,
	 pc-accountNumber   AS CHARACTER) FORWARD.

FUNCTION com-HasSchedule RETURNS INTEGER 
    (pc-companyCode AS CHARACTER,
    pc-LoginId     AS CHARACTER) FORWARD.

FUNCTION com-Initialise RETURNS LOGICAL
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION com-InitialSetup RETURNS LOGICAL
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-InternalTime RETURNS INTEGER
    ( pi-hours AS INTEGER,
    pi-mins  AS INTEGER )  FORWARD.


FUNCTION com-IsActivityChargeable RETURNS LOGICAL 
	(pf-ActID     AS DECIMAL) FORWARD.

FUNCTION com-IsContractor RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-LoginID      AS CHARACTER )  FORWARD.


FUNCTION com-IsCustomer RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-LoginID      AS CHARACTER )  FORWARD.


FUNCTION com-IssueActionsStatus RETURNS INTEGER
    ( pc-companyCode AS CHARACTER,
    pi-issue   AS INTEGER,
    pc-status  AS CHARACTER)  FORWARD.


FUNCTION com-IssueStatusAlert RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER,
    pc-CreateSource AS CHARACTER,
    pc-StatusCode   AS CHARACTER )  FORWARD.


FUNCTION com-IsSuperUser RETURNS LOGICAL
    ( pc-LoginID      AS CHARACTER )  FORWARD.


FUNCTION com-LimitCustomerName RETURNS CHARACTER 
    (pc-name AS CHARACTER) FORWARD.

FUNCTION com-MMDDYYYY RETURNS CHARACTER 
    (pd-date AS DATE) FORWARD.

FUNCTION com-Money RETURNS CHARACTER 
    (pf-amount AS DECIMAL) FORWARD.

FUNCTION com-MonthBegin RETURNS DATE
    ( pd-date AS DATE)  FORWARD.


FUNCTION com-MonthEnd RETURNS DATE
    ( pd-date AS DATE )  FORWARD.


FUNCTION com-NearestTimeUnit RETURNS INTEGER
    ( pi-time AS INTEGER )  FORWARD.


FUNCTION com-NumberOfActions RETURNS INTEGER
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-NumberOfAlerts RETURNS INTEGER
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-NumberOfEmails RETURNS INTEGER
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-NumberOfInventoryWarnings RETURNS INTEGER
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-NumberOfOpenActions RETURNS INTEGER
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-NumberUnAssigned RETURNS INTEGER
    ( pc-CompanyCode AS CHARACTER )  FORWARD.


FUNCTION com-QuickView RETURNS LOGICAL
    ( pc-LoginID  AS CHARACTER )  FORWARD.


FUNCTION com-ReadParam RETURNS CHARACTER 
    (pc-loginid   AS CHARACTER,
    pc-key AS CHARACTER) FORWARD.

FUNCTION com-RequirePasswordChange RETURNS LOGICAL
    ( pc-user AS CHARACTER )  FORWARD.


FUNCTION com-SLADescription RETURNS CHARACTER
    ( pf-SLAID AS DECIMAL )  FORWARD.


FUNCTION com-StatusTrackIssue RETURNS LOGICAL
    ( pc-companycode AS CHARACTER,
    pc-StatusCode  AS CHARACTER )  FORWARD.


FUNCTION com-StringReturn RETURNS CHARACTER
    ( pc-orig AS CHARACTER,
    pc-add AS CHARACTER )  FORWARD.


FUNCTION com-SystemLog RETURNS ROWID
    ( pc-ActType AS CHARACTER,
    pc-LoginID AS CHARACTER,
    pc-AttrData AS CHARACTER )  FORWARD.


FUNCTION com-TicketOnly RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-AccountNumber      AS CHARACTER )  FORWARD.


FUNCTION com-TimeReturn RETURNS CHARACTER
    ( pc-Type AS CHARACTER )  FORWARD.


FUNCTION com-TimeToString RETURNS CHARACTER
    ( pi-time AS INTEGER )  FORWARD.


FUNCTION com-UserName RETURNS CHARACTER
    ( pc-LoginID AS CHARACTER )  FORWARD.


FUNCTION com-UsersCompany RETURNS CHARACTER
    ( pc-LoginID  AS CHARACTER )  FORWARD.


FUNCTION com-UserTrackIssue RETURNS LOGICAL
    ( pc-LoginID AS CHARACTER
    )  FORWARD.


FUNCTION com-WriteParam RETURNS ROWID 
    (pc-LoginID AS CHARACTER,
    pc-Key     AS CHARACTER,
    pc-data    AS CHARACTER) FORWARD.

FUNCTION com-WriteQueryInfo RETURNS LOGICAL
    ( hQuery AS HANDLE )  FORWARD.



/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15.38
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */

DYNAMIC-FUNCTION('com-Initialise':U).



/* **********************  Internal Procedures  *********************** */

PROCEDURE com-EndTimeCalc:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pd-start AS DATE         NO-UNDO.
    DEFINE INPUT PARAMETER pi-start AS INTEGER          NO-UNDO.
    DEFINE INPUT PARAMETER pi-duration AS INTEGER   NO-UNDO.
    DEFINE OUTPUT PARAMETER pd-end  AS DATE         NO-UNDO.
    DEFINE OUTPUT PARAMETER pi-end  AS INTEGER      NO-UNDO.
    
    DEFINE VARIABLE lc-dt   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ldt     LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE ldt2    LIKE issue.lastactivity NO-UNDO.
    DEFINE VARIABLE li-hour AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-min  AS INTEGER   NO-UNDO.
    
    

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
        pi-end  = li-min * 60.
           
        
END PROCEDURE.

PROCEDURE com-GenTabSelect :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-GType       AS CHARACTER NO-UNDO.

    DEFINE OUTPUT PARAMETER pc-code     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc     AS CHARACTER NO-UNDO.

    DEFINE VARIABLE icount AS INTEGER NO-UNDO.


    DEFINE BUFFER b-GenTab FOR GenTab.

    FOR EACH b-GenTab NO-LOCK 
        WHERE b-GenTab.CompanyCode = pc-CompanyCode
        AND b-GenTab.gType = pc-gType
        :

        IF icount = 0 
            THEN ASSIGN pc-code = b-GenTab.gCode
                pc-Desc = b-GenTab.Descr.

        ELSE ASSIGN pc-code = pc-code + '|' + 
               b-GenTab.gCode
                pc-Desc = pc-Desc + '|' + 
               b-GenTab.Descr.

        icount = icount + 1.

    END.


END PROCEDURE.


PROCEDURE com-GetAccountManagerList:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user FOR WebUser.

    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(lc-global-internal,b-user.UserClass)
        AND b-user.accountManager
        AND b-user.CompanyCode = pc-CompanyCode
        BY b-user.name:

        IF pc-loginID = ""
            THEN ASSIGN 
                pc-loginID = b-user.LoginID
                pc-name    = b-user.Name.

        ELSE ASSIGN 
                pc-LoginID = pc-LoginID + '|' + 
               b-user.LoginID
                pc-name    = pc-name + '|' + 
               b-user.Name.
    END.

END PROCEDURE.

PROCEDURE com-GetAction :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-buffer FOR WebAction.

    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode
        BY b-buffer.Description:

        IF pc-codes = ""
            THEN ASSIGN pc-Codes = b-buffer.ActionCode
                pc-Desc  = b-buffer.Description.
        ELSE ASSIGN pc-Codes = pc-Codes + '|' + 
               b-buffer.ActionCode
                pc-Desc  = pc-Desc + '|' + 
               b-buffer.Description.
    END.
END PROCEDURE.


PROCEDURE com-GetActivityType :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE INPUT  PARAMETER pc-companyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Active          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Time            AS CHARACTER NO-UNDO.

    /* def var acttype as char initial "Take Call|Travel for Job|Analyse Fault|Repair Fault|Order Goods".  */
    /* def var actcodes as char initial "1|2|3|4|5".                                                       */

    DEFINE BUFFER b-WebActType FOR WebActType .

    ASSIGN 
        pc-Codes  = ""
        pc-Active = ""
        pc-Desc   = ""
        pc-Time   = "".


    FOR EACH b-WebActType NO-LOCK 
        WHERE b-WebActType.CompanyCode = pc-CompanyCode
        BREAK BY b-WebActType.TypeID 
        :

        ASSIGN 
            pc-Codes  = pc-Codes  + '|' + string(b-WebActType.TypeID)
            pc-Active = pc-Active + '|' + b-WebActType.ActivityType 
            pc-Desc   = pc-Desc   + '|' + b-WebActType.Description  
            pc-Time   = pc-Time   + '|' + string(b-WebActType.MinTime)
            .
    END.

    ASSIGN
        pc-Codes  = substr(pc-Codes,2)
        pc-Active = substr(pc-Active,2)
        pc-Desc   = substr(pc-Desc,2)  
        pc-Time   = substr(pc-Time,2).  
    
    
    
    
    


END PROCEDURE.


PROCEDURE com-GetArea :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-IssArea FOR WebIssArea.

    ASSIGN 
        pc-Codes = DYNAMIC-FUNCTION("htmlib-Null") + "|NotAssigned"
        pc-Desc  = "All Areas|Not Assigned".


    FOR EACH b-IssArea NO-LOCK 
        WHERE b-IssArea.CompanyCode = pc-CompanyCode
        /* by b-IssArea.Description: */
        :
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-IssArea.AreaCode
            pc-Desc  = pc-Desc + '|' + 
               b-IssArea.Description.
    END.
END PROCEDURE.


PROCEDURE com-GetAreaIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-IssArea FOR WebIssArea.

    ASSIGN 
        pc-Codes = ""
        pc-Desc  = "Not Applicable/Known".


    FOR EACH b-IssArea NO-LOCK 
        WHERE b-IssArea.CompanyCode = pc-CompanyCode
        BY b-IssArea.Description:
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-IssArea.AreaCode
            pc-Desc  = pc-Desc + '|' + 
               b-IssArea.Description.
    END.

END PROCEDURE.


PROCEDURE com-GetAssign :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user FOR WebUser.

    ASSIGN 
        pc-LoginID = DYNAMIC-FUNCTION("htmlib-Null") + "|NotAssigned"
        pc-name    = "All People|Not Assigned".


    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(lc-global-internal,b-user.UserClass)
        AND b-user.CompanyCode = pc-CompanyCode
        BY b-user.name:
        ASSIGN 
            pc-LoginID = pc-LoginID + '|' + 
               b-user.LoginID
            pc-name    = pc-name + '|' + 
               b-user.Name.
    END.
END PROCEDURE.


PROCEDURE com-GetAssignIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user FOR WebUser.

    ASSIGN 
        pc-LoginID = ""
        pc-name    = "Not Assigned".


    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(lc-global-internal,b-user.UserClass)
        AND b-user.CompanyCode = pc-CompanyCode
        AND b-user.Disabled = FALSE
        BY b-user.name:
        ASSIGN 
            pc-LoginID = pc-LoginID + '|' + 
               b-user.LoginID
            pc-name    = pc-name + '|' + 
               b-user.Name .
    END.
END PROCEDURE.


PROCEDURE com-GetAssignList :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user FOR WebUser.

    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(lc-global-internal,b-user.UserClass)
        AND b-user.CompanyCode = pc-CompanyCode
        AND b-user.Disabled = FALSE
        BY b-user.name:

        IF pc-loginID = ""
            THEN ASSIGN pc-loginID = b-user.LoginID
                pc-name    = b-user.Name.

        ELSE ASSIGN pc-LoginID = pc-LoginID + '|' + 
               b-user.LoginID
                pc-name    = pc-name + '|' + 
               b-user.Name.
    END.
END PROCEDURE.


PROCEDURE com-GetAssignRoot:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-userid      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER webUStream FOR WebUSteam.
    DEFINE BUFFER webUx      FOR WebUSteam.
    DEFINE BUFFER b-user     FOR WebUser.
    
    IF DYNAMIC-FUNCTION("com-isTeamMember", pc-companycode,pc-userid,?) THEN
    DO:
        ASSIGN 
            pc-LoginID = DYNAMIC-FUNCTION("htmlib-Null") + "|NotAssigned"
            pc-name    = "Your Team(s)and Disabled|Not Assigned".
           
        FOR EACH WebUSteam NO-LOCK
            WHERE WebUSteam.LoginID = pc-UserID,
            EACH webux NO-LOCK
            WHERE webux.st-num = WebUSteam.st-num,
            EACH b-user NO-LOCK
            WHERE b-user.LoginID = webux.LoginID
            AND b-user.companycode = pc-companyCode
            BY b-user.name
            :
                
            IF LOOKUP( b-user.LoginID,pc-loginid,"|") = 0 
                THEN ASSIGN 
                    pc-LoginID = pc-LoginID + '|' + b-user.LoginID
                    pc-name    = pc-name + '|' + b-user.Name.
                           
                    
        END.
             
    END.
    ELSE 
        RUN com-GetAssign ( pc-companyCode, 
            OUTPUT pc-loginID , 
            OUTPUT pc-name ).
    
    
    


END PROCEDURE.

PROCEDURE com-GetAutoAction :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER  pc-Exclude         AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-buffer FOR WebAction.

    ASSIGN
        pc-codes = ""
        pc-desc  = "No Auto Action".

    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode
        BY b-buffer.Description:

        IF b-buffer.ActionCode = pc-Exclude THEN NEXT.

        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-buffer.ActionCode
            pc-Desc  = pc-Desc + '|' + 
               b-buffer.Description.
    END.
END PROCEDURE.


PROCEDURE com-GetCategoryIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-company             AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-CatCode             AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Description         AS CHARACTER NO-UNDO.

    
    DEFINE BUFFER b-Cat FOR WebIssCat.

   
    ASSIGN 
        pc-CatCode     = ""
        pc-Description = "".

    FOR EACH b-Cat NO-LOCK
        WHERE b-Cat.CompanyCode = pc-company
        BY b-Cat.description
        :

        IF pc-CatCode = ""
            THEN ASSIGN  pc-CatCode     = b-Cat.CatCode
                pc-Description = b-Cat.Description.
        ELSE ASSIGN pc-CatCode     = pc-CatCode + '|' + b-Cat.CatCode
                pc-Description = pc-Description + '|' + b-Cat.Description.

    END.

END PROCEDURE.


PROCEDURE com-GetCatSelect :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-IssArea FOR WebIssCat.

    ASSIGN 
        pc-Codes = DYNAMIC-FUNCTION("htmlib-Null")
        pc-Desc  = "All Categories".


    FOR EACH b-IssArea NO-LOCK 
        WHERE b-IssArea.CompanyCode = pc-CompanyCode
        /* by b-IssArea.Description: */
        :
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-IssArea.CatCode
            pc-Desc  = pc-Desc + '|' + 
               b-IssArea.Description.
    END.
END PROCEDURE.


PROCEDURE com-GetCustomer :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-LoginID          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-AccountNumber   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-cust FOR customer.
    DEFINE BUFFER b-user FOR WebUser.

    ASSIGN 
        pc-AccountNumber = DYNAMIC-FUNCTION("htmlib-Null")
        pc-name          = "All Customers".

    FIND b-user WHERE b-user.LoginID = pc-LoginID NO-LOCK NO-ERROR.
    
    FOR EACH b-cust NO-LOCK 
        WHERE b-cust.CompanyCode = pc-CompanyCode
        BY b-cust.name:
        IF AVAILABLE b-user THEN
        DO:
            IF NOT DYNAMIC-FUNCTION('com-AllowCustomerAccess':U,
                pc-companyCode,
                pc-LoginID,
                b-cust.AccountNumber) THEN NEXT.
        END.
        ASSIGN 
            pc-AccountNumber = pc-AccountNumber + '|' + 
               b-cust.AccountNumber
            pc-name          = pc-name + '|' + 
               com-LimitCustomerName(b-cust.Name).
    END.


END PROCEDURE.


PROCEDURE com-GetCustomerAccount :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-LoginID          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-AccountNumber   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-cust FOR customer.
    DEFINE BUFFER b-user FOR WebUser.

   
    FIND b-user WHERE b-user.LoginID = pc-LoginID NO-LOCK NO-ERROR.
    
    FOR EACH b-cust NO-LOCK 
        WHERE b-cust.CompanyCode = pc-CompanyCode
        BY b-cust.AccountNumber:
        IF pc-AccountNumber = "" 
            THEN ASSIGN 
                pc-AccountNumber = b-cust.AccountNumber
                pc-name          = b-cust.AccountNumber + " " + com-LimitCustomerName(b-cust.NAME).
        ELSE ASSIGN 
                pc-AccountNumber = pc-AccountNumber + '|' + 
               b-cust.AccountNumber
                pc-name          = pc-name + '|' + 
               b-cust.AccountNumber + " " + com-LimitCustomerName(b-cust.Name).
    END.


END PROCEDURE.



PROCEDURE com-GetCustomerAccountActiveOnly:

/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/

    DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-LoginID          AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-AccountNumber   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-cust FOR customer.
    DEFINE BUFFER b-user FOR WebUser.

   
    FIND b-user WHERE b-user.LoginID = pc-LoginID NO-LOCK NO-ERROR.
    
    FOR EACH b-cust NO-LOCK 
        WHERE b-cust.CompanyCode = pc-CompanyCode
          AND b-cust.IsActive = TRUE
        BY b-cust.AccountNumber:
        IF pc-AccountNumber = "" 
            THEN ASSIGN 
                pc-AccountNumber = b-cust.AccountNumber
                pc-name          = b-cust.AccountNumber + " " + com-LimitCustomerName(b-cust.NAME).
        ELSE ASSIGN 
                pc-AccountNumber = pc-AccountNumber + '|' + 
               b-cust.AccountNumber
                pc-name          = pc-name + '|' + 
               b-cust.AccountNumber + " " + com-LimitCustomerName(b-cust.Name).
    END.
    


END PROCEDURE.



PROCEDURE com-GetEngineerList:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-EngType     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user FOR WebUser.

   
    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(lc-global-internal,b-user.UserClass)
        AND b-user.EngType <> ""
        AND b-user.CompanyCode = pc-CompanyCode
        BY b-user.name:

        IF pc-engType <> ""
            AND pc-engTYpe <> b-user.engType 
            THEN NEXT.
        
        IF pc-loginID = ""
            THEN ASSIGN pc-LoginID = b-user.LoginID
                pc-name    = b-user.name.
        ELSE ASSIGN pc-LoginID = pc-LoginID + '|' + 
                      b-user.LoginID
                pc-name    = pc-name + '|' + 
                        b-user.Name.
    END.
    

END PROCEDURE.

PROCEDURE com-GetInternalUser :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user FOR WebUser.

   
    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(lc-global-internal,b-user.UserClass)
        AND b-user.CompanyCode = pc-CompanyCode
        BY b-user.name:

        IF pc-loginID = ""
            THEN ASSIGN pc-LoginID = b-user.LoginID
                pc-name    = b-user.name.
        ELSE ASSIGN pc-LoginID = pc-LoginID + '|' + 
                      b-user.LoginID
                pc-name    = pc-name + '|' + 
                        b-user.Name.
    END.
END PROCEDURE.


PROCEDURE com-GetKBSection :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-buffer FOR knbSection.

    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode
        BY b-buffer.Description:

        IF pc-codes = ""
            THEN ASSIGN pc-Codes = b-buffer.knbCode
                pc-Desc  = b-buffer.Description.
        ELSE ASSIGN pc-Codes = pc-Codes + '|' + b-buffer.knbCode
                pc-Desc  = pc-Desc + '|' + b-buffer.Description.
    END.

END PROCEDURE.


PROCEDURE com-GetProjectTemplateList:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-buffer FOR ptp_proj.

    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode
        BY b-buffer.Descr:

        IF pc-codes = ""
            THEN ASSIGN pc-Codes = b-buffer.ProjCode
                pc-Desc  = b-buffer.Descr.
        ELSE ASSIGN pc-Codes = pc-Codes + '|' + b-buffer.ProjCode
                pc-Desc  = pc-Desc + '|' + b-buffer.Descr.
    END.
    

END PROCEDURE.

PROCEDURE com-GetStatus :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-companyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-WebStatus FOR WebStatus.

    ASSIGN 
        pc-Codes = DYNAMIC-FUNCTION("htmlib-Null")
        pc-name  = "All Status Codes".


    FOR EACH b-WebStatus NO-LOCK 
        WHERE b-WebStatus.CompanyCode = pc-CompanyCode
        BREAK BY b-WebStatus.CompletedStatus 
        BY ( IF b-WebStatus.DisplayOrder = 0 THEN 99999 ELSE b-Webstatus.DisplayOrder )
        BY b-WebStatus.description:
        IF FIRST-OF(b-WebStatus.CompletedStatus) THEN
        DO:
            IF b-WebStatus.CompletedStatus = FALSE 
                THEN ASSIGN pc-Codes = pc-Codes + "|AllOpen"
                    pc-name  = pc-name + '|* All Open'.
            ELSE ASSIGN pc-Codes = pc-Codes + "|AllClosed"
                    pc-name  = pc-name + '|* All Closed'.

        END.
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-WebStatus.StatusCode
            pc-name  = pc-name + '|&nbsp;&nbsp;&nbsp;' + 
               b-WebStatus.description.
    END.

END PROCEDURE.


PROCEDURE com-GetStatusIssue :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE INPUT  PARAMETER pc-companyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-WebStatus FOR WebStatus.

    ASSIGN 
        pc-Codes = ""
        pc-name  = "".


    FOR EACH b-WebStatus NO-LOCK 
        WHERE b-WebStatus.CompanyCode = pc-CompanyCode
        BREAK BY b-WebStatus.CompletedStatus 
        BY ( IF b-WebStatus.DisplayOrder = 0 THEN 99999 ELSE b-Webstatus.DisplayOrder )
        BY b-WebStatus.description:
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-WebStatus.StatusCode
            pc-name  = pc-name + '|' + 
               b-WebStatus.description + " (" + 
                ( IF b-WebStatus.CompletedStatus THEN "Closed" ELSE "Open" ) + 
            ")".
    END.

    ASSIGN
        pc-codes = substr(pc-codes,2)
        pc-name  = substr(pc-name,2).

END PROCEDURE.


PROCEDURE com-GetStatusIssueOpen :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE INPUT  PARAMETER pc-companyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-WebStatus FOR WebStatus.

    ASSIGN 
        pc-Codes = ""
        pc-name  = "".


    FOR EACH b-WebStatus NO-LOCK 
        WHERE b-WebStatus.CompanyCode = pc-CompanyCode
        AND b-WeBStatus.CompletedStatus = NO
        BREAK BY ( IF b-WebStatus.DisplayOrder = 0 THEN 99999 ELSE b-Webstatus.DisplayOrder )
        BY b-WebStatus.description:
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-WebStatus.StatusCode
            pc-name  = pc-name + '|' + 
               b-WebStatus.description + " (" + 
                ( IF b-WebStatus.CompletedStatus THEN "Closed" ELSE "Open" ) + 
            ")".
    END.

    ASSIGN
        pc-codes = substr(pc-codes,2)
        pc-name  = substr(pc-name,2).


END PROCEDURE.


PROCEDURE com-GetStatusOpenOnly :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-companyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes   AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-WebStatus FOR WebStatus.

    ASSIGN 
        pc-Codes = "AllOpen"
        pc-name  = "All Open".


    FOR EACH b-WebStatus NO-LOCK 
        WHERE b-WebStatus.CompanyCode = pc-CompanyCode
        AND b-webStatus.CompletedStatus = FALSE
        BREAK BY b-WebStatus.CompletedStatus 
        BY ( IF b-WebStatus.DisplayOrder = 0 THEN 99999 ELSE b-Webstatus.DisplayOrder )
        BY b-WebStatus.description:
                                                                  
        ASSIGN 
            pc-Codes = pc-Codes + '|' + 
               b-WebStatus.StatusCode
            pc-name  = pc-name + '|&nbsp;&nbsp;&nbsp;' + 
               b-WebStatus.description.
    END.
END PROCEDURE.


PROCEDURE com-GetTeamMembers:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-userid      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER webUStream FOR WebUSteam.
    DEFINE BUFFER webUx      FOR WebUSteam.
    DEFINE BUFFER b-user     FOR WebUser.
    
         
    FOR EACH WebUSteam NO-LOCK
        WHERE WebUSteam.LoginID = pc-UserID,
        EACH webux NO-LOCK
        WHERE webux.st-num = WebUSteam.st-num,
        EACH b-user NO-LOCK
        WHERE b-user.LoginID = webux.LoginID
        BREAK 
        BY b-user.LoginID:
        
        IF FIRST-OF(b-user.loginid) 
            THEN ASSIGN 
                pc-LoginID = TRIM(pc-LoginID + ',' + b-user.LoginID).
                
               
    END.
             
    ASSIGN 
        pc-LoginID = substr(pc-LoginId,2) no-error.
     
    


END PROCEDURE.

PROCEDURE com-GetTeams :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-buffer FOR steam.

    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode
        :

        IF pc-codes = ""
            THEN ASSIGN pc-Codes = STRING(b-buffer.st-num)
                pc-Desc  = b-buffer.Descr.
        ELSE ASSIGN pc-Codes = pc-Codes + '|' + 
               string(b-buffer.st-num)
                pc-Desc  = pc-Desc + '|' + 
               b-buffer.Descr.
    END.

END PROCEDURE.


PROCEDURE com-getTemplateSelect :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER  pc-CompanyCode     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Codes           AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Desc            AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-buffer FOR iemailtmp.

    FOR EACH b-buffer NO-LOCK 
        WHERE b-buffer.CompanyCode = pc-CompanyCode
        :
        IF pc-codes = ""
            THEN ASSIGN pc-Codes = b-buffer.tmpcode
                pc-Desc  = b-buffer.Descr.
        ELSE ASSIGN pc-Codes = pc-Codes + '|' + b-buffer.tmpCode
                pc-Desc  = pc-Desc + '|' + b-buffer.Descr.
    END.


END PROCEDURE.


PROCEDURE com-GetUserListByClass:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-class       AS CHARACTER NO-UNDO.
        
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.

    DEFINE VARIABLE icount AS INTEGER NO-UNDO.
    
    DEFINE BUFFER b-user FOR WebUser.

    FOR EACH b-user NO-LOCK 
        WHERE CAN-DO(pc-class,b-user.UserClass)
        AND b-user.CompanyCode = pc-CompanyCode
        BY b-user.name:
        icount = icount + 1.
        IF icount = 1 
            THEN ASSIGN
                pc-loginid = b-user.LoginID
                pc-name    = b-user.name.
        ELSE   
            ASSIGN 
                pc-LoginID = pc-LoginID + '|' + 
               b-user.LoginID
                pc-name    = pc-name + '|' + 
               b-user.Name.
    END.
    

END PROCEDURE.

PROCEDURE com-GetUserListForAccount:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
                Purpose:                                                                      
                Notes:                                                                        
        ------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER pc-CompanyCode AS CHARACTER NO-UNDO.
    DEFINE INPUT  PARAMETER pc-Account     AS CHARACTER NO-UNDO.
        
    DEFINE OUTPUT PARAMETER pc-LoginID     AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Name        AS CHARACTER NO-UNDO.

    DEFINE VARIABLE icount AS INTEGER NO-UNDO.
    
    DEFINE BUFFER b-user FOR WebUser.

    FOR EACH b-user NO-LOCK 
        WHERE b-user.CompanyCode = pc-CompanyCode
        AND b-user.AccountNumber = pc-Account
        BY b-user.name:
        icount = icount + 1.
        IF icount = 1 
            THEN ASSIGN
                pc-loginid = b-user.LoginID
                pc-name    = b-user.name.
        ELSE   
            ASSIGN 
                pc-LoginID = pc-LoginID + '|' + 
               b-user.LoginID
                pc-name    = pc-name + '|' + 
               b-user.Name.
    END.
    

END PROCEDURE.

PROCEDURE com-ResetDefaultStatus :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER     NO-UNDO.

    DEFINE BUFFER b-WebStatus FOR WebStatus.

    FOR EACH b-WebStatus
        WHERE b-WebStatus.CompanyCode = pc-CompanyCode
        AND b-WebStatus.DefaultCode EXCLUSIVE-LOCK:

        ASSIGN 
            b-WebStatus.DefaultCode = NO.
    END.
END PROCEDURE.


PROCEDURE com-SplitTime :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pi-time     AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER pi-hours   AS INTEGER      NO-UNDO.
    DEFINE OUTPUT PARAMETER pi-mins    AS INTEGER      NO-UNDO.

    DEFINE VARIABLE li-sec-hours AS INTEGER INITIAL 3600 NO-UNDO.
    DEFINE VARIABLE li-seconds   AS INTEGER NO-UNDO.
   
    ASSIGN 
        li-seconds = pi-time MOD li-sec-hours
        pi-mins    = TRUNCATE(li-seconds / 60,0).
        
    ASSIGN
        pi-time = pi-time - li-seconds.
        
    ASSIGN
        pi-hours = TRUNCATE(pi-time / li-sec-hours,0).

    
END PROCEDURE.


PROCEDURE com-StatusType :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER     pc-CompanyCode      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER    pc-open-status      AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER    pc-closed-status    AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-status FOR WebStatus.

    FOR EACH b-status NO-LOCK
        WHERE b-status.CompanyCode = pc-companyCode
        BY ( IF b-status.DisplayOrder = 0 THEN 99999 ELSE b-status.DisplayOrder ):
        IF b-status.CompletedStatus = FALSE 
            THEN ASSIGN pc-open-status = TRIM(pc-open-status + ',' + b-status.StatusCode).
        ELSE ASSIGN pc-closed-status = TRIM(pc-closed-status + ',' + b-status.StatusCode).
        
    END.

END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION com-AllowCustomerAccess RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER,
    pc-LoginID AS CHARACTER,
    pc-AccountNumber AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-user       FOR WebUser.
    DEFINE BUFFER b-ContAccess FOR ContAccess.
    DEFINE BUFFER webusteam    FOR webusteam.
    DEFINE BUFFER customer     FOR customer.
    DEFINE VARIABLE ll-Steam  AS LOG NO-UNDO.
    DEFINE VARIABLE ll-Access AS LOG NO-UNDO.

    
    ll-Steam = CAN-FIND(FIRST webUsteam WHERE webusteam.loginid =  pc-LoginID NO-LOCK).


    FIND b-user WHERE b-user.LoginID = pc-LoginID NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-user THEN RETURN FALSE.

    /*
    ***
    *** If internal member of a team then customer must be in one of his/her team
    ***
    */
    IF b-user.UserClass = "{&INTERNAL}" THEN 
    DO:
        IF NOT ll-Steam THEN RETURN TRUE.
        FIND customer WHERE customer.companyCode = pc-CompanyCode
            AND customer.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.
        /*
        ** Allow to every one
        */
        IF Customer.allowAllTeams  = TRUE THEN RETURN TRUE.
        IF customer.st-num = 0 THEN RETURN FALSE.
        ll-access = CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-LoginID
            AND webusteam.st-num = customer.st-num NO-LOCK).
        RETURN ll-access.
    END.

    IF b-user.UserClass = "{&CUSTOMER}" THEN
    DO:
        RETURN b-user.AccountNumber = pc-AccountNumber.
    END.

    RETURN CAN-FIND(FIRST b-ContAccess WHERE b-ContAccess.LoginID = pc-LoginID 
        AND b-ContAccess.AccountNumber = pc-AccountNumber NO-LOCK ).


 

END FUNCTION.


FUNCTION com-AllowTicketSupport RETURNS LOGICAL
    ( pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER customer FOR customer.

    FIND customer WHERE ROWID(customer) = pr-rowid NO-LOCK NO-ERROR.
    IF NOT AVAILABLE customer THEN RETURN FALSE.

    RETURN CAN-DO(REPLACE(lc-global-Allow-TicketSupport,"|",","),customer.SupportTicket).

END FUNCTION.


FUNCTION com-AreaName RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER ,
    pc-AreaCode    AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b1 FOR webissArea.


    FIND b1 WHERE b1.CompanyCode = pc-CompanyCode
        AND b1.AreaCode    = pc-AreaCode
        NO-LOCK NO-ERROR.


    RETURN IF AVAILABLE b1 THEN b1.DESCRIPTION ELSE "".

END FUNCTION.


FUNCTION com-AskTicket RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-AccountNumber      AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Customer FOR Customer.

    FIND Customer
        WHERE Customer.CompanyCode      = pc-companyCode
        AND Customer.AccountNumber    = pc-AccountNumber
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE Customer THEN RETURN FALSE.
    
    RETURN Customer.SupportTicket = "BOTH".

END FUNCTION.


FUNCTION com-AssignedToUser RETURNS INTEGER
    ( pc-CompanyCode AS CHARACTER,
    pc-LoginID     AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER WebStatus FOR WebStatus.


    FOR EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = pc-companyCode
        AND Issue.AssignTo = pc-LoginID
        ,
        FIRST WebStatus NO-LOCK
        WHERE WebStatus.companyCode = Issue.CompanyCode
        AND WebStatus.StatusCode  = Issue.StatusCode
        AND WebStatus.Completed   = FALSE
        :

        ASSIGN 
            li-return = li-return + 1.

    END.

    RETURN li-return.

END FUNCTION.



FUNCTION com-CanDelete RETURNS LOGICAL
    ( pc-loginid  AS CHARACTER,
    pc-table    AS CHARACTER,
    pr-rowid    AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webuser    FOR webuser.
    DEFINE BUFFER customer   FOR customer.
    DEFINE BUFFER custiv     FOR custiv.
    DEFINE BUFFER issue      FOR issue.
    DEFINE BUFFER ivClass    FOR ivClass.
    DEFINE BUFFER ivSub      FOR ivSub.
    DEFINE BUFFER ivField    FOR IvField.
    DEFINE BUFFER CustField  FOR CustField.
    DEFINE BUFFER webIssCat  FOR WebIssCat.
    DEFINE BUFFER webIssCont FOR WebIssCont.
    DEFINE BUFFER issAction  FOR issAction.
    DEFINE BUFFER issStatus  FOR issStatus.
    DEFINE BUFFER issNote    FOR IssNote.
    DEFINE BUFFER WebStatus  FOR WebStatus.
    DEFINE BUFFER webNote    FOR WebNote.
    DEFINE BUFFER webIssArea FOR WebIssArea.
    DEFINE BUFFER knbSection FOR knbSection.
    DEFINE BUFFER knbItem    FOR knbItem.
    DEFINE BUFFER webissagrp FOR webissagrp.
    DEFINE BUFFER steam      FOR steam.
    DEFINE BUFFER ptp_proj   FOR ptp_proj.
    DEFINE BUFFER ptp_phase  FOR ptp_phase.
    DEFINE BUFFER ptp_task   FOR ptp_task.
    DEFINE BUFFER acs_head   FOR acs_head.
    DEFINE BUFFER acs_line   FOR acs_line.
    DEFINE BUFFER acs_res    FOR acs_res.
         
    
 

    CASE pc-table:
        WHEN "webissagrp" THEN
            DO:
                FIND webissagrp WHERE ROWID(webissagrp) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webissagrp THEN RETURN FALSE.
                RETURN NOT 
                    CAN-FIND(FIRST WebIssArea 
                    WHERE webIssArea.CompanyCode = webissagrp.CompanyCode
                    AND webIssArea.GroupID = webissagrp.GroupId NO-LOCK).
            
            END.
        WHEN "webIssCat" THEN
            DO:
                FIND webIssCat WHERE ROWID(webIssCat) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webIssCat THEN RETURN FALSE.
                IF webIssCat.IsDefault THEN RETURN FALSE.
                RETURN NOT 
                    CAN-FIND(FIRST issue OF webissCat NO-LOCK).
            END.
        WHEN "webEQClass" THEN
            DO:
                RETURN TRUE.
            /* PH - Allow delete regardless 
            find ivClass where rowid(ivClass) = pr-rowid no-lock no-error.
            if not avail ivClass then return false.
            return not
                can-find(first ivSub of ivClass no-lock).
            */
            END.
        WHEN "webSubClass" THEN
            DO:
                RETURN TRUE.
            /*
            find ivSub where rowid(ivSub) = pr-rowid no-lock no-error.
            if not avail ivSub then return false.
            if can-find(first ivField where ivField.ivSubID = 
                               ivSub.ivSubID no-lock) then return false.

            if can-find(first Custiv where Custiv.ivSubID = 
                               ivSub.ivSubID no-lock) then return false.
            return true.
            */    
            END.
        WHEN "webInvField" THEN
            DO:
                FIND ivfield WHERE ROWID(ivfield) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE ivfield THEN RETURN FALSE.

                RETURN NOT 
                    CAN-FIND(FIRST Custfield 
                    WHERE CustField.ivFieldID = ivField.ivFieldID
                    NO-LOCK).


            END.
        WHEN "CUSTOMER" THEN
            DO:
                FIND customer WHERE ROWID(customer) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE customer THEN RETURN FALSE.
                IF CAN-FIND(FIRST issue
                    WHERE issue.CompanyCode     = customer.CompanyCode
                    AND issue.AccountNumber   = customer.AccountNumber
                    NO-LOCK) THEN RETURN FALSE.
                IF CAN-FIND(FIRST WebUser
                    WHERE WebUser.CompanyCode     = customer.CompanyCode
                    AND WebUser.AccountNumber   = customer.AccountNumber
                    NO-LOCK) THEN RETURN FALSE.
                RETURN TRUE.
            END.
        WHEN "customerequip" THEN
            DO:
                RETURN TRUE.
            END.
        WHEN "WEBUSER" THEN
            DO:
                FIND webuser WHERE ROWID(webuser) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webuser THEN RETURN FALSE.
                IF CAN-FIND(FIRST issue
                    WHERE issue.AssignTo = webuser.LoginID 
                    AND issue.companyCode = webuser.companyCode NO-LOCK) 
                    THEN RETURN FALSE.
                IF CAN-FIND(FIRST issue
                    WHERE issue.RaisedLoginID = webuser.LoginID 
                    AND issue.companyCode = webuser.companyCode NO-LOCK) 
                    THEN RETURN FALSE.
                IF CAN-FIND(FIRST issAction
                    WHERE issAction.AssignTo = webuser.LoginID NO-LOCK)
                    THEN RETURN FALSE.

                IF CAN-FIND(FIRST issAction
                    WHERE issAction.AssignBy = webuser.LoginID NO-LOCK)
                    THEN RETURN FALSE.
                IF CAN-FIND(FIRST issAction
                    WHERE issAction.CreatedBy = webuser.LoginID NO-LOCK)
                    THEN RETURN FALSE.
                RETURN TRUE.
            END.

        


        WHEN "webactivetype" THEN
            DO:
                RETURN TRUE.
            END.
            
        WHEN "webeqcontract" THEN
            DO:
                RETURN TRUE.
            END.

        WHEN "webattr" THEN
            DO:
                RETURN FALSE.
            END.
        WHEN "webmenu" THEN
            DO:
                RETURN FALSE.
            END.
        WHEN "webobject" THEN
            DO:
                RETURN FALSE.
            END.
        WHEN "webstatus" THEN
            DO:
                FIND webStatus WHERE ROWID(webStatus) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webStatus THEN RETURN FALSE.
                IF webStatus.DefaultCode THEN RETURN FALSE.

                IF CAN-FIND(FIRST IssStatus WHERE issStatus.CompanyCode = 
                    webStatus.CompanyCode
                    AND IssStatus.NewStatusCode = webStatus.StatusCode
                    NO-LOCK)
                    OR CAN-FIND(FIRST IssStatus WHERE issStatus.CompanyCode = 
                    webStatus.CompanyCode
                    AND IssStatus.OldStatusCode = webStatus.StatusCode
                    NO-LOCK) THEN RETURN FALSE.

                RETURN TRUE.


            END.
        WHEN "webnote" THEN
            DO:
                FIND webNote WHERE ROWID(webNote) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webNote THEN RETURN FALSE.
                IF webNote.NoteCode BEGINS "sys." THEN RETURN FALSE.

                IF CAN-FIND(FIRST issNote
                    WHERE issNote.CompanyCode = webNote.CompanyCode
                    AND issNote.NoteCode    = webNote.NoteCode NO-LOCK)
                    THEN RETURN FALSE.


                RETURN TRUE.

            END.
        WHEN "webIssArea" THEN
            DO:
                FIND webIssArea WHERE ROWID(webIssArea) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webIssArea THEN RETURN FALSE.
                IF CAN-FIND(FIRST issue
                    WHERE issue.CompanyCode = webIssArea.CompanyCode
                    AND issue.AreaCode    = webIssArea.AreaCode NO-LOCK)
                    THEN RETURN FALSE.

                RETURN TRUE.

            END.
        WHEN "webcomp" THEN
            DO:
                RETURN FALSE.
            END.
        WHEN "WEBACTION" THEN
            DO:
                FIND webAction WHERE ROWID(webAction) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE webAction THEN RETURN FALSE.
                IF CAN-FIND(FIRST issAction
                    WHERE issAction.ActionID = webAction.ActionID
                    NO-LOCK)
                    THEN RETURN FALSE.

                RETURN TRUE.
            END.
        WHEN "knbsection" THEN
            DO:
                FIND knbSection WHERE ROWID(knbSection) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE knbSection THEN RETURN FALSE.
                IF CAN-FIND(FIRST knbItem OF knbSection NO-LOCK)
                    THEN RETURN FALSE.

                RETURN TRUE.
            END.
        WHEN "knbitem" THEN
            DO:
                RETURN TRUE.
            END.
        WHEN "gentab" THEN
            DO:
                RETURN TRUE.
            END.
        WHEN 'iemailtmp' THEN
            DO:
                RETURN TRUE.
            END.
        WHEN "Steam" THEN
            DO:
                FIND steam WHERE ROWID(steam) = pr-rowid NO-LOCK NO-ERROR.

                RETURN NOT
                    CAN-FIND(FIRST customer 
                    WHERE customer.companyCode = steam.companyCode
                    AND customer.st-num = steam.st-num NO-LOCK).


            END.
        WHEN 'sla' THEN
            DO:
                RETURN FALSE.
            END.
        WHEN "webHoliday" THEN
            DO:
                RETURN TRUE.
            END.
        WHEN "webprojtask" THEN 
            RETURN TRUE.
        WHEN "webprojtemp" THEN 
            DO:
                FIND ptp_proj WHERE ROWID(ptp_proj) = pr-rowid NO-LOCK NO-ERROR.
                
                RETURN NOT CAN-FIND(FIRST ptp_phase WHERE ptp_phase.companyCode = ptp_proj.CompanyCode
                    AND ptp_phase.ProjCode = ptp_proj.projCode NO-LOCK).
                
                 
            END.
                
        WHEN "webprojphase" THEN 
            DO:
                FIND ptp_phase WHERE ROWID(ptp_phase) = pr-rowid NO-LOCK NO-ERROR.
                
                RETURN NOT CAN-FIND(FIRST ptp_task WHERE ptp_task.companyCode = ptp_phase.CompanyCode
                    AND ptp_task.ProjCode = ptp_phase.projCode 
                    AND ptp_task.PhaseID = ptp_phase.PhaseID NO-LOCK).
                
                 
            END.
            
        WHEN "webprojptask"
        OR 
        WHEN "webdashb" THEN 
            RETURN TRUE.
        WHEN 'Contract' THEN
            DO:
                FIND WebissCont WHERE ROWID(webissCont) =  pr-rowid NO-LOCK NO-ERROR.
            
                RETURN NOT CAN-FIND(FIRST  Issue 
                    WHERE Issue.CompanyCode = WebissCont.CompanyCode
                    AND Issue.ContractType =  WebissCont.ContractCode 
                    AND Issue.AccountNumber = WebissCont.Customer NO-LOCK ).
                  
            END.
            WHEN "webacs" THEN
            DO:
                FIND acs_head WHERE ROWID(acs_head) = pr-rowid NO-LOCK NO-ERROR.
                IF NOT AVAILABLE acs_head THEN RETURN FALSE.
                IF CAN-FIND(FIRST acs_line OF acs_head NO-LOCK)
                    THEN RETURN FALSE.

                RETURN TRUE.
            END.
        WHEN "webacsquestion" THEN
        DO:
            FIND acs_line WHERE ROWID(acs_line)  = pr-rowid NO-LOCK NO-ERROR.
            IF NOT AVAILABLE acs_line THEN RETURN FALSE.
            IF CAN-FIND(FIRST acs_res WHERE acs_res.acs_line_id = acs_line.acs_line_id NO-LOCK)
            THEN RETURN FALSE.
            RETURN TRUE.
        END.
        OTHERWISE
        DO:
            MESSAGE "com-CanDelete invalid table for " pc-table.
            RETURN FALSE.
        END.
    END CASE.
 
    RETURN TRUE.

END FUNCTION.


FUNCTION com-CatName RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER,
    pc-Code AS CHARACTER
    ) :


    
    DEFINE BUFFER b-table FOR WebissCat.

    FIND b-table NO-LOCK 
        WHERE b-table.CompanyCode = pc-CompanyCode
        AND b-table.CatCode = pc-Code NO-ERROR.

       
    RETURN IF AVAILABLE  b-table THEN b-table.DESCRIPTION ELSE pc-code.




END FUNCTION.


FUNCTION com-CheckSystemSetup RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    /*
    def var lc-System-Note-Code                 as char
initial 'SYS.EMAILCUST,SYS.ASSIGN,SYS.SLA'  no-undo.
def var lc-System-Note-Desc                 as char
initial 'System - Customer Emailed,System - Issue Assignment,Sys - SLA Assigned'
no-undo.
*/
    DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.
  
    DEFINE BUFFER WebNote    FOR WebNote.
    DEFINE BUFFER KnbSection FOR knbSection.

    IF pc-companyCode = "" THEN RETURN TRUE.

    DO TRANSACTION:
        DO li-loop = 1 TO NUM-ENTRIES(lc-System-Note-Code):
            IF CAN-FIND(WebNote WHERE WebNote.CompanyCode = pc-companyCode 
                AND WebNote.NoteCode = entry(li-loop,lc-System-Note-Code) NO-LOCK)
                THEN NEXT.
            CREATE WebNote.
            ASSIGN 
                WebNote.CompanyCode     = pc-companyCode
                WebNote.NoteCode        = ENTRY(li-loop,lc-System-Note-Code)
                WebNote.description     = ENTRY(li-loop,lc-System-Note-Desc)
                WebNote.CustomerCanView = FALSE.
            RELEASE WebNote.
        END.


    END.
END FUNCTION.


FUNCTION com-ContractDescription RETURNS CHARACTER 
    ( pc-companyCode AS CHARACTER ,
    pc-ContractType AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	
    DEFINE BUFFER ContractType FOR ContractType.
    
    FIND ContractType 
        WHERE  ContractType.CompanyCode = pc-companyCode
        AND ContractType.ContractNumber = pc-ContractType NO-LOCK NO-ERROR.
             
    RETURN IF AVAILABLE ContractType THEN ContractType.Description ELSE "".             

		
END FUNCTION.

FUNCTION com-ConvertJSDate RETURNS DATE 
    (  pc-date AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE ld-date  AS DATE    NO-UNDO.
    DEFINE VARIABLE li-month AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-day   AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-year  AS INTEGER NO-UNDO.
    
    pc-date = REPLACE(TRIM(pc-date)," ",",").
       
    ASSIGN
        li-day   = INTEGER(ENTRY(3,pc-date))
        li-year  = INTEGER(ENTRY(4,pc-date))
        li-month = LOOKUP(ENTRY(2,pc-date),"Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec")
        .   
    ASSIGN
        ld-date = DATE(li-month,li-day,li-year) NO-ERROR.
        
    RETURN ld-date.
        


		
END FUNCTION.

FUNCTION com-CookieDate RETURNS DATE
    ( pc-user AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webuser FOR webuser.
    DEFINE BUFFER company FOR company.

    FIND webuser WHERE webuser.LoginID = pc-user NO-LOCK NO-ERROR.
    IF NOT AVAILABLE webuser THEN RETURN ?.
    IF WebUser.disabletimeout THEN RETURN ?.
    
    
    FIND company WHERE company.CompanyCode = webuser.CompanyCode 
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE company THEN RETURN ?.
    
    RETURN IF company.timeout = 0 THEN ? ELSE TODAY.
        
 

END FUNCTION.


FUNCTION com-CookieTime RETURNS INTEGER
    ( pc-user AS CHARACTER ) :
    /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webuser FOR webuser.
    DEFINE BUFFER company FOR company.

    FIND webuser WHERE webuser.LoginID = pc-user NO-LOCK NO-ERROR.
    IF NOT AVAILABLE webuser THEN RETURN ?.
    IF WebUser.disabletimeout THEN RETURN ?.
    
    
    FIND company WHERE company.CompanyCode = webuser.CompanyCode 
        NO-LOCK NO-ERROR.
    IF NOT AVAILABLE company THEN RETURN ?.
    /*
    message "time * 60 = " string(time,"hh:mm:SS") " to = " company.timeout 
                    " rev = " string(time + ( company.timeout * 60 ),"hh:mm:SS").
    */
    RETURN IF company.timeout = 0 THEN ? ELSE TIME + ( company.timeout * 60 ).


END FUNCTION.


FUNCTION com-CustomerAvailableSLA RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER,
    pc-AccountNumber AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-char   AS CHARACTER NO-UNDO.

    DEFINE BUFFER slahead FOR slahead.


    DO li-loop = 1 TO 2:
        ASSIGN
            lc-char = IF li-loop = 1 THEN pc-AccountNumber ELSE "".
        IF li-loop = 1 AND lc-char = "" THEN NEXT.

        FOR EACH slahead NO-LOCK
            WHERE slahead.companycode = pc-CompanyCode
            AND slahead.AccountNumber = lc-char
            BY slahead.SLACode:

            IF lc-return = ""
                THEN lc-return = STRING(ROWID(slahead)).
            ELSE lc-return = lc-return + "|" + string(ROWID(slahead)).
        END.

    END.
    

    RETURN lc-return.

END FUNCTION.


FUNCTION com-CustomerName RETURNS CHARACTER
    ( pc-Company AS CHARACTER,
    pc-Account  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

   
    DEFINE BUFFER b-Customer FOR Customer.

    
    FIND b-Customer
        WHERE b-Customer.CompanyCode = pc-Company
        AND b-Customer.AccountNumber = pc-Account
        NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE b-Customer THEN b-Customer.name ELSE "".


END FUNCTION.


FUNCTION com-CustomerOpenIssues RETURNS INTEGER
    ( pc-CompanyCode AS CHARACTER,
    pc-accountNumber AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER WebStatus FOR WebStatus.


    FOR EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = pc-companyCode
        AND Issue.AccountNumber = pc-AccountNumber
        ,
        FIRST WebStatus NO-LOCK
        WHERE WebStatus.companyCode = Issue.CompanyCode
        AND WebStatus.StatusCode  = Issue.StatusCode
        AND WebStatus.Completed   = FALSE
        :

        ASSIGN 
            li-return = li-return + 1.

    END.

    RETURN li-return.

END FUNCTION.


FUNCTION com-DayName RETURNS CHARACTER 
    ( pd-Date AS DATE ,
    pc-Format AS CHARACTER):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE lc-day AS CHARACTER INITIAL "Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday" NO-UNDO.
    



    
    RETURN TRIM(substr(ENTRY(WEEKDAY(pd-date),lc-day),1,( IF pc-format = "S" THEN 3 ELSE 10))).
    
		
END FUNCTION.

FUNCTION com-DayOfWeek RETURNS INTEGER 
    (INPUT pd-Date AS DATE,
    INPUT pi-base AS INTEGER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE iDay    AS INTEGER   NO-UNDO.
    
    DEFINE VARIABLE DayList AS CHARACTER NO-UNDO.
    IF pi-base = 1 THEN DayList = "1,2,3,4,5,6,7".
    ELSE DayList = "7,1,2,3,4,5,6". /* Based on wk Starting on a monday */

    iDay = WEEKDAY(pd-Date).
    iDay = INTEGER(ENTRY(iDay,DayList)).
    RETURN  iDay.
    

		
END FUNCTION.

FUNCTION com-DecodeLookup RETURNS CHARACTER
    ( pc-code AS CHARACTER,
    pc-code-list AS CHARACTER,
    pc-code-display AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-index AS INTEGER NO-UNDO.

    ASSIGN
        li-index = LOOKUP(pc-code,pc-code-list,"|").

    RETURN
        IF li-index = 0 THEN pc-code
        ELSE ENTRY(li-index,pc-code-display,"|").

END FUNCTION.


FUNCTION com-DescribeTicket RETURNS CHARACTER
    ( pc-TxnType AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    CASE pc-txntype:
        WHEN "TCK" THEN 
            RETURN "Ticket".
        WHEN "ADJ" THEN 
            RETURN "Adjustment".
        WHEN "ACT" THEN 
            RETURN "Activity".
    END CASE.
      
    RETURN pc-txntype.

END FUNCTION.



FUNCTION com-GenTabDesc RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER,
    pc-GType AS CHARACTER,
    pc-Code AS CHARACTER
    ) :


    
    DEFINE BUFFER b-GenTab FOR GenTab.

    FIND b-GenTab NO-LOCK 
        WHERE b-GenTab.CompanyCode = pc-CompanyCode
        AND b-GenTab.gType = pc-gType
        AND b-gentab.gCode = pc-Code NO-ERROR.

       
    RETURN IF AVAILABLE  b-gentab THEN b-GenTab.Descr ELSE "Missing".




END FUNCTION.


FUNCTION com-GetActivityByType RETURNS CHARACTER 
	    ( pc-companyCode AS CHARACTER ,
	      pi-TypeID      AS INTEGER  ):
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	

		DEFINE BUFFER WebActType FOR WebActType.
		
		FOR FIRST WebActType NO-LOCK
		  WHERE WebActType.CompanyCode = pc-companyCode
		    AND WebActType.TypeID = pi-TypeID:
		      RETURN WebActType.ActivityType.
		END.
		RETURN "".

		
END FUNCTION.

FUNCTION com-GetDefaultCategory RETURNS CHARACTER
    ( pc-CompanyCode AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-table FOR WebIssCat.


    FIND FIRST b-table
        WHERE b-table.CompanyCode = pc-CompanyCode
        AND b-table.isDefault   = TRUE
        NO-LOCK NO-ERROR.

    RETURN
        IF AVAILABLE b-table THEN b-table.CatCode ELSE "".


END FUNCTION.


FUNCTION com-GetHelpDeskEmail RETURNS CHARACTER 
    ( 
    pc-mode        AS CHARACTER,
    pc-companyCode AS CHARACTER,
    pc-accountNumber AS CHARACTER ):

    DEFINE BUFFER Company  FOR Company.
    DEFINE BUFFER steam    FOR steam.
    DEFINE BUFFER Customer FOR Customer.
    DEFINE VARIABLE lc-Email AS CHARACTER NO-UNDO.
    
    FIND Customer WHERE Customer.CompanyCode = pc-companyCode
                    AND Customer.AccountNumber = pc-accountNumber
                    NO-LOCK NO-ERROR.
    IF AVAILABLE Customer AND Customer.st-num > 0 THEN
    DO:
        FIND steam WHERE steam.CompanyCode = pc-companyCode
                     AND steam.st-num = Customer.st-num NO-LOCK NO-ERROR.
        IF AVAILABLE steam
        THEN lc-email = steam.supportemail.                
    END.
       
    IF lc-email  = ""
    OR lc-email  = ? THEN
    DO:
        FIND Company WHERE Company.CompanyCode = pc-companyCode NO-LOCK NO-ERROR.
        lc-email = Company.HelpDeskEmail.
    END.                 
    
    
    RETURN lc-email.
    
		
END FUNCTION.

FUNCTION com-GetTicketBalance RETURNS INTEGER  
	    ( pc-companyCode AS CHARACTER ,
	      pc-accountNumber   AS CHARACTER  ):
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	

        DEFINE BUFFER b-query    FOR Ticket.
        
		DEFINE VARIABLE li-bal AS INTEGER  NO-UNDO.
        FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode   = pc-CompanyCode
            AND b-query.AccountNumber = pc-AccountNumber
        :
         
            IF b-query.IssActivityID <> 0 THEN
            DO:
                IF com-IsActivityChargeable(b-query.IssActivityID) = FALSE THEN NEXT.
                
            END.
            
            
            li-bal = li-bal + b-query.Amount.
            
        END.
        
		RETURN li-bal.
		


		
END FUNCTION.

FUNCTION com-GetTicketBalanceWithAdmin RETURNS INTEGER 
	   ( pc-companyCode AS CHARACTER ,
         pc-accountNumber   AS CHARACTER  ):
/*------------------------------------------------------------------------------
        Purpose:                                                                      
        Notes:                                                                        
------------------------------------------------------------------------------*/    

        DEFINE BUFFER b-query    FOR Ticket.
        
        DEFINE VARIABLE li-bal AS INTEGER  NO-UNDO.
        FOR EACH b-query NO-LOCK
            WHERE b-query.CompanyCode   = pc-CompanyCode
            AND b-query.AccountNumber = pc-AccountNumber
        :
         
                        
            
            li-bal = li-bal + b-query.Amount.
            
        END.
        
        RETURN li-bal.


		
END FUNCTION.

FUNCTION com-HasSchedule RETURNS INTEGER 
    ( pc-companyCode AS CHARACTER ,
    pc-LoginId     AS CHARACTER ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE li-count AS INTEGER NO-UNDO.
        
    DEFINE BUFFER eSched FOR eSched.
        
    FOR EACH eSched NO-LOCK
        WHERE eSched.CompanyCode = pc-CompanyCode
        AND eSched.AssignTo = pc-LoginID
        AND eSched.ActionDate >= ( TODAY - li-global-sched-days-back )
        :
        ASSIGN
            li-count = li-count + 1. 
    END.
        
    RETURN li-count.


		
END FUNCTION.

FUNCTION com-Initialise RETURNS LOGICAL
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.


    DO li-loop = 0 TO 23:

        IF li-loop = 0 THEN
        DO:
            ASSIGN 
                lc-global-hour-display = "00"
                lc-global-hour-code    = "00".
            NEXT.
        END.
        ASSIGN 
            lc-global-hour-code    = lc-global-hour-code + "|" + 
                                  string(li-loop)
            lc-global-hour-display = lc-global-hour-display + "|" + 
                                         string(li-loop).

       
                
    END.

    DO li-loop = 0 TO 55 BY 5:
        IF li-loop = 0
            THEN ASSIGN lc-global-min-code    = STRING(li-loop)
                lc-global-min-display = STRING(li-loop,"99").
        ELSE ASSIGN lc-global-min-code    = lc-global-min-code + "|" + string(li-loop)
                lc-global-min-display = lc-global-min-display + "|" + string(li-loop,"99").
    END.
    
    DO li-loop = 0 TO 59 BY 1:
        IF li-loop = 0
            THEN ASSIGN lc-global-min-code    = STRING(li-loop)
                lc-global-min-display = STRING(li-loop,"99").
        ELSE ASSIGN lc-global-min-code    = lc-global-min-code + "|" + string(li-loop)
                lc-global-min-display = lc-global-min-display + "|" + string(li-loop,"99").
    END.


    RETURN TRUE.

END FUNCTION.


FUNCTION com-InitialSetup RETURNS LOGICAL
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webuser FOR webuser.

    DEFINE VARIABLE lc-temp AS CHARACTER NO-UNDO.
    
    ASSIGN 
        lc-global-user = pc-LoginID.

    /*
    ASSIGN
        lc-global-secure = DYNAMIC-FUNCTION("sysec-EncodeValue","GlobalSecure",TODAY,"GlobalSecure",lc-global-user).
    */
    ASSIGN
        lc-global-secure = "".
        
    FIND webuser WHERE webuser.LoginID = pc-LoginID NO-LOCK NO-ERROR.

    IF AVAILABLE webuser THEN 
    DO:
        /*lc-temp = STRING(ROWID(webuser)) + ":" + WebUser.LoginID.
        
        ASSIGN
         lc-global-secure = DYNAMIC-FUNCTION("sysec-EncodeValue","GlobalSecure",TODAY,"GlobalSecure",lc-temp).
        */
        ASSIGN
            lc-global-secure = STRING(ROWID(webuser)).
        ASSIGN 
            lc-global-company = webuser.CompanyCode.
        DYNAMIC-FUNCTION('com-CheckSystemSetup':U,lc-global-company).
    END.


    RETURN TRUE.

END FUNCTION.


FUNCTION com-InternalTime RETURNS INTEGER
    ( pi-hours AS INTEGER,
    pi-mins  AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/


    RETURN ( ( pi-hours * 60 ) * 60 ) + ( pi-mins * 60 ).

END FUNCTION.


FUNCTION com-IsActivityChargeable RETURNS LOGICAL 
	    ( pf-ActID     AS DECIMAL ):
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	

    DEFINE BUFFER IssActivity  FOR IssActivity.
    DEFINE BUFFER WebActType   FOR WebActType.		 
    FIND issActivity WHERE issActivity.issActivityID = 
                pf-ActID NO-LOCK NO-ERROR.
    IF AVAILABLE issActivity AND issActivity.ActivityType <> "" THEN
    FOR FIRST WebActType NO-LOCK
        WHERE WebActType.CompanyCode = issActivity.CompanyCode
          AND WebActType.ActivityType = issActivity.ActivityType
          AND WebActType.isAdminTime = TRUE:
              
        RETURN FALSE.
              
    END.
          
	RETURN TRUE.
		


		
END FUNCTION.

FUNCTION com-IsContractor RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-LoginID      AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Webuser FOR WebUser.

    FIND WebUser
        WHERE WebUser.LoginID = pc-LoginID
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE WebUser THEN RETURN FALSE.
    
    RETURN WebUser.UserClass = "contract".

END FUNCTION.


FUNCTION com-IsCustomer RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-LoginID      AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Webuser FOR WebUser.

    FIND WebUser
        WHERE WebUser.LoginID = pc-LoginID
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE WebUser THEN RETURN FALSE.
    
    RETURN WebUser.UserClass = "customer".

END FUNCTION.


FUNCTION com-IssueActionsStatus RETURNS INTEGER
    ( pc-companyCode AS CHARACTER,
    pi-issue   AS INTEGER,
    pc-status  AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER IssAction FOR IssAction.


    FOR EACH IssAction NO-LOCK
        WHERE IssAction.companycode = pc-companyCode
        AND issAction.issuenumber = pi-issue 
        AND IssAction.ActionStatus = pc-status:

        ASSIGN 
            li-return = li-return + 1.

    END.

    RETURN li-return.
    

  
END FUNCTION.


FUNCTION com-IssueStatusAlert RETURNS LOGICAL
    ( pc-CompanyCode AS CHARACTER,
    pc-CreateSource AS CHARACTER,
    pc-StatusCode   AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER WebStatus FOR WebStatus.

    IF pc-CreateSource <> "EMAIL" THEN RETURN TRUE.

    FIND WebStatus
        WHERE WebStatus.CompanyCode = pc-CompanyCode
        AND WebStatus.StatusCode  = pc-StatusCode NO-LOCK NO-ERROR.
    IF NOT AVAILABLE WebStatus THEN RETURN TRUE.

    RETURN NOT WebStatus.IgnoreEmail.
    

END FUNCTION.


FUNCTION com-IsSuperUser RETURNS LOGICAL
    ( pc-LoginID      AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Webuser FOR WebUser.

    FIND WebUser
        WHERE WebUser.LoginID = pc-LoginID
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE WebUser THEN RETURN FALSE.
    
    RETURN WebUser.UserClass = "INTERNAL" AND WebUser.SuperUser.

END FUNCTION.


FUNCTION com-LimitCustomerName RETURNS CHARACTER 
    ( pc-name AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    RETURN TRIM(substr(pc-name,1,25)).

		
END FUNCTION.

FUNCTION com-MMDDYYYY RETURNS CHARACTER 
    (  pd-date AS DATE ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-return = STRING(MONTH(pd-date),"99") + "/" +
                        string(DAY(pd-date),"99") + "/" +
                        string(YEAR(pd-date),"9999").
                            
    RETURN lc-return.


		
END FUNCTION.

FUNCTION com-Money RETURNS CHARACTER 
    (  pf-amount AS DECIMAL ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    RETURN TRIM(STRING(pf-amount,">>>,>>>,>>9.99-")).
		
END FUNCTION.

FUNCTION com-MonthBegin RETURNS DATE
    ( pd-date AS DATE) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN pd-date - ( DAY(pd-date) ) + 1.

END FUNCTION.


FUNCTION com-MonthEnd RETURNS DATE
    ( pd-date AS DATE ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN ((DATE(MONTH(pd-date),28,YEAR(pd-date)) + 4) - 
        DAY(DATE(MONTH(pd-date),28,YEAR(pd-date)) + 4)).

END FUNCTION.


FUNCTION com-NearestTimeUnit RETURNS INTEGER
    ( pi-time AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

  
    DEFINE VARIABLE lc-time AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-mins AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-rem  AS INTEGER   NO-UNDO.


    ASSIGN
        lc-time = STRING(pi-time,"hh:mm").


    ASSIGN
        li-mins = int(substr(lc-time,4,2)).


    IF li-mins = 0 THEN RETURN 0.

    ASSIGN
        li-rem = li-mins MOD 5.

    RETURN ( li-mins - ( li-mins MOD 5 ) ). 

END FUNCTION.


FUNCTION com-NumberOfActions RETURNS INTEGER
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER IssAction FOR IssAction.


    FOR EACH IssAction NO-LOCK
        WHERE IssAction.AssignTo = pc-LoginID
        AND IssAction.ActionStatus = "OPEN":

        ASSIGN 
            li-return = li-return + 1.

    END.

    RETURN li-return.
    

END FUNCTION.


FUNCTION com-NumberOfAlerts RETURNS INTEGER
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER IssAlert FOR IssAlert.


    FOR EACH IssAlert NO-LOCK
        WHERE IssAlert.LoginID = pc-LoginID
        :

        ASSIGN 
            li-return = li-return + 1.

    END.

    RETURN li-return.

END FUNCTION.


FUNCTION com-NumberOfEmails RETURNS INTEGER
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.
    DEFINE BUFFER webuser  FOR webuser.
    DEFINE BUFFER e        FOR EmailH.
    DEFINE BUFFER Customer FOR Customer.
    DEFINE VARIABLE ll-steam AS LOGICAL NO-UNDO.
    
    FIND webuser WHERE webuser.LoginID = pc-loginID NO-LOCK NO-ERROR.

    ll-Steam =
        DYNAMIC-FUNCTION("com-isTeamMember", webuser.CompanyCode,pc-loginID,?).
        
    IF AVAILABLE webuser
        AND webuser.userclass = "INTERNAL" AND webuser.SuperUser THEN
    DO:
        FOR EACH e WHERE e.companyCode = webuser.CompanyCode NO-LOCK:
            IF e.AccountNumber <> "" THEN
            DO:
                FIND Customer WHERE Customer.CompanyCode = webuser.CompanyCode
                    AND Customer.AccountNumber = e.AccountNumber
                    NO-LOCK NO-ERROR.
                IF ll-steam THEN
                DO:
                    IF Customer.st-num = 0 
                        THEN NEXT.
                    ELSE
                        IF NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-loginID
                            AND webusteam.st-num = customer.st-num NO-LOCK) 
                
                            THEN NEXT.
                
                END.    
            END.
            
            ASSIGN
                li-return = li-return + 1.
        END.
    END.
    
    RETURN li-return.
    


END FUNCTION.


FUNCTION com-NumberOfInventoryWarnings RETURNS INTEGER
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return   AS INTEGER NO-UNDO.
    DEFINE VARIABLE ld-WarnFrom AS DATE    NO-UNDO.
    DEFINE VARIABLE ld-DueDate  AS DATE    NO-UNDO.
    
    DEFINE BUFFER webUser   FOR WebUser.
    DEFINE BUFFER ivField   FOR ivField.
    DEFINE BUFFER ivSub     FOR ivSub.
    DEFINE BUFFER custField FOR custField.

    FIND webuser WHERE webuser.LoginID = pc-loginID NO-LOCK NO-ERROR.

    IF DYNAMIC-FUNCTION('com-IsSuperUser':U,pc-loginid) THEN
        FOR EACH ivField NO-LOCK
            WHERE ivField.dType = "date"
            AND ivField.dWarning > 0,
            FIRST ivSub OF ivField NO-LOCK:

            IF ivSub.CompanyCode <> webuser.CompanyCode THEN NEXT.

            ASSIGN
                ld-WarnFrom = TODAY - ivField.dWarning.

            FOR EACH CustField NO-LOCK
                WHERE CustField.ivFieldID = ivField.ivFieldID:

            
                IF custField.FieldData = "" 
                    OR custField.FieldData = ? THEN NEXT.

                ASSIGN
                    ld-DueDate = DATE(custfield.FieldData) no-error.
                IF ERROR-STATUS:ERROR 
                    OR ld-DueDate = ? THEN NEXT.

                /* 
                *** Waring base on
                *** Today in within range of Inventory Date - Warning Period AND
                *** Inventory Date is today or in the future
                *** If the inventory date has passed then no more warnings
                ***
                */
                IF TODAY >= ld-DueDate - ivField.dWarning
                    AND ld-DueDate >= TODAY  
                    THEN ASSIGN li-return = li-return + 1.
            END.
            


        END.

    RETURN li-return.

END FUNCTION.


FUNCTION com-NumberOfOpenActions RETURNS INTEGER
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER IssAction FOR IssAction.
    DEFINE BUFFER WebUser   FOR WebUser.
    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER customer  FOR Customer.
    DEFINE VARIABLE ll-steam AS LOGICAL NO-UNDO.
        


    FIND webuser WHERE webuser.LoginID = pc-loginid NO-LOCK NO-ERROR.

    IF NOT AVAILABLE webuser THEN RETURN 0.

    ll-Steam =
        DYNAMIC-FUNCTION("com-isTeamMember", webuser.CompanyCode,pc-loginID,?).
        

    IF webUser.SuperUser THEN
        FOR EACH IssAction NO-LOCK
            WHERE IssAction.CompanyCode = webuser.CompanyCode
            AND IssAction.ActionStatus = "OPEN":
    
            IF ll-steam THEN
            DO:
                FIND Issue OF issaction NO-LOCK NO-ERROR.
                FIND Customer OF Issue NO-LOCK NO-ERROR.
                IF Customer.st-num = 0 
                    THEN NEXT.
                ELSE
                    IF NOT CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-loginID
                        AND webusteam.st-num = customer.st-num NO-LOCK) THEN NEXT.
                            
            
            END.
            ASSIGN 
                li-return = li-return + 1.

        END.

    RETURN li-return.
    

END FUNCTION.


FUNCTION com-NumberUnAssigned RETURNS INTEGER
    ( pc-CompanyCode AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-return AS INTEGER NO-UNDO.

    DEFINE BUFFER Issue     FOR Issue.
    DEFINE BUFFER WebStatus FOR WebStatus.


    FOR EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = pc-companyCode
        AND Issue.AssignTo = ""
        ,
        FIRST WebStatus NO-LOCK
        WHERE WebStatus.companyCode = Issue.CompanyCode
        AND WebStatus.StatusCode  = Issue.StatusCode
        AND WebStatus.Completed   = FALSE
        :

        ASSIGN 
            li-return = li-return + 1.

    END.

    RETURN li-return.

END FUNCTION.


FUNCTION com-QuickView RETURNS LOGICAL
    ( pc-LoginID  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-WebUser  FOR webUser.
    DEFINE BUFFER b-Customer FOR Customer.

    FIND b-WebUser
        WHERE b-WebUser.LoginID = pc-LoginID NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-webuser
        OR b-webuser.UserClass = "{&CUSTOMER}" THEN RETURN FALSE.

    IF b-webuser.UserClass = "{&CONTRACT}" THEN RETURN TRUE.
    
    IF b-webuser.SuperUser THEN RETURN TRUE.

    RETURN b-webuser.QuickView.


END FUNCTION.


FUNCTION com-ReadParam RETURNS CHARACTER 
    ( pc-loginid   AS CHARACTER ,
    pc-key AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE BUFFER bup FOR userParam.
           
    FIND bup WHERE bup.loginid = pc-loginid 
        AND bup.pkey = pc-key
        NO-LOCK NO-ERROR.
        
    RETURN IF AVAILABLE bup THEN bup.pData ELSE ?.

		
END FUNCTION.

FUNCTION com-RequirePasswordChange RETURNS LOGICAL
    ( pc-user AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webUser FOR WebUser.
    DEFINE BUFFER company FOR company.
  

    FIND webUser
        WHERE webUser.loginid = pc-user EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

    IF LOCKED webuser
        OR NOT AVAILABLE webuser THEN RETURN FALSE.

    
    FIND company 
        WHERE company.CompanyCode = webuser.CompanyCode NO-LOCK NO-ERROR.
    IF NOT AVAILABLE company THEN RETURN FALSE.

    IF company.PasswordExpire = 0 THEN RETURN FALSE.

    
    IF webuser.LastPasswordChange = ?
        THEN ASSIGN webUser.LastPasswordChange = TODAY.


    RETURN ( webuser.LastPasswordChange + company.PasswordExpire ) <=
        TODAY.
    

END FUNCTION.


FUNCTION com-SLADescription RETURNS CHARACTER
    ( pf-SLAID AS DECIMAL ) :
    /*------------------------------------------------------------------------------
     Purpose:  
       Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER slahead FOR slahead.

    FIND slahead
        WHERE slahead.SLAID = pf-SLAID
        NO-LOCK NO-ERROR.


    RETURN IF AVAILABLE slahead
        THEN slahead.description ELSE "".

END FUNCTION.


FUNCTION com-StatusTrackIssue RETURNS LOGICAL
    ( pc-companycode AS CHARACTER,
    pc-StatusCode  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webStatus FOR webStatus.

    FIND webStatus
        WHERE webStatus.companycode = pc-companycode
        AND webStatus.StatusCode  = pc-statuscode
        NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE webstatus THEN webstatus.CustomerTrack ELSE FALSE.

END FUNCTION.


FUNCTION com-StringReturn RETURNS CHARACTER
    ( pc-orig AS CHARACTER,
    pc-add AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF pc-add = ""
        OR pc-add = ? THEN RETURN pc-orig.

    IF pc-orig = "" THEN RETURN pc-add.

    RETURN pc-orig + "~n" + pc-add.

END FUNCTION.


FUNCTION com-SystemLog RETURNS ROWID
    ( pc-ActType AS CHARACTER,
    pc-LoginID AS CHARACTER,
    pc-AttrData AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lrSysAct AS ROWID NO-UNDO.
    
    DEFINE BUFFER SysAct FOR SysAct.

    DO TRANSACTION:
        CREATE SysAct.
        ASSIGN
            SysAct.ActDate  = TODAY
            SysAct.ActTime  = TIME
            SysAct.LoginID  = pc-LoginID
            SysAct.ActType  = pc-ActType
            SysAct.AttrData = pc-AttrData.
        lrSysAct = ROWID(SysAct).
        
        RELEASE SysAct.
    END.


    RETURN lrSysAct.

END FUNCTION.


FUNCTION com-TicketOnly RETURNS LOGICAL
    ( pc-companyCode  AS CHARACTER,
    pc-AccountNumber      AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Customer FOR Customer.

    FIND Customer
        WHERE Customer.CompanyCode      = pc-companyCode
        AND Customer.AccountNumber    = pc-AccountNumber
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE Customer THEN RETURN FALSE.
    
    RETURN Customer.SupportTicket = "YES".

END FUNCTION.


FUNCTION com-TimeReturn RETURNS CHARACTER
    ( pc-Type AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    CASE pc-Type:
        WHEN "HOUR" 
        THEN      
            RETURN lc-global-hour-code + "^" + lc-global-hour-display.
        OTHERWISE 
        RETURN lc-global-min-code + "^" + lc-global-min-display.
    END CASE.
END FUNCTION.


FUNCTION com-TimeToString RETURNS CHARACTER
    ( pi-time AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-sec-hours AS INTEGER INITIAL 3600 NO-UNDO.
    DEFINE VARIABLE li-seconds   AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-mins      AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-hours     AS INTEGER NO-UNDO.
    DEFINE VARIABLE ll-neg       AS LOG     NO-UNDO.

    IF pi-time < 0 THEN ASSIGN ll-neg  = TRUE
            pi-time = pi-time * -1.

    ASSIGN 
        li-seconds = pi-time MOD li-sec-hours
        li-mins    = TRUNCATE(li-seconds / 60,0).
        
    ASSIGN
        pi-time = pi-time - li-seconds.
        
    ASSIGN
        li-hours = TRUNCATE(pi-time / li-sec-hours,0).

    RETURN TRIM( ( IF ll-neg THEN "-" ELSE "" ) + string(li-hours) + ":" + string(li-mins,'99')).
    
END FUNCTION.


FUNCTION com-UserName RETURNS CHARACTER
    ( pc-LoginID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webuser FOR webuser.

    CASE pc-loginID:
        WHEN "SLA.ALERT" THEN 
            RETURN "SLA Processing".
    END CASE.

    FIND webuser
        WHERE webuser.LoginID = pc-LoginID
        NO-LOCK NO-ERROR.


    RETURN IF AVAILABLE webuser
        THEN TRIM(webuser.forename + " " + webuser.surname)
        ELSE pc-LoginID.


END FUNCTION.


FUNCTION com-UsersCompany RETURNS CHARACTER
    ( pc-LoginID  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-WebUser  FOR webUser.
    DEFINE BUFFER b-Customer FOR Customer.

    FIND b-WebUser
        WHERE b-WebUser.LoginID = pc-LoginID NO-LOCK NO-ERROR.

    IF NOT AVAILABLE b-webuser
        OR b-webuser.UserClass <> "{&CUSTOMER}" THEN RETURN "".

    FIND b-Customer
        WHERE b-Customer.CompanyCode = b-WebUser.CompanyCode
        AND b-Customer.AccountNumber = b-WebUser.AccountNumber
        NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE b-Customer THEN b-Customer.name ELSE "".


END FUNCTION.


FUNCTION com-UserTrackIssue RETURNS LOGICAL
    ( pc-LoginID AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER webUser FOR webUser.

    FIND webUser
        WHERE webUser.LoginID = pc-LoginID
        NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE webUser AND webUser.email <> "" 
        THEN webUser.CustomerTrack ELSE FALSE.

END FUNCTION.


FUNCTION com-WriteParam RETURNS ROWID 
    ( pc-LoginID AS CHARACTER,
    pc-Key     AS CHARACTER,
    pc-data    AS CHARACTER ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE lr-row AS ROWID NO-UNDO.
    
    DEFINE BUFFER bup FOR userParam.
    
    DO TRANSACTION:
        
        FIND bup WHERE bup.loginid = pc-loginid 
            AND bup.pkey = pc-key
            EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE bup THEN
        DO:
            CREATE bup.
            ASSIGN 
                bup.loginid = pc-loginid
                bup.pkey    = pc-key.
                   
        END.       
        ASSIGN
            lr-row    = ROWID(bup)
            bup.pdata = pc-data.
            
                
    END.
    
    
    RETURN lr-row.


		
END FUNCTION.

FUNCTION com-WriteQueryInfo RETURNS LOGICAL
    ( hQuery AS HANDLE ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE ix AS INTEGER NO-UNDO.
    DEFINE VARIABLE jx AS INTEGER NO-UNDO.

    REPEAT ix = 1 TO hQuery:NUM-BUFFERS:  
        jx = LOOKUP("WHOLE-INDEX", hQuery:INDEX-INFORMATION(ix)).  
        IF jx > 0 
            THEN    MESSAGE "inefficient index" ENTRY(jx + 1, hQuery:INDEX-INFORMATION(ix)).  
        ELSE     MESSAGE "bracketed index use of" hQuery:INDEX-INFORMATION(ix).
    END.


    RETURN TRUE.


END FUNCTION.

FUNCTION com-isTeamMember RETURNS LOGICAL
    (pc-companyCode AS CHARACTER,
    pc-loginid AS CHARACTER,
    pi-st-num AS INTEGER  ):
         
     
    DEFINE BUFFER webUStream FOR WebUSteam.
    IF pi-st-num = ?
        OR pi-st-num = 0
        THEN RETURN CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-loginid NO-LOCK).
    ELSE RETURN CAN-FIND(FIRST webUsteam WHERE webusteam.loginid = pc-loginid 
            AND WebUSteam.st-num = pi-st-num NO-LOCK).
          
     
END FUNCTION.



