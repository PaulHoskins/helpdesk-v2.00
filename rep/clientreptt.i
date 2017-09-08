/***********************************************************************

    Program:        rep/clientreptt.i
    
    Purpose:        Client Rep Temp Table Def
    
    Notes:
    
    
    When        Who         What
    
    05/08/2017  phoski      Initial
 
***********************************************************************/

DEFINE TEMP-TABLE tt-ilog NO-UNDO
    FIELD period              AS INTEGER
    FIELD issueNumber         LIKE issue.IssueNumber
    FIELD AccountNumber       LIKE issue.AccountNumber
    FIELD BriefDescription    LIKE issue.BriefDescription
    FIELD iType               AS CHARACTER LABEL 'Issue Type'
    FIELD RaisedLoginID       LIKE issue.RaisedLoginID
    FIELD AreaCode            LIKE issue.AreaCode LABEL 'System'
    FIELD SLALevel            AS INTEGER   LABEL 'SLA Level'
    FIELD SLADesc             AS CHARACTER LABEL 'SLA'
    FIELD CreateDate          LIKE issue.CreateDate LABEL 'Date Raised'
    FIELD CreateTime          LIKE issue.CreateTime LABEL 'Time Raised'
    FIELD CompDate            LIKE issue.CompDate LABEL 'Date Raised'
    FIELD CompTime            LIKE issue.CompTime LABEL 'Time Raised'
    FIELD ActDuration         AS CHARACTER LABEL 'Activity Duration'
    FIELD SLAAchieved         AS LOG       LABEL 'SLA Achieved'
    FIELD SLAComment          AS CHARACTER LABEL 'SLA Comment'
    FIELD ClosedBy            AS CHARACTER LABEL 'Closed By'
    FIELD isClosed            AS LOG       LABEL 'Is Closed'
    FIELD iActDuration        AS INTEGER 
    FIELD fActDate            AS DATE      LABEL 'First Acivity Date'
    FIELD fActTime            AS INTEGER   LABEL 'First Activity Time'
    
    FIELD orig-SLALevel       AS INTEGER   LABEL 'SLA Level'
    FIELD orig-SLADesc        AS CHARACTER LABEL 'SLA'
    FIELD orig-SLAAchieved    AS LOGICAL   LABEL 'SLA Achieved'
    FIELD SLAOverrideAchieved AS LOGICAL
    FIELD AssignTo            LIKE Issue.AssignTo
    FIELD latestComment       AS CHARACTER 
    FIELD catcode             LIKE Issue.catcode
    
     
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



