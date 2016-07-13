/***********************************************************************

    Program:        lib/htmlib.i
    
    Purpose:        Standard HTML
    
    Notes:
    
    
    When        Who         What
    06/04/2006  phoski      DYNAMIC-FUNCTION('htmlib-ExpandBox':U)
    08/04/2006  phoski      DYNAMIC-FUNCTION('htmlib-Header':U),
                            strict doc type
    

    02/09/2010  DJS         3674 - Added function for Document Quickview
                              toolbar buttons
                              
    13/09/2010  DJS         3708  Added Calendar Input Field Submit     
    25/09/2014  phoski      Include security lib   
    30/11/2014  phoski      htmlib-SelectTime       
    26/03/2015  phoski      MntNoLines down max is 30   
    21/03/2016  phoski      Document Link Encrypt 
    21/05/2016  phoski      htmlib-SelectLong to fix problems with big 
                            selections
          
 ***********************************************************************/

{lib/common.i}
{lib/toolbar.i}
{lib/syseclib.i}




/* ********************  Preprocessor Definitions  ******************** */





/* ************************  Function Prototypes ********************** */

FUNCTION htmlib-AcrobatReport RETURNS CHARACTER
    ( pc-url AS CHARACTER
    )  FORWARD.


FUNCTION htmlib-ActionHidden RETURNS CHARACTER
    ( pc-value AS CHARACTER )  FORWARD.


FUNCTION htmlib-AddLink RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-ALookup RETURNS CHARACTER
    ( pc-field-name AS CHARACTER,
    pc-desc-name AS CHARACTER,
    pc-program AS CHARACTER  )  FORWARD.


FUNCTION htmlib-AnswerHyperLink RETURNS CHARACTER
    (INPUT pc-FieldName AS CHARACTER,
    INPUT pc-Value AS CHARACTER,
    INPUT pc-descfield AS CHARACTER,
    INPUT pc-descvalue AS CHARACTER,
    INPUT pc-Description AS CHARACTER) FORWARD.


FUNCTION htmlib-BeginCriteria RETURNS CHARACTER
    ( pc-legend AS CHARACTER )  FORWARD.


FUNCTION htmlib-BlankTableLines RETURNS CHARACTER
    ( pi-lines AS INTEGER )  FORWARD.


FUNCTION htmlib-Button RETURNS CHARACTER
    ( 
    pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pc-param AS CHARACTER
    ) FORWARD.


FUNCTION htmlib-CalendarInclude RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-CalendarInputField RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER )  FORWARD.


FUNCTION htmlib-CalendarLink RETURNS CHARACTER
    ( pc-name AS CHARACTER )  FORWARD.


FUNCTION htmlib-CalendarScript RETURNS CHARACTER
    ( pc-name AS CHARACTER )  FORWARD.


FUNCTION htmlib-CheckBox RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pl-checked AS LOG
    )  FORWARD.


FUNCTION htmlib-CloseHeader RETURNS CHARACTER
    ( params AS CHARACTER )  FORWARD.


FUNCTION htmlib-CustomerDocs RETURNS CHARACTER
    ( pc-companyCode AS CHARACTER,
    pc-AccountNumber AS CHARACTER,  
    pc-thisUser      AS CHARACTER , 
    pc-appurl AS CHARACTER,

    
     pl-isCustomer AS LOG)  FORWARD.


FUNCTION htmlib-CustomerViewable RETURNS CHARACTER
    ( pc-companyCode AS CHARACTER,
    pc-AccountNumber AS CHARACTER
    )  FORWARD.


FUNCTION htmlib-DecodeUser RETURNS CHARACTER
    ( pc-value AS CHARACTER )  FORWARD.


FUNCTION htmlib-EncodeUser RETURNS CHARACTER
    ( pc-user AS CHARACTER )  FORWARD.


FUNCTION htmlib-EndCriteria RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-EndFieldSet RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-EndForm RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-EndPanel RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-EndTable RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-ErrorMessage RETURNS CHARACTER
    ( pc-error AS CHARACTER )  FORWARD.


FUNCTION htmlib-ExpandBox RETURNS CHARACTER
    ( pc-objectID AS CHARACTER,
    pc-Data     AS CHARACTER )  FORWARD.


FUNCTION htmlib-Footer RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-GenPassword RETURNS CHARACTER
    ( pi-Length AS INTEGER )  FORWARD.


FUNCTION htmlib-GetAttr RETURNS CHARACTER
    ( pc-systemid AS CHARACTER,
    pc-attrid   AS CHARACTER
    )  FORWARD.


FUNCTION htmlib-Header RETURNS CHARACTER
    ( pc-title AS CHARACTER )  FORWARD.


FUNCTION htmlib-HelpButton RETURNS CHARACTER
    ( pc-appurl AS CHARACTER,
    pc-program AS CHARACTER  )  FORWARD.


FUNCTION htmlib-Hidden RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER )  FORWARD.


FUNCTION htmlib-ImageLink RETURNS CHARACTER
    ( 
    pc-image AS CHARACTER,
    pc-url AS CHARACTER,
    pc-alt AS CHARACTER)  FORWARD.


FUNCTION htmlib-InputField RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER )  FORWARD.


FUNCTION htmlib-InputPassword RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER )  FORWARD.


FUNCTION htmlib-Jscript-Lookup RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-JScript-Maintenance RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-JScript-Spinner RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-Lookup RETURNS CHARACTER
    ( pc-label AS CHARACTER ,
    pc-field-name AS CHARACTER,
    pc-desc-name AS CHARACTER,
    pc-program AS CHARACTER  )  FORWARD.


FUNCTION htmlib-LookupAction RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-action AS CHARACTER,
    pc-label AS CHARACTER )  FORWARD.


FUNCTION htmlib-mBanner RETURNS CHARACTER
    ( pc-companyCode AS CHARACTER )  FORWARD.


FUNCTION htmlib-MntButton RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-action AS CHARACTER,
    pc-label AS CHARACTER )  FORWARD.


FUNCTION htmlib-MntLink RETURNS CHARACTER
    ( pc-mode AS CHARACTER,
    pr-rowid AS ROWID,
    pc-url AS CHARACTER,
    pc-other-params AS CHARACTER )  FORWARD.


FUNCTION htmlib-MntTableField RETURNS CHARACTER
    ( pc-data AS CHARACTER,
    pc-align AS CHARACTER)  FORWARD.


FUNCTION htmlib-MntTableFieldComplex RETURNS CHARACTER
    ( pc-data AS CHARACTER,
    pc-align AS CHARACTER,
    pi-cols AS INTEGER,
    pi-rows AS INTEGER)  FORWARD.


FUNCTION htmlib-MultiplyErrorMessage RETURNS CHARACTER
    ( pc-error AS CHARACTER )  FORWARD.


FUNCTION htmlib-NexusParam RETURNS CHARACTER
    ( pc-param AS CHARACTER  )  FORWARD.


FUNCTION htmlib-NormalTextLink RETURNS CHARACTER
    ( pc-text AS CHARACTER,
    pc-url  AS CHARACTER )  FORWARD.


FUNCTION htmlib-Null RETURNS CHARACTER
    ( )  FORWARD.


FUNCTION htmlib-OpenHeader RETURNS CHARACTER
    ( pc-title AS CHARACTER )  FORWARD.


FUNCTION htmlib-ProgramTitle RETURNS CHARACTER
    ( pc-title AS CHARACTER )  FORWARD.


