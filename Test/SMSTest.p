
/*------------------------------------------------------------------------
    File        : SMSTest.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Paul
    Created     : Sun Jul 03 08:50:34 BST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/*

AccountId=CI00133959
Email=alex@ouritdept.co.uk
Password=kOemp1G2

regsvr32 RedoxygenCOM.dll 
 Server.CreateObject("REDOXYGENCOM.SMSInterface") 
     With sms         
     .Email = "username@company.com"         
     .AccountID = "CI00001234"         
     .Password = "MyPassword"    
End With  
    sms.SendSMSMessage "61417999999", "Hello from ASP"     
    Response.Write sms.responseText 
    */
    
DEFINE VARIABLE oSMS    AS COM-HANDLE NO-UNDO.
DEFINE VAR lc-res AS CHAR NO-UNDO.

    
CREATE "REDOXYGENCOM.SMSInterface" oSMS.

oSMS:Email = "alex@ouritdept.co.uk".
OSMS:AccountID = "CI00133959".
oSMS:Password = "kOemp1G2".

/*
oSMS:SendSMSMessage("07980667239","Hello from me").
*/
oSMS:SendSMSMessage("07919 698922","Test SMS from helpdesk").


lc-res = oSMS:responseText.

MESSAGE lc-res VIEW-AS ALERT-BOX.

RELEASE OBJECT oSMS NO-ERROR.
oSMS = ?.
        
