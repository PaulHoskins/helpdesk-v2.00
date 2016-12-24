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
DEFINE VARIABLE ll-Customer    AS LOGICAL   NO-UNDO.
DEFINE VARIABLE lc-filename    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-CodeName    AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-loop        AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-output      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-submit      AS CHARACTER NO-UNDO.
DEFINE VARIABLE cPart          AS CHARACTER NO-UNDO.
DEFINE VARIABLE cCode          AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDesc          AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-StatusList  AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-crit-rep    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-selr-Code   AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-selr-Name   AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE lc-Label       AS CHARACTER EXTENT 12 NO-UNDO.
DEFINE VARIABLE lc-Banner      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-tr          AS CHARACTER NO-UNDO.


{rep/crmpipelinett.i}


    

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


PROCEDURE ip-ExportReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE OUTPUT PARAMETER pc-filename AS CHARACTER NO-UNDO.
  

    DEFINE VARIABLE lc-GenKey AS CHARACTER NO-UNDO.

   
    ASSIGN
        lc-genkey = STRING(NEXT-VALUE(ReportNumber)).
    
        
    pc-filename = SESSION:TEMP-DIR + "/CRMPipeLine-" + lc-GenKey
        + ".csv".

    OUTPUT TO VALUE(pc-filename).

    PUT UNFORMATTED
                
        '"Sales Rep","Status","Type"' + lc-banner
        SKIP.


    FOR EACH tt-pipe NO-LOCK
        BREAK BY IF tt-pipe.loginid = "TOTAL" THEN 2 ELSE 1
        BY tt-pipe.loginid 
        BY tt-pipe.opStatus:
            
        EXPORT DELIMITER ','   
            tt-pipe.loginid
            tt-pipe.opDesc
            "Count"
            tt-pipe.ocount.
            
                 
        EXPORT DELIMITER ','   
            tt-pipe.loginid
            tt-pipe.opDesc
            "Revenue" tt-pipe.Rev.
            
        

        EXPORT DELIMITER ','   
            tt-pipe.loginid
            tt-pipe.opDesc
            "Cost"
            tt-pipe.Cost.
        

        EXPORT DELIMITER ','   
            tt-pipe.loginid
            tt-pipe.opDesc
            "GP Profit" 
            tt-pipe.gpProf.
            

        EXPORT DELIMITER ','   
            tt-pipe.loginid
            tt-pipe.opDesc
            "Projected Revenue" 
            tt-pipe.ProjRev.

                
        EXPORT DELIMITER ','   
            tt-pipe.loginid
            tt-pipe.opDesc
            "Projected"
            tt-pipe.ProjGP.
        
        
        
               
    END.
   
    OUTPUT CLOSE.


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
        
   
    ASSIGN 
        lc-selr-code = "ALL|" + lc-selr-code
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


PROCEDURE ip-Line:
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-status    AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pc-type      AS CHARACTER    NO-UNDO.
    DEFINE INPUT PARAMETER pf-value     AS DECIMAL EXTENT 13    NO-UNDO.
    
    DEFINE VARIABLE li-loop AS INTEGER NO-UNDO.
    
    {&out}
        SKIP
        lc-tr
        SKIP
        htmlib-MntTableField(html-encode(pc-status),'left')
        htmlib-MntTableField(html-encode(pc-type),'left')
        .

    DO li-loop = 1 TO 13:
        IF pc-type = "Count"
            THEN  {&out}
                htmlib-MntTableField(STRING(pf-value[li-loop],"zzzzzzzz9"),'right').
        ELSE
            {&out}
                htmlib-MntTableField("&pound" + com-money(pf-value[li-loop]),'right').
           
        
    END.
                       
    {&out} 
        '</tr>' SKIP.
         

END PROCEDURE.