FUNCTION htmlib-Radio RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pl-checked AS LOG
    )  FORWARD.


FUNCTION htmlib-RandomURL RETURNS CHARACTER
    (  )  FORWARD.


FUNCTION htmlib-ReportButton RETURNS CHARACTER
    ( pc-url AS CHARACTER
    )  FORWARD.


FUNCTION htmlib-Select RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER )  FORWARD.


FUNCTION htmlib-Select-By-ID RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER )  FORWARD.


FUNCTION htmlib-SelectJS RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-js  AS CHARACTER,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER )  FORWARD.




FUNCTION htmlib-SelectLong RETURNS LONGCHAR 
	(pc-name AS CHARACTER,
	 pc-value AS CHARACTER,
	 pc-display AS CHARACTER,
	 pc-selected AS CHARACTER) FORWARD.


FUNCTION htmlib-SelectTime RETURNS CHARACTER 
    (pc-name AS CHARACTER,
    pc-selected AS CHARACTER) FORWARD.

FUNCTION htmlib-SideLabel RETURNS CHARACTER
    ( pc-Label AS CHARACTER )  FORWARD.


FUNCTION htmlib-SideLabelError RETURNS CHARACTER
    ( pc-Label AS CHARACTER )  FORWARD.


FUNCTION htmlib-SimpleBackButton RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-SimpleExpandBox RETURNS CHARACTER
    ( pc-objectID AS CHARACTER,
    pc-Data     AS CHARACTER )  FORWARD.


FUNCTION htmlib-SimpleTableRow RETURNS CHARACTER 
	(pc-label AS CHARACTER,
	 pc-data  AS CHARACTER,
	 pc-align AS CHARACTER) FORWARD.

FUNCTION htmlib-StartFieldSet RETURNS CHARACTER
    ( pc-legend AS CHARACTER  )  FORWARD.


FUNCTION htmlib-StartForm RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-method AS CHARACTER,
    pc-action AS CHARACTER )  FORWARD.


FUNCTION htmlib-StartInputTable RETURNS CHARACTER FORWARD.


FUNCTION htmlib-StartMntTable RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-StartPanel RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-StartTable RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-width AS INTEGER,
    pi-border AS INTEGER,
    pi-padding AS INTEGER,
    pi-spacing AS INTEGER,
    pc-align AS CHARACTER
    )  FORWARD.


FUNCTION htmlib-StyleSheet RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


FUNCTION htmlib-SubmitButton RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER 
    )  FORWARD.


FUNCTION htmlib-TableField RETURNS CHARACTER
    ( pc-data AS CHARACTER,
    pc-align AS CHARACTER)  FORWARD.


FUNCTION htmlib-TableHeading RETURNS CHARACTER
    ( pc-param AS CHARACTER )  FORWARD.


FUNCTION htmlib-TextArea RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pi-rows AS INTEGER,
    pi-cols AS INTEGER )  FORWARD.


FUNCTION htmlib-TextLink RETURNS CHARACTER
    ( pc-text AS CHARACTER,
    pc-url  AS CHARACTER )  FORWARD.


FUNCTION htmlib-TimeSelect RETURNS CHARACTER
    ( pc-hour-name    AS CHARACTER,
    pc-hour-value   AS CHARACTER,
    pc-min-name     AS CHARACTER,
    pc-min-value    AS CHARACTER )  FORWARD.


FUNCTION htmlib-TimeSelect-By-Id RETURNS CHARACTER
    ( pc-hour-name    AS CHARACTER,
    pc-hour-value   AS CHARACTER,
    pc-min-name     AS CHARACTER,
    pc-min-value    AS CHARACTER )  FORWARD.


FUNCTION htmlib-trmouse RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.



/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */



/* **********************  Internal Procedures  *********************** */

PROCEDURE htmlib-AddErrorMessage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-field        AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pc-message      AS CHARACTER NO-UNDO.

    DEFINE INPUT-OUTPUT PARAMETER pc-field-list  AS CHARACTER NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER pc-mess-list   AS CHARACTER NO-UNDO.

    IF pc-field-list = ""
        OR pc-field-list = ""
        THEN ASSIGN pc-field-list = pc-field
            pc-mess-list  = pc-message.
    ELSE ASSIGN pc-field-list = pc-field-list + '|' + pc-field
            pc-mess-list  = pc-mess-list + '|' + pc-message.

END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION htmlib-AcrobatReport RETURNS CHARACTER
    ( pc-url AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN  SUBSTITUTE(
        '<a class="imglink" onclick="RepWindow(~'&1~')"><img src="/images/general/acrobat.gif"></a>',
        pc-url).
  

END FUNCTION.


FUNCTION htmlib-ActionHidden RETURNS CHARACTER
    ( pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN htmlib-Hidden("action", pc-value).

END FUNCTION.


FUNCTION htmlib-AddLink RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    /*
     return substitute('<a href="&2">&1</a>',
                          pc-text,
                          pc-url ).
    */
  
    RETURN "".   /* Function return value. */

END FUNCTION.


FUNCTION htmlib-ALookup RETURNS CHARACTER
    ( pc-field-name AS CHARACTER,
    pc-desc-name AS CHARACTER,
    pc-program AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-htm   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-click AS CHARACTER NO-UNDO.

    ASSIGN
        lc-click = 'javascript:LookupWindow('
            + '~'' + pc-program + '~','
            + '~'' + pc-field-name + '~','
            + '~'' + pc-desc-name + '~''

        + ')'.
    ASSIGN 
        lc-htm = '<a href="' 
            + lc-click +
            '">' +
        '<img src="/images/general/lookup.gif" border=0 align="middle" alt="Lookup">' +
        '</a>'
        .
    
   
    RETURN lc-htm.

END FUNCTION.


FUNCTION htmlib-AnswerHyperLink RETURNS CHARACTER
    (INPUT pc-FieldName AS CHARACTER,
    INPUT pc-Value AS CHARACTER,
    INPUT pc-descfield AS CHARACTER,
    INPUT pc-descvalue AS CHARACTER,
    INPUT pc-Description AS CHARACTER):


    RETURN "<a href=~"#~""
        + " onclick=~'javascript:opener.document.forms[0]." 
        + pc-FieldName + ".value=~"" + pc-Value + 
        "~";opener.document.forms[0]."
        + pc-descfield + ".value=~"" + pc-descvalue + 
        "~";" +
        "opener.document.forms[0]." 
        + pc-FieldName + ".focus();"
        +
        "opener.document.forms[0]." 
        + pc-FieldName + ".blur();"
        +
        "window.close();~'>" 
        + pc-Description + "</a> <br>".

END FUNCTION.


FUNCTION htmlib-BeginCriteria RETURNS CHARACTER
    ( pc-legend AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF pc-legend <> ""
        THEN RETURN '<div class="crit"><fieldset><legend>' + 
            dynamic-function("html-encode",pc-legend) + '</legend>'.
    ELSE RETURN '<div class="crit"><fieldset>'.

END FUNCTION.


FUNCTION htmlib-BlankTableLines RETURNS CHARACTER
    ( pi-lines AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-char AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-char = '<tr>' + htmlib-TableField("&nbsp;",'left') + '</tr>'.
        
    IF pi-lines > 100 
    THEN pi-lines = 0.
    

    IF pi-lines > 0 THEN
        RETURN FILL(lc-char,pi-lines).   /* Function return value. */
    ELSE RETURN "".

END FUNCTION.


FUNCTION htmlib-Button RETURNS CHARACTER
    ( 
    pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pc-param AS CHARACTER
    ):
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN SUBSTITUTE('<input onclick="SubmitThePage(~'&3~')" class="submitbutton" type="button" name="&1" value="&2">',
        pc-name,
        pc-value,
        pc-param).

END FUNCTION.


FUNCTION htmlib-CalendarInclude RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '~n' + 
        '<link rel="stylesheet" href="/scripts/cal/calendar-blue.css?v=1.0.0" type="text/css" >' + '~n' +
        '<script type="text/javascript" src="/scripts/cal/calendar.js?v1.0.0"></script>' + '~n' + 
        '<script type="text/javascript" src="/scripts/cal/lang/calendar-en.js?v=1.0.0"></script>' + '~n' + 
        '<script type="text/javascript" src="/scripts/cal/calendar-setup.js?v=1.0.0"></script>' + '~n'.


END FUNCTION.


FUNCTION htmlib-CalendarInputField RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        SUBSTITUTE(
        '<input class="inputfield" type="text" name="&1" id="ff&1" size="&2" value="&3" onChange="ChangeDates()">',
        pc-name,
        STRING(pi-size),
        pc-value).

END FUNCTION.


FUNCTION htmlib-CalendarLink RETURNS CHARACTER
    ( pc-name AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        SUBSTITUTE('<img src="/images/general/calendar.gif" id="trigger-ff&1" class="calimg">',
        pc-name).


END FUNCTION.


FUNCTION htmlib-CalendarScript RETURNS CHARACTER
    ( pc-name AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

  
    RETURN 
        
        '<script type="text/javascript">' + '~n' +
        'Calendar.setup(' + '~n' +
        '~{' + '~n' +
        'inputField  : "ff' + pc-name + '",' + '~n' +
        'ifFormat    : "%d/%m/%Y",' + '~n' +
        'button      : "trigger-ff' + pc-name + '",' + '~n' +
        'firstDay : 1 ,' + '~n' +
        'electric : false ' + '~n' +          /* if true (default) then given fields/date areas are updated for each move; otherwise they're updated only on close */
        /*             'singleClick : false ' + '~n' + */ /* (true/false) wether the calendar is in single click mode or not (default: true) */
        '~}' + '~n' +
        ');' + '~n' +
        '</script>' + '~n'.
END FUNCTION.


FUNCTION htmlib-CheckBox RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pl-checked AS LOG
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-checked AS CHARACTER NO-UNDO.

    IF pl-checked
        THEN ASSIGN lc-checked = 'checked'.

    RETURN 
        SUBSTITUTE(
        '<input class="inputfield" type="checkbox" id="&1" name="&1" &2 >',
        pc-name,
        lc-checked).
              

END FUNCTION.


FUNCTION htmlib-CloseHeader RETURNS CHARACTER
    ( params AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-header AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.
  
    IF params <> "" THEN
        ASSIGN
            lc-return = lc-return + '~n</HEAD>' + '<body class="normaltext" onUnload="ClosePage()" onLoad="' + params + '">'.
    ELSE
        ASSIGN
            lc-return = lc-return + '~n</HEAD>' + '<body class="normaltext" onUnload="ClosePage()">'.

    RETURN lc-return.


END FUNCTION.


FUNCTION htmlib-CustomerDocs RETURNS CHARACTER
    ( pc-companyCode AS CHARACTER,
    pc-AccountNumber AS CHARACTER,  
    pc-thisUser      AS CHARACTER,
    pc-appurl AS CHARACTER , 
    pl-isCustomer AS LOG

    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Customer FOR Customer.
    DEFINE VARIABLE btnLink   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vx        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-doc-key  AS CHARACTER NO-UNDO. 
    
    
    FIND customer
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE customer THEN RETURN "".
    
    
    ASSIGN 
        lc-return = '<div class="buttonbox" >'.
    
    
    FOR EACH doch NO-LOCK
        WHERE doch.CompanyCode = lc-global-company
        AND doch.RelType       = "customer"
        AND doch.RelKey        = customer.AccountNumber
        AND doch.QuickView     = TRUE
        BY doch.CreateDate DESCENDING
        :
        
        IF pl-isCustomer AND doch.CustomerView = FALSE THEN NEXT.
        
    
        ASSIGN 
            lc-doc-key = DYNAMIC-FUNCTION("sysec-EncodeValue",pc-thisUser,TODAY,"Document",STRING(ROWID(doch))).
            
         
        lc-doc-key = DYNAMIC-FUNCTION("url-encode",lc-doc-key,"Query").
        
        vx = vx + 1.
        IF vx > 3 THEN LEAVE.
      
        btnLink = 'javascript:OpenNewWindow('
            + '~'' + pc-appurl
            + '/sys/docview.' + lc(doch.doctype) + '?docid=' + lc-doc-key
            + '~''
            + ');'.
        lc-return = lc-return + '<a class="button" href="' + btnLink 
            + '" onclick="this.blur();"><span> &nbsp;&nbsp; ' 
            + trim(doch.descr) + '</span></a>' .   
    
    END.
    ASSIGN 
        lc-return = lc-return + '</div>'.
    
    IF vx = 0 THEN RETURN "". 
    ELSE RETURN lc-return.
    

END FUNCTION.


FUNCTION htmlib-CustomerViewable RETURNS CHARACTER
    ( pc-companyCode AS CHARACTER,
    pc-AccountNumber AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER Customer FOR Customer.

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    FIND customer
        WHERE customer.CompanyCode = pc-CompanyCode
        AND customer.AccountNumber = pc-AccountNumber NO-LOCK NO-ERROR.


    IF NOT AVAILABLE customer THEN RETURN "".


    ASSIGN 
        lc-return = '<div class="infobox" style="font-size: 10px;">'.

    IF NOT customer.ViewAction THEN
    DO:
        ASSIGN 
            lc-return = lc-return + "This customer can NOT view Actions/Activities".
    END.
    ELSE
    DO:
        IF NOT customer.ViewActivity 
            THEN ASSIGN lc-return = lc-return + "This customer can view Actions only, Activities are not shown".
        ELSE ASSIGN lc-return = lc-return + "<span style='color: red;'>This customer can view Actions AND Activities</span>".
    END.

    ASSIGN 
        lc-return = lc-return + '</div>'.


    RETURN lc-return.


END FUNCTION.


FUNCTION htmlib-DecodeUser RETURNS CHARACTER
    ( pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-part1  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-part2  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-part3  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-part4  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lr-rowid  AS ROWID     NO-UNDO.
    DEFINE VARIABLE lc-remote AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER b-webuser FOR webuser.

    IF NUM-ENTRIES(pc-value,':') <> 4 THEN RETURN "".

    
    ASSIGN 
        lc-part1 = ENTRY(1,pc-value,':')
        lc-part2 = ENTRY(2,pc-value,':')
        lc-part3 = ENTRY(3,pc-value,':')
        lc-part4 = ENTRY(4,pc-value,":").


    ASSIGN 
        lr-rowid = TO-ROWID(lc-part2) no-error.
    IF ERROR-STATUS:ERROR THEN RETURN "".
 
    FIND b-webuser WHERE ROWID(b-webuser) = lr-rowid NO-LOCK NO-ERROR.
    IF NOT AVAILABLE b-webuser 
        THEN RETURN "".


    IF lc-part1 <> encode(LC(b-webuser.loginid)) 
        THEN RETURN "".

    IF lc-part3 <> encode('ExtraInfo')
        THEN RETURN "".

    /*
    IF lc-part4 <> ENCODE(lc-remote) THEN
    DO:
        MESSAGE "Remote Addr changed".
        RETURN "".
    END.
    */

    RETURN b-webuser.loginid.

END FUNCTION.


FUNCTION htmlib-EncodeUser RETURNS CHARACTER
    ( pc-user AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-code AS CHARACTER NO-UNDO.
    DEFINE BUFFER b-web FOR webuser.
    DEFINE VARIABLE lc-remote AS CHARACTER NO-UNDO.
    
    FIND b-web WHERE b-web.loginid = pc-user NO-LOCK NO-ERROR.

    IF AVAILABLE b-web 
        THEN ASSIGN lc-code = ENCODE(LC(pc-user)) +
                        ':' +
                        string(ROWID(b-web)) + 
                        ':' + 
                        encode('ExtraInfo') +
                        ":" + 
                        ENCODE(lc-remote).
   
    
    RETURN lc-code.  

END FUNCTION.


FUNCTION htmlib-EndCriteria RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '</fieldset></div>'.

END FUNCTION.


FUNCTION htmlib-EndFieldSet RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '</fieldset></span>'.

END FUNCTION.


FUNCTION htmlib-EndForm RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        '</fieldset></span></form>'.

END FUNCTION.


FUNCTION htmlib-EndPanel RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN "</table>".   /* Function return value. */

END FUNCTION.


FUNCTION htmlib-EndTable RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '</table>'.  

END FUNCTION.


FUNCTION htmlib-ErrorMessage RETURNS CHARACTER
    ( pc-error AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

  
    ASSIGN 
        pc-error = '<span class="errormessage">' + pc-error + '</span>'.

      
    RETURN pc-error.

END FUNCTION.


FUNCTION htmlib-ExpandBox RETURNS CHARACTER
    ( pc-objectID AS CHARACTER,
    pc-Data     AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.


    DEFINE VARIABLE lc-return       AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-return = '<div class="expandboxc" id="' + pc-objectID +
         '" style="display: none;"><fieldset><legend>Details</legend>'.
    
    ASSIGN 
        lc-return = lc-return + 
        replace(
            DYNAMIC-FUNCTION("html-encode",REPLACE(pc-data,"~n",lc-dummy-return)),
                           lc-dummy-return,'<br/>').
       
    ASSIGN 
        lc-return = lc-return + '</fieldset></div>'.

    RETURN lc-return.

END FUNCTION.


FUNCTION htmlib-Footer RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN "</body></html>".


END FUNCTION.


FUNCTION htmlib-GenPassword RETURNS CHARACTER
    ( pi-Length AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-const  AS CHARACTER
        INITIAL 'abcdefghijklmnopqrstuvwxyz0123456789'
        NO-UNDO.

    DEFINE VARIABLE lc-string AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-last   AS CHARACTER CASE-SENSITIVE NO-UNDO.
    DEFINE VARIABLE lc-this   AS CHARACTER CASE-SENSITIVE NO-UNDO.
    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    REPEAT:
        ASSIGN 
            li-loop = RANDOM(0,ETIME).

        ASSIGN 
            li-loop = RANDOM(1,LENGTH(lc-const)).

        ASSIGN 
            lc-this = substr(lc-const,li-loop,1).

        IF RANDOM(1,100) > 50
            THEN ASSIGN lc-this = CAPS(lc-this).

        IF lc-this = lc-last THEN NEXT.

        lc-last = lc-this.

        IF lc-return = ""
            THEN lc-return = lc-this.
        ELSE lc-return = lc-return + lc-this.

        IF LENGTH(lc-return) = pi-length THEN LEAVE.



    END.

    RETURN lc-return.

END FUNCTION.


FUNCTION htmlib-GetAttr RETURNS CHARACTER
    ( pc-systemid AS CHARACTER,
    pc-attrid   AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b-attr  FOR webattr.
    DEFINE BUFFER webuser FOR webuser.

    IF pc-attrid = "MNTNoLinesDown" AND lc-global-user <> ""
        AND CAN-FIND(webuser WHERE webuser.loginid = lc-global-user NO-LOCK) THEN
    DO:
        FIND webuser WHERE webuser.loginid = lc-global-user NO-LOCK NO-ERROR.

        IF webuser.recordsperpage > 0 
            THEN RETURN STRING(max(30,webuser.recordsperpage)).
    END.

    FIND b-attr WHERE b-attr.systemid = pc-systemid
        AND b-attr.attrid   = pc-attrid NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE b-attr
        THEN b-attr.attrvalue
        ELSE "".

END FUNCTION.


FUNCTION htmlib-Header RETURNS CHARACTER
    ( pc-title AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-header   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-return   AS CHARACTER NO-UNDO.

    DEFINE VARIABLE ll-backbase AS LOG       NO-UNDO.


    IF LOOKUP("ip-HTM-Header",THIS-PROCEDURE:INTERNAL-ENTRIES) > 0 THEN
    DO:
        RUN ip-HTM-Header IN this-procedure 
            ( OUTPUT lc-header ).
    END.

    ASSIGN 
        lc-return = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' + '~n' +
         '<html>~n' +
         '<head>~n' +
         lc-header + 
         '~n<meta http-equiv="X-UA-Compatible" content="IE=7">' + '~n' +
         '<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>' + '~n' +
         '<meta http-equiv="Cache-Control" content="No-Cache">' + '~n' +
         '<meta http-equiv="Pragma"        content="No-Cache">' + '~n' +
         '<meta http-equiv="Expires"       content="0">' + '~n' +
         '<title>' + pc-title + '</title>~n' +
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U) +
         '~n<script type="text/javascript" src="/scripts/js/tabber.js?v=1.0.0"></script>' + '~n' +
         '<link rel="stylesheet" href="/style/tab.css?v=1.0.0" TYPE="text/css" MEDIA="screen">' + '~n' +
         '<script language="JavaScript" src="/scripts/js/standard.js?v=1.0.0"></script>' + '~n'.
   
  

    IF LOOKUP("ip-HeaderInclude-Calendar",THIS-PROCEDURE:INTERNAL-ENTRIES) > 0 THEN
    DO:
        ASSIGN 
            lc-return = lc-return  + DYNAMIC-FUNCTION('htmlib-CalendarInclude':U).
          
    END.

    ASSIGN
        lc-return = lc-return + '~n</head>~n' + '<body class="normaltext" onUnload="ClosePage()">~n'
        .

    RETURN lc-return.


END FUNCTION.


FUNCTION htmlib-HelpButton RETURNS CHARACTER
    ( pc-appurl AS CHARACTER,
    pc-program AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-url AS CHARACTER NO-UNDO.

    DEFINE BUFFER b-attr FOR webattr.

    RETURN "".
  
END FUNCTION.


FUNCTION htmlib-Hidden RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    RETURN 
        SUBSTITUTE(
        '<input  type="hidden" id="&1" name="&1" value="&2">',
        pc-name,
        pc-value).


END FUNCTION.


FUNCTION htmlib-ImageLink RETURNS CHARACTER
    ( 
    pc-image AS CHARACTER,
    pc-url AS CHARACTER,
    pc-alt AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN
        SUBSTITUTE(
        '<a href="&1"><img border="0" src="&2" alt="&3"></a>',
        pc-url,
        pc-image,
        pc-alt).
      

END FUNCTION.


FUNCTION htmlib-InputField RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        SUBSTITUTE(
        '<input class="inputfield" type="text" name="&1" id="ff&1" size="&2" value="&3">',
        pc-name,
        STRING(pi-size),
        pc-value).

END FUNCTION.


FUNCTION htmlib-InputPassword RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-size AS INTEGER,
    pc-value AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        SUBSTITUTE(
        '<input class="inputfield" type="password" name="&1" size="&2" value="&3">',
        pc-name,
        STRING(pi-size),
        pc-value).


END FUNCTION.


FUNCTION htmlib-Jscript-Lookup RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '~n<script language="JavaScript" src="/scripts/js/lookup.js?v1.0.0"></script>~n'.   

END FUNCTION.


FUNCTION htmlib-JScript-Maintenance RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '~n<script language="JavaScript" src="/scripts/js/maint.js?v=1.0.0"></script>~n'.   

END FUNCTION.


FUNCTION htmlib-JScript-Spinner RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '~n' +
        '<link rel="stylesheet" href="/style/spinner.css?fn="' + string(TIME) + string(RANDOM(1,100)) + '" type="text/css" >' + '~n' +
        '<script language="JavaScript" src="/scripts/js/spinner.js"></script>'. 

END FUNCTION.


FUNCTION htmlib-Lookup RETURNS CHARACTER
    ( pc-label AS CHARACTER ,
    pc-field-name AS CHARACTER,
    pc-desc-name AS CHARACTER,
    pc-program AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    

    RETURN DYNAMIC-FUNCTION('htmlib-ALookup':U,
        pc-field-name,
        pc-desc-name,
        pc-program).

END FUNCTION.


FUNCTION htmlib-LookupAction RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-action AS CHARACTER,
    pc-label AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN  SUBSTITUTE(
        '<INPUT onclick="LookupButtonPress(~'&1~',~'&2~')" type=button class="actionbutton" value="&3">',
        pc-action,
        pc-url,
        pc-label).
 

END FUNCTION.


FUNCTION htmlib-mBanner RETURNS CHARACTER
    ( pc-companyCode AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER company FOR company.


    FIND company WHERE company.companycode = pc-companycode NO-LOCK NO-ERROR.

    RETURN IF AVAILABLE company THEN TRIM(company.mBanner) ELSE "".

END FUNCTION.


FUNCTION htmlib-MntButton RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-action AS CHARACTER,
    pc-label AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF pc-action = "prevpage" 
        THEN RETURN 
            '<a href="javascript:MntButtonPress(~'' + pc-action + '~',~'' + pc-url + '~')">'
            + '<img src="/images/toolbar/prev.gif" border=0 alt="Previous Page"></a>'
            .
    ELSE
        IF pc-action = "nextpage" 
            THEN RETURN 
                '<a href="javascript:MntButtonPress(~'' + pc-action + '~',~'' + pc-url + '~')">'
                + '<img src="/images/toolbar/next.gif" border=0 alt="Next Page"></a>'
                .
        ELSE
            IF pc-action = "firstpage" 
                THEN RETURN 
                    '<a href="javascript:MntButtonPress(~'' + pc-action + '~',~'' + pc-url + '~')">'
                    + '<img src="/images/toolbar/begin.gif" border=0 alt="First Page"></a>'
                    .
            ELSE
                IF pc-action = "lastpage" 
                    THEN RETURN 
                        '<a href="javascript:MntButtonPress(~'' + pc-action + '~',~'' + pc-url + '~')">'
                        + '<img src="/images/toolbar/end.gif" border=0 alt="Last Page"></a>'
                        .
                ELSE RETURN  SUBSTITUTE(
                        '<INPUT onclick="MntButtonPress(~'&1~',~'&2~')" type=button class="actionbutton" value="&3">',
                        pc-action,
                        pc-url,
                        pc-label).
 

END FUNCTION.


FUNCTION htmlib-MntLink RETURNS CHARACTER
    ( pc-mode AS CHARACTER,
    pr-rowid AS ROWID,
    pc-url AS CHARACTER,
    pc-other-params AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-image    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-alt-text AS CHARACTER NO-UNDO.

    CASE pc-mode:
        WHEN 'add':U
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/add.gif'
                lc-alt-text = 'Add'.
        WHEN 'delete':U
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/delete.gif'
                lc-alt-text = 'Delete'.
        WHEN 'update':U
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/update.gif'
                lc-alt-text = 'Update'.
        WHEN 'view':u
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/view.gif'
                lc-alt-text = 'View'.
        WHEN 'genpassword' 
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/lock.gif'
                lc-alt-text = 'Generate password'.
        WHEN "contaccess" 
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/contaccess.gif'
                lc-alt-text = 'Contractor account access'.
        WHEN "doclist" 
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/doclist.gif'
                lc-alt-text = 'Documents'.
        WHEN "eqsubclass"
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/eqsubedit.gif'
                lc-alt-text = 'Inventory subclassifications'.
        WHEN "customfield"
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/customfield.gif'
                lc-alt-text = 'Define custom fields'.
        WHEN "custequip"
        THEN 
            ASSIGN 
                lc-image    = '/images/maintenance/custequip.gif'
                lc-alt-text = 'Customer equipment'.
    END CASE.
    ASSIGN 
        pc-url = pc-url + '?mode=' + pc-mode
                    + '&rowid=' + IF pr-rowid = ? THEN "" ELSE STRING(pr-rowid).
    IF pc-other-params <> ""
        AND pc-other-params <> ?
        THEN ASSIGN pc-url = pc-url + "&" + pc-other-params.


    RETURN htmlib-ImageLink(lc-image,pc-url,
        lc-alt-text).

END FUNCTION.


FUNCTION htmlib-MntTableField RETURNS CHARACTER
    ( pc-data AS CHARACTER,
    pc-align AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    /*
    assign lc-return = '<td class="mnttablefield" valign="top"'.
    */

    ASSIGN 
        lc-return = '<td valign="top"'.

    IF pc-data = ""
        THEN pc-data = "&nbsp;".

    IF pc-align <> ""
        THEN lc-return = lc-return + ' align="' + pc-align + '">'.
    ELSE lc-return = lc-return + '>'.

    ASSIGN 
        lc-return = lc-return + pc-data + '</td>'.

    RETURN lc-return.


END FUNCTION.


FUNCTION htmlib-MntTableFieldComplex RETURNS CHARACTER
    ( pc-data AS CHARACTER,
    pc-align AS CHARACTER,
    pi-cols AS INTEGER,
    pi-rows AS INTEGER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    /*
    assign lc-return = '<td class="mnttablefield" valign="top"'.
    */

    ASSIGN 
        lc-return = '<td valign="top"'.

    IF pi-cols > 1 THEN
    DO:
        lc-return = lc-return + ' colspan="' + string(pi-cols) 
            + '" '.
        
    END.

    IF pi-rows > 1 THEN
    DO:
        lc-return = lc-return + ' rowspan="' + string(pi-rows) 
            + '" '.
          
    END.
    IF pc-data = ""
        THEN pc-data = "&nbsp;".

    IF pc-align <> ""
        THEN lc-return = lc-return + ' align="' + pc-align + '">'.
    ELSE lc-return = lc-return + '>'.

    ASSIGN 
        lc-return = lc-return + pc-data + '</td>'.

    RETURN lc-return.


END FUNCTION.


FUNCTION htmlib-MultiplyErrorMessage RETURNS CHARACTER
    ( pc-error AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-loop    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-message AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-line    AS CHARACTER NO-UNDO.
   
    IF NUM-ENTRIES(pc-error,'|') > 0
        AND pc-error <> "" THEN
    DO:
    
        ASSIGN 
            lc-message = '<p class="errormessage">'.
        
        DO li-loop = 1 TO NUM-ENTRIES(pc-error,'|'):

            IF li-loop > 1
                THEN ASSIGN lc-message = lc-message + "<br>".

            ASSIGN 
                lc-line = ENTRY(li-loop,pc-error,'|').

            IF lc-message = ""
                THEN lc-message = lc-line.
            ELSE lc-message = lc-message + lc-line.

        END.
        ASSIGN 
            lc-message = lc-message + "</p>".
    END.
    RETURN lc-message.

END FUNCTION.


FUNCTION htmlib-NexusParam RETURNS CHARACTER
    ( pc-param AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-value AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-value = htmlib-GetAttr("Nexus",pc-param).

    IF lc-value = "" 
        THEN MESSAGE 'Nexus missing ' pc-param.
    ELSE lc-value = '<param name="' + pc-param + '" value="' +
            lc-value + '">'.

    RETURN lc-value.   /* Function return value. */

END FUNCTION.


FUNCTION htmlib-NormalTextLink RETURNS CHARACTER
    ( pc-text AS CHARACTER,
    pc-url  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN SUBSTITUTE('<a href="&2">&1</a>',
        pc-text,
        pc-url ).

END FUNCTION.


FUNCTION htmlib-Null RETURNS CHARACTER
    ( ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN "AllHDDataAvail".   /* Function return value. */

END FUNCTION.


FUNCTION htmlib-OpenHeader RETURNS CHARACTER
    ( pc-title AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-header   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-return   AS CHARACTER NO-UNDO.

    DEFINE VARIABLE ll-backbase AS LOG       NO-UNDO.


    IF LOOKUP("ip-HTM-Header",THIS-PROCEDURE:INTERNAL-ENTRIES) > 0 THEN
    DO:
        RUN ip-HTM-Header IN this-procedure 
            ( OUTPUT lc-header ).
    END.

    ASSIGN 
        lc-return = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' + '~n' +
         '<html>' +
         '<head>' +
         lc-header + 
         '<meta http-equiv="X-UA-Compatible" content="IE=7">' + '~n' +
         '<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7"/>' + '~n' +
         '<meta http-equiv="Cache-Control" content="No-Cache">' + '~n' +
         '<meta http-equiv="Pragma"        content="No-Cache">' + '~n' +
         '<meta http-equiv="Expires"       content="0">' + '~n' +
         '<title>' + pc-title + '</title>' +
         DYNAMIC-FUNCTION('htmlib-StyleSheet':U) +
         '<script type="text/javascript" src="/scripts/js/tabber.js"></script>' + '~n' +
         '<link rel="stylesheet" href="/style/tab.css" TYPE="text/css" MEDIA="screen">' + '~n' +
         '<script language="JavaScript" src="/scripts/js/standard.js"></script>' + '~n'.
   
  

    IF LOOKUP("ip-HeaderInclude-Calendar",THIS-PROCEDURE:INTERNAL-ENTRIES) > 0 THEN
    DO:
        ASSIGN 
            lc-return = lc-return + DYNAMIC-FUNCTION('htmlib-CalendarInclude':U).
          
    END.

 
    RETURN lc-return.


END FUNCTION.


FUNCTION htmlib-ProgramTitle RETURNS CHARACTER
    ( pc-title AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/



    RETURN '<div class="programtitle">' + pc-title + '</div><br>'.


  
END FUNCTION.


FUNCTION htmlib-Radio RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pl-checked AS LOG
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-checked AS CHARACTER NO-UNDO.

    IF pl-checked
        THEN ASSIGN lc-checked = 'checked'.

    RETURN 
        SUBSTITUTE(
        '<input class="inputfield" type="radio" id="&1" name="&1" value="&2" &3 >',
        pc-name,
        pc-value,
        lc-checked).
              


END FUNCTION.


FUNCTION htmlib-RandomURL RETURNS CHARACTER
    (  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        "RanDomTimeValue=" + 
        string(int(TODAY)) +
        string(TIME) +
        string(RANDOM(1,1000)).

END FUNCTION.


FUNCTION htmlib-ReportButton RETURNS CHARACTER
    ( pc-url AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

  
    RETURN  SUBSTITUTE(
        '<a class="imglink" onclick="RepWindow(~'&1~')"><img src="/images/general/print.gif"></a>',
        pc-url).
/*
return  substitute(
        '<INPUT onclick="RepWindow(~'&1~')" type=button class="actionbutton" value="Report">',
        pc-url).

*/

END FUNCTION.


FUNCTION htmlib-Select RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-data     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-display  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-selected AS CHARACTER NO-UNDO.

    IF pc-display = ""
        THEN pc-display = pc-value.

    ASSIGN 
        lc-data = '<select class="inputfield" id="' + pc-name + '" name="' + pc-name + '">'.

    DO li-loop = 1 TO NUM-ENTRIES(pc-value,'|'):
        ASSIGN 
            lc-value   = ENTRY(li-loop,pc-value,'|')
            lc-display = ENTRY(li-loop,pc-display,'|').
        IF lc-value = pc-selected 
            THEN lc-selected = 'selected'.
        ELSE lc-selected = "".
        ASSIGN 
            lc-data = lc-data + 
                       '<option ' +
                       lc-selected + 
                       ' value="' + 
                       lc-value + 
                       '">' + 
                       lc-display +
                       '</option>'.
    END.
  
    ASSIGN 
        lc-data = lc-data + '</select>'.

    RETURN lc-data.

 

END FUNCTION.


FUNCTION htmlib-Select-By-ID RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-data     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-display  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-selected AS CHARACTER NO-UNDO.

    IF pc-display = ""
        THEN pc-display = pc-value.

    ASSIGN 
        lc-data = '<select class="inputfield" id="' + pc-name + '" name="' + pc-name + '">'.

    DO li-loop = 1 TO NUM-ENTRIES(pc-value,'|'):
        ASSIGN 
            lc-value   = ENTRY(li-loop,pc-value,'|')
            lc-display = ENTRY(li-loop,pc-display,'|').
        IF lc-value = pc-selected 
            THEN lc-selected = 'selected'.
        ELSE lc-selected = "".
        ASSIGN 
            lc-data = lc-data + 
                       '<option ' +
                       lc-selected +
                       ' id="' +
                       pc-name +
                       lc-display +
                       '"' +
                       ' value="' + 
                       lc-value + 
                       '">' + 
                       lc-display +
                       '</option>'.
    END.
  
    ASSIGN 
        lc-data = lc-data + '</select>'.

    RETURN lc-data.

/*
<select name="select">
<option value="01">Paul</option>
<option selected value="02">Paul2</option>
</select>
*/

END FUNCTION.


FUNCTION htmlib-SelectJS RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-js  AS CHARACTER,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-data     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-display  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-selected AS CHARACTER NO-UNDO.

    IF pc-display = ""
        THEN pc-display = pc-value.
    /* onChange="ChangeAccount()"') */
    ASSIGN 
        lc-data = '<select class="inputfield" id="' + pc-name + '" name="' + pc-name 
        + '" onChange="' + pc-js + '")>'.

    DO li-loop = 1 TO NUM-ENTRIES(pc-value,'|'):
        ASSIGN 
            lc-value   = ENTRY(li-loop,pc-value,'|')
            lc-display = ENTRY(li-loop,pc-display,'|').
        IF lc-value = pc-selected 
            THEN lc-selected = 'selected'.
        ELSE lc-selected = "".
        ASSIGN 
            lc-data = lc-data + 
                       '<option ' +
                       lc-selected + 
                       ' value="' + 
                       lc-value + 
                       '">' + 
                       lc-display +
                       '</option>'.
    END.
  
    ASSIGN 
        lc-data = lc-data + '</select>'.

    RETURN lc-data.

END FUNCTION.




FUNCTION htmlib-SelectLong RETURNS LONGCHAR 
      ( pc-name AS CHARACTER ,
    pc-value AS CHARACTER ,
    pc-display AS CHARACTER,
    pc-selected AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-data     AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-display  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-selected AS CHARACTER NO-UNDO.

    IF pc-display = ""
        THEN pc-display = pc-value.

    ASSIGN 
        lc-data = '<select class="inputfield" id="' + pc-name + '" name="' + pc-name + '">'.

    DO li-loop = 1 TO NUM-ENTRIES(pc-value,'|'):
        ASSIGN 
            lc-value   = ENTRY(li-loop,pc-value,'|')
            lc-display = ENTRY(li-loop,pc-display,'|').
        IF lc-value = pc-selected 
            THEN lc-selected = 'selected'.
        ELSE lc-selected = "".
        ASSIGN 
            lc-data = lc-data + 
                       '<option ' +
                       lc-selected + 
                       ' value="' + 
                       lc-value + 
                       '">' + 
                       lc-display +
                       '</option>'.
    END.
  
    ASSIGN 
        lc-data = lc-data + '</select>'.

    RETURN lc-data.


		
END FUNCTION.


FUNCTION htmlib-SelectTime RETURNS CHARACTER 
    ( pc-name AS CHARACTER ,
    pc-selected AS CHARACTER ) :
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
	
    DEFINE VARIABLE lc-data     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-hour     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-min      AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-display  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-selected AS CHARACTER NO-UNDO.
    DEFINE VARIABLE pc-value    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE pc-display  AS CHARACTER NO-UNDO.
    
    DO li-hour = 0 TO 23:
        
        DO li-min = 0 TO 59 BY 15:
            lc-value = STRING(li-hour,"99")  + ":" + string(li-min,"99").
            IF pc-display = ""
                THEN ASSIGN pc-display = lc-value.
            ELSE ASSIGN pc-display = pc-display + "|" + lc-value.
        END.
       
    END.
    
    ASSIGN 
        pc-value = REPLACE(pc-display,":","").
    


    ASSIGN 
        lc-data = '<select class="inputfield" id="' + pc-name + '" name="' + pc-name + '">'.

    DO li-loop = 1 TO NUM-ENTRIES(pc-value,'|'):
        ASSIGN 
            lc-value   = ENTRY(li-loop,pc-value,'|')
            lc-display = ENTRY(li-loop,pc-display,'|').
        IF lc-value = pc-selected 
            THEN lc-selected = 'selected'.
        ELSE lc-selected = "".
        ASSIGN 
            lc-data = lc-data + 
                       '<option ' +
                       lc-selected + 
                       ' value="' + 
                       lc-value + 
                       '">' + 
                       lc-display +
                       '</option>'.
    END.
  
    ASSIGN 
        lc-data = lc-data + '</select>'.

    RETURN lc-data.
                    
		
END FUNCTION.

FUNCTION htmlib-SideLabel RETURNS CHARACTER
    ( pc-Label AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN SUBSTITUTE('<span class="sidelabel">&1:</span>',
        pc-label).


END FUNCTION.


FUNCTION htmlib-SideLabelError RETURNS CHARACTER
    ( pc-Label AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN SUBSTITUTE('<span class="sidelabelerror">&1*:</span>',
        pc-label).


END FUNCTION.


FUNCTION htmlib-SimpleBackButton RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/


    RETURN STRING('<a class="tlink" href="javascript:history.go(-1);">'
        + dynamic-function("html-encode","<<") 
        + '&nbsp;Back</a>' ).
END FUNCTION.


FUNCTION htmlib-SimpleExpandBox RETURNS CHARACTER
    ( pc-objectID AS CHARACTER,
    pc-Data     AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-dummy-return AS CHARACTER INITIAL "MYXXX111PPP2222" NO-UNDO.


    DEFINE VARIABLE lc-return       AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-return = '<div class="expandboxc" id="' + pc-objectID +
         '" style="display: none;">'.
    
    ASSIGN 
        lc-return = lc-return + 
        replace(
            DYNAMIC-FUNCTION("html-encode",REPLACE(pc-data,"~n",lc-dummy-return)),
                           lc-dummy-return,'<br/>').
       
    ASSIGN 
        lc-return = lc-return + '</div>'.

    RETURN lc-return.

END FUNCTION.


FUNCTION htmlib-SimpleTableRow RETURNS CHARACTER 
	    (  pc-label AS CHARACTER ,
	       pc-data  AS CHARACTER ,
	       pc-align AS CHARACTER ):
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	
        DEFINE VARIABLE lc-row  AS CHARACTER NO-UNDO.
        
        IF pc-align = ""
        THEN pc-align = "left".
        
        ASSIGN
            lc-row = '<TR><TD VALIGN="TOP" ALIGN="right">' 
            + htmlib-SideLabel(pc-label) + '</TD>'.
    
        ASSIGN
            lc-row = lc-row +
            dynamic-function("htmlib-TableField",REPLACE(pc-data,"~n","<br />"),pc-align) + '~n'.
            
        RETURN lc-row.
		
END FUNCTION.

FUNCTION htmlib-StartFieldSet RETURNS CHARACTER
    ( pc-legend AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF pc-legend = ""
        THEN RETURN '<span class="inform"><fieldset>'.
    ELSE RETURN '<span class="inform"><fieldset><legend>' + 
            dynamic-function("html-encode",pc-legend) +
            '</legend>'.


END FUNCTION.


FUNCTION htmlib-StartForm RETURNS CHARACTER
    ( pc-name AS CHARACTER ,
    pc-method AS CHARACTER,
    pc-action AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN 
        SUBSTITUTE('<form name="&1" method="&2" action="&3">',
        pc-name,
        pc-method,
        pc-action) + 
        '~n<span class="inform"><fieldset>~n'. 
 

END FUNCTION.


FUNCTION htmlib-StartInputTable RETURNS CHARACTER:
  
    RETURN htmlib-StartTable(
        "mnt",
        0,
        0,
        0,
        0,
        "center").


END FUNCTION.


FUNCTION htmlib-StartMntTable RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-table AS CHARACTER NO-UNDO.
    /*
    pc-name as char,
        pi-width as int,
        pi-border as int,
        pi-padding as int,
        pi-spacing as int,
        pc-align as char
        */
    ASSIGN 
        lc-table = REPLACE(htmlib-StartTable(
            "mnt",
            100,
            0,
            0,
            0,
            "center"),'>',' class="tableback" >').

    RETURN lc-table.
/* style="background-color: #E0E3E7;" */

END FUNCTION.


FUNCTION htmlib-StartPanel RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '<table class="buttonpanel" align="center" width="100%">'.

END FUNCTION.


FUNCTION htmlib-StartTable RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pi-width AS INTEGER,
    pi-border AS INTEGER,
    pi-padding AS INTEGER,
    pi-spacing AS INTEGER,
    pc-align AS CHARACTER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

  
    DEFINE VARIABLE lc-htm AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-htm = '<table'.
   
    IF pc-name <> ""
        THEN ASSIGN lc-htm = lc-htm + ' name="' + pc-name + '"'.

    IF pi-width <> 0
        THEN ASSIGN lc-htm = lc-htm + ' width="' + string(pi-width) + '%"'.

    IF pi-border <> 0
        THEN ASSIGN lc-htm = lc-htm + ' border="' + string(pi-border) + '"'.

   
    /* new */
    ASSIGN 
        lc-htm = lc-htm + ' cellpadding="' + string(pi-padding) + '"'.
    
    
    ASSIGN 
        lc-htm = lc-htm + ' cellspacing="' + string(pi-spacing) + '"'.



    IF pc-align <> ""
        THEN ASSIGN lc-htm = lc-htm + ' align="' + pc-align + '"'.

    ASSIGN 
        lc-htm = lc-htm + '>'.

    RETURN lc-htm.


END FUNCTION.


FUNCTION htmlib-StyleSheet RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    
    RETURN 
        '~n<meta http-equiv="Content-Type" content="text/html; charset= ISO-8859-1">~n~n' +
        REPLACE(
        htmlib-GetAttr("system","stylesheet"),
        ".css",
        ".css?v=1.0.0") + '~n~n'
        .


END FUNCTION.


FUNCTION htmlib-SubmitButton RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER 
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN SUBSTITUTE('<INPUT class="submitbutton" type="submit" name="&1" value="&2">',
        pc-name,
        pc-value).
END FUNCTION.


FUNCTION htmlib-TableField RETURNS CHARACTER
    ( pc-data AS CHARACTER,
    pc-align AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-return = '<td class="tablefield" valign="top"'.

    IF pc-align <> ""
        THEN lc-return = lc-return + ' align="' + pc-align + '">'.
    ELSE lc-return = lc-return + '>'.

    ASSIGN 
        lc-return = lc-return + pc-data + '</td>'.

    RETURN lc-return.




END FUNCTION.


FUNCTION htmlib-TableHeading RETURNS CHARACTER
    ( pc-param AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-loop    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-entry   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-return  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-label   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-align   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-colspan AS CHARACTER NO-UNDO.


    /*
    assign lc-return = '<tr class="tableheading">'.


    do li-loop = 1 to num-entries(pc-param,'|'):
        assign lc-entry = entry(li-loop,pc-param,'|').

        assign lc-label = entry(1,lc-entry,'^')
               lc-align = ''.
        if num-entries(lc-entry,'^') > 1 
        then assign lc-align = ' align="' + entry(2,lc-entry,'^') + '"'.

        if li-loop = num-entries(pc-param,'|')
        then assign lc-colspan = " colspan='8'".
        else assign lc-colspan = "".
        
        assign lc-return = lc-return + '<td valign="bottom" ' + lc-align + lc-colspan + '>' + lc-label + '</td>'.
        

    end.

    assign lc-return = lc-return + '</tr>'.

    return lc-return.
    */

    ASSIGN 
        lc-return = '<tr>'.


    DO li-loop = 1 TO NUM-ENTRIES(pc-param,'|'):
        ASSIGN 
            lc-entry = ENTRY(li-loop,pc-param,'|').

        ASSIGN 
            lc-label = ENTRY(1,lc-entry,'^')
            lc-align = ''.
        IF NUM-ENTRIES(lc-entry,'^') > 1 
            THEN ASSIGN lc-align = ' style=" text-align: ' + entry(2,lc-entry,'^') + '"'.

        IF li-loop = num-entries(pc-param,'|')
            THEN ASSIGN lc-colspan = " colspan='8'".
        ELSE ASSIGN lc-colspan = "".

        ASSIGN 
            lc-return = lc-return + '<th valign="bottom" ' + lc-align + lc-colspan + '>' + lc-label + '</th>'.


    END.

    ASSIGN 
        lc-return = lc-return + '</tr>'.

    RETURN lc-return.




END FUNCTION.


FUNCTION htmlib-TextArea RETURNS CHARACTER
    ( pc-name AS CHARACTER,
    pc-value AS CHARACTER,
    pi-rows AS INTEGER,
    pi-cols AS INTEGER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/



    RETURN SUBSTITUTE(
        '<textarea class="inputfield" id="&1" name="&1" rows="&3" cols="&4">&2</textarea>',
        pc-name,
        pc-value,
        STRING(pi-rows),
        STRING(pi-cols)).

END FUNCTION.


FUNCTION htmlib-TextLink RETURNS CHARACTER
    ( pc-text AS CHARACTER,
    pc-url  AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    
    IF pc-text BEGINS "Back" 
        OR pc-text BEGINS "Cancel"
        THEN pc-text = 
            DYNAMIC-FUNCTION("html-encode","<<") + 
            "&nbsp;" + 
            pc-text.
    RETURN SUBSTITUTE('<a class="tlink" href="&2">&1</a>',
        pc-text,
        pc-url ).
END FUNCTION.


FUNCTION htmlib-TimeSelect RETURNS CHARACTER
    ( pc-hour-name    AS CHARACTER,
    pc-hour-value   AS CHARACTER,
    pc-min-name     AS CHARACTER,
    pc-min-value    AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-hour-info AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-min-info  AS CHARACTER NO-UNDO.

    ASSIGN
        lc-hour-info = DYNAMIC-FUNCTION("com-TimeReturn","HOUR")
        lc-min-info  = DYNAMIC-FUNCTION("com-TimeReturn","MINUTE").


    RETURN
        htmlib-Select(
        pc-hour-name,
        ENTRY(1,lc-hour-info,"^"),
        ENTRY(2,lc-hour-info,"^"),
        pc-hour-value
        ) 
        + " : " +
        htmlib-Select(
        pc-min-name,
        ENTRY(1,lc-min-info,"^"),
        ENTRY(2,lc-min-info,"^"),
        pc-min-value
        ) .



END FUNCTION.


FUNCTION htmlib-TimeSelect-By-Id RETURNS CHARACTER
    ( pc-hour-name    AS CHARACTER,
    pc-hour-value   AS CHARACTER,
    pc-min-name     AS CHARACTER,
    pc-min-value    AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-hour-info AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-min-info  AS CHARACTER NO-UNDO.

    ASSIGN
        lc-hour-info = DYNAMIC-FUNCTION("com-TimeReturn","HOUR")
        lc-min-info  = DYNAMIC-FUNCTION("com-TimeReturn","MINUTE").


    RETURN
        htmlib-Select-By-Id(
        pc-hour-name,
        ENTRY(1,lc-hour-info,"^"),
        ENTRY(2,lc-hour-info,"^"),
        pc-hour-value
        ) 
        + " : " +
        htmlib-Select-By-Id(
        pc-min-name,
        ENTRY(1,lc-min-info,"^"),
        ENTRY(2,lc-min-info,"^"),
        pc-min-value
        ) .



END FUNCTION.


FUNCTION htmlib-trmouse RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '<tr class="tabrow1" onmouseover="this.className=~'tabrow2~'" onmouseout="this.className=~'tabrow1~'">'.

END FUNCTION.


