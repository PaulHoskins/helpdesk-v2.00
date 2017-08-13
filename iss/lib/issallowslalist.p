/***********************************************************************

    Program:        iss/lib/issallowslalist.p
    
    Purpose:        Issue - What SLA's are selectable
    
    Notes:
    
    
    When        Who         What
    13/08/2017  phoski      Initial
 
***********************************************************************/


{lib/common.i}

DEFINE INPUT PARAMETER pr-issue     AS ROWID        NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid   AS CHARACTER    NO-UNDO.
DEFINE OUTPUT PARAMETER pc-sla-rows AS CHARACTER    NO-UNDO.

DEFINE BUFFER Issue   FOR Issue.
DEFINE BUFFER WebUser FOR WebUser.
DEFINE BUFFER slahead FOR slahead.

DEFINE VARIABLE li-next     AS INTEGER      NO-UNDO.

FIND Issue WHERE ROWID(issue) = pr-issue NO-LOCK NO-ERROR.

ASSIGN 
    lc-global-company = Issue.CompanyCode.

FIND WebUser WHERE WebUser.LoginID = pc-LoginID NO-LOCK NO-ERROR.

IF WebUser.SuperUser 
OR Issue.link-SLAID = 0 THEN
DO:
    ASSIGN
        pc-sla-rows = com-CustomerAvailableSLA(lc-global-company,issue.AccountNumber).
    RETURN.
END.  

FIND slahead WHERE slahead.SLAID = Issue.link-SLAID NO-LOCK NO-ERROR.
IF NOT AVAILABLE slahead OR slahead.seq-no = 0 THEN
DO:
    ASSIGN
        pc-sla-rows = com-CustomerAvailableSLA(lc-global-company,issue.AccountNumber).
    RETURN.
END.
ASSIGN pc-sla-rows = STRING(ROWID(slahead))
       li-next = slahead.seq-no + 1.
       
FIND slahead WHERE slahead.CompanyCode = Issue.companyCode
               AND slahead.seq-no = li-next NO-LOCK NO-ERROR.
               


IF AVAILABLE slahead THEN
DO:
    ASSIGN pc-sla-rows = pc-sla-rows + "|" + STRING(ROWID(slahead)).
END.

 
 
        