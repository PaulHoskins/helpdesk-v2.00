/***********************************************************************

    Program:        cust/ivrenewal.p
    
    Purpose:        Inventory Renewal Browse
    
    Notes:
    
    
    When        Who         What
    16/07/2006  phoski      Initial 
    
    10/09/2010  DJS         3671 amended to utilise for inventory
                              renewals - added menu item
    26/11/2014  phoski      Ignore inactive customers                          
    
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

DEFINE VARIABLE lc-error-field AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-error-mess  AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-rowid       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-print  AS CHARACTER NO-UNDO.

DEFINE VARIABLE li-max-lines   AS INTEGER   INITIAL 12 NO-UNDO.


DEFINE BUFFER b-query  FOR ivField.
DEFINE BUFFER b-search FOR ivField.



  
DEFINE QUERY q FOR b-query SCROLLING.


DEFINE VARIABLE lc-info         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-object       AS CHARACTER NO-UNDO.
DEFINE VARIABLE li-tag-end      AS INTEGER   NO-UNDO.
DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.
DEFINE VARIABLE lc-Customer     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-link-otherp  AS CHARACTER NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
         WIDTH              = 60.57.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}
{lib/htmlib.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */


RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-ExportJScript) = 0 &THEN

PROCEDURE ip-ExportJScript :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

   
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-outputHeader) = 0 &THEN

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


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER Customer FOR Customer.

    DEFINE VARIABLE ld-date         AS DATE     NO-UNDO.
    DEFINE VARIABLE ld-renewal      AS DATE     NO-UNDO.

    {lib/checkloggedin.i}

    
    RUN outputHeader.
    
    
    {&out} htmlib-Header("Inventory Renewals") skip.

    RUN ip-ExportJScript.

    {&out} htmlib-JScript-Maintenance() skip.

    {&out} htmlib-StartForm("mainform","post", appurl + '/cust/ivrenewal.p' ) skip.

    {&out} htmlib-ProgramTitle("Inventory Renewals") 
    htmlib-hidden("submitsource","") skip
    .
  
    
    {&out}
    tbar-Begin(
        ""
        )
    tbar-BeginOption()
    tbar-Link("view",?,"off",lc-link-otherp)
    tbar-Link("update",?,"off",lc-link-otherp)
    tbar-EndOption()
    tbar-End().

    {&out} skip
           replace(htmlib-StartMntTable(),'width="100%"','width="97%"') skip
           htmlib-TableHeading(
            "Customer|Inventory Reference|Class|Field|Date|Warning Period|Days Remaining"
            ) skip.
 
    FOR EACH b-query NO-LOCK
        WHERE b-query.dType = "date"
        AND b-query.dWarning > 0,
        FIRST ivSub OF b-query NO-LOCK:

        IF ivSub.Company <> lc-global-company THEN NEXT.

        FOR EACH CustField NO-LOCK
            WHERE CustField.ivFieldID = b-query.ivFieldID:

            
            IF custField.FieldData = "" 
                OR custField.FieldData = ? THEN NEXT.

            ASSIGN
                ld-renewal = DATE(custfield.FieldData) no-error.
            IF ERROR-STATUS:ERROR 
                OR ld-renewal = ? THEN NEXT.

            IF TODAY >= ld-renewal - b-query.dWarning THEN 
            DO:

                FIND custIv 
                    WHERE custiv.CustIvID = 
                    custField.CustIvId NO-LOCK NO-ERROR.
                            
                FIND customer OF CustIv NO-LOCK NO-ERROR.
                
                IF Customer.IsActive = FALSE THEN NEXT.
                
                FIND ivClass  OF ivSub  NO-LOCK NO-ERROR.

                ASSIGN
                    lc-link-otherp = "returnback=renewal&customer=" + string(ROWID(customer)) +
                    '&' + htmlib-RandomURL().
                {&out}
                tbar-tr(ROWID(custiv))
                '<td>' html-encode(customer.AccountNumber + " - " + customer.name) '</td>'
                '<td>' html-encode(custiv.Ref)  '</td>'
                '<td>' html-encode(ivClass.name + " - " + 
                    ivSub.name ) '</td>'
                '<td>' html-encode(b-query.dLabel) '</td>'
                '<td>' STRING(ld-renewal,'99/99/9999') '</td>'
                '<td>' STRING(b-query.dWarning) '</td>'
                '<td>' ld-renewal - TODAY '</td>'
                tbar-BeginHidden(ROWID(custiv)) 
                tbar-Link("view",ROWID(custiv),appurl + '/cust/custequipmnt.p',lc-link-otherp)
                tbar-Link("update",ROWID(custiv),appurl + '/cust/custequipmnt.p',lc-link-otherp)
                tbar-EndHidden() 

                '</tr>' skip.

            END.
        END.

       
            
    END.

    {&out} skip 
           htmlib-EndTable()
           skip.


    {&out} htmlib-EndForm().

    
    {&OUT} htmlib-Footer() skip.
    
  
END PROCEDURE.


&ENDIF

