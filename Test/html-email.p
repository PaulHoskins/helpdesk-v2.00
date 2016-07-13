
/*------------------------------------------------------------------------
    File        : html-email.p
    Purpose     : 

    Syntax      :

    Description : Creates & Sends HTML formatted  emails

    Author(s)   : paul.hoskins
    Created     : Fri Oct 24 06:26:07 BST 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

ROUTINE-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

DEFINE VARIABLE oSmtp          AS COM-HANDLE NO-UNDO.
DEFINE VARIABLE li-Recipient   AS INTEGER    INITIAL 0 NO-UNDO.
DEFINE VARIABLE li-cc          AS INTEGER    INITIAL 1 NO-UNDO.
DEFINE VARIABLE li-bcc         AS INTEGER    INITIAL 2 NO-UNDO.

DEFINE VARIABLE li-email-plain AS INTEGER    INITIAL 0 NO-UNDO.
DEFINE VARIABLE li-email-html  AS INTEGER    INITIAL 1 NO-UNDO.
DEFINE VARIABLE li-result      AS INTEGER    NO-UNDO.



CREATE "EASendMailObj.Mail" oSmtp.

oSmtp:LicenseCode = "ES-B1331025340-00798-79VDBD295B4F9DD9-D6A242ECTD49UV5F".
oSmtp:Reset().


oSmtp:FromAddr 	= 'paulanhoskins@outlook.com'.
oSmtp:Subject	= 'Subject line'.
oSmtp:BodyFormat	= li-email-html.
oSmtp:BodyText	= 'hi there<br>Paul is a <b>Clever sod - its our 4th aniversary</b><br>'.
oSmtp:ServerAddr	= "smtp.live.com".

oSmtp:UserName = "paulanhoskins@outlook.com".
oSmtp:Password = "00pudsey".


DEFINE VARIABLE lc-Fname    AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-source   AS CHARACTER NO-UNDO.
DEFINE VARIABLE lc-contents AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE ll-ok       AS LOG       NO-UNDO.

ASSIGN 
    lc-fname  = "c:\temp\em.html"
    lc-source = "C:\html_email\ouritdept\email.html".

COPY-LOB FROM FILE lc-source TO lc-contents.

lc-contents = REPLACE(lc-contents,"[#contents#]","<b>My contents</b>").

lc-contents = REPLACE(lc-contents,"[#name#]","Paul Andrew Hoskins").

lc-contents = REPLACE(lc-contents,"[#position#]","<i>Developer</i>").

lc-contents = REPLACE(lc-contents,"[#email#]","paulanhoskins@outlook.com").

lc-contents = REPLACE(lc-contents,"[#telephone#]","01792 774540").






COPY-LOB FROM OBJECT lc-contents TO FILE lc-fname.


/*
oSmtp:ImportMailEx("C:\Users\paul.hoskins\workspace\web\WebContent\email.html").
*/
oSmtp:ImportMailEx(lc-fname).

/*
li-result = oSmtp:AddAttachment( "c:\temp\cv.docx" ).

MESSAGE "at res = " li-result skip
    oSmtp:GetLastErrDescription() 
    VIEW-AS ALERT-BOX
    .
*/

oSmtp:SSL_init.

/* Paul.Hoskins@advancedcomputersoftware.com */
oSmtp:AddRecipient( 'paulanhoskins@outlook.com', 'paulanhoskins@outlook.com', li-Recipient ).

li-result = oSmtp:SendMail().
MESSAGE "res = " li-result SKIP
    oSmtp:GetLastErrDescription() 
    VIEW-AS ALERT-BOX.
oSmtp:SaveMail("c:\temp\test.eml").


RELEASE OBJECT oSmtp.

