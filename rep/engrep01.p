/***********************************************************************

    Program:        rep/engrep01.p
    
    Purpose:        Management Report - Web Page
    
    Notes:
    
    
    When        Who         What
    10/11/2010  DJS         Initial
    21/11/2014  phoski      Fix it
    18/03/2015  phoski      debug info
    10/06/2015  phoski      Customer Report - Sort options
    23/10/2015  phoski      Replace week/year DJS drivel with a 
                            date range
    02/07/2016  phoski      Admin Time option
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-global-helpdesk         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-global-reportpath       AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-error-field             AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-title                   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-reptypeA                AS CHARACTER NO-UNDO.   
DEFINE VARIABLE lc-reptypeE                AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-reptype-checked         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selectengineer          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selectcustomer          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-date                    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-days                    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-pdf                     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-setrun                  AS LOG       NO-UNDO.

DEFINE VARIABLE li-run                     AS INTEGER   NO-UNDO.
DEFINE VARIABLE TYPEOF                     AS CHARACTER INITIAL "Detail,Summary Detail,Summary" NO-UNDO.
DEFINE VARIABLE ISSUE                      AS CHARACTER INITIAL "Customer,Engineer,Issues" NO-UNDO.

DEFINE VARIABLE typedesc                   AS CHARACTER INITIAL "Detail,SumDet,Summary" NO-UNDO.
DEFINE VARIABLE engcust                    AS CHARACTER INITIAL "Cust,Eng,Iss" NO-UNDO.
DEFINE VARIABLE lc-csort-cde               AS CHARACTER INITIAL 'Account|Customer Name|Total' NO-UNDO.
DEFINE VARIABLE lc-custSort                AS CHARACTER NO-UNDO.

DEFINE VARIABLE reportdesc                 AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-style                   AS CHARACTER NO-UNDO.


DEFINE VARIABLE li-tot-billable            AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-tot-nonbillable         AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-tot-productivity        AS DECIMAL   NO-UNDO.
DEFINE VARIABLE li-tot-period-billable     AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-tot-period-nonbillable  AS INTEGER   NO-UNDO.
DEFINE VARIABLE li-tot-period-productivity AS DECIMAL   NO-UNDO.

DEFINE VARIABLE lc-lodate                  AS CHARACTER FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE lc-hidate                  AS CHARACTER FORMAT "99/99/9999" NO-UNDO.
DEFINE VARIABLE lc-admin                   AS CHARACTER NO-UNDO.

{rep/engrep01-build.i}




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Date2Wk) = 0 &THEN

FUNCTION Date2Wk RETURNS INTEGER
    (INPUT dMyDate AS DATE)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Period) = 0 &THEN

FUNCTION fnFullName RETURNS CHARACTER 
    (pc-loginid AS CHARACTER) FORWARD.

FUNCTION Format-Select-Period RETURNS CHARACTER
    ( pc-htm AS CHARACTER)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Type) = 0 &THEN

FUNCTION Format-Select-Type RETURNS CHARACTER
    ( pc-htm AS CHARACTER)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Submit-Button) = 0 &THEN

FUNCTION Format-Submit-Button RETURNS CHARACTER
    ( pc-htm AS CHARACTER,
    pc-val AS CHARACTER)  FORWARD.


&ENDIF


FUNCTION lcom-ts RETURNS CHARACTER 
    (pi-time AS INTEGER) FORWARD.

FUNCTION percentage-calc RETURNS DECIMAL 
    (p-one AS DECIMAL,
    p-two AS DECIMAL) FORWARD.

/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
         WIDTH              = 34.29.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}
{lib/maillib.i}
{lib/replib.i}

/* ************************  Main Code Block  *********************** */


/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-customer-select) = 0 &THEN

PROCEDURE ip-customer-select :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
 
    {&out}  '<div id="customerdiv" style="display:none;">' skip
            '<span class="tableheading" >Please select customer(s)</span><br>' skip
            '<select id="selectcustomer" name="selectcustomer" class="inputfield" ' skip
            'multiple="multiple" size=8 width="200px" style="width:200px;" >' skip.
 
    {&out}
    '<option value="ALL" selected >Select All</option>' skip.

    FOR EACH customer NO-LOCK
        WHERE customer.company = lc-global-company
        BY customer.name:
 
        {&out}
        '<option value="'  customer.accountnumber '" ' '>'  html-encode(customer.name) '</option>' skip.
    END.
    {&out} '</select></div>'.
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-engcust-table) = 0 &THEN

