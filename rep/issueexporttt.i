/***********************************************************************

    Program:        rep/issueexporttt.i
    
    Purpose:        Issue Export Temp Table Def
    
    Notes:
    
    
    When        Who         What
    
    08/06/2017  phoski      Initial
   ***********************************************************************/

DEFINE TEMP-TABLE tt-ilog NO-UNDO
    FIELD issueNumber        LIKE issue.IssueNumber
    FIELD AccountNumber      LIKE issue.AccountNumber
    FIELD BriefDescription   LIKE issue.BriefDescription
    FIELD iType              AS CHARACTER LABEL 'Issue Type'
    FIELD RaisedLoginID      LIKE issue.RaisedLoginID
    FIELD SLALevel           AS INTEGER   LABEL 'SLA Level'
    FIELD SLADesc            AS CHARACTER LABEL 'SLA'
    FIELD CreateDate         LIKE issue.CreateDate LABEL 'Date Raised'
    FIELD CreateTime         LIKE issue.CreateTime LABEL 'Time Raised'
    FIELD CompDate           LIKE issue.CompDate LABEL 'Date Raised'
    FIELD CompTime           LIKE issue.CompTime LABEL 'Time Raised'
    FIELD ActDuration        AS CHARACTER LABEL 'Activity Duration'
    FIELD SLAAchieved        AS LOG       LABEL 'SLA Achieved'
    FIELD SLAComment         AS CHARACTER LABEL 'SLA Comment'
    FIELD ClosedBy           AS CHARACTER LABEL 'Closed By'
    FIELD isClosed           AS LOG       LABEL 'Is Closed'
    FIELD iActDuration       AS INTEGER 
    FIELD fActDate           AS DATE      LABEL 'First Acivity Date'
    FIELD fActTime           AS INTEGER   LABEL 'First Activity Time'
    FIELD contractType       LIKE Issue.contractType
    FIELD iLongDesc          LIKE Issue.LongDescription
    FIELD iBillable          LIKE Issue.Billable
    FIELD cArea              AS CHARACTER 
    FIELD cStatus            AS CHARACTER 
    FIELD cAssignTo          AS CHARACTER 
    FIELD cActionType        AS CHARACTER 
    FIELD ActionDate         AS DATE
    FIELD cActionAssignTo    AS CHARACTER 
    FIELD ActionNote         AS CHARACTER 
    FIELD ActionStatus       AS CHARACTER 
    FIELD ActionCustomerView AS LOGICAL
    FIELD ActivityType       AS CHARACTER 
    FIELD actDate            AS DATE
    FIELD StartDate          AS DATE
    
    FIELD actDesc           AS CHARACTER 
    FIELD ActivityBy        AS CHARACTER 
    FIELD siteVisit         AS LOGICAL 
    FIELD Duration          AS CHARACTER 
    FIELD iDuration         AS INTEGER 
    FIELD ActBillable       AS LOGICAL
    FIELD isAdmin           AS LOGICAL
    FIELD ActTypeDesc       AS CHARACTER
    
    INDEX MainKey IS PRIMARY 
    AccountNumber IssueNumber       
    .




/* ********************  Preprocessor Definitions  ******************** */






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */



