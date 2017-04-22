/***********************************************************************

    Program:        epulse-v2
    
    Purpose:        Mail Monitor - EpulseMail 
    
    Notes:
    
    
    When        Who         What
    20/04/2017  phoski      Initial
       
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


{lib/common.i}
{lib/maillib.i}

DEFINE VARIABLE lc-from               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-uidl               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subject            AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-body               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-html               AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-date               AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-epulse-cstring     AS CHARACTER INITIAL
    "THIS REPORT HAS BEEN SENT TO THE CLIENT:"
    NO-UNDO.

DEFINE VARIABLE lc-epulse-error-begin AS CHARACTER INITIAL
    "Status : Error" NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.15
         WIDTH              = 61.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-Decode) = 0 &THEN

PROCEDURE ip-Decode :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-subject  AS CHARACTER     NO-UNDO.

    DEFINE OUTPUT PARAMETER pc-AccountNumber   AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-one  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-two  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-temp AS CHARACTER NO-UNDO.

    ASSIGN
        li-one = INDEX(pc-subject,"-").

    IF li-one = 0 THEN LEAVE.

    ASSIGN
        li-two = INDEX(pc-subject,"-",li-one + 1).

    IF li-two = 0 THEN LEAVE.

    ASSIGN
        lc-temp = substr(pc-subject,li-one + 1,
                         ( li-two - li-one ) - 1) no-error.

    lc-temp = TRIM(lc-temp).

    pc-AccountNumber = lc-temp.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-ProcessEmail) = 0 &THEN

PROCEDURE ip-ProcessEmail :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE BUFFER b       FOR EmailH.
    DEFINE BUFFER WebUser FOR WebUser.

    DEFINE VARIABLE li-loop          AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-file          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-title         AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-AccountNumber AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-msg           AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE li-year          AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-month         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-day           AS INTEGER   NO-UNDO.
    DEFINE VARIABLE ld-date          AS DATE      NO-UNDO.


    DEFINE VARIABLE lf-EmailID       LIKE EmailH.EmailID NO-UNDO.

    FIND company WHERE company.CompanyCode = lc-global-company NO-LOCK NO-ERROR.


    IF lc-uidl <> "" THEN
    DO:
        FIND emrcv WHERE emrcv.companyCode = lc-global-company
            AND emrcv.uidl = lc-uidl NO-LOCK NO-ERROR.
        MESSAGE "Email Ignored " AVAILABLE emrcv.
        IF AVAILABLE emrcv THEN RETURN.
    END. 

    REPEAT TRANSACTION ON ERROR UNDO , LEAVE:
        IF lc-uidl <> "" THEN
        DO:
            CREATE emrcv.
            ASSIGN 
                emrcv.companyCode = lc-global-company
                emrcv.uidl        = lc-uidl.
        END. 
        
        


        RUN ip-Decode ( lc-subject, OUTPUT lc-AccountNumber).
            
        IF lc-AccountNumber <> "" THEN 
        DO:
            FIND customer WHERE customer.companycode = lc-global-company
                AND customer.accountNumber = lc-AccountNumber
                NO-LOCK NO-ERROR.
            
            IF NOT AVAILABLE Customer
                THEN lc-AccountNumber = "".
        END.
      
        /**
        IF INDEX(lc-body,"Status : Error") = 0 THEN LEAVE.
        **/
        ld-date = ?.
       
        IF lc-date <> "" THEN
        DO:
            ASSIGN 
                ld-date = DATE(lc-date) NO-ERROR.
        END.
        

        IF ld-date = ?
            THEN ld-date = TODAY.

        FIND LAST b NO-LOCK NO-ERROR.

        ASSIGN
            lf-EmailID = IF AVAILABLE b THEN b.EmailID + 1 ELSE 1.
        CREATE b.
        ASSIGN 
            b.CompanyCode = lc-global-company
            b.EmailID     = lf-EmailID.

        ASSIGN
            b.Email         = lc-from
            b.mText         = lc-body
            b.Subject       = lc-Subject
            b.RcpDate       = ld-date
            b.RcpTime       = TIME
            b.uidl          = lc-uidl
            b.AccountNumber = lc-AccountNumber.

        {&out} SKIP
            'Created msg ' lf-EmailID.
        LEAVE.
    END.


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
    output-content-type("text/plain~; charset=iso-8859-1":U).
  
END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-process-web-request) = 0 &THEN

PROCEDURE process-web-request :
    /*------------------------------------------------------------------------------
      Purpose:     Process the web request.
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
   

    ASSIGN
        lc-from    = get-value("from")
        lc-uidl    = get-value("uidl")
        lc-subject = get-value("subject")
        lc-body    = get-value("body")
        lc-date    = get-value("date")
        .
    IF lc-date <> ""
        THEN lc-date = ENTRY(1,lc-date," ").
    
    
    MESSAGE "EMAIL: ".
    MESSAGE "uidl       " lc-uidl       SKIP.    
    MESSAGE "from       " lc-from     SKIP.     
    MESSAGE "subject    " lc-subject  SKIP.
    MESSAGE "Date       " lc-date SKIP.        
    /*    MESSAGE "body       " lc-body     SKIP.*/
  

    RUN outputHeader.
    
    
    
    ASSIGN
        lc-global-company = "OURITDEPT".

   
    {&out} STRING(TIME,"hh:mm:ss") " mail monitor received from "
        lc-from " #o " lc-uidl " for company " lc-global-company
        " subject " lc-subject 
        .


    IF lc-global-company <> "" 
        AND lc-from <> ""
        THEN RUN ip-ProcessEmail.

     
   
  
END PROCEDURE.


&ENDIF

