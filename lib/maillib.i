/***********************************************************************

    Program:        lib/maillib.i
    
    Purpose:             
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      Initial
    20/06/2011  DJS         Added email html format
    09/11/2014  phoski      Replace perl with com object
    24/02/2016  phoski      Change password email msg
***********************************************************************/

&if defined(maillib-library-defined) = 0 &then

&glob maillib-library-defined yes

DEFINE STREAM mlib-s.

DEFINE VARIABLE oSmtp          AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE li-Recipient   AS INTEGER    INITIAL 0 NO-UNDO.
DEFINE VARIABLE li-cc          AS INTEGER    INITIAL 1 NO-UNDO.
DEFINE VARIABLE li-bcc         AS INTEGER    INITIAL 2 NO-UNDO.

DEFINE VARIABLE li-email-plain AS INTEGER    INITIAL 0 NO-UNDO.
DEFINE VARIABLE li-email-html  AS INTEGER    INITIAL 1 NO-UNDO.
DEFINE VARIABLE li-result      AS INTEGER    NO-UNDO.
DEFINE VARIABLE li-footer-done AS LOG        INITIAL NO NO-UNDO.


FUNCTION mlib-StartCom RETURNS LOG (pc-companyCode AS CHARACTER ):
    DEFINE BUFFER company FOR company.
    
    FIND company 
        WHERE company.companycode = pc-companyCode NO-LOCK NO-ERROR.
        
    IF NOT AVAILABLE company THEN RETURN FALSE.
    
    
    CREATE "EASendMailObj.Mail" oSmtp.

    oSmtp:LicenseCode = "ES-B1331025340-00798-79VDBD295B4F9DD9-D6A242ECTD49UV5F".
    oSmtp:Reset().
    oSmtp:ServerAddr    = Company.smtp.

    IF Company.em_user <> "" THEN
    DO:
     
        oSmtp:UserName = Company.em_user.
        oSmtp:Password = Company.em_pass. 
        IF Company.em_ssl
            THEN oSmtp:SSL_init.   
    
    END.

    
END FUNCTION.

