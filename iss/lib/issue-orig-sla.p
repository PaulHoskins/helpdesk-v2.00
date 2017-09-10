/***********************************************************************

    Program:        iss/lib/issue-orig-sla.p
    
    Purpose:        Issue - setup original sla details
    
    Notes:
    
    
    When        Who         What
    19/08/2017  phoski      Initial
 
***********************************************************************/


{lib/common.i}

DEFINE INPUT PARAMETER pr-issue     AS ROWID        NO-UNDO.


DEFINE BUFFER Issue   FOR Issue.



FIND Issue WHERE ROWID(issue) = pr-issue EXCLUSIVE-LOCK NO-ERROR.

ASSIGN 
    lc-global-company = Issue.CompanyCode.
 

IF Issue.link-SLAID <> 0 AND Issue.orig-SLAID = 0 THEN
DO:
    RUN UpdateOriginalSLA.
END.
   

/* **********************  Internal Procedures  *********************** */

PROCEDURE UpdateOriginalSLA:
/*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop  AS INTEGER      NO-UNDO.

    

    ASSIGN
        Issue.orig-SLAID = Issue.link-SLAID
        Issue.orig-SLAAmber = Issue.SLAAmber
        Issue.orig-SLAStatus = Issue.SLAStatus
        Issue.orig-SLATrip = Issue.SLATrip
        Issue.orig-tLight = Issue.tLight
        Issue.orig-SLALevel = Issue.SLALevel
        .
        
   DO li-loop = 1 TO EXTENT(Issue.SLADate):
       
       ASSIGN 
            Issue.orig-SLADate[li-loop] = Issue.SLADate[li-loop]
            Issue.orig-SLATime[li-loop] = Issue.SLAtime[li-loop]
            .
   END.

END PROCEDURE.
