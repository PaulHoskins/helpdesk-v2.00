/***********************************************************************

    Program:        rep/survanalysis-build.p
    
    Purpose:        Survey Analysis Report - Build
    
    Notes:
    
    
    When        Who         What
    
    30/06/2016  phoski      Initial

***********************************************************************/

{rep/survanalysistt.i}

DEFINE INPUT PARAMETER pc-companycode          AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-acs_code             AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pi-acs_line_id          AS INTEGER           NO-UNDO.
DEFINE INPUT PARAMETER pc-FromAccountNumber    AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-ToAccountNumber      AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pl-allcust              AS LOG               NO-UNDO.
DEFINE INPUT PARAMETER pd-FromDate             AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pd-ToDate               AS DATE              NO-UNDO.
DEFINE INPUT PARAMETER pc-FromEng              AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-ToEng                AS CHARACTER         NO-UNDO.
DEFINE INPUT PARAMETER pc-sort                 AS CHARACTER         NO-UNDO.

DEFINE OUTPUT PARAMETER table              FOR tt-san.

{lib/common.i}

RUN ip-Build.


/* **********************  Internal Procedures  *********************** */

PROCEDURE ip-Build:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-seq AS INTEGER NO-UNDO.
   
    FOR EACH acs_rq NO-LOCK
        WHERE acs_rq.CompanyCode = pc-CompanyCode
        AND acs_rq.rq_status = 1 /* Completed */
        AND acs_rq.acs_code = pc-acs_code 
        AND acs_rq.eng-loginid >=  pc-fromEng 
        AND acs_rq.eng-loginid <=  pc-ToEng 
        ,
        EACH issue NO-LOCK 
        WHERE issue.CompanyCode = pc-CompanyCode
        AND Issue.IssueNumber = acs_rq.IssueNumber  
        AND issue.issueDate >= pd-FromDate 
        AND issue.issueDate <= pd-ToDate 
        AND issue.accountNumber >=  pc-FromAccountNumber 
        AND issue.accountNumber <= pc-ToAccountNumber 
        ,
        EACH acs_res NO-LOCK
        WHERE acs_res.rq_id = acs_rq.rq_id
        :
             
        IF pi-acs_line_id <> 0 THEN
        DO:
            IF acs_res.acs_line_id <> pi-acs_line_id THEN NEXT.
        END.
        
        FIND acs_line WHERE acs_line.acs_line_id = acs_res.acs_line_id NO-LOCK NO-ERROR.
        IF NOT AVAILABLE  acs_line THEN NEXT.
        IF NOT acs_line.qType BEGINS "RANGE"  THEN NEXT.
        
        
        MESSAGE "crt = " Issue.IssueNumber.
        
        FIND Customer OF Issue NO-LOCK NO-ERROR.
        IF NOT AVAILABLE Customer THEN NEXT.
        
        IF NOT pl-allCust AND NOT Customer.IsActive THEN NEXT.
        
        FIND FIRST tt-san WHERE tt-san.rq_id =  acs_rq.rq_id EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-san
            THEN CREATE tt-san.
        ASSIGN
            tt-san.rSeq        = ?
            tt-san.Eng-Loginid = acs_rq.Eng-LoginID
            
            tt-san.issueNumber = Issue.IssueNumber
            tt-san.issDate     = Issue.IssueDate
            tt-san.rq_id       = acs_rq.rq_id
            tt-san.cName       = Customer.Name
            tt-san.eName       = com-UserName(tt-san.eng-loginid)
            tt-san.iDesc       = Issue.BriefDescription
            tt-san.cu-loginid  = Issue.RaisedLoginID
            tt-san.cuName      = com-UserName(tt-san.cu-loginid)
            tt-san.rq_completed = acs_rq.rq_completed
            tt-san.rq_created  = acs_rq.rq_created
            
            .
             
        ASSIGN
            tt-san.ivalue =  tt-san.ivalue + INTEGER(acs_res.rvalue) NO-ERROR.
            
        
             
    END.
           
    /* TSHI|TSLO|ENG|CUST","Total Score (High to Low)|Total Score (Low To High)|Engineer|Customer */
 
    IF pc-Sort = "CUST" THEN
        FOR EACH tt-san EXCLUSIVE-LOCK
            BY tt-san.cName
            BY tt-san.ivalue:
            ASSIGN
                li-seq = li-seq + 1.
            ASSIGN
                tt-san.rSeq = li-seq.         
        END.
  
    IF pc-sort = "ENG" THEN
        FOR EACH tt-san EXCLUSIVE-LOCK
            BY tt-san.eng-loginid
            BY tt-san.ivalue:
            ASSIGN
                li-seq = li-seq + 1.
            ASSIGN
                tt-san.rSeq = li-seq.         
        END.
  
    IF pc-sort = "TSHI" THEN
        FOR EACH tt-san EXCLUSIVE-LOCK
            BY tt-san.ivalue DESC
            BY tt-san.eng-Loginid:
                    
            ASSIGN
                li-seq = li-seq + 1.
            ASSIGN
                tt-san.rSeq = li-seq.         
        END.  
            
    IF pc-sort = "TSLO" THEN
        FOR EACH tt-san EXCLUSIVE-LOCK
            BY tt-san.ivalue 
            BY tt-san.eng-Loginid:
                    
            ASSIGN
                li-seq = li-seq + 1.
            ASSIGN
                tt-san.rSeq = li-seq.         
        END.              
       
   
        

END PROCEDURE.
