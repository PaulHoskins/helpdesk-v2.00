/***********************************************************************

    Program:        batch/customersurvey.p
    
    Purpose:        Sends customer surveys for closed issued
    
    Notes:
    
    
    When        Who         What
    25/06/2016  phoski      Initial
    
***********************************************************************/
{lib/common.i}
{iss/issue.i}

DEFINE STREAM slog.
DEFINE VARIABLE ld-date     AS DATE EXTENT 2    NO-UNDO.
DEFINE VARIABLE lc-msg     AS CHARACTER NO-UNDO.



ASSIGN
    ld-date[1] = TODAY - 1
    ld-date[2] = ld-date[1]
    .

OUTPUT STREAM slog TO "c:\temp\surveylog.txt" PAGED.



FOR EACH Company NO-LOCK
    WHERE Company.isc_acs_code > "",
    FIRST acs_head NO-LOCK
    WHERE acs_head.CompanyCode = Company.CompanyCode
    AND acs_head.acs_code = Company.isc_acs_code
    :
              
    FOR EACH IssStatus NO-LOCK
        WHERE IssStatus.CompanyCode = Company.companycode  
        AND IssStatus.ChangeDate >= ld-date[1]
        AND IssStatus.ChangeDate <= ld-date[2]
        BREAK BY IssStatus.IssueNumber
        BY IssStatus.ChangeDate
        BY IssStatus.ChangeTime
        WITH FRAME flog DOWN STREAM-IO WIDTH 255:
              
        IF NOT LAST-OF(IssStatus.IssueNumber) THEN NEXT.
        
        FIND WebStatus WHERE WebStatus.CompanyCode = Company.CompanyCode
            AND WebStatus.StatusCode = IssStatus.NewStatusCode 
            AND WebStatus.CompletedStatus = TRUE NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebStatus THEN NEXT.
        
        FIND Issue 
            WHERE Issue.CompanyCode = Company.CompanyCode
            AND Issue.IssueNumber = IssStatus.IssueNumber
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE Issue THEN NEXT.
              
        
        IF islib-IssueIsOpen(ROWID(issue)) THEN NEXT.
        
        FIND Customer OF Issue NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE Customer
            OR Customer.iss_survey = FALSE THEN NEXT.
        
        FIND WebUser WHERE WebUser.LoginID = Issue.RaisedLoginID NO-LOCK NO-ERROR.
        IF NOT AVAILABLE WebUser
            OR WebUser.iss_survey = FALSE THEN NEXT.
        
        RUN lib/createSurveyRequest.p 
            ( Issue.CompanyCode , acs_head.acs_code ,
            Issue.IssueNumber, "SYSTEM" , webuser.Email,NO,OUTPUT lc-msg).
                  
        DISPLAY STREAM slog
            Issue.CompanyCode
            Issue.IssueNumber
            Customer.Name
            IssStatus.ChangeDate
            IssStatus.NewStatusCode
            WebUser.LoginID 
            WebUser.email
            .
        DOWN STREAM slog.
            
                          
              
    END.              
                           
              

END.


OUTPUT STREAM slog CLOSE.


