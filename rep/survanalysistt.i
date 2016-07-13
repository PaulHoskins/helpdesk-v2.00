/***********************************************************************

    Program:        rep/survanalysistt.i
    
    Purpose:        Survey Analysis TT
    
    Notes:
    
    
    When        Who         What
    
    30/06/2016  phoski      Initial

***********************************************************************/

DEFINE TEMP-TABLE tt-san NO-UNDO
    FIELD rSeq         AS INTEGER 
    FIELD eng-loginid  AS CHARACTER
    FIELD eName        AS CHARACTER 
    FIELD cu-loginid   AS CHARACTER
    FIELD cuname       AS CHARACTER 
    FIELD issueNumber  AS INTEGER
    FIELD iDesc        AS CHARACTER 
    FIELD issDate      AS DATE
    FIELD rq_id        AS CHARACTER
    FIELD cName        AS CHARACTER 
    FIELD iValue       AS INTEGER
    FIELD rq_created   AS DATETIME
    FIELD rq_completed AS DATETIME
   
    INDEX rq_id rq_id.
    
    .
    
    
