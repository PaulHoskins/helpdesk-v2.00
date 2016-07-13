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


DEFINE VARIABLE lc-from         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-to           AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-subject      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-body         AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-attachdir    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-attachfile   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-html         AS CHARACTER NO-UNDO.

DEFINE VARIABLE lc-epulse-cstring AS CHARACTER INITIAL
    "THIS REPORT HAS BEEN SENT TO THE CLIENT:"
    NO-UNDO.

DEFINE VARIABLE lc-epulse-error-begin   AS CHARACTER INITIAL
    "<http://dashboard.hound-dog.co.uk/images/testerror.gif>" NO-UNDO.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 14.14
         WIDTH              = 60.6.
/* END WINDOW DEFINITION */
                                                                        */

/* ************************* Included-Libraries *********************** */

{src/web2/wrap-cgi.i}



 




/* ************************  Main Code Block  *********************** */

/* Process the latest Web event. */
RUN process-web-request.



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-EpulseMessage) = 0 &THEN

PROCEDURE ip-EpulseMessage :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pc-msg          AS CHARACTER         NO-UNDO.

    DEFINE OUTPUT PARAMETER pc-AccountNumber AS CHARACTER       NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-Result        AS CHARACTER       NO-UNDO.
    
    DEFINE VARIABLE li-customer             AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-work                 AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE li-loop                 AS INTEGER          NO-UNDO.
    DEFINE VARIABLE li-begin                AS INTEGER          NO-UNDO.
    DEFINE VARIABLE li-end                  AS INTEGER          NO-UNDO.
    DEFINE VARIABLE li-error                AS INTEGER          NO-UNDO.
    DEFINE VARIABLE lc-error                AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE lc-result               AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE lc-word                 AS CHARACTER         NO-UNDO.
    DEFINE VARIABLE lc-final                AS CHARACTER         NO-UNDO.

    ASSIGN 
        pc-result = ?.
    
    
    ASSIGN 
        li-customer = INDEX(pc-msg,lc-epulse-cstring).

    IF li-customer = 0 THEN RETURN.
    
    {&out} skip
            "EPLUSE MESSAGE FOR " lc-Subject.

    ASSIGN 
        lc-work = 
        REPLACE(REPLACE(lc-subject," ","|"),"~n","|").

    
    
    IF NUM-ENTRIES(lc-work,"|") = 0 THEN RETURN.
    
    
    DO li-loop = 1 TO min(30,NUM-ENTRIES(lc-work,"|")):
        ASSIGN 
            pc-AccountNumber = TRIM(ENTRY(li-loop,lc-work,"|")) .
        IF pc-AccountNumber = "-" THEN LEAVE.
        IF pc-AccountNumber = "" THEN NEXT.
        IF CAN-FIND(Customer WHERE customer.companyCode = lc-global-company
            AND customer.AccountNumber = pc-AccountNumber NO-LOCK)
            THEN LEAVE.
        pc-AccountNumber = "".
        
        
    END.
    
    FIND Customer
        WHERE Customer.CompanyCode = lc-global-company
        AND Customer.AccountNumber = pc-AccountNumber 
        NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE Customer THEN 
    DO:
        pc-AccountNumber = "".
        RETURN.
       
    END.
    
    
    ASSIGN
        li-error = INDEX(pc-msg,lc-epulse-error-begin).
    
    IF li-error = 0 THEN 
    DO:
        {&out} "NO TAG OF " lc-epulse-error-begin.
        
    END.
    
    
    lc-work = pc-msg.
    
    DO WHILE TRUE:

        ASSIGN 
            li-error = INDEX(lc-work,lc-epulse-error-begin).
        IF li-error = 0 THEN LEAVE.

        /*
        *** Position after error
        */
        ASSIGN 
            lc-work = substr(lc-work,li-error + length(lc-epulse-error-begin)).
        
        /*
        *** Theres a link to an error gif so position after this
        */
        ASSIGN 
            li-begin = INDEX(lc-work,">").

        IF li-begin = 0 THEN LEAVE.

        ASSIGN 
            lc-work = substr(lc-work,li-begin + 1).
        

        /* 
        *** lc-work contains then message from the errors begins to the end of the html
        *** so need to get the next < which denotes the next epulse start message
        */

        ASSIGN
            li-end = INDEX(lc-work,"<").

        IF li-end > 0
            THEN lc-error = substr(lc-work,1,li-end - 1).
        ELSE lc-error = lc-work.

        lc-error = REPLACE(lc-error,"~n","|").
        lc-error = REPLACE(lc-error," ","|").

        ASSIGN 
            lc-result = "".
        DO li-loop = 1 TO NUM-ENTRIES(lc-error,"|").
            lc-word = ENTRY(li-loop,lc-error,"|").
            IF lc-word = "" THEN NEXT.
            lc-result = lc-result + " " + lc-word.

        END.
        lc-result = TRIM(lc-result).
           
       

        IF lc-final = ""
            THEN ASSIGN lc-final = lc-result.
        ELSE ASSIGN lc-final = lc-final + "~n" + lc-result.

        IF li-end = 0 THEN LEAVE.

        ASSIGN
            lc-work = substr(lc-work,li-end).
       

    END.

    ASSIGN 
        pc-Result = lc-Final.


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
    
   

    DEFINE VARIABLE lf-EmailID      LIKE    EmailH.EmailID      NO-UNDO.

    FIND company WHERE company.CompanyCode = lc-global-company NO-LOCK NO-ERROR.

  
    REPEAT TRANSACTION ON ERROR UNDO , LEAVE:

        RUN ip-EpulseMessage ( lc-body, 
            OUTPUT lc-AccountNumber, 
            OUTPUT lc-Msg ).

        IF lc-msg = ? THEN RETURN.
        MESSAGE "Process for account " lc-AccountNumber.

        FIND LAST b NO-LOCK NO-ERROR.

        ASSIGN
            lf-EmailID = IF AVAILABLE b THEN b.EmailID + 1 ELSE 1.
        CREATE b.
        ASSIGN 
            b.CompanyCode = lc-global-company
            b.EmailID     = lf-EmailID.

        ASSIGN
            b.Email       = lc-from
            b.mText       = lc-msg
            b.Subject     = lc-Subject
            b.RcpDate     = TODAY
            b.RcpTime     = TIME.
        b.AccountNumber = lc-AccountNumber.

           
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
  
    ASSIGN
        lc-from         = get-value("from")
        lc-to           = get-value("to")
        lc-subject      = get-value("subject")
        lc-body         = get-value("body")
        lc-attachdir    = get-value("attachdir")
        lc-attachfile   = get-value("attachfile")
        /* lc-html         = get-value("html") */
        .
    

    RUN outputHeader.
    
   
    ASSIGN
        lc-body = lc-subject + "|" + lc-body.

    ASSIGN
        lc-global-company = "OURITDEPT".

   
    {&out} STRING(TIME,"hh:mm:ss") " mail monitor received from "
    lc-from " to " lc-to " for company " lc-global-company
    " subject " lc-subject 
        .

    IF lc-global-company <> "" 
        AND lc-from <> ""
        THEN RUN ip-ProcessEmail.
    
    
  
END PROCEDURE.


&ENDIF

