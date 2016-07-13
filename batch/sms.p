/***********************************************************************

    Program:        batch/sms.p
    
    Purpose:        SMS Processing
    
    Notes:
    
    
    When        Who         What
    12/05/2006  phoski      Initial

***********************************************************************/

{lib/common.i}
{iss/issue.i}

DEFINE BUFFER SMSQueue        FOR SMSQueue.
DEFINE BUFFER ro-SMSQueue     FOR SMSQueue.




/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no






/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */

DEFINE VARIABLE ld-date             AS DATE         NO-UNDO.
DEFINE VARIABLE li-time             AS INTEGER          NO-UNDO.
DEFINE VARIABLE chSMS               AS COM-HANDLE.
DEFINE VARIABLE li-ok               AS INTEGER      NO-UNDO.
DEFINE VARIABLE lc-id               AS CHARACTER     NO-UNDO.


CREATE "IntelliSoftware.IntelliSMS.1" chSMS NO-ERROR.

IF ERROR-STATUS:ERROR THEN
DO:
    MESSAGE "Its an error".
    RETURN.
END.


chSMS:UserName = lc-global-sms-username.
chSMS:Password = lc-global-sms-password.



FOR EACH ro-SMSQueue NO-LOCK
    WHERE ro-SMSQueue.QStatus = 0 TRANSACTION
    WITH FRAME f-log DOWN STREAM-IO:

    FIND SMSQueue WHERE ROWID(SMSQueue) = rowid(ro-SMSQueue) 
        EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
    IF LOCKED SMSQueue
    OR NOT AVAILABLE SMSQueue THEN NEXT.


    li-ok = chSMS:SendMessage( 
        	  SMSQueue.Mobile,
        	  TRIM(substr(SMSQueue.Msg,1,140)),
        	  "HelpDesk",
        	  OUTPUT lc-id BY-VARIANT-POINTER ).
   
    ASSIGN
        SMSQueue.SMSResponse = li-ok
        SMSQueue.SentDate    = TODAY
        SMSQueue.SentTime    = TIME
        SMSQueue.QStatus     = 1.

    IF li-ok = 1
    THEN ASSIGN
            SMSQueue.SMSID       = lc-id.
 
END.

RELEASE OBJECT chSMS.