PROCEDURE ip-CustomerReport:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-rep-type      AS INT   NO-UNDO.
    
    DEFINE VARIABLE pc-local-period AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE std-hours       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE i-Fuck          AS INT       EXTENT 3 NO-UNDO.
    DEFINE VARIABLE lc-Key          AS CHARACTER NO-UNDO.
    
    /*
    ***
    *** Can sort by Account,Customer Name or total 
    *** Put account at end of string to ensure field is unique
    ***
    */
    FOR EACH tt-issRep EXCLUSIVE-LOCK:
        
        ASSIGN
            tt-issRep.SortField = tt-issRep.AccountNumber.
        CASE lc-custsort:
            WHEN "Total" THEN
                DO:
                    FIND  FIRST tt-issCust 
                        WHERE tt-issCust.AccountNumber = tt-IssRep.AccountNumber 
                        AND tt-issCust.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.
                    FIND FIRST tt-IssTotal WHERE tt-IssTotal.AccountNumber = tt-IssRep.AccountNumber  NO-LOCK NO-ERROR.
                  
                    ASSIGN
                        tt-issRep.SortField = STRING(tt-IssTotal.billable + tt-IssTotal.nonbillable,"9999999999.99-") + "," + tt-issrep.AccountNumber.         
                END.
            WHEN "Customer Name" THEN
                DO:
                    FIND  Customer WHERE Customer.CompanyCode  = lc-global-company
                        AND  Customer.AccountNumber = tt-IssRep.AccountNumber NO-LOCK NO-ERROR.
                    IF AVAILABLE Customer
                        THEN ASSIGN
                            tt-issRep.SortField = Customer.Name + "," + tt-issrep.AccountNumber.        
                END.
            
        END CASE. 
        
    END.   
    
    
    {&out} '<table width=100% class="rptable">' SKIP.
    
    CASE pc-rep-type:
        WHEN 1 THEN
            DO:
                {&out} replib-TableHeading('Customer^left|Period^left||Billable^right|Non Billable^right|Total^right') SKIP.
            END.
        WHEN 2 THEN
            DO:
                {&out} replib-TableHeading('Customer^left|Period^left|Brief Description||Billable^right|Non Billable^right|Total^right') SKIP.
            END.
        WHEN 3 THEN
            DO:
                {&out} replib-TableHeading('Customer^left|Period^left|Billable^right|Non Billable^right|Total^right') SKIP.
                
            END.
        
    END CASE.
    
    FOR EACH tt-IssRep NO-LOCK 
        BREAK BY tt-IssRep.SortField
        BY tt-IssRep.period-of 
        BY tt-IssRep.IssueNumber:
            
            
        FIND  Customer WHERE Customer.CompanyCode  = lc-global-company
            AND  Customer.AccountNumber = tt-IssRep.AccountNumber NO-LOCK NO-ERROR.
        
        FIND FIRST tt-IssTotal WHERE tt-IssTotal.AccountNumber = tt-IssRep.AccountNumber  NO-LOCK NO-ERROR.
           
        IF FIRST-OF(tt-IssRep.SortField) AND pc-rep-type = 1 THEN
        DO:
            FIND  tt-issCust 
                WHERE tt-issCust.AccountNumber = tt-IssRep.AccountNumber 
                AND tt-issCust.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.
            
            {&out}
            '<tr>' SKIP
                  replib-RepField(Customer.Name,'','font-weight:bold')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField(lcom-ts(tt-IssTotal.billable),'right','font-weight:bold')
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right','font-weight:bold')
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right','font-weight:bold')
                '</tr>' SKIP.
            ASSIGN
                li-tot-billable     = li-tot-billable + tt-IssTotal.billable
                li-tot-nonbillable  = li-tot-nonbillable + tt-IssTotal.nonbillable
                .
                
        END.
        IF FIRST-OF(tt-IssRep.period-of) AND pc-rep-type = 2 THEN
        DO:
            ASSIGN 
                i-fuck = 0.
            
            FIND tt-issCust 
                WHERE tt-issCust.AccountNumber = tt-IssRep.AccountNumber
                AND tt-issCust.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.
   
            ASSIGN 
                std-hours = com-TimeToString(tt-issCust.billable + tt-issCust.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) .
            
            ASSIGN
                lc-style = 'font-weight:bold;'.
            IF FIRST-OF(tt-IssRep.SortField)
                THEN lc-style = lc-style + "border-top:1px solid black;".
            {&out}
            '<tr>' SKIP
                  replib-RepField(IF first-of(tt-IssRep.SortField) then Customer.name ELSE '','',lc-style)
                  replib-RepField(STRING(tt-IssRep.period-of,"99"),'',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.billable + tt-issCust.nonbillable),'right',lc-style)
                  
                '</tr>' SKIP.
            ASSIGN
                lc-style = 'font-weight:bold;'.
            {&out}
            '<tr>' SKIP
                  replib-RepField('','',lc-style)
                  replib-RepField('Issue No','',lc-style)
                  replib-RepField('','right',lc-style)
                  replib-RepField('Contract Type','left',lc-style)
              '</tr>' SKIP.
                
              
            ASSIGN
                li-tot-billable     = li-tot-billable + tt-issCust.billable
                li-tot-nonbillable  = li-tot-nonbillable + tt-issCust.nonbillable
                .
                    
            
        END.
        
        IF FIRST-OF(tt-IssRep.period-of) AND pc-rep-type = 3 THEN
        DO:
            FIND tt-issCust 
                WHERE tt-issCust.AccountNumber = tt-IssRep.AccountNumber
                AND tt-issCust.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.

            ASSIGN 
                std-hours = com-TimeToString(tt-issCust.billable + tt-issCust.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) .
            
            ASSIGN
                lc-style = ''.
            {&out}
            '<tr>' SKIP
                  replib-RepField(IF first-of(tt-IssRep.SortField) then Customer.name ELSE '','',lc-style)
                  replib-RepField(STRING(tt-IssRep.period-of,"99"),'',lc-style)
                  
                  replib-RepField(lcom-ts(tt-issCust.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.billable + tt-issCust.nonbillable),'right',lc-style)
                  
                '</tr>' SKIP.
            ASSIGN
                li-tot-billable     = li-tot-billable + tt-issCust.billable
                li-tot-nonbillable  = li-tot-nonbillable + tt-issCust.nonbillable
                .
                
        END.
        
         
        IF FIRST-OF(tt-IssRep.IssueNumber) AND pc-rep-type <> 3 THEN
        DO:
            FIND tt-IssTime 
                WHERE tt-IssTime.IssueNumber = tt-IssRep.IssueNumber 
                AND tt-IssTime.ActivityBy = tt-IssRep.ActivityBy 
                AND tt-IssTime.period =  tt-IssRep.period-of  NO-LOCK NO-ERROR.
        
            IF pc-rep-type = 1 THEN
            DO:
           
                {&out}
                '<tr>' SKIP
                    replib-RepField('','','')
                    replib-RepField('Issue Number','left','font-weight:bold')
                    replib-RepField("Contract Type          Date: " + string(tt-IssRep.IssueDate,"99/99/9999"),'left','font-weight:bold')
                    '</tr>' SKIP 
                               
                '<tr>' SKIP
                    replib-RepField('','','')
                    replib-RepField(STRING(tt-IssRep.IssueNumber),'left','')
                    replib-RepField(tt-IssRep.ContractType,'left','')
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.nonbillable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable + tt-IssTime.nonbillable ELSE 0),"right","")
                    
                    
                    '</tr>' SKIP. 
                {&out} 
                '<tr>' SKIP
                        replib-RepField('','','')
                        replib-RepField('Brief Description','left','')
                        replib-RepField(tt-IssRep.Description,'left','')
                        '</tr>' SKIP
                        '<tr>' SKIP
                        replib-RepField('','','')
                        replib-RepField('Action Desc','left','')
                       
                        replib-RepField(replace(tt-IssRep.ActionDesc,'~n','<br/>'),'left',' max-width: 100px;')
                        
                        '</tr>' SKIP
                        
                .
     
                                   
            END.
            ELSE
                IF pc-rep-type = 2 THEN
                DO:
                    {&out}
                    '<tr>' SKIP
                    replib-RepField('','','')
                    replib-RepField(STRING(tt-IssRep.IssueNumber),'left','')
                    replib-RepField(replace(tt-IssRep.Description,'~n','<br/>'),'left','max-width: 400px;')
                    replib-RepField(tt-IssRep.ContractType,'left','')
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.nonbillable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable + tt-IssTime.nonbillable ELSE 0),"right","")
                    
                    
                    '</tr>' SKIP. 
                    ASSIGN
                        i-fuck[1] = i-fuck[1] + IF AVAILABLE tt-IssTime THEN tt-IssTime.billable ELSE 0      
                        i-fuck[2] = i-fuck[2] + IF AVAILABLE tt-IssTime THEN tt-IssTime.nonbillable ELSE 0
                        i-fuck[3] = i-fuck[3] + IF AVAILABLE tt-IssTime THEN tt-IssTime.billable + tt-IssTime.nonbillable ELSE 0 
                        .             
                
                END.
            
            
        END.
        
        /* Main info */
        IF pc-rep-type = 1 THEN
        DO:
           
            {&out} 
            '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Activity','left','')
                        replib-RepField(tt-IssRep.ActivityType + " by: " + fnFullName(tt-IssRep.ActivityBy) + " on: " + string(tt-IssRep.StartDate,"99/99/9999"),'left','')
                        
                '</tr>' SKIP
                '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Billable','left','')
                        replib-RepField(IF tt-IssRep.Billable THEN "Yes" ELSE "No",'left','')
                        
                '</tr>' SKIP
                '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Time','left','')
                        replib-RepField(lcom-ts(tt-IssRep.Duration),'left','')
                        
                '</tr>' SKIP
                
                '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Activity Desc','left','')
                        replib-RepField(replace(tt-IssRep.Notes,'~n','<br/>'),'left',' max-width: 100px;')
                       
                '</tr>' SKIP
                
            .
                
        END.
        
        IF LAST-OF(tt-IssRep.period-of) AND pc-rep-type = 2 THEN
        DO:
            FIND  tt-issCust 
                WHERE tt-issCust.AccountNumber = tt-IssRep.AccountNumber
                AND tt-issCust.period-of  = tt-IssRep.period-of  NO-LOCK NO-ERROR.
       
            ASSIGN 
                std-hours = com-TimeToString(tt-issCust.billable + tt-issCust.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) .
                
            ASSIGN
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
     
            {&out}
            '<tr>' SKIP
            
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  /*
                  replib-RepField(lcom-ts(i-fuck[1]),'right',lc-style)
                  replib-RepField(lcom-ts(i-fuck[2]),'right',lc-style)
                  replib-RepField(lcom-ts(i-fuck[3]),'right',lc-style)
                  */
                  
                  replib-RepField('Total Period - ' + string(tt-IssRep.period-of,"99"),'right',lc-style)
               
                  replib-RepField(lcom-ts(tt-issCust.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-issCust.billable + tt-issCust.nonbillable),'right',lc-style)
                  
                '</tr>' SKIP
                '<tr>' SKIP
                 replib-RepField('','','')
                 '</tr>' SKIP.
                
        END.
    
        IF LAST-OF(tt-IssRep.SortField) AND pc-rep-type = 1 THEN
        DO:
                      
            ASSIGN 
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
            {&out}
            '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Customer Total - ' +  Customer.Name ,'',lc-style)
                                    replib-RepField(lcom-ts(tt-IssTotal.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right',lc-style)
                '</tr>' SKIP.
                
                
        END.
        IF LAST-OF(tt-IssRep.SortField) AND pc-rep-type = 2 THEN
        DO:
                  
            ASSIGN 
                std-hours = com-TimeToString(tt-IssTotal.billable + tt-IssTotal.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) . 
            
            ASSIGN 
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
            {&out}
            '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  
                  replib-RepField('Customer Total - ' + Customer.name,'',lc-style)
                  replib-RepField('','',lc-style)
                  
                  replib-RepField(lcom-ts(tt-IssTotal.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right',lc-style)
                  
                '</tr>' SKIP
                 '<tr>' SKIP
                 replib-RepField('','','')
                 '</tr>' SKIP.
                 
                      
        END.
        IF LAST-OF(tt-IssRep.SortField) AND pc-rep-type = 3 THEN
        DO:
            /*           
            ASSIGN 
                std-hours = lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) . 
           */
            
            ASSIGN 
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
            {&out}
            '<tr>' SKIP
                   replib-RepField('','','')
                  replib-RepField('Customer Total - ' + Customer.name ,'',lc-style)
                  
                  replib-RepField(lcom-ts(tt-IssTotal.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right',lc-style)
                  '</tr>' SKIP
                 '<tr>' SKIP
                 replib-RepField('','','')
                 '</tr>' SKIP.
                 
                      
        END.
        
        
       
        
    END. /* each tt-Issrep */
    
    
    IF pc-rep-type = 1 THEN
    DO:
        ASSIGN 
            lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
        {&out}
        '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Report Total','',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable + li-tot-nonbillable),'right',lc-style)
                '</tr>' SKIP.
                    
        
    END.
    IF pc-rep-type = 2 THEN
    DO:
        ASSIGN 
            lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
        {&out}
        '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Report Total','',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable + li-tot-nonbillable),'right',lc-style)
                '</tr>' SKIP.
                    
        
    END.
    IF pc-rep-type = 3 THEN
    DO:
        ASSIGN 
            lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
        {&out}
        '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('Report Total','',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable + li-tot-nonbillable),'right',lc-style)
                '</tr>' SKIP.
                    
        
    END.
    
    
     
    {&out} '</table>' SKIP.

END PROCEDURE.

PROCEDURE ip-engcust-table :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
 

    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading("Customer or Engineer") skip.
    
    {&out}
    /*htmlib-trmouse() '<td>' skip */
    '<tr><td>' skip
      Format-Select-Type(htmlib-Radio("engcust", "eng" , true ) ) '</td>' skip
      htmlib-TableField(html-encode("Engineer"),'left') '</tr>' skip.
    
    {&out}
    '<tr><td>' SKIP /*htmlib-trmouse() '<td>' skip*/
      Format-Select-Type(htmlib-Radio("engcust" , "cust", false) ) '</td>' skip
      htmlib-TableField(html-encode("Customer"),'left') '</tr>' SKIP
      '<tr><td align="right"><b>Sort By</b></td><td>' SKIP
      
      htmlib-Select("custsort",lc-csort-cde,lc-csort-cde,get-value("custsort")) SKIP.
      
      
    
    {&out} '</td><tr>' SKIP.
    
    {&out} skip 
      htmlib-EndTable()
      skip.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-engineer-select) = 0 &THEN

PROCEDURE ip-engineer-select :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
  
 
    {&out}  '<div id="engineerdiv" style="display:block;">' skip
            '<span class="tableheading" >Please select engineer(s)</span><br>' skip
            '<select id="selectengineer" name="selectengineer" class="inputfield" ' skip
            'multiple="multiple" size=8 width="200px" style="width:200px;" >' skip.

 
    {&out}
    '<option value="ALL" selected >Select All</option>' skip.

    FOR EACH webUser NO-LOCK
        WHERE webuser.company = lc-global-company
        AND   webuser.UserClass = "internal"
        BY webUser.name:

                
 
        {&out}
        '<option value="'  webUser.loginid '" ' '>'  html-encode(webuser.name) '</option>' skip.
 
    END.
  
      

    {&out} '</select></div>'.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ExportJavascript) = 0 &THEN

