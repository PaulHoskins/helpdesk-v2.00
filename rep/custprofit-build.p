/***********************************************************************

    Program:        rep/custprofit-build.p
    
    Purpose:        Customer Profit Report Build Data
    
    Notes:
    
    
    When        Who         What
    15/06/2015  phoski      Initial
    26/11/2015  phoski      Contract Totals only for 'current' and
                            customer status
    15/03/2016  phoski      Contract Status    
    02/07/2016  phoski      Exclude Admin                    
   
***********************************************************************/
CREATE WIDGET-POOL.

{rep/custprofit-tt.i}

DEFINE INPUT PARAMETER pc-CompanyCode   AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pd-DateFrom      AS DATE         NO-UNDO.
DEFINE INPUT PARAMETER pd-DateTo        AS DATE         NO-UNDO.
DEFINE INPUT PARAMETER pc-CustomerList  AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pc-CustStatus    AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pc-ContStatus    AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER pl-ExcludeAdmin  AS LOGICAL      NO-UNDO.


DEFINE OUTPUT PARAMETER table           FOR tt-custp.


DEFINE VARIABLE ld-YearStart AS DATE NO-UNDO.

DEFINE BUFFER iact         FOR issActivity.
DEFINE BUFFER issuse       FOR Issue.
DEFINE BUFFER WebUser      FOR WebUser.
DEFINE BUFFER WebissCont   FOR WebissCont.
DEFINE BUFFER ContractRate FOR ContractRate.
DEFINE BUFFER ContractType FOR ContractType.

{lib/common.i}
    

ASSIGN
    ld-YearStart = DATE(1,1,YEAR(pd-DateFrom)).
    

    
RUN ip-Build.

FUNCTION fnConvertToHours RETURNS INTEGER 
    (pi-time AS INTEGER) FORWARD.

/* **********************  Internal Procedures  *********************** */

