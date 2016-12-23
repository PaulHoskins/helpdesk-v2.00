/***********************************************************************

    Program:        rep/crmpipeline.p
    
    Purpose:        CRM Pipeline Report
    
    Notes:
    
    
    When        Who         What
    
    23/12/2016  phoski      Initial
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-msg   AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-char        AS CHARACTER NO-UNDO.


 
DEFINE VARIABLE ll-Customer    AS LOG       NO-UNDO.
DEFINE VARIABLE lc-filename    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CodeName    AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-output      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit      AS CHARACTER NO-UNDO.

DEFINE VARIABLE cPart          AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCode          AS CHARACTER NO-UNDO.

DEFINE VARIABLE cDesc          AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-StatusList     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-rep       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selr-Code      AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-selr-Name      AS LONGCHAR  NO-UNDO.




    

DEFINE BUFFER this-user FOR WebUser.
        
    
.
{lib/maillib.i}
{lib/princexml.i}



/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no





/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-Format-Select-Account) = 0 &THEN


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */



/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
    {lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

PROCEDURE ip-ExportJScript :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
/**
{&out} SKIP
        '<script language="JavaScript" src="/scripts/js/hidedisplay.js"></script>' SKIP
        '<script language="JavaScript" src="/asset/chart/Chart.js"></script>'.

{&out} SKIP 
      '<script language="JavaScript">' SKIP.

{&out} SKIP
    'function ChangeAccount() ~{' SKIP
    '   SubmitThePage("AccountChange")' SKIP
    '~}' SKIP

    'function ChangeStatus() ~{' SKIP
    '   SubmitThePage("StatusChange")' SKIP
    '~}' SKIP

        'function ChangeDates() ~{' SKIP
   /* '   SubmitThePage("DatesChange")' skip */
    '~}' SKIP.

{&out} SKIP
       '</script>' SKIP.
           
 **/
           
END PROCEDURE.


PROCEDURE ip-ExportReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-filename AS CHARACTER NO-UNDO.
    

    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER issue    FOR issue.
    

    DEFINE VARIABLE lc-GenKey AS CHARACTER NO-UNDO.

   
    ASSIGN
        lc-genkey = STRING(NEXT-VALUE(ReportNumber)).
    
        
    pc-filename = SESSION:TEMP-DIR + "/CRMPipeLine-" + lc-GenKey
        + ".csv".
/**
    OUTPUT TO VALUE(pc-filename).

    PUT UNFORMATTED
                
        '"Customer","Issue Number","Description","Issue Type","Raised By","System","SLA","' +
        'Date Raised","Time Raised","Date Completed","Time Completed","Date First Activity","Time First Activity","Activity Duration","SLA Achieved","SLA Comment","' +
        '"Closed By' SKIP.


    FOR EACH tt-ilog NO-LOCK
        BREAK BY tt-ilog.AccountNumber
        BY tt-ilog.IssueNumber
        :
            
        FIND customer WHERE customer.CompanyCode = lc-global-company
            AND customer.AccountNumber = tt-ilog.AccountNumber
            NO-LOCK NO-ERROR.


        EXPORT DELIMITER ','
            ( customer.AccountNumber + " " + customer.NAME )
            tt-ilog.issuenumber
            tt-ilog.briefDescription
            tt-ilog.iType
            tt-ilog.RaisedLoginID
            tt-ilog.AreaCode
            tt-ilog.SLADesc
            tt-ilog.CreateDate
            STRING(tt-ilog.CreateTime,"hh:mm")
      
            IF tt-ilog.CompDate = ? THEN "" ELSE STRING(tt-ilog.CompDate,"99/99/9999")

            IF tt-ilog.CompTime = 0 THEN "" ELSE STRING(tt-ilog.CompTime,"hh:mm")
            
            IF tt-ilog.fActDate = ? THEN "" ELSE STRING(tt-ilog.fActDate,"99/99/9999")
             
            IF tt-ilog.fActTime = 0 THEN "" ELSE STRING(tt-ilog.factTime,"hh:mm")
       
            tt-ilog.ActDuration
            tt-ilog.SLAAchieved
            tt-ilog.SLAComment
            tt-ilog.ClosedBy

            . 
           
    END.

    OUTPUT CLOSE.

**/

END PROCEDURE.




PROCEDURE ip-InitialProcess :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-temp AS CHARACTER NO-UNDO.
    
     RUN crm/lib/getRepList.p ( lc-global-company, lc-global-user, OUTPUT lc-selr-Code, OUTPUT lc-selr-Name).
     
    lc-crit-rep  = get-value("rep").
        
   
    ASSIGN lc-selr-code = "ALL|" + lc-selr-code
            lc-selr-name = "All|" + lc-selr-name.
            
        
    ASSIGN
       
        lc-output = get-value("output")
        lc-submit = get-value("submitsource")
        .
    
   


    IF request_method = "GET" THEN
    DO:
        DO li-loop = 1 TO NUM-ENTRIES(lc-global-opStatus-Code,"|"):
            lc-codeName = "chk" + ENTRY(li-loop,lc-global-opStatus-Code,"|").
        
            set-user-field(lc-codeName,"on").
           
    
        END.
    
        set-user-field("month",STRING(MONTH(TODAY))).
        set-user-field("year",STRING(YEAR(TODAY) - 1 )).
        
    END.

    
    

END PROCEDURE.



PROCEDURE ip-PDF:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-pdf AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER issue    FOR issue.
    
    DEFINE VARIABLE lc-html         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-pdf          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE ll-ok           AS LOG       NO-UNDO.
    DEFINE VARIABLE li-ReportNumber AS INTEGER   NO-UNDO.

    ASSIGN    
        li-ReportNumber = NEXT-VALUE(ReportNumber).
    ASSIGN 
        lc-html = SESSION:TEMP-DIR + caps(lc-global-company) + "-PipeLine-" + string(li-ReportNumber).


    ASSIGN 
        lc-pdf  = lc-html + ".pdf"
        lc-html = lc-html + ".html".

    OS-DELETE value(lc-pdf) no-error.
    OS-DELETE value(lc-html) no-error.

    /*                                                                                                                                                                                                               */
    /*    DYNAMIC-FUNCTION("pxml-Initialise").                                                                                                                                                                       */
    /*                                                                                                                                                                                                               */
    /*    CREATE tt-pxml.                                                                                                                                                                                            */
    /*    ASSIGN                                                                                                                                                                                                     */
    /*        tt-pxml.PageOrientation = "LANDSCAPE".                                                                                                                                                                 */
    /*                                                                                                                                                                                                               */
    /*    DYNAMIC-FUNCTION("pxml-OpenStream",lc-html).                                                                                                                                                               */
    /*    DYNAMIC-FUNCTION("pxml-Header", lc-global-company).                                                                                                                                                        */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*    {&prince}                                                                                                                                                                                                  */
    /*    '<p style="text-align: center; font-size: 14px; font-weight: 900;">Issue Log - '                                                                                                                           */
    /*    'From ' STRING(DATE(lc-lodate),"99/99/9999")                                                                                                                                                               */
    /*    ' To ' STRING(DATE(lc-hidate),"99/99/9999")                                                                                                                                                                */
    /*                                                                                                                                                                                                               */
    /*    '</div>'.                                                                                                                                                                                                  */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*    FOR EACH tt-ilog NO-LOCK                                                                                                                                                                                   */
    /*        BREAK BY tt-ilog.AccountNumber                                                                                                                                                                         */
    /*        BY tt-ilog.IssueNumber                                                                                                                                                                                 */
    /*        :                                                                                                                                                                                                      */
    /*                                                                                                                                                                                                               */
    /*        IF FIRST-OF(tt-ilog.AccountNumber) THEN                                                                                                                                                                */
    /*        DO:                                                                                                                                                                                                    */
    /*            FIND customer WHERE customer.CompanyCode = lc-global-company                                                                                                                                       */
    /*                AND customer.AccountNumber = tt-ilog.AccountNumber                                                                                                                                             */
    /*                NO-LOCK NO-ERROR.                                                                                                                                                                              */
    /*            {&prince} htmlib-BeginCriteria("Customer - " + tt-ilog.AccountNumber + " " +                                                                                                                       */
    /*                customer.NAME) SKIP.                                                                                                                                                                           */
    /*                                                                                                                                                                                                               */
    /*            {&prince}                                                                                                                                                                                          */
    /*            '<table class="landrep">'                                                                                                                                                                          */
    /*            '<thead>'                                                                                                                                                                                          */
    /*            '<tr>'                                                                                                                                                                                             */
    /*            htmlib-TableHeading(                                                                                                                                                                               */
    /*                "Issue Number^right|Description^left|Issue Class^left|Raised By^left|System^left|SLA^left|" +                                                                                                  */
    /*                "Date Raised^right|Time Raised^right|Date Completed^right|Time Completed^right|Date First Activity^left|Time First Activity^left|Activity Duration^right|SLA Achieved^left|SLA Comment^left|" +*/
    /*                "Closed By^left")                                                                                                                                                                              */
    /*                                                                                                                                                                                                               */
    /*            '</tr>'                                                                                                                                                                                            */
    /*            '</thead>'                                                                                                                                                                                         */
    /*        SKIP.                                                                                                                                                                                                  */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*        END.                                                                                                                                                                                                   */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*        {&prince}                                                                                                                                                                                              */
    /*            SKIP                                                                                                                                                                                               */
    /*            '<tr>'                                                                                                                                                                                             */
    /*            SKIP                                                                                                                                                                                               */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.issuenumber)),'right')                                                                                                                             */
    /*                                                                                                                                                                                                               */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.briefDescription)),'left')                                                                                                                         */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.iType)),'left')                                                                                                                                    */
    /*                                                                                                                                                                                                               */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.RaisedLoginID)),'left')                                                                                                                            */
    /*                                                                                                                                                                                                               */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.AreaCode)),'left')                                                                                                                                 */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.SLADesc)),'left')                                                                                                                                  */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateDate,"99/99/9999")),'right')                                                                                                                 */
    /*            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateTime,"hh:mm")),'right').                                                                                                                     */
    /*                                                                                                                                                                                                               */
    /*        IF tt-ilog.CompDate <> ? THEN                                                                                                                                                                          */
    /*            {&prince}                                                                                                                                                                                          */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompDate,"99/99/9999")),'right')                                                                                                                       */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompTime,"hh:mm")),'right').                                                                                                                           */
    /*        ELSE                                                                                                                                                                                                   */
    /*        {&prince}                                                                                                                                                                                              */
    /*            htmlib-MntTableField(html-encode(""),'right')                                                                                                                                                      */
    /*            htmlib-MntTableField(html-encode(""),'right').                                                                                                                                                     */
    /*                                                                                                                                                                                                               */
    /*        IF tt-ilog.factDate <> ? THEN                                                                                                                                                                          */
    /*            {&prince}                                                                                                                                                                                          */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.fActDate,"99/99/9999")),'right')                                                                                                                       */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.fActTime,"hh:mm")),'right').                                                                                                                           */
    /*        ELSE                                                                                                                                                                                                   */
    /*        {&prince}                                                                                                                                                                                              */
    /*            htmlib-MntTableField(html-encode(""),'right')                                                                                                                                                      */
    /*            htmlib-MntTableField(html-encode(""),'right').                                                                                                                                                     */
    /*                                                                                                                                                                                                               */
    /*        {&prince}                                                                                                                                                                                              */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.ActDuration)),'right')                                                                                                                                 */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.SLAAchieved)),'left')                                                                                                                                  */
    /*        htmlib-MntTableField(REPLACE(tt-ilog.SLAComment,'~n','<br/>'),'left')                                                                                                                                  */
    /*                                                                                                                                                                                                               */
    /*        htmlib-MntTableField(html-encode(STRING(tt-ilog.ClosedBy)),'left')                                                                                                                                     */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*            SKIP .                                                                                                                                                                                             */
    /*                                                                                                                                                                                                               */
    /*        {&prince} '</tr>' SKIP.                                                                                                                                                                                */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*        IF LAST-OF(tt-ilog.AccountNumber) THEN                                                                                                                                                                 */
    /*        DO:                                                                                                                                                                                                    */
    /*            {&prince} SKIP                                                                                                                                                                                     */
    /*                htmlib-EndTable()                                                                                                                                                                              */
    /*                SKIP.                                                                                                                                                                                          */
    /*                                                                                                                                                                                                               */
    /*            {&prince} htmlib-EndCriteria().                                                                                                                                                                    */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*        END.                                                                                                                                                                                                   */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*    END.                                                                                                                                                                                                       */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*    DYNAMIC-FUNCTION("pxml-Footer",lc-global-company).                                                                                                                                                         */
    /*    DYNAMIC-FUNCTION("pxml-CloseStream").                                                                                                                                                                      */
    /*                                                                                                                                                                                                               */
    /*                                                                                                                                                                                                               */
    /*    ll-ok = DYNAMIC-FUNCTION("pxml-Convert",lc-html,lc-pdf).                                                                                                                                                   */

    OS-DELETE value(lc-html) no-error.
    
    IF ll-ok
        THEN ASSIGN pc-pdf = lc-pdf.
    

END PROCEDURE.

PROCEDURE ip-PrintReport :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

/*    DEFINE BUFFER customer     FOR customer.                                                                                                                                                                     */
/*    DEFINE BUFFER issue        FOR issue.                                                                                                                                                                        */
/*    DEFINE VARIABLE li-count        AS INTEGER          NO-UNDO.                                                                                                                                                 */
/*    DEFINE VARIABLE lc-tr           AS CHARACTER        NO-UNDO.                                                                                                                                                 */
/*    DEFINE VARIABLE li-eng          AS INTEGER          NO-UNDO.                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*    DEFINE BUFFER tt-ilog   FOR tt-ilog.                                                                                                                                                                         */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*    FOR EACH tt-ilog NO-LOCK                                                                                                                                                                                     */
/*        BREAK BY tt-ilog.AccountNumber                                                                                                                                                                           */
/*        BY tt-ilog.IssueNumber                                                                                                                                                                                   */
/*        :                                                                                                                                                                                                        */
/*                                                                                                                                                                                                                 */
/*        IF FIRST-OF(tt-ilog.AccountNumber) THEN                                                                                                                                                                  */
/*        DO:                                                                                                                                                                                                      */
/*            FIND customer WHERE customer.CompanyCode = lc-global-company                                                                                                                                         */
/*                AND customer.AccountNumber = tt-ilog.AccountNumber                                                                                                                                               */
/*                NO-LOCK NO-ERROR.                                                                                                                                                                                */
/*            {&out} htmlib-BeginCriteria("Customer - " + tt-ilog.AccountNumber + " " +                                                                                                                            */
/*                customer.NAME) SKIP.                                                                                                                                                                             */
/*            IF get-value("summary") = "on" THEN                                                                                                                                                                  */
/*            DO:                                                                                                                                                                                                  */
/*                RUN ip-SummaryPage (tt-ilog.AccountNumber).                                                                                                                                                      */
/*                                                                                                                                                                                                                 */
/*            END.                                                                                                                                                                                                 */
/*            {&out} SKIP                                                                                                                                                                                          */
/*                htmlib-StartMntTable() SKIP                                                                                                                                                                      */
/*                htmlib-TableHeading(                                                                                                                                                                             */
/*                "Issue Number^right|Description^left|Issue Class^left|Raised By^left|System^left|SLA^left|" +                                                                                                    */
/*                "Date Raised^right|Time Raised^right|Date Completed^right|Time Completed^right|Date First Activity^right|Time First Activity^right|Activity Duration^right|SLA Achieved^left|SLA Comment^left|" +*/
/*                "Closed By^left"                                                                                                                                                                                 */
/*            ) SKIP.                                                                                                                                                                                              */
/*                                                                                                                                                                                                                 */
/*            li-count = 0.                                                                                                                                                                                        */
/*                                                                                                                                                                                                                 */
/*        END.                                                                                                                                                                                                     */
/*                                                                                                                                                                                                                 */
/*        li-count = li-count + 1.                                                                                                                                                                                 */
/*        IF li-count MOD 2 = 0                                                                                                                                                                                    */
/*            THEN lc-tr = '<tr style="background: #EBEBE6;">'.                                                                                                                                                    */
/*        ELSE lc-tr = '<tr style="background: white;">'.                                                                                                                                                          */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*        {&out}                                                                                                                                                                                                   */
/*            SKIP                                                                                                                                                                                                 */
/*            lc-tr                                                                                                                                                                                                */
/*            SKIP                                                                                                                                                                                                 */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.issuenumber)),'right')                                                                                                                               */
/*                                                                                                                                                                                                                 */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.briefDescription)),'left')                                                                                                                           */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.iType)),'left')                                                                                                                                      */
/*                                                                                                                                                                                                                 */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.RaisedLoginID)),'left')                                                                                                                              */
/*                                                                                                                                                                                                                 */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.AreaCode)),'left')                                                                                                                                   */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.SLADesc)),'left')                                                                                                                                    */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateDate,"99/99/9999")),'right')                                                                                                                   */
/*            htmlib-MntTableField(html-encode(STRING(tt-ilog.CreateTime,"hh:mm")),'right').                                                                                                                       */
/*                                                                                                                                                                                                                 */
/*        IF tt-ilog.CompDate <> ? THEN                                                                                                                                                                            */
/*            {&out}                                                                                                                                                                                               */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompDate,"99/99/9999")),'right')                                                                                                                         */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.CompTime,"hh:mm")),'right').                                                                                                                             */
/*        ELSE                                                                                                                                                                                                     */
/*        {&out}                                                                                                                                                                                                   */
/*            htmlib-MntTableField(html-encode(""),'right')                                                                                                                                                        */
/*            htmlib-MntTableField(html-encode(""),'right').                                                                                                                                                       */
/*                                                                                                                                                                                                                 */
/*        IF tt-ilog.fActDate <> ? THEN                                                                                                                                                                            */
/*            {&out}                                                                                                                                                                                               */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.fActDate,"99/99/9999")),'right')                                                                                                                         */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.fActTime,"hh:mm")),'right').                                                                                                                             */
/*        ELSE                                                                                                                                                                                                     */
/*        {&out}                                                                                                                                                                                                   */
/*            htmlib-MntTableField(html-encode(""),'right')                                                                                                                                                        */
/*            htmlib-MntTableField(html-encode(""),'right').                                                                                                                                                       */
/*        {&out}                                                                                                                                                                                                   */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.ActDuration)),'right')                                                                                                                                   */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.SLAAchieved)),'left')                                                                                                                                    */
/*        htmlib-MntTableField(REPLACE(tt-ilog.SLAComment,'~n','<br/>'),'left')                                                                                                                                    */
/*                                                                                                                                                                                                                 */
/*        htmlib-MntTableField(html-encode(STRING(tt-ilog.ClosedBy)),'left')                                                                                                                                       */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*            SKIP .                                                                                                                                                                                               */
/*                                                                                                                                                                                                                 */
/*        {&out} '</tr>' SKIP.                                                                                                                                                                                     */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*        IF LAST-OF(tt-ilog.AccountNumber) THEN                                                                                                                                                                   */
/*        DO:                                                                                                                                                                                                      */
/*            {&out} SKIP                                                                                                                                                                                          */
/*                htmlib-EndTable()                                                                                                                                                                                */
/*                SKIP.                                                                                                                                                                                            */
/*                                                                                                                                                                                                                 */
/*            {&out} htmlib-EndCriteria().                                                                                                                                                                         */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*        END.                                                                                                                                                                                                     */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*    END.                                                                                                                                                                                                         */
/*                                                                                                                                                                                                                 */
/*    FIND FIRST ttc NO-LOCK NO-ERROR.                                                                                                                                                                             */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*    IF AVAILABLE ttc THEN                                                                                                                                                                                        */
/*    DO:                                                                                                                                                                                                          */
/*        {&out} SKIP                                                                                                                                                                                              */
/*            '<script>' SKIP                                                                                                                                                                                      */
/*                                                                                                                                                                                                                 */
/*          'window.onload = function()~{' SKIP                                                                                                                                                                    */
/*        .                                                                                                                                                                                                        */
/*        FOR EACH ttc NO-LOCK:                                                                                                                                                                                    */
/*                                                                                                                                                                                                                 */
/*            {&out}                                                                                                                                                                                               */
/*            'var ctx = document.getElementById("' ttc.id '").getContext("2d");' SKIP.                                                                                                                            */
/*                                                                                                                                                                                                                 */
/*            IF  ttc.id BEGINS "B" THEN                                                                                                                                                                           */
/*            DO:                                                                                                                                                                                                  */
/*              {&out}                                                                                                                                                                                             */
/*            'window.myPie = new Chart(ctx).Bar(pd' ttc.id ', ~{' SKIP                                                                                                                                            */
/*            '  responsive : true ' SKIP                                                                                                                                                                          */
/*            '~});' SKIP.                                                                                                                                                                                         */
/*                                                                                                                                                                                                                 */
/*            END.                                                                                                                                                                                                 */
/*            ELSE {&out}                                                                                                                                                                                          */
/*            'window.myPie = new Chart(ctx).Pie(pd' ttc.id ');' SKIP.                                                                                                                                             */
/*                                                                                                                                                                                                                 */
/*        END.                                                                                                                                                                                                     */
/*                                                                                                                                                                                                                 */
/*        {&out}                                                                                                                                                                                                   */
/*        '~};' SKIP                                                                                                                                                                                               */
/*         '</script>' SKIP.                                                                                                                                                                                       */
/*                                                                                                                                                                                                                 */
/*                                                                                                                                                                                                                 */
/*    END.                                                                                                                                                                                                         */

