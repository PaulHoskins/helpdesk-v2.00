/***********************************************************************

    Program:        lib/checkloggedin.i
    
    Purpose:        Make sure user is logged in                  
    
    Notes:
    
    
    When        Who         What
    10/09/2006  phoski      com-InitialSetup
    25/09/2014  phoski      Security functions

***********************************************************************/

DEFINE VARIABLE lc-user      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-value     AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-lkey      AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-ws-fields AS CHARACTER NO-UNDO.


ASSIGN 
    lc-value = get-cookie(lc-global-cookie-name).

    
lc-lkey = DYNAMIC-FUNCTION("sysec-DecodeValue","System",TODAY,"Password",lc-value).

ASSIGN 
    lc-user = htmlib-DecodeUser(lc-lkey).

IF lc-user = "" THEN
DO:
    ASSIGN 
        lc-user = get-user-field("ExtranetUser").
END.
IF lc-user = "" THEN
DO:
    RUN run-web-object IN web-utilities-hdl ("mn/notloggedin.p").
    RETURN.
END.
set-user-field("ExtranetUser",lc-user).

DYNAMIC-FUNCTION("com-InitialSetup",lc-user).

IF DYNAMIC-FUNCTION("syec-UserHasAcessToObject",lc-user,"RunObject", THIS-PROCEDURE:FILE-NAME, lc-ws-fields) = NO THEN
DO:
    com-SystemLog("ERROR:PageDenied",lc-user,THIS-PROCEDURE:FILE-NAME).
    set-user-field("ObjectName",THIS-PROCEDURE:FILE-NAME).
    RUN run-web-object IN web-utilities-hdl ("mn/secure.p").
    RETURN.
END.
IF "{&object-class}" = "INTERNAL-ONLY"
AND com-IsCustomer(lc-global-company,lc-user) THEN
DO:
    com-SystemLog("ERROR:PageDenied",lc-user,THIS-PROCEDURE:FILE-NAME).
    set-user-field("ObjectName",THIS-PROCEDURE:FILE-NAME + " (Internal Access Only)").
    RUN run-web-object IN web-utilities-hdl ("mn/secure.p").
    RETURN.
        
END.


IF request_method <> "POST" THEN
DO:
    lc-value = DYNAMIC-FUNCTION("sysec-EncodeValue","System",TODAY,"Password",htmlib-EncodeUser(lc-user)).
    Set-Cookie(lc-global-cookie-name,
        lc-value,
        DYNAMIC-FUNCTION("com-CookieDate",lc-user),
        DYNAMIC-FUNCTION("com-CookieTime",lc-user),
        APPurl,
        ?,
        IF hostURL BEGINS "https" THEN "secure" ELSE ?).
END.