PROCEDURE ip-EngineerReport:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-rep-type      AS INT   NO-UNDO.
    
    DEFINE VARIABLE pc-local-period AS CHARACTER NO-UNDO. 
    DEFINE VARIABLE std-hours       AS CHARACTER NO-UNDO.
     
    
    
    {&out} '<table width=100% class="rptable">' SKIP.
    
    CASE pc-rep-type:
        WHEN 1 THEN
            DO:
                {&out} replib-TableHeading('Engineer^left|Period^left||Billable^right|Non Billable^right|Total^right') SKIP.
            END.
        WHEN 2 THEN
            DO:
                {&out} replib-TableHeading('Engineer^left|Period^left|Client|Brief Description|Contract Time^right|Billable^right|Non Billable^right|Total^right|Productivity %^right') SKIP.
            END.
        WHEN 3 THEN
            DO:
                {&out} replib-TableHeading('Engineer^left|Period^left|Contract Time^right|Billable^right|Non Billable^right|Total^right|Productivity %^right') SKIP.
                
            END.
        
    END CASE.
    
    FOR EACH tt-IssRep NO-LOCK 
        BREAK BY tt-IssRep.ActivityBy 
        BY tt-IssRep.period-of 
        BY tt-IssRep.IssueNumber:
            
        IF FIRST-OF(tt-IssRep.ActivityBy) AND pc-rep-type = 1 THEN
        DO:
            FIND  tt-IssUser 
                WHERE tt-IssUser.ActivityBy = tt-IssRep.ActivityBy 
                AND tt-IssUser.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.
            FIND tt-IssTotal 
                WHERE tt-IssTotal.ActivityBy = tt-IssRep.ActivityBy  NO-LOCK NO-ERROR.
            
            
            {&out}
            '<tr>' SKIP
                  replib-RepField(fnFullName(tt-IssRep.ActivityBy),'','font-weight:bold')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField(lcom-ts(tt-IssTotal.billable),'right','font-weight:bold')
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right','font-weight:bold')
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right','font-weight:bold')
                '</tr>' SKIP.
            ASSIGN
                li-tot-billable     = li-tot-billable + tt-IssTotal.billable
                li-tot-nonbillable  = li-tot-nonbillable + tt-IssTotal.nonbillable
                .
                
        END.
        IF FIRST-OF(tt-IssRep.period-of) AND pc-rep-type = 2 THEN
        DO:
            FIND tt-IssUser 
                WHERE tt-IssUser.ActivityBy = tt-IssRep.ActivityBy 
                AND tt-IssUser.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.
            FIND tt-IssTotal 
                WHERE tt-IssTotal.ActivityBy = tt-IssRep.ActivityBy  NO-LOCK NO-ERROR.
            ASSIGN 
                std-hours = com-TimeToString(tt-IssUser.billable + tt-IssUser.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) .
            
            ASSIGN
                lc-style = 'font-weight:bold;'.
            IF FIRST-OF(tt-IssRep.ActivityBy)
                THEN lc-style = lc-style + "border-top:1px solid black;".
            {&out}
            '<tr>' SKIP
                  replib-RepField(IF first-of(tt-IssRep.ActivityBy) then fnFullName(tt-IssRep.ActivityBy) ELSE '','',lc-style)
                  replib-RepField(STRING(tt-IssRep.period-of,"99"),'',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField(string(tt-IssUser.productivity,">>>>>>>>>9.99-"),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.billable + tt-IssUser.nonbillable),'right',lc-style)
                  replib-RepField(
                    IF tt-IssUser.productivity <> 0 then
                    STRING(percentage-calc(dec(std-hours),tt-IssUser.productivity)
                    ,">>>>>>>>>9.99-") ELSE '','right',lc-style)
                '</tr>' SKIP.
            ASSIGN
                lc-style = 'font-weight:bold;'.
            {&out}
            '<tr>' SKIP
                  replib-RepField('','',lc-style)
                  replib-RepField('Issue No','',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField('','',lc-style)
                  replib-RepField('Contract Type','left',lc-style)
                  replib-RepField('','right',lc-style)
                  replib-RepField('','right',lc-style)
                  replib-RepField('','right',lc-style)
                  replib-RepField('','right',lc-style)
                '</tr>' SKIP.
                
              
            ASSIGN
                li-tot-billable     = li-tot-billable + tt-IssUser.billable
                li-tot-nonbillable  = li-tot-nonbillable + tt-IssUser.nonbillable
                .
                    
            
        END.
        
        IF FIRST-OF(tt-IssRep.period-of) AND pc-rep-type = 3 THEN
        DO:
            FIND tt-IssUser 
                WHERE tt-IssUser.ActivityBy = tt-IssRep.ActivityBy 
                AND tt-IssUser.period-of  = tt-IssRep.period-of NO-LOCK NO-ERROR.
            FIND tt-IssTotal 
                WHERE tt-IssTotal.ActivityBy = tt-IssRep.ActivityBy  NO-LOCK NO-ERROR.
            ASSIGN 
                std-hours = com-TimeToString(tt-IssUser.billable + tt-IssUser.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) .
            
            ASSIGN
                lc-style = ''.
            {&out}
            '<tr>' SKIP
                  replib-RepField(IF first-of(tt-IssRep.ActivityBy) then fnFullName(tt-IssRep.ActivityBy) ELSE '','',lc-style)
                  replib-RepField(STRING(tt-IssRep.period-of,"99"),'',lc-style)
                  replib-RepField(string(tt-IssUser.productivity,">>>>>>>>>9.99-"),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.billable + tt-IssUser.nonbillable),'right',lc-style)
                  replib-RepField(
                    IF tt-IssUser.productivity <> 0 then
                    STRING(percentage-calc(dec(std-hours),tt-IssUser.productivity)
                    ,">>>>>>>>>9.99-") ELSE '','right',lc-style)
                '</tr>' SKIP.
            ASSIGN
                li-tot-billable     = li-tot-billable + tt-IssUser.billable
                li-tot-nonbillable  = li-tot-nonbillable + tt-IssUser.nonbillable
                .
                
        END.
        
         
        IF FIRST-OF(tt-IssRep.IssueNumber) AND pc-rep-type <> 3 THEN
        DO:
            FIND tt-IssTime 
                WHERE tt-IssTime.IssueNumber = tt-IssRep.IssueNumber 
                AND tt-IssTime.ActivityBy = tt-IssRep.ActivityBy 
                AND tt-IssTime.period =  tt-IssRep.period-of  NO-LOCK NO-ERROR.
            FIND Customer 
                WHERE Customer.AccountNumber = tt-IssRep.AccountNumber 
                AND customer.companyCode  = lc-global-company NO-LOCK NO-ERROR.
            IF pc-rep-type = 1 THEN
            DO:
           
                {&out}
                '<tr>' SKIP
                    replib-RepField('','','')
                    replib-RepField('Issue Number','left','font-weight:bold')
                    replib-RepField("Contract Type          Date: " + string(tt-IssRep.IssueDate,"99/99/9999"),'left','font-weight:bold')
                    '</tr>' SKIP 
                               
                '<tr>' SKIP
                    replib-RepField('','','')
                    replib-RepField(STRING(tt-IssRep.IssueNumber),'left','')
                    replib-RepField(tt-IssRep.ContractType,'left','')
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.nonbillable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable + tt-IssTime.nonbillable ELSE 0),"right","")
                    
                    
                    '</tr>' SKIP. 
                {&out} 
                '<tr>' SKIP
                        replib-RepField('','','')
                        replib-RepField('Client','left','')
                        replib-RepField(IF AVAILABLE customer THEN Customer.Name ELSE "Unknown",'left','')
                        '</tr>' SKIP
                        '<tr>' SKIP
                        replib-RepField('','','')
                        replib-RepField('Brief Description','left','')
                        replib-RepField(tt-IssRep.Description,'left','')
                        '</tr>' SKIP
                        '<tr>' SKIP
                        replib-RepField('','','')
                        replib-RepField('Action Desc','left','')
                       
                        replib-RepField(replace(tt-IssRep.ActionDesc,'~n','<br/>'),'left',' max-width: 100px;')
                        
                        '</tr>' SKIP
                        
                .
     
                                   
            END.
            ELSE
                IF pc-rep-type = 2 THEN
                DO:
                    {&out}
                    '<tr>' SKIP
                    replib-RepField('','','')
                    replib-RepField(STRING(tt-IssRep.IssueNumber),'left','')
                    replib-RepField(Customer.name,'left','')
                    replib-RepField(replace(tt-IssRep.Description,'~n','<br/>'),'left','max-width: 400px;')
                    replib-RepField(tt-IssRep.ContractType,'left','')
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.nonbillable ELSE 0),"right","")
                    replib-RepField(lcom-ts(IF AVAILABLE tt-IssTime THEN tt-IssTime.billable + tt-IssTime.nonbillable ELSE 0),"right","")
                    
                    
                    '</tr>' SKIP. 
                    
                
                END.
            
            
        END.
        
        IF pc-rep-type = 1 THEN
        DO:
           
            {&out} 
            '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Activity','left','')
                        replib-RepField(tt-IssRep.ActivityType + " by: " + fnFullName(tt-IssRep.ActivityBy) + " on: " + string(tt-IssRep.StartDate,"99/99/9999"),'left','')
                        
                '</tr>' SKIP
                '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Billable','left','')
                        replib-RepField(IF tt-IssRep.Billable THEN "Yes" ELSE "No",'left','')
                        
                '</tr>' SKIP
                '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Time','left','')
                        replib-RepField(lcom-ts(tt-IssRep.Duration),'left','')
                        
                '</tr>' SKIP
                
                '<tr>' SKIP
                replib-RepField('','','')
                        replib-RepField('Activity Desc','left','')
                        replib-RepField(replace(tt-IssRep.Notes,'~n','<br/>'),'left',' max-width: 100px;')
                       
                '</tr>' SKIP
                
            .
                
        END.
        
        IF LAST-OF(tt-IssRep.period-of) AND pc-rep-type = 2 THEN
        DO:
            FIND  tt-IssUser 
                WHERE tt-IssUser.ActivityBy = tt-IssRep.ActivityBy 
                AND tt-IssUser.period-of  = tt-IssRep.period-of  NO-LOCK NO-ERROR.
       
            ASSIGN 
                std-hours = com-TimeToString(tt-IssUser.billable + tt-IssUser.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) .
                
            ASSIGN
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
     
            {&out}
            '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Total Period - ' + string(tt-IssRep.period-of,"99"),'right',lc-style)
                  
                  replib-RepField(lcom-ts(tt-IssUser.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssUser.billable + tt-IssUser.nonbillable),'right',lc-style)
                  replib-RepField(
                    IF tt-IssUser.productivity <> 0 then
                    STRING(percentage-calc(dec(std-hours),tt-IssUser.productivity)
                    ,">>>>>>>>>9.99-") ELSE '','right',lc-style)
                '</tr>' SKIP
                 '<tr>' SKIP
                 replib-RepField('','','')
                 '</tr>' SKIP.
                
        END.
    
        IF LAST-OF(tt-IssRep.ActivityBy) AND pc-rep-type = 1 THEN
        DO:
            FIND tt-IssTotal 
                WHERE tt-IssTotal.ActivityBy = tt-IssRep.ActivityBy  NO-LOCK NO-ERROR.
            
            ASSIGN 
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
            {&out}
            '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Engineer Total - ' +  fnFullName(tt-IssRep.ActivityBy),'',lc-style)
                                    replib-RepField(lcom-ts(tt-IssTotal.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right',lc-style)
                '</tr>' SKIP.
                
                
        END.
        IF LAST-OF(tt-IssRep.ActivityBy) AND pc-rep-type = 2 THEN
        DO:
            FIND tt-IssTotal 
                WHERE tt-IssTotal.ActivityBy = tt-IssRep.ActivityBy  NO-LOCK NO-ERROR.
            
            ASSIGN 
                std-hours = com-TimeToString(tt-IssTotal.billable + tt-IssTotal.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) . 
            
            ASSIGN 
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
            {&out}
            '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Engineer Total - ' +  fnFullName(tt-IssRep.ActivityBy) ,'',lc-style)
                  replib-RepField(string(tt-IssTotal.productivity,">>>>>>>>>9.99-"),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(
                    IF tt-IssTotal.productivity <> 0 then
                    STRING(percentage-calc(dec(std-hours),tt-IssTotal.productivity)
                    ,">>>>>>>>>9.99-") ELSE '','right',lc-style)
                '</tr>' SKIP
                 '<tr>' SKIP
                 replib-RepField('','','')
                 '</tr>' SKIP.
                 
                      
        END.
        IF LAST-OF(tt-IssRep.ActivityBy) AND pc-rep-type = 3 THEN
        DO:
            FIND tt-IssTotal 
                WHERE tt-IssTotal.ActivityBy = tt-IssRep.ActivityBy  NO-LOCK NO-ERROR.
            
            ASSIGN 
                std-hours = com-TimeToString(tt-IssTotal.billable + tt-IssTotal.nonbillable)
                std-hours = STRING(dec(INTEGER( ENTRY(1,std-hours,":")) + truncate(INTEGER(ENTRY(2,std-hours,":")) / 60,2))) . 
            
            ASSIGN 
                lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
            {&out}
            '<tr>' SKIP
                   replib-RepField('','','')
                  replib-RepField('Engineer Total - ' +  fnFullName(tt-IssRep.ActivityBy) ,'',lc-style)
                  replib-RepField(string(tt-IssTotal.productivity,">>>>>>>>>9.99-"),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(tt-IssTotal.billable + tt-IssTotal.nonbillable),'right',lc-style)
                  replib-RepField(
                    IF tt-IssTotal.productivity <> 0 then
                    STRING(percentage-calc(dec(std-hours),tt-IssTotal.productivity)
                    ,">>>>>>>>>9.99-") ELSE '','right',lc-style)
                '</tr>' SKIP
                 '<tr>' SKIP
                 replib-RepField('','','')
                 '</tr>' SKIP.
                 
                      
        END.
        
        
       
        
    END. /* each tt-Issrep */
    
    IF pc-rep-type = 1 THEN
    DO:
        ASSIGN 
            lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
        {&out}
        '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Report Total','',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable + li-tot-nonbillable),'right',lc-style)
                '</tr>' SKIP.
                    
        
    END.
    IF pc-rep-type = 2 THEN
    DO:
        ASSIGN 
            lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
        {&out}
        '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Report Total','',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable + li-tot-nonbillable),'right',lc-style)
                '</tr>' SKIP.
                    
        
    END.
    IF pc-rep-type = 3 THEN
    DO:
        ASSIGN 
            lc-style = 'font-weight:bold;border-top:1px solid black;border-bottom:2px solid black;'.
        {&out}
        '<tr>' SKIP
                  replib-RepField('','','')
                  replib-RepField('','','')
                  replib-RepField('Report Total','',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-nonbillable),'right',lc-style)
                  replib-RepField(lcom-ts(li-tot-billable + li-tot-nonbillable),'right',lc-style)
                '</tr>' SKIP.
                    
        
    END.
    
    
     
    {&out} '</table>' SKIP.