END PROCEDURE.


PROCEDURE ip-ProcessReport :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/


/*                                     */
/*    RUN rep/issuelogbuild.p (        */
/*        lc-global-company,           */
/*        lc-global-user,              */
/*        lc-lo-Account,               */
/*        lc-hi-Account,               */
/*        get-value("allcust") = "on", */
/*        get-value("oneday") = "on",  */
/*        DATE(lc-lodate),             */
/*        DATE(lc-hidate),             */
/*        SUBSTR(TRIM(lc-classlist),2),*/
/*        OUTPUT TABLE tt-ilog         */
/*                                     */
/*        ).                           */

END PROCEDURE.



PROCEDURE ip-Selection :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    
   
    {&out}
        '</tr><tr>' SKIP
        '<td align=right valign=top>' 
        (IF LOOKUP("month",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Start From")
        ELSE htmlib-SideLabel("Start From"))
            
        '</td>'
        '<td align=left valign=top>'.
    {&out}
        htmlib-Select("month","1|2|3|4|5|6|7|8|9|10|11|12",lc-Global-Months-Name,get-value("month")).
        
    DEFINE VARIABLE li-year AS INTEGER NO-UNDO.
    ASSIGN li-year = YEAR(TODAY)
           cCode = ""
           .
    DO li-loop = 10 TO 1 BY -1:
        
        IF cCode = ""
        THEN cCode = STRING(li-year,"9999").
        ELSE cCode = cCode + "|" + string(li-year,"9999").
        ASSIGN li-year = li-year - 1.
        
    END.
    {&out} ' - '
        htmlib-Select("year",cCode,cCode,get-value("year")).
        
        
        
                    
    {&out} 
        '</td></tr>'.
        
   {&out} 
        '<tr><td align=right valign=top>' htmlib-SideLabel("Sales Rep") 
        '</td><td align=left valign=top>'.
    
    {&out-long}
        htmlib-SelectJSLong(
        "rep",
        'ChangeCriteria()',
        lc-selr-code,
        lc-selr-name,
        lc-crit-rep
        ) '</td>'.
        
        
                    
    
    DO li-loop = 1 TO NUM-ENTRIES(lc-global-opStatus-Code,"|"):
        lc-codeName = "chk" + ENTRY(li-loop,lc-global-opStatus-Code,"|").
        
        cCode = ENTRY(li-loop,lc-global-opStatus-Code,"|").
        cDesc = com-DecodeLookup(cCode,lc-global-opStatus-Code,lc-global-opStatus-desc).
        

        {&out} 
            '<tr><td valign="top" align="right">' 
            htmlib-SideLabel("Include Status " +  cDesc)
            '</td>'
            '<td valign="top" align="left">'
            htmlib-checkBox(lc-CodeName,get-value(lc-CodeName) = "on")
            '</td></tr>' SKIP.
    
    END.
  
    
    {&out}
        '<tr><td valign="top" align="right">' 
        htmlib-SideLabel("Report Output")
        '</td>'
        '<td align=left valign=top>' 
        htmlib-Select("output","WEB|CSV|PDF","Web Page|Email CSV|Email PDF",get-value("output")) '</td></tr>'.
    
  
    {&out} 
        '</table>' SKIP.
END PROCEDURE.


PROCEDURE ip-Validate :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      emails:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-error-field AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-error-msg  AS CHARACTER NO-UNDO.


     

    DO li-loop = 1 TO NUM-ENTRIES(lc-global-opStatus-Code,"|"):
        lc-codeName = "chk" + ENTRY(li-loop,lc-global-opStatus-Code,"|").
    
    
        IF get-value(lc-CodeName) = "on" THEN
        DO:
            lc-statusList = lc-StatusList + "," + 
                ENTRY(li-loop,lc-global-opStatus-Code,"|").
        END.
      
        
    END.
    IF TRIM(lc-StatusList ) = "" 
        THEN RUN htmlib-AddErrorMessage(
            'Lalal', 
            'You must select one or more statuses',
            INPUT-OUTPUT pc-error-field,
            INPUT-OUTPUT pc-error-msg ).





END PROCEDURE.



PROCEDURE outputHeader :
    /*------------------------------------------------------------------------------
      Purpose:     Output the MIME header, and any "cookie" information needed 
                   by this procedure.  
      Parameters:  <none>
      Notes:       In the event that this Web object is state-aware, this is
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



PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-filename AS CHARACTER NO-UNDO.
    
  
    {lib/checkloggedin.i}

    
    FIND this-user
        WHERE this-user.LoginID = lc-global-user NO-LOCK NO-ERROR.
    
    ASSIGN
        ll-customer = this-user.UserClass = "CUSTOMER".

    RUN ip-InitialProcess.

    IF request_method = "POST" AND lc-submit = "" THEN
    DO:
        
        
        RUN ip-Validate( OUTPUT lc-error-field,
            OUTPUT lc-error-msg ).

        IF lc-error-msg = "" THEN
        DO:
            RUN ip-ProcessReport.
            
            IF lc-output = "CSV" THEN RUN ip-ExportReport (OUTPUT lc-filename).
            ELSE
                IF lc-output = "PDF" THEN RUN ip-PDF (OUTPUT lc-filename).
            
            IF lc-output <> "WEB" THEN 
            DO:
            /*
            mlib-SendAttEmail 
                ( lc-global-company,
                "",
                "HelpDesk Issue Log Report ",
                "Please find attached your report covering the period "
                + string(DATE(lc-lodate),"99/99/9999") + " to " +
                string(DATE(lc-hidate),'99/99/9999'),
                this-user.email,
                "",
                "",
                lc-filename).
            OS-DELETE value(lc-filename).
            */
            END.
            
        END.
    END.
       
    RUN outputHeader.

    {&out} htmlib-Header("CRM Pipeline Report") SKIP.
    RUN ip-ExportJScript.
    {&out} htmlib-JScript-Maintenance() SKIP.
    {&out} htmlib-StartForm("mainform","post", appurl + '/rep/crmpipeline.p' ) SKIP.
    {&out} htmlib-ProgramTitle("Issue Log") 
        htmlib-hidden("submitsource","") SKIP.
    {&out} htmlib-BeginCriteria("Report Criteria").
    
    {&out} 
        '<table align=center><tr>' SKIP.

    RUN ip-Selection.

    {&out} htmlib-EndCriteria().

    

    IF lc-error-msg <> "" THEN
    DO:
        {&out} 
            '<BR><BR><CENTER>' 
            htmlib-MultiplyErrorMessage(lc-error-msg) '</CENTER>' SKIP.
    END.

    {&out} 
        '<center>' htmlib-SubmitButton("submitform","Report") 
        '</center>' SKIP.

    
    
    
    IF request_method = "POST" 
        AND lc-error-msg = "" THEN
    DO:
       
        IF lc-output = "WEB" THEN RUN ip-PrintReport.   
        ELSE
            {&out} '<div class="infobox" style="font-size: 10px;">Your report has been emailed to '
                this-user.email
                '</div>'.
            
        
    END.



    
    {&out} htmlib-EndForm() SKIP.
    {&OUT} htmlib-Footer() SKIP.


END PROCEDURE.



/* ************************  Function Implementations ***************** */