PROCEDURE ip-Build:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lf-cvalue       AS DECIMAL                      NO-UNDO.
    DEFINE VARIABLE lf-gp           LIKE ContractType.GrossProfit   NO-UNDO.
    DEFINE VARIABLE li-loop         AS INTEGER                      NO-UNDO.
    DEFINE VARIABLE lc-temp         AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE li-Count        AS INTEGER                      NO-UNDO.
    DEFINE VARIABLE ll-Default      AS LOGICAL                      NO-UNDO.
    DEFINE VARIABLE lf-col1         AS DECIMAL                      NO-UNDO.
    DEFINE VARIABLE li-pass         AS INTEGER                      NO-UNDO.
    DEFINE VARIABLE lc-code         AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE lc-account      AS CHARACTER                    NO-UNDO.
    DEFINE VARIABLE ld-cbegin       AS DATE                         NO-UNDO.
    DEFINE VARIABLE ld-cend         AS DATE                         NO-UNDO.
    
    DEFINE BUFFER bContractRate     FOR  ContractRate. 
        
  
    /*
    ***
    *** Populate all tt with all contracts regardless of activity
    ***
    */
   
    FOR EACH Customer NO-LOCK
        WHERE Customer.CompanyCode = pc-companyCode,
        EACH WebissCont NO-LOCK
        WHERE WebissCont.CompanyCode = customer.CompanyCode
        AND WebissCont.Customer = customer.AccountNumber
        :
               
        IF pc-CustomerList <> "ALL" THEN
        DO:
            IF LOOKUP(Customer.AccountNumber,pc-CustomerList) = 0 THEN NEXT.
        END.
        IF pc-CustStatus <> "ALL" THEN
        DO:
            IF pc-CustStatus = "ACT" AND Customer.IsActive = FALSE THEN NEXT.
            IF pc-CustStatus = "INACT" AND Customer.IsActive = TRUE THEN NEXT.
            
        END.
        
        IF pc-ContStatus <> "ALL" THEN
        DO:
            IF pc-ContStatus = "ACT" AND webissCont.ConActive = FALSE THEN NEXT.
            IF pc-ContStatus = "INACT" AND webissCont.ConActive = TRUE THEN NEXT.
            
        END.
        
         
        FIND FIRST ContractType 
            WHERE ContractType.CompanyCode = customer.CompanyCode
            AND ContractType.ContractNumber =  WebissCont.ContractCode 
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE ContractType THEN 
        DO:
            NEXT.
        END.
          
        ASSIGN 
            lf-gp = ContractType.GrossProfit
            lf-cvalue = 0
            ld-cbegin = ?
            ld-cend = ?.
          
                   
        ASSIGN  
            ll-default = WebissCont.DefCon. 
        
        FIND FIRST ContractRate 
            WHERE ContractRate.CompanyCode = webIssCont.CompanyCode
            AND ContractRate.Customer =  webIssCont.Customer
            AND ContractRate.ContractCode = WebissCont.ContractCode
            NO-LOCK NO-ERROR.
        IF AVAILABLE ContractRate THEN
            FOR EACH ContractRate NO-LOCK
                WHERE ContractRate.CompanyCode = webIssCont.CompanyCode
                AND ContractRate.Customer =  webIssCont.Customer
                AND ContractRate.ContractCode = WebissCont.ContractCode 
                BY ContractRate.cBegin:    
            
                ASSIGN 
                    lf-cvalue = ContractRate.cValue
                    ld-cbegin = ContractRate.cBegin
                    ld-cend = pd-DateTo.
                
                FIND FIRST bContractRate 
                    WHERE bContractRate.CompanyCode = webIssCont.CompanyCode
                    AND bContractRate.Customer =  webIssCont.Customer
                    AND bContractRate.ContractCode = WebissCont.ContractCode
                    AND bContractRate.cBegin > ld-cbegin
                    NO-LOCK NO-ERROR.
                IF AVAILABLE bContractRate
                    THEN ASSIGN ld-cEnd = bContractRate.cBegin - 1.
            
            
                CREATE tt-custt.  
                ASSIGN 
                    tt-custt.AccountNumber = Customer.AccountNumber 
                    tt-custt.ContractCode = WebissCont.ContractCode
                    tt-custt.ConActive = WebissCont.conActive
                    tt-custt.cbegin = ld-cbegin
                    tt-custt.cvalue = lf-cvalue
                    tt-custt.cend = ld-cend
                    tt-custt.GrossProfit% = lf-gp
                    tt-custt.isDefault = ll-default
                    .
              
            END.
        ELSE
        DO:
            CREATE tt-custt.  
            ASSIGN 
                tt-custt.AccountNumber = Customer.AccountNumber 
                tt-custt.ContractCode = WebissCont.ContractCode
                tt-custt.ConActive = WebissCont.conActive
                tt-custt.cbegin = pd-datefrom
                tt-custt.cvalue = 0.00
                tt-custt.cend = pd-dateto
                tt-custt.GrossProfit% = lf-gp
                tt-custt.isDefault = ll-default
                .
                
             
            
        END.
       
    
               
    END.
    FOR EACH tt-custt EXCLUSIVE-LOCK:
               
        IF tt-custt.cend < pd-DateFrom
        OR tt-custt.cbegin > pd-dateTo 
        THEN DELETE tt-custt.
        ELSE
        DO:
            ASSIGN
                tt-custt.ndays[1] = ( tt-custt.cend - tt-custt.cbegin ) + 1.
        
            ASSIGN
                ld-cbegin = max(tt-custt.cbegin,pd-dateFrom)
                ld-cend   = min(tt-custt.cend,pd-dateto).   
            ASSIGN
                tt-custt.rdays[1] = ( ld-cend - ld-cbegin ) + 1.
        
        END.
        
    END.     
     
            
    
    
        
    FOR EACH iact NO-LOCK
        WHERE iact.companycode = pc-companyCode
        AND iact.startdate >= pd-dateFrom
        AND iact.startDate <= pd-DateTo
        ,
        FIRST Issue NO-LOCK
        WHERE Issue.CompanyCode = pc-companyCode
        AND Issue.IssueNumber = iact.IssueNumber
        :
        IF pc-CustomerList <> "ALL" THEN
        DO:
            IF LOOKUP(Issue.AccountNumber,pc-CustomerList) = 0 THEN NEXT.
        END.
        FIND Customer WHERE Customer.companycode = Issue.CompanyCode
                        AND Customer.AccountNumber = Issue.AccountNumber NO-LOCK NO-ERROR.
        IF pc-CustStatus <> "ALL" THEN
        DO:
            IF pc-CustStatus = "ACT" AND Customer.IsActive = FALSE THEN NEXT.
            IF pc-CustStatus = "INACT" AND Customer.IsActive = TRUE THEN NEXT.
            
        END.
        IF pl-ExcludeAdmin 
        AND com-IsActivityChargeable(iAct.IssActivityID) = FALSE THEN NEXT.
            
            
            
            
        FIND ContractType 
            WHERE ContractType.CompanyCode = Issue.CompanyCode
            AND ContractType.ContractNumber = entry(1,Issue.ContractType,"|") 
            NO-LOCK NO-ERROR.
        IF NOT AVAILABLE ContractType THEN NEXT.
          
       
        
        
        FIND FIRST tt-custt 
            WHERE tt-custt.AccountNumber = Issue.AccountNumber
            AND tt-custt.ContractCode = entry(1,Issue.ContractType,"|")
            AND tt-custt.cbegin <= iact.startdate
            AND tt-custt.cend >= iact.StartDate
            EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE tt-custt THEN NEXT.
              
        
        /*
        ***
        *** 1 = YTD
        *** 2 = Period Selected
        ***
        */
        DO li-loop = 1 TO 1:
            IF li-loop = 2 THEN
            DO:
                IF iact.startdate < pd-DateFrom THEN NEXT.
                
            END.
            ASSIGN
                tt-custt.bill-time[li-loop] = tt-custt.bill-time[li-loop]  + IF iact.Billable THEN iact.Duration ELSE 0
                tt-custt.nonb-time[li-loop] = tt-custt.nonb-time[li-loop]  + IF NOT iact.Billable THEN iact.Duration ELSE 0.
            
        END.                  
                
    END.
   
    FIND Company WHERE Company.CompanyCode = pc-companyCode NO-LOCK NO-ERROR.
     
    FOR EACH tt-custt EXCLUSIVE-LOCK:
        
        DO li-loop = 1 TO 1:
        
            ASSIGN
                tt-custt.hbill-time[li-loop] = DYNAMIC-FUNCTION("fnConvertToHours",tt-custt.bill-time[li-loop]) 
                tt-custt.hnonb-time[li-loop] = DYNAMIC-FUNCTION("fnConvertToHours",tt-custt.nonb-time[li-loop])
                .
                        
        
        END.
        
        DO li-loop = 1 TO 1:
            DEFINE VARIABLE li-no-days  AS INT  NO-UNDO.
            
            IF li-loop = 2 
                THEN ASSIGN li-no-days = ( pd-DateTo - pd-DateFrom ) + 1. 
            ELSE ASSIGN li-no-days = ( pd-DateTo - ld-YearStart ) + 1.
            
            ASSIGN 
                li-no-days = tt-custt.rdays[li-loop].
            ASSIGN
                tt-custt.drate[li-loop] = ROUND(tt-custt.cValue / 365 , 2).
                
            IF tt-custt.cvalue <> 0 
                THEN ASSIGN
                    tt-custt.Revenue[li-loop] = ROUND(tt-custt.drate[li-loop] * li-no-days,2)
                    .
            ASSIGN 
                tt-custt.Cost[li-loop] = ROUND(tt-custt.hnonb-time[li-loop] * Company.engCost,2).
            
            
   
                
        END.
        ASSIGN tt-custt.GrossProfitV = tt-custt.Revenue[1] - tt-custt.cost[1].
        
        IF tt-custt.GrossProfit% <> 0
        THEN tt-custt.GrossProfitV = ROUND(tt-custt.GrossProfitV * tt-custt.GrossProfit% / 100,2).
        
        
                   
    END. 
  
    /*
    ***
    *** Final data and totals
    ***
    */
    FOR EACH tt-custt NO-LOCK:
        
        /*
        ***
        *** Pass 2 is for the customer total record
        *** Pass 3 is for the report total record
        ***
        */
        DO li-pass = 1 TO 3:
            ASSIGN
                lc-code = IF li-pass = 1 THEN  tt-custt.ContractCode ELSE cc-TotalKey
                ld-cbegin = IF li-pass = 1 THEN tt-custt.cbegin ELSE ?
                ld-cend = IF li-pass = 1 THEN tt-custt.cend ELSE ?
                lc-account = IF li-pass = 3 THEN cc-totalKey ELSE tt-custt.AccountNumber
                .
                
            FIND FIRST tt-custp 
                WHERE tt-custp.AccountNumber = lc-account
                AND tt-custp.contractCode = lc-code 
                AND tt-custp.cbegin = ld-cbegin
                EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE tt-custp THEN
            DO:
                
                            
                CREATE tt-custp.
                ASSIGN 
                    tt-custp.AccountNumber = lc-account
                    tt-custp.contractCode = lc-code 
                    tt-custp.ConActive = tt-custt.ConActive
                    tt-custp.cbegin = ld-cbegin
                    tt-custp.cend = ld-cend
                    tt-custp.cvalue = 0
                    tt-custp.GrossProfitV = 0
                    .
                    
                    
                IF li-pass = 1 THEN
                ASSIGN
                    tt-custp.GrossProfit% = tt-custt.GrossProfit%  
                    tt-custp.ndays[1] = tt-custt.ndays[1]
                    tt-custp.ndays[2] = tt-custt.ndays[2]
                    tt-custp.rdays[1] = tt-custt.rdays[1]
                    tt-custp.rdays[2] = tt-custt.rdays[2]
                    tt-custp.drate[1] = tt-custt.drate[1]
                    tt-custp.drate[2] = tt-custt.drate[2]
                    .
                    
                    
                    
                IF li-pass = 3 THEN
                DO:
                    ASSIGN 
                        tt-custp.name = lc-code
                        tt-custp.SortField = "B," + lc-code.
                         
                END.
                ELSE
                DO: 
                    FIND Customer WHERE Customer.CompanyCode = pc-CompanyCode
                        AND Customer.AccountNumber = lc-account NO-LOCK NO-ERROR.
                    ASSIGN 
                        tt-custp.name = Customer.Name
                        tt-custp.SortField = "A," + Customer.Name + "," + tt-custt.AccountNumber + "," + lc-code.
                END. 
            
            END. 
            /*
            ***
            *** Contract Value
            ***
            */
            
            IF li-pass = 1
            THEN 
            DO:
                ASSIGN
                    tt-custp.cValue = tt-custp.cValue + tt-custt.cvalue.
            END.
            ELSE
            /*
            *** Only active today
            */
            DO:
                IF tt-custt.cbegin <= TODAY
                AND tt-custt.cend >= TODAY
                THEN tt-custp.cValue = tt-custp.cValue + tt-custt.cvalue.
            END.
                
            ASSIGN   
                tt-custp.GrossProfitV = tt-custp.GrossProfitV + tt-custt.GrossProfitV.
                
            DO li-loop = 1 TO 2:
        
                ASSIGN
                    tt-custp.hbill-time[li-loop] = tt-custp.hbill-time[li-loop] + tt-custt.hbill-time[li-loop] 
                    tt-custp.hnonb-time[li-loop] = tt-custp.hnonb-time[li-loop] + tt-custt.hnonb-time[li-loop]
               
                    tt-custp.Revenue[li-loop] =  tt-custp.Revenue[li-loop] + tt-custt.Revenue[li-loop] 
                    tt-custp.Cost[li-loop] =  tt-custp.Cost[li-loop] + tt-custt.Cost[li-loop] 
                    .
                
               
            END.
        END.
                
    END.
    ASSIGN 
        li-count = 0.
   
    

END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION fnConvertToHours RETURNS INTEGER 
    ( pi-time AS INTEGER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE li-hour   AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-str    AS CHARACTER    NO-UNDO.
		
		
    IF pi-time > 0 THEN
    DO:
        lc-str = DYNAMIC-FUNCTION("com-TimeToString",pi-time).
        ASSIGN 
            li-hour = INTEGER(ENTRY(1,lc-str,":")).
        /*
        ***
        *** always round up to next hour
        ***
        */    
        IF INTEGER (ENTRY(2,lc-str,":")) > 0 
            THEN ASSIGN li-hour = li-hour + 1.    
		                                                                                                                     
    END.
		
    RETURN li-hour.
		
		
END FUNCTION.