FUNCTION mlib-SendAttEmail RETURNS LOG
    (pc-companyCode AS CHARACTER,
    pc-Sender AS CHARACTER,
    pc-Subject AS CHARACTER,
    pc-Message AS CHARACTER,
    pc-To AS CHARACTER,
    pc-cc AS CHARACTER,
    pc-Bcc AS CHARACTER,
    pc-Attachment AS CHARACTER):
     
    DEFINE VARIABLE lc-perl       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-message    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-loop       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE li-mail       AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-address-to AS CHARACTER NO-UNDO.

    DEFINE BUFFER company FOR company.
    FIND company 
        WHERE company.companycode = pc-companyCode NO-LOCK NO-ERROR.
    IF NOT AVAILABLE company THEN RETURN FALSE.
    IF company.smtp = "" THEN RETURN FALSE.
    
    mlib-StartCom(pc-companyCode).
    
    ASSIGN 
        pc-subject = REPLACE(pc-subject,"~"","").
    ASSIGN 
        pc-subject = REPLACE(pc-subject,"'","").
    
    ASSIGN 
        pc-message = REPLACE(pc-message,"~"","").
    ASSIGN 
        pc-message = REPLACE(pc-message,"'","").
    
    IF li-footer-done = FALSE THEN
    DO:
        IF company.EmailFooter <> ""
            THEN ASSIGN pc-message = pc-message + "~n~n" + company.EmailFooter.
    END.
    li-footer-done = FALSE.
   
    IF pc-Sender = ""
        THEN ASSIGN pc-Sender = company.HelpDeskEmail.
    
    IF pc-attachment <> ""
        THEN ASSIGN 
            pc-message = pc-message + "~n~n"
            + dynamic-function("mlib-Reader",pc-attachment).

    DO li-loop = 1 TO NUM-ENTRIES(pc-message,'|'):
    
        IF li-loop = 1
            THEN ASSIGN lc-message = ENTRY(1,pc-message,'|').
        ELSE ASSIGN lc-message = lc-message + "~n" 
                                + entry(li-loop,pc-message,'|').
    END.

    ASSIGN 
        lc-address-to = DYNAMIC-FUNCTION("mlib-OutAddress",pc-to).
    
    oSmtp:FromAddr  = pc-sender.
    oSmtp:Subject   = pc-subject.   
    oSmtp:BodyFormat    = li-email-html.
    IF pc-attachment <> "" THEN 
    DO:
        li-result = oSmtp:AddAttachment( pc-Attachment ).
    END.
    oSmtp:BodyText = REPLACE(lc-message,"~n","<br/>").
    
    DO li-mail = 1 TO NUM-ENTRIES(lc-address-to):
        oSmtp:AddRecipient( ENTRY(li-mail,lc-address-to), ENTRY(li-mail,lc-address-to), li-Recipient ).
    END.
    DEFINE VARIABLE li-time AS INTEGER NO-UNDO.
    li-time = TIME.
    /* oSmtp:LogFileName = "c:\temp\email.log". */
    
    /*MESSAGE "SendM " lc-address-to " " pc-Subject " From " pc-sender.
    */
    li-result = oSmtp:SendMail().
    IF li-result <> 0 THEN
    DO:
        MESSAGE
            "Email failed to " lc-address-to SKIP
            "Subject " pc-subject SKIP
            "Result Code = " li-result SKIP
            "Err Desc  = " oSmtp:GetLastErrDescription() .
    END.
    li-time = TIME - li-time.
    /*MESSAGE "SendE " lc-address-to " In " STRING(li-time,"HH:MM:SS"). */
    RELEASE OBJECT oSmtp NO-ERROR.
    oSmtp = ?.
    
    RETURN TRUE.
END FUNCTION.     
    
   
FUNCTION mlib-SendEmail RETURNS LOG
    (pc-CompanyCode AS CHARACTER,
    pc-Sender AS CHARACTER,
    pc-Subject AS CHARACTER,
    pc-Message AS CHARACTER,
    pc-To AS CHARACTER
    ):

    mlib-SendAttEmail (
        pc-CompanyCode ,
        pc-sender,
        pc-subject,
        pc-message,
        pc-to,
        "",
        "",
        ""
        ).
    RETURN TRUE.
    
    

END FUNCTION.    


/* ADDED June 2011 - DJS */
FUNCTION mlib-SendMultipartEmail RETURNS LOG
    (pc-CompanyCode AS CHARACTER,
    pc-Sender AS CHARACTER,
    pc-Subject AS CHARACTER,
    pc-Message AS CHARACTER,
    pc-H-Message AS CHARACTER,
    pc-To AS CHARACTER
    ):
        
    DEFINE BUFFER company FOR company.

    FIND company WHERE company.companycode = pc-companyCode NO-LOCK NO-ERROR.
    IF NOT AVAILABLE company THEN RETURN FALSE.
    IF company.smtp = "" THEN RETURN FALSE.
    
    IF company.EmailFooter <> "" THEN
    DO:
        ASSIGN 
            pc-Message     = pc-Message + "~n~n" + Company.EmailFooter
            li-footer-done = TRUE
            pc-H-Message   = pc-H-message + '<pre style="font-family:Verdana,Geneva,Arial,Helvetica sans-serif;font-size:12px">'
                             + company.EmailFooter + '</pre></div></body></html>'.
    END.
    ELSE ASSIGN pc-H-Message = pc-H-message + '</div></body></html>'.
    
        
    mlib-SendAttEmail (
        pc-CompanyCode ,
        pc-sender,
        pc-subject,
        pc-h-message,
        pc-to,
        "",
        "",
        ""
        ).
    
    
    RETURN TRUE.

END FUNCTION.     
/* ------------------------------------------------------ */


FUNCTION mlib-SendPassword RETURNS LOG ( pc-user AS CHARACTER, pc-password AS CHARACTER ):

    DEFINE VARIABLE lc-file    AS CHARACTER NO-UNDO.

    DEFINE VARIABLE lc-smtp    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-sender  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-message AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-subject AS CHARACTER NO-UNDO.

    DEFINE VARIABLE li-count   AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-line    AS CHARACTER NO-UNDO.


    DEFINE BUFFER b-user  FOR WebUser.
    DEFINE BUFFER company FOR company.


    FIND b-user WHERE b-user.loginid = pc-user NO-LOCK NO-ERROR.

    IF b-user.email = "" THEN RETURN FALSE.

    FIND company WHERE company.companycode = b-user.company NO-LOCK NO-ERROR.
    IF company.HelpDeskEmail = "" THEN RETURN FALSE.

    ASSIGN
        lc-message = "Dear $forename,~n~nYour password has been changed for the $company HelpDesk to the following:~n~n" + 
                     "User Name: $user~n" + 
                     " Password: $password~n~n" +
                     "Once you have logged in you will be prompted to choose another password.~n~nPlease note that this password is case sensitive.~n".
    
    ASSIGN 
        lc-message = REPLACE(lc-message,"$name",
                                b-user.forename + ' ' + b-user.surname).
    ASSIGN 
        lc-message = REPLACE(lc-message,"$forename",
                                b-user.forename).
    ASSIGN 
        lc-message = REPLACE(lc-message,"$user",pc-user).
    ASSIGN 
        lc-message = REPLACE(lc-message,"$company",company.name).

    ASSIGN 
        lc-message = REPLACE(lc-message,"$password",pc-password).

    RETURN DYNAMIC-FUNCTION("mlib-SendEmail",
        b-user.companycode,
        company.HelpDeskemail,
        "Password changed",
        lc-message,
        b-user.email).
                           

    
   

END FUNCTION.
    
FUNCTION mlib-PerlFile RETURNS CHARACTER
    ():
        
    DEFINE VARIABLE lc-base AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-cnt  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-file AS CHARACTER NO-UNDO.            
                
    ASSIGN 
        lc-base = SESSION:TEMP-DIR + string(YEAR(TODAY),"9999") 
                                      + string(MONTH(TODAY),"99")
                                      + string(DAY(TODAY),"99")
                                      + "-" + string(TIME).
                
    DO WHILE TRUE:
        ASSIGN 
            li-cnt = li-cnt + 1.
        ASSIGN 
            lc-file = lc-base + string(li-cnt) + '.pl'.
        IF SEARCH(lc-file) <> ? THEN NEXT.
        LEAVE.
    END.
    RETURN lc-file.
END FUNCTION.        

FUNCTION mlib-Reader RETURNS CHARACTER
    ( pc-attachment AS CHARACTER ):
    
    
    IF pc-attachment MATCHES "*.pdf" THEN
    DO:
        RETURN "||The attachment has been created using Adode Acrobat" + 
            " and you will require the Acrobat Reader." + 
            "|This is available free of charge from www.adobe.com.".
    END.
    ELSE RETURN "".
END FUNCTION.    

/*
*** 
*** See dev 1051
***
*/
FUNCTION mlib-OutAddress RETURNS CHARACTER ( pc-out AS CHARACTER ):
    DEFINE VARIABLE lc-conv AS CHARACTER NO-UNDO.
    
    RETURN pc-out.

END FUNCTION.
&endif
