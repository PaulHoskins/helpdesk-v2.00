/***********************************************************************

    Program:        batch/issuearchive.p
    
    Purpose:        Issue Archive Process
    
    Notes:
    
    
    When        Who         What
    21/07/2017  phoski      Initial
       
***********************************************************************/



DEFINE VARIABLE ld-date    AS DATE    FORMAT '99/99/9999' NO-UNDO.
DEFINE VARIABLE ll-Archive AS LOGICAL NO-UNDO.
DEFINE VARIABLE ld-status  AS DATE    FORMAT '99/99/9999' NO-UNDO.
DEFINE VARIABLE li-count   AS INT     NO-UNDO.

DEFINE BUFFER company   FOR Company.
DEFINE BUFFER Issue     FOR Issue.
DEFINE BUFFER b-issue   FOR Issue.  
DEFINE BUFFER WebStatus FOR WebStatus.
DEFINE BUFFER IssStatus FOR IssStatus.

DEFINE STREAM rp.
   
OUTPUT STREAM rp TO c:\temp\issueArchive.log unbuffered.
 
FOR EACH Company NO-LOCK
    WHERE Company.ArchiveDays > 0 WITH FRAME flog DOWN STREAM-IO WIDTH 255:

    ASSIGN
        ld-date           = TODAY -  Company.ArchiveDays.
    
   FOR EACH Issue NO-LOCK
        WHERE Issue.CompanyCode = company.companyCode
        ,
        FIRST WebStatus NO-LOCK OF issue
          
        WITH FRAME flog DOWN STREAM-IO WIDTH 255:
            
        ASSIGN 
            ll-Archive = Issue.archived
            ld-status  = ?
            li-count   = li-count + 1.
        
        IF WebStatus.CompletedStatus = FALSE THEN ll-archive = FALSE.
        ELSE
        DO:
            ASSIGN
                ld-status = Issue.CreateDate.
            FOR EACH IssStatus NO-LOCK 
                WHERE IssStatus.CompanyCode = Issue.companyCode
                  AND IssStatus.IssueNumber = Issue.IssueNumber
                  :
                IF IssStatus.NewStatusCode <> Issue.StatusCode
                OR IssStatus.ChangeDate = ? THEN NEXT.
            
                ld-status = max(ld-Status,IssStatus.ChangeDate).
                
            END.    
            ll-Archive = ld-status < ld-date.
             
          
        END.
        
        
        DISPLAY STREAM rp 
            NOW
            li-count COLUMN-LABEL '#'
            Issue.CompanyCode Issue.IssueNumber Issue.StatusCode  WebStatus.CompletedStatus 
            Issue.CreateDate ld-status COLUMN-LABEL 'Close Date'
            ld-date COLUMN-LABEL 'Arch Date'
            Issue.archived COLUMN-LABEL 'Current Arch'
            ll-archive  COLUMN-LABEL 'Set Arch'
            .
        DOWN STREAM rp.
        
        IF Issue.archived <> ll-archive THEN
        DO:
            FIND b-issue WHERE ROWID(b-issue) = rowid(issue) EXCLUSIVE-LOCK.
            ASSIGN
                b-issue.archived = ll-archive.
        END.
                             
    END.   
    
END.

OUTPUT STREAM rp CLOSE.



/* **********************  Internal Procedures  *********************** */