END PROCEDURE.

PROCEDURE ip-ExportJavascript :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

  
    {&out}
    '<script language="JavaScript">' skip


        'function validateForm()' skip
        '~{' SKIP
          ' return true;' SKIP
        '~}' SKIP
        

        '</script>' skip.              
              
              
              
              
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-month-select) = 0 &THEN

PROCEDURE ip-GenerateReport:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-loop     AS INT      NO-UNDO.
    DEFINE BUFFER webuser       FOR webuser.
    DEFINE BUFFER customer      FOR Customer.
    
     


    {&out} htmlib-BeginCriteria("Report Criteria").
    
    {&out} '<table align=center><tr>' skip.

    {&out} '<th valign="top">Report Type: </th><td valign="top">' 
    ENTRY(LOOKUP(lc-reptypeA,typedesc),typeof)
    '</td>' SKIP
           '<th valign="top">For: </th><td valign="top">' 
                entry(LOOKUP(lc-reptypeE,engcust),issue)
             '</td>' SKIP
           
           '<th valign="top">Date Range: </th><td valign="top">' lc-lodate ' - ' lc-hidate '</td>' SKIP
           '<th valign="top">' IF LOOKUP(lc-reptypeE,engcust) = 1 THEN "Customer(s)"
                  ELSE 'Engineer(s)' ': </th><td valign="top">'.
                  
         
    IF LOOKUP(lc-reptypeE,engcust) = 2 THEN
    DO:
        IF lc-selectengineer <> "ALL" THEN
        DO li-loop = 1 TO NUM-ENTRIES(lc-selectengineer):
            FIND WebUser WHERE WebUser.LoginID = entry(li-loop,lc-selectEngineer) NO-LOCK NO-ERROR.
            IF AVAILABLE webuser THEN 
                {&out} WebUser.Name '<br/>'.
            ELSE 
            {&out} entry(li-loop,lc-selectEngineer) '<br/>'.
            
        END.
        ELSE {&out} lc-SelectEngineer.
        
    END.
    ELSE
    DO:
        IF lc-selectcustomer <> "ALL" THEN
        DO li-loop = 1 TO NUM-ENTRIES(lc-selectcustomer):
            FIND customer WHERE Customer.CompanyCode = lc-global-company
                AND Customer.AccountNumber = ENTRY(li-loop,lc-selectcustomer) NO-LOCK NO-ERROR.
            IF AVAILABLE customer THEN 
                {&out} Customer.Name '<br/>'.
            ELSE 
            {&out} entry(li-loop,lc-selectCustomer) '<br/>'.
            
        END.
        ELSE {&out} lc-SelectCustomer.
        
        {&out} '</td><th>Sort By:</th><td>' lc-custSort.
        
    END.
    
    
             
    {&out} '</td>' SKIP
        '<th>' IF lc-admin = "on" THEN "Exclude Administration Time"
               ELSE "Include Administration Time" '</th>' SKIP.
               
    .
       
    {&out} '</tr></table>' skip.
    
    {&out} htmlib-EndCriteria().
    
   
    {&out} htmlib-BeginCriteria("Report") '<div id="repdata">'.
       
    CASE STRING(LOOKUP(lc-reptypeE,engcust)):
        WHEN "1" THEN /* Customer */
            DO:
                RUN ip-CustomerReport (LOOKUP(lc-reptypeA,typedesc)).  
            END.
        WHEN "2" THEN /* Engineer */
            DO:
                RUN ip-EngineerReport (LOOKUP(lc-reptypeA,typedesc)).
                
            END.
        
    END.  
    
    {&out} '</div>
            'htmlib-EndCriteria().
       
        
        
    
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ProcessReport) = 0 &THEN

