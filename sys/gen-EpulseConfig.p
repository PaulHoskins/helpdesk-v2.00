/***********************************************************************

    Program:        sys/gen-EpulseConfig.p
    
    Purpose:        Generate Epulse Configuration
    
    Notes:
    
    
    When        Who         What
    20/04/20176 phoski      initial
   
***********************************************************************/


DEFINE TEMP-TABLE config    NO-UNDO
    FIELD server        AS CHARACTER
    FIELD ssl           AS CHARACTER
    FIELD port          AS CHARACTER
    FIELD type          AS CHARACTER
    FIELD emailAccount  AS CHARACTER
    FIELD pwd           AS CHARACTER
    FIELD fromEmail     AS CHARACTER
    FIELD subject       AS CHARACTER
    FIELD posturl       AS CHARACTER 
    .

CREATE config.

ASSIGN
    config.server = "imap-mail.outlook.com"
    config.ssl = "Y"
    config.port = "993"
    config.type = "1"
    config.emailaccount = "paulanhoskins@outlook.com"
    config.pwd = "00pudsey"
    config.fromEmail = "paulh@proteussoftware.com"
    config.subject = "Our IT Department report"
    config.posturl = "https://localhost/cgi-bin/cgiip.exe/WService=helpdesk/mail/epulse-v2.p".
   
ASSIGN config.postURL = "https://ouritdept-helpdesk.co.uk/cgi-bin/helpdesk.sh/mail/epulse-v2.p".
   
TEMP-TABLE config:WRITE-XML("file", "c:\epulse\config.xml", TRUE, ?, ?, FALSE, FALSE).
    