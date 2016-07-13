/***********************************************************************

    Program:        mail/monitor.p
    
    Purpose:        Mail Monitor - Email2DB post
    
    Notes:
    
    
    When        Who         What
    14/07/2006  phoski      Initial
       
***********************************************************************/
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


{lib/common.i}
{lib/maillib.i}

DEFINE STREAM djs.
DEFINE VARIABLE lc-from         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-to           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subject      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-body         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-attachdir    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-attachfile   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-html         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-date         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-epulse-cstring AS CHARACTER INITIAL
    "THIS REPORT HAS BEEN SENT TO THE CLIENT:"
    NO-UNDO.

DEFINE VARIABLE lc-epulse-error-begin   AS CHARACTER INITIAL
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

    DEFINE VARIABLE li-one  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE li-two  AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-temp AS CHARACTER     NO-UNDO.

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

    DEFINE BUFFER b        FOR EmailH.
    DEFINE BUFFER WebUser  FOR WebUser.

    DEFINE VARIABLE li-loop             AS INTEGER  NO-UNDO.
    DEFINE VARIABLE lc-file             AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-title            AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-AccountNumber    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-msg              AS CHARACTER NO-UNDO.
    
    DEFINE VARIABLE li-year             AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-month            AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-day              AS INTEGER  NO-UNDO.
    DEFINE VARIABLE ld-date             AS DATE NO-UNDO.


    DEFINE VARIABLE lf-EmailID      LIKE    EmailH.EmailID      NO-UNDO.

    FIND company WHERE company.CompanyCode = lc-global-company NO-LOCK NO-ERROR.

  
    REPEAT TRANSACTION ON ERROR UNDO , LEAVE:

        RUN ip-Decode ( lc-subject, OUTPUT lc-AccountNumber).
            
        IF lc-AccountNumber <> "" THEN 
        DO:
            FIND customer WHERE customer.companycode = lc-global-company
                AND customer.accountNumber = lc-AccountNumber
                NO-LOCK NO-ERROR.
            
            IF NOT AVAILABLE Customer
                THEN lc-AccountNumber = "".
        END.
        PUT STREAM djs UNFORMATTED "Customer: "  lc-AccountNumber SKIP.
        PUT STREAM djs UNFORMATTED "Customer: "  lc-body SKIP.
        
        IF INDEX(lc-body,"Status : Error") = 0 THEN LEAVE.

        ld-date = ?.
       
        IF lc-date <> "" THEN
        DO:
            ASSIGN 
                li-year = int(substr(lc-date,1,4)) no-error.
            IF ERROR-STATUS:ERROR 
                THEN li-year = 0.

            ASSIGN 
                li-month = int(substr(lc-date,6,2)) no-error.
            IF ERROR-STATUS:ERROR
                THEN li-month = 0.

            ASSIGN 
                li-day = int(substr(lc-date,9,2)) no-error.
            IF ERROR-STATUS:ERROR
                THEN li-day = 0.

            IF li-year <> 0
                AND li-month <> 0
                AND li-day <> 0 THEN
            DO:
                ld-date = DATE(li-month,li-day,li-year) NO-ERROR.
                IF ERROR-STATUS:ERROR
                    THEN ld-date = ?.
            END.


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
            b.Email       = lc-from
            b.mText       = lc-body
            b.Subject     = lc-Subject
            b.RcpDate     = ld-date
            b.RcpTime     = TIME.
        b.AccountNumber = lc-AccountNumber.

        {&out} skip
            'Created msg ' lf-EmailID.
        LEAVE.
    END.
   

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-UploadAttachment) = 0 &THEN

PROCEDURE ip-UploadAttachment :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pf-EmailID      LIKE EmailH.EmailID     NO-UNDO.
    DEFINE INPUT PARAMETER pc-FileName     AS CHARACTER                 NO-UNDO.
    DEFINE INPUT PARAMETER pc-Title        AS CHARACTER                 NO-UNDO.
    
    DEFINE VARIABLE li-docid    LIKE doch.docid NO-UNDO.
    DEFINE VARIABLE lr-raw      AS RAW          NO-UNDO.
    DEFINE VARIABLE li-line     AS INTEGER          NO-UNDO.
    DEFINE VARIABLE li-size     AS INTEGER          NO-UNDO.
    


    DEFINE VARIABLE lc-ext   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-valid AS CHARACTER INITIAL
        "zip,doc,dot,xlt,xls,ppt,pdf,htm,html,txt,ini,d,df,xml,png,gif,jpg,jpeg,jpe,png" NO-UNDO.


    ASSIGN 
        lc-ext = substr(pc-FileName,R-INDEX(pc-FileName,".") + 1) no-error.

    IF ERROR-STATUS:ERROR THEN RETURN.
    
    IF CAN-DO(lc-valid,lc-ext) = FALSE THEN RETURN.
    
    FILE-INFO:FILE-NAME = pc-FileName.
    li-size = FILE-INFO:FILE-SIZE.
    IF li-size = 0 
        THEN RETURN.
    
    REPEAT:
        li-docid = NEXT-VALUE(docid).
        IF CAN-FIND(doch WHERE doch.docid = li-docid NO-LOCK) THEN NEXT.
        CREATE doch.
        ASSIGN 
            doch.docid = li-docid
            doch.CreateBy = "EMAIL"
            doch.CreateDate = TODAY
            doch.CreateTime = TIME
            doch.RelType = "EMAIL"
            doch.RelKey  = STRING(pf-EmailID)
            doch.CompanyCode = lc-global-company
            doch.DocType = CAPS(lc-ext)
            doch.InBytes = li-size.

        ASSIGN 
            doch.descr = pc-title
            .


        ASSIGN 
            LENGTH(lr-raw) = 16384.
        INPUT from value(pc-FileName) binary no-map no-convert.
        REPEAT:
            IMPORT UNFORMATTED lr-raw.
            ASSIGN 
                li-line = li-line + 1.
            CREATE docl.
            ASSIGN 
                docl.DocID = li-DocID
                docl.Lineno  = li-line
                docl.rdata    = lr-raw.
               
        END.
        INPUT close.
        OS-DELETE value(pc-filename) no-error.
        ASSIGN 
            LENGTH(lr-raw) = 0.

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
    OUTPUT STREAM  djs TO "c:\temp\epulse2.log" APPEND.
    PUT STREAM djs UNFORMATTED "START --------------------------------------" SKIP.
  
    ASSIGN
        lc-from         = get-value("from")
        lc-to           = get-value("to")
        lc-subject      = get-value("subject")
        lc-body         = get-value("body")
        lc-attachdir    = get-value("attachdir")
        lc-attachfile   = get-value("attachfile")
        lc-date         = get-value("msgdate").
    .
     
    
    PUT STREAM djs UNFORMATTED "EMAIL: " SKIP.

    PUT STREAM djs UNFORMATTED  "lc-from       " lc-from     SKIP.     
    PUT STREAM djs UNFORMATTED  "lc-to         " lc-to       SKIP.         
    PUT STREAM djs UNFORMATTED  "lc-subject    " lc-subject  SKIP.         
    PUT STREAM djs UNFORMATTED  "lc-body       " lc-body     SKIP.           
    PUT STREAM djs UNFORMATTED  "lc-date       " lc-date    SKIP.          


    RUN outputHeader.
    
    
    
    ASSIGN
        lc-global-company = "OURIT2".

   
    {&out} STRING(TIME,"hh:mm:ss") " mail monitor received from "
    lc-from " to " lc-to " for company " lc-global-company
    " subject " lc-subject 
        .

    IF lc-global-company <> "" 
        AND lc-from <> ""
        THEN RUN ip-ProcessEmail.
    
    PUT STREAM djs UNFORMATTED "END --------------------------------------" SKIP(2).
    OUTPUT STREAM  djs CLOSE.    
  
END PROCEDURE.


&ENDIF