PROCEDURE ip-ProcessReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
   

    RUN rep/engrep01-build.p
        (
        lc-global-company,
        DATE(lc-lodate),
        DATE(lc-hidate),
        STRING(LOOKUP(lc-reptypeA,typedesc)),
        STRING(LOOKUP(lc-reptypeE,engcust)),
        lc-selectengineer ,
        lc-selectcustomer ,
        lc-admin = 'on',
        OUTPUT TABLE tt-IssRep,
        OUTPUT TABLE tt-IssTime,
        OUTPUT TABLE tt-IssTotal,
        OUTPUT TABLE tt-IssUser,
        OUTPUT TABLE tt-IssCust,
        OUTPUT TABLE tt-IssTable,
        OUTPUT TABLE tt-ThisPeriod
        ).
        
        



 
    ASSIGN 
        lc-setrun = TRUE.
       
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-report-type) = 0 &THEN

PROCEDURE ip-report-type :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading("Report Type") skip.
    
    {&out}
    /*htmlib-trmouse() '<td>' */ '<tr><td>' skip 
    htmlib-Radio("reptype", "detail" , TRUE ) '</td>'
    htmlib-TableField(html-encode("Detail"),'left') '</tr>' skip.
    
    {&out}
    /* htmlib-trmouse() '<td>' */ '<tr><td>' skip 
    htmlib-Radio("reptype" , "sumdet", FALSE) '</td>'
    htmlib-TableField(html-encode("Summary Detail"),'left') '</tr>' skip.

    {&out}
    /* htmlib-trmouse() '<td>' */ '<tr><td>' skip 
    htmlib-Radio("reptype" , "summary", FALSE) '</td>'
    htmlib-TableField(html-encode("Summary"),'left') '</tr>' skip.
    
    {&out} '<tr>'
            '<TD VALIGN="TOP" colspan="2" nowrap ALIGN="right">&nbsp;' 
            htmlib-SideLabel("Exclude Administration Time?")
     
             '</td><TD VALIGN="TOP" ALIGN="left">'
                htmlib-CheckBox("admin", IF lc-admin = 'on'
                                        THEN TRUE ELSE FALSE) 
            '</TD><tr>'.
            
    {&out} skip 
      htmlib-EndTable()
      skip.


