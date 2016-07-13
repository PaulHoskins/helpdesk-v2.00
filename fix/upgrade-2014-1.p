


OUTPUT TO value(SESSION:TEMP-DIR + "/upgrade-2014-1.log").

RUN ipIssue.
RUN ipLastActivity.

OUTPUT CLOSE.

PROCEDURE ipIssue:

    DEF BUFFER issue        FOR issue.
    def buffer b-query      for issAction.
    def buffer IssActivity  for IssActivity.
  
    DEF VAR lc-dt           AS CHAR NO-UNDO.

    FOR EACH issue EXCLUSIVE-LOCK WITH DOWN STREAM-IO:

        ASSIGN 
            issue.tlight = 99
            issue.slaTrip = ?
            issue.SlaAmber = ?.


        IF issue.SlaDate[2] <> ? THEN
        DO:
        
            lc-dt = STRING(Issue.SLADate[2],"99/99/9999") + " " 
            + STRING(Issue.SLATime[2],"HH:MM").
            issue.SlaTrip = DATETIME(lc-dt).
        END.


    END.
END.

PROCEDURE ipLastActivity:

    DEF BUFFER issue        FOR issue.
    def buffer b-query      for issAction.
    def buffer IssActivity  for IssActivity.
    
    DEF VAR ldt LIKE issue.lastactivity NO-UNDO.
    DEF VAR LC  AS CHAR FORMAT 'x(20)'.
    
    FOR EACH issue EXCLUSIVE-LOCK WITH DOWN STREAM-IO:

        ldt = ?.
        LC = "".
   
        for each b-query no-lock
           where b-query.CompanyCode = issue.companyCode
             and b-query.IssueNumber = issue.IssueNumber
           , each IssActivity no-lock
               where issActivity.CompanyCode = b-query.CompanyCode
                 and issActivity.IssueNumber = b-query.IssueNumber
                 and IssActivity.IssActionId = b-query.IssActionID
                 AND IssActivity.StartDate <> ?
        
                 by IssActivity.StartDate DESC
                 by IssActivity.StartTime DESC
        
           :
            /*
            ldt = DATETIME(IssActivity.StartDate,STRING(IssActivity.StartTime,"HH:MM").
            */

            LC = STRING(IssActivity.StartDate,"99/99/9999") + " " + STRING(IssActivity.StartTime,"HH:MM").
            ldt = DATETIME(LC).
        
            LEAVE.
        END.

        DISP issue.companyCode issue.IssueNumber ldt LC.

        issue.LastActivity = ldt.


    END.


END.
