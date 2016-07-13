/***********************************************************************

    Program:        lib/sendsms.p
    
    Purpose:        Security Lib     
    
    Notes:
    
    
    When        Who         What
    25/09/2014  phoski      initial
    04/07/2016  phoski      Two Factor Authorisation

***********************************************************************/

DEFINE INPUT PARAMETER pc-loginId       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-Class         AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-msg           AS CHARACTER NO-UNDO.

DEFINE BUFFER WebUser FOR WebUser.
DEFINE BUFFER Company FOR Company.

{lib/common.i}
    
DEFINE VARIABLE oSMS   AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE lc-res AS CHARACTER  NO-UNDO.

    
FIND WebUser WHERE WebUser.LoginID = pc-loginid NO-LOCK.

FIND Company WHERE Company.CompanyCode = WebUser.CompanyCode NO-LOCK.

    
CREATE "REDOXYGENCOM.SMSInterface" oSMS.

oSMS:Email = Company.TwoFactor_Email.
OSMS:AccountID = Company.TwoFactor_Account.
oSMS:Password = Company.TwoFactor_Password.

oSMS:SendSMSMessage(WebUser.Mobile,pc-msg).


lc-res = oSMS:responseText.

MESSAGE "send sms " WebUser.Mobile pc-msg.

IF lc-res <> "" THEN
MESSAGE lc-res VIEW-AS ALERT-BOX.
    
IF lc-res = ""
THEN com-SystemLog("OK:SMS",pc-LoginID,pc-msg ).
ELSE com-SystemLog("ERROR:SMS",pc-LoginID,pc-msg + " - " + lc-res).

    

RELEASE OBJECT oSMS NO-ERROR.
oSMS = ?.