END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Validate) = 0 &THEN

PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
     DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
     DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


    
       
    IF lc-selectengineer BEGINS "ALL," AND NUM-ENTRIES(lc-selectengineer) > 1 THEN lc-selectengineer = substr(lc-selectengineer,INDEX(lc-selectengineer,",") + 1).
    IF lc-selectcustomer BEGINS "ALL," AND NUM-ENTRIES(lc-selectcustomer) > 1 THEN lc-selectcustomer = substr(lc-selectcustomer,INDEX(lc-selectcustomer,",") + 1).

    
    DEFINE VARIABLE ld-lodate   AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-hidate   AS DATE     NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rowid    AS CHARACTER     NO-UNDO.

    ASSIGN
        ld-lodate = DATE(lc-lodate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-lodate = ?
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The from date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
    
    
    ASSIGN
        ld-hidate = DATE(lc-hidate) no-error.
    IF ERROR-STATUS:ERROR 
        OR ld-hidate = ?
        THEN RUN htmlib-AddErrorMessage(
            'hidate', 
            'The to date is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).

    IF ld-lodate > ld-hidate 
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The date range is invalid',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
    IF pc-error-field <> ""
    THEN RETURN.
    IF YEAR(ld-lodate) <> YEAR(ld-hidate) 
        THEN RUN htmlib-AddErrorMessage(
            'lodate', 
            'The dates must be in the same year',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).
            
                          
            
            

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-week-month) = 0 &THEN

PROCEDURE ip-week-month :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    {&out}
    htmlib-StartMntTable()
    htmlib-TableHeading("Date Range|") skip.
    
    
    
    {&out} 
    '<tr><td valign="top" align="right">' 
        (IF LOOKUP("lodate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("From")
        ELSE htmlib-SideLabel("From"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("lodate",10,lc-lodate) 
    htmlib-CalendarLink("lodate")
    '</td></tr>' skip.
    
    {&out} '<tr><td valign="top" align="right">' 
        (IF LOOKUP("hidate",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("To")
        ELSE htmlib-SideLabel("To"))
    '</td>'
    '<td valign="top" align="left">'
    htmlib-CalendarInputField("hidate",10,lc-hidate) 
    htmlib-CalendarLink("hidate")
    '</td></tr>' skip.
    
    
    {&out} skip 
      htmlib-EndTable()
      skip.

END PROCEDURE.


&ENDIF



&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      emails:       In the event that this Web object is state-aware, this is
                   a good place to set the webState and webTimeout attributes.
    ------------------------------------------------------------------------------*/

    /* To make this a state-aware Web object, pass in the timeout period 
     * (in minutes) before running outputContentType.  If you supply a timeout 
     * period greater than 0, the Web object becomes state-aware and the 
     * following happens:
     *
     *   - 4GL variables webState and webTimeout are set
     *   - a cookie is created for the broker to id the client on the return trip
     *   - a cookie is created to id the correct procedure on the return trip
     *
     * If you supply a timeout period less than 1, the following happens:
     *
     *   - 4GL variables webState and webTimeout are set to an empty string
     *   - a cookie is killed for the broker to id the client on the return trip
     *   - a cookie is killed to id the correct procedure on the return trip
     *
     * Example: Timeout period of 5 minutes for this Web object.
     *
     *   setWebState (5.0).
     */
    
    /* 
     * Output additional cookie information here before running outputContentType.
     *      For more information about the Netscape Cookie Specification, see
     *      http://home.netscape.com/newsref/std/cookie_spec.html  
     *   
     *      Name         - name of the cookie
     *      Value        - value of the cookie
     *      Expires date - Date to expire (optional). See TODAY function.
     *      Expires time - Time to expire (optional). See TIME function.
     *      Path         - Override default URL path (optional)
     *      Domain       - Override default domain (optional)
     *      Secure       - "secure" or unknown (optional)
     * 
     *      The following example sets cust-num=23 and expires tomorrow at (about) the 
     *      same time but only for secure (https) connections.
     *      
     *      RUN SetCookie IN web-utilities-hdl 
     *        ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
     */ 
    output-content-type ("text/html":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
  Purpose:     Process the web request.
  Parameters:  <none>
  emails:       
------------------------------------------------------------------------------*/
   
    {lib/checkloggedin.i} 
  
    FIND webuser WHERE webuser.loginid = lc-global-user NO-LOCK NO-ERROR.
  
    IF request_method = "POST" THEN
    DO:
        ASSIGN
            lc-reptypeA       = get-value("reptype")   /* 1=Detailed , 2=SummaryDetail, 3=Summary */ 
            lc-reptypeE       = get-value("engcust")
            lc-selectengineer = get-value("selectengineer")
            lc-selectcustomer = get-value("selectcustomer")
            lc-custsort       = get-value("custsort")
            lc-lodate   = get-value("lodate")         
            lc-hidate   = get-value("hidate")
            lc-admin    = get-value("admin").  

        
         RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).
       
        IF lc-error-field = "" 
            THEN RUN ip-ProcessReport.
      
    END.

    IF request_method <> "post"
        THEN ASSIGN lc-date = STRING(TODAY,"99/99/9999")
            lc-days = "7"
            lc-lodate = STRING(TODAY - 7, "99/99/9999")
            lc-hidate = STRING(TODAY, "99/99/9999")
            .

    RUN outputHeader.  
    
    
    {&out} htmlib-Header(lc-title) SKIP.
    {&out} DYNAMIC-FUNCTION('htmlib-CalendarInclude':U) skip.
    {&out}
    '<script language="JavaScript" src="/scripts/js/prototype.js"></script>' skip
    '<script language="JavaScript" src="/scripts/js/scriptaculous.js"></script>' skip
    '<script language="JavaScript" src="/scripts/js/effects.js"></script>' skip
    .
    
    RUN ip-ExportJavascript.
    
    {&out}
    htmlib-StartForm("mainform","post", appurl + '/rep/engrep01.p'  )
    htmlib-ProgramTitle("Engineers Time Report") skip.

    
    IF request_method <> "POST" OR lc-error-field <> "" THEN
    DO:
        {&out} '<div id="content">' SKIP. 
        {&out} htmlib-StartTable("mnt",
            0,
            0,
            5,
            0,
            "center") skip.

        {&out} '<TD VALIGN="TOP" ALIGN="center" WIDTH="200px">'  skip.
        RUN ip-report-type.
        {&out}         '</TD> ' skip.

   
        {&out} ' <TD VALIGN="TOP" ALIGN="center" WIDTH="200px">'  skip.
        RUN ip-engcust-table.
        RUN ip-week-month.
        {&out}         '</TD>' skip.
    
     
     

     
        {&out} '<TD VALIGN="TOP" ALIGN="center" HEIGHT="150px">'  skip.
        RUN ip-engineer-select.
        RUN ip-customer-select.
        {&out}         '</TD></TR>' skip.

        {&out} htmlib-EndTable() skip.


        IF lc-error-msg <> "" THEN
        DO:
            {&out} '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' skip.
        END.
    
        {&out} '<center>' Format-Submit-Button("submitform","Report")
        '</center><br>' skip.
    
        {&out} htmlib-Hidden("submitsource","") SKIP
               '</div>' skip.
  
        {&out} htmlib-CalendarScript("lodate") skip
           htmlib-CalendarScript("hidate") skip.
   
    END.
    ELSE
    DO:
        RUN ip-GenerateReport.
    END.
    
    {&out} htmlib-EndForm() skip.
    
    
         
    {&out} htmlib-Footer() skip.
    

END PROCEDURE.


&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-Date2Wk) = 0 &THEN

FUNCTION Date2Wk RETURNS INTEGER
    (INPUT dMyDate AS DATE) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cYear AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iDayNo AS INTEGER NO-UNDO.
    DEFINE VARIABLE iCent AS INTEGER NO-UNDO.
    DEFINE VARIABLE iWkNo AS INTEGER  NO-UNDO.
    ASSIGN
        cYear = SUBSTRING(STRING(dMyDate),7)
        cYear = IF LENGTH(cYear) = 4 THEN SUBSTRING(cYear,3) ELSE cYear
        iCent = TRUNCATE(YEAR(TODAY) / 100,0)
        iDayNo = dMyDate - date(12,31,(iCent * 100) + (INTEGER(cYear) - 1)).
    iWkNo = iDayNo / 7. 

    RETURN  iWkNo.


END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Period) = 0 &THEN

FUNCTION fnFullName RETURNS CHARACTER 
    (  pc-loginid AS CHARACTER ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE BUFFER WebUser FOR WebUser.
		
    FIND WebUser
        WHERE WebUser.LoginID = pc-loginid NO-LOCK NO-ERROR.
		  
    RETURN IF AVAILABLE WebUser THEN WebUser.Name ELSE ''.

		
END FUNCTION.

FUNCTION Format-Select-Period RETURNS CHARACTER
    ( pc-htm AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<input',
        '<input onClick="ChangeReportPeriod(this.value)"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Select-Type) = 0 &THEN

FUNCTION Format-Select-Type RETURNS CHARACTER
    ( pc-htm AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = REPLACE(pc-htm,'<input',
        '<input onClick="ChangeReportType(this.value)"'). 


    RETURN lc-htm.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-Format-Submit-Button) = 0 &THEN

FUNCTION Format-Submit-Button RETURNS CHARACTER
    ( pc-htm AS CHARACTER,
    pc-val AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    lc-htm = '<input onclick="return validateForm()" class="submitbutton" type="submit" name="' + pc-htm + '" value="' + pc-val + '"> ' .

 
    RETURN lc-htm.

END FUNCTION.


&ENDIF

FUNCTION lcom-ts RETURNS CHARACTER 
    ( pi-time AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-sec-hours AS INTEGER INITIAL 3600 NO-UNDO.
    DEFINE VARIABLE li-seconds   AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-mins      AS INTEGER NO-UNDO.
    DEFINE VARIABLE li-hours     AS INTEGER NO-UNDO.
    DEFINE VARIABLE ll-neg       AS LOG     NO-UNDO.

      
    IF pi-time < 0 THEN ASSIGN ll-neg  = TRUE
            pi-time = pi-time * -1.

    ASSIGN 
        li-seconds = pi-time MOD li-sec-hours
        li-mins    = TRUNCATE(li-seconds / 60,0).
        
    ASSIGN
        pi-time = pi-time - li-seconds.
        
    ASSIGN
        li-hours = TRUNCATE(pi-time / li-sec-hours,0).

    RETURN TRIM( ( IF ll-neg THEN "-" ELSE "" ) + string(li-hours) + ":" + string(li-mins,'99')).
    

		
END FUNCTION.

FUNCTION percentage-calc RETURNS DECIMAL 
    ( p-one AS DECIMAL,
    p-two AS DECIMAL ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE p-result AS DECIMAL.
    /*  p-one =   billable/nonbillable total      */
    /*  p-two =   productivity / contarcted hours */
    p-result = ROUND(( p-one * 100) / p-two , 2).
    RETURN p-result.
		
END FUNCTION.