PROCEDURE ip-PrintReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

 
    DEFINE VARIABLE li-count AS INTEGER NO-UNDO.


    {&out} SKIP                                                                                                                                                                                          
        htmlib-StartMntTable() SKIP                                                                                                                                                                      
        htmlib-TableHeading(                                                                                                                                                                             
        "Status|Type" + lc-banner                                                                                                                                           
        ) SKIP.  
        
        
    FOR EACH tt-pipe NO-LOCK
        BREAK BY IF tt-pipe.loginid = "TOTAL" THEN 2 ELSE 1
        BY tt-pipe.loginid 
        BY tt-pipe.opStatus:
            
          
        IF FIRST-OF(tt-pipe.loginid) THEN
        DO:
            li-count = 0.
           
            ASSIGN
                li-count = li-count + 1.
            IF li-count MOD 2 = 0
                THEN lc-tr = '<tr style="background: #EBEBE6;">'.
            ELSE lc-tr = '<tr style="background: white;">'.
            
            lc-tr = '<tr style="background: #d1d0c2;">'.
            
            {&out}
                SKIP
                lc-tr
                SKIP
                REPLACE(htmlib-MntTableField(html-encode((IF tt-pipe.loginid = "TOTAL" THEN "" ELSE "Sales Rep: " ) + tt-pipe.loginid),'left'),"<td","<td colspan=15 style='font-weight: bold;padding: 10px;'")
                '</tr>' SKIP.
            
        END.   
            
            
        ASSIGN
            li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.
        
        RUN ip-Line (tt-pipe.opdesc,"Count", tt-pipe.oCount).
        
        ASSIGN
            li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.
                
        RUN ip-Line ("","Revenue", tt-pipe.Rev).
        
        ASSIGN
            li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.
                
        RUN ip-Line ("","Cost", tt-pipe.Cost).
        
        ASSIGN
            li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.
                
        RUN ip-Line ("","GP Profit", tt-pipe.gpProf).
            
        ASSIGN
            li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.
                
        RUN ip-Line ("","Projected Revenue", tt-pipe.ProjRev).
        
            
        ASSIGN
            li-count = li-count + 1.
        IF li-count MOD 2 = 0
            THEN lc-tr = '<tr style="background: #EBEBE6;">'.
        ELSE lc-tr = '<tr style="background: white;">'.
                
        RUN ip-Line ("","Projected", tt-pipe.ProjGP).
        
        
        

     
                  
    END.    
    {&out} SKIP                                                                                                                                                                                          
        htmlib-EndTable()                                                                                                                                                                                
        SKIP. 
                                                                                                                                                                                             

END PROCEDURE.


PROCEDURE ip-ProcessReport :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE ld-start AS DATE    EXTENT 12 NO-UNDO.
    DEFINE VARIABLE li-loop  AS INTEGER NO-UNDO.
    
    
    ASSIGN
        ld-start[1] = DATE(int(get-value("month")),1,int(get-value("year"))).
    
    DO li-loop = 2 TO 12:
        ld-start[li-loop] = ADD-INTERVAL(ld-start[li-loop - 1 ],1,"month").    
    END.

    DO li-loop = 1 TO 12:
        ASSIGN 
            lc-label[li-loop] = ENTRY(MONTH(ld-start[li-loop]),lc-Global-Months-Name,"|") + " " + string(YEAR(ld-start[li-loop]),"9999").
            
        IF lc-output = "CSV"
            THEN lc-Banner = TRIM(lc-banner + ',"' + lc-label[li-loop] + '"' ).
        ELSE  
            ASSIGN 
                lc-banner = TRIM(lc-banner + "|" + lc-label[li-loop] + "^right").     
       
    END.
    
    IF lc-output = "CSV"
        THEN lc-Banner = TRIM(lc-banner + ',"Total"' ).
    ELSE  
        ASSIGN 
            lc-banner = TRIM(lc-banner + "|Total^right"). 
                
    
    
    RUN rep/crmpipeline-build.p (
        lc-global-company,
        lc-global-user,
        int(get-value("month")),
        int(get-value("year")),
        get-value("rep"),
        SUBSTR(TRIM(lc-statusList),2),
        OUTPUT TABLE tt-pipe
        ).

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
    ASSIGN 
        li-year = YEAR(TODAY)
        cCode   = ""
        .
    DO li-loop = 10 TO 1 BY -1:
        
        IF cCode = ""
            THEN cCode = STRING(li-year,"9999").
        ELSE cCode = cCode + "|" + string(li-year,"9999").
        ASSIGN 
            li-year = li-year - 1.
        
    END.
    {&out} 
        ' - '
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
        htmlib-Select("output","WEB|CSV","Web Page|Email CSV",get-value("output")) '</td></tr>'.
    
  
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
            
            FIND FIRST tt-pipe NO-LOCK NO-ERROR.
            
            IF NOT AVAILABLE tt-pipe
                THEN ASSIGN lc-error-msg = "There is no data to report".
            ELSE
            DO:
                
            
                IF lc-output = "CSV" THEN RUN ip-ExportReport (OUTPUT lc-filename).
        
                IF lc-output <> "WEB" THEN 
                DO:
            
                    mlib-SendAttEmail 
                        ( lc-global-company,
                        "",
                        "CRM Pipe Line Report ",
                        "Please find attached your report",
                        this-user.email,
                        "",
                        "",
                        lc-filename).
                    OS-DELETE value(lc-filename).
                END.
            END.
            
        END.
    END.
       
    RUN outputHeader.

    {&out} htmlib-Header("CRM Pipeline Report") SKIP.
    {&out} htmlib-JScript-Maintenance() SKIP.
    {&out} htmlib-StartForm("mainform","post", appurl + '/rep/crmpipeline.p' ) SKIP.
    {&out} 
        htmlib-ProgramTitle("Issue Log") 
        htmlib-hidden("submitsource","") SKIP
        htmlib-BeginCriteria("Report Criteria").
    
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





