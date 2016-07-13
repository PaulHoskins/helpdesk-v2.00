&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------
    File        : 
    Purpose     :

    Syntax      :

    Description :

    Author(s)   :
    Created     :
    Notes       :
  ----------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


DEF INPUT PARAM pcFromCompCode      AS CHAR     NO-UNDO.
DEF INPUT PARAM pcToCompCode        AS CHAR     NO-UNDO.
DEF INPUT PARAM pcToCompName        AS CHAR     NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */
RUN gui/proc/deletecompany.p ( pcToCompCode ).

pcToCompCode = CAPS(pcToCompCode).


IF pcFromCompCode <> "none"
OR pcFromCompCode <> "" THEN
DO:
    FOR EACH _file NO-LOCK,
        EACH _field OF _file NO-LOCK
            WHERE _field-name = "companyCode":

        IF _file-name BEGINS "cust" THEN NEXT.
        IF _file-name BEGINS "Iss" THEN NEXT.
        IF _file-name BEGINS "WebUser" THEN NEXT.
        IF _file-name BEGINS "knb" THEN NEXT.


        IF lookup(_file-name,"company,webStdTime,ticket,ivsub,ivfield,doch,docl,emailh") > 0 THEN NEXT.

        RUN SendStatus ( _file-name, 0 ).

        RUN CopyData ( _file-name ).

    END.

END.

RUN SendStatus ( "Defaults", 0 ).
RUN PrimaryData.

RUN SendStatus ( "", 0 ).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-CopyData) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CopyData Procedure 
PROCEDURE CopyData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT PARAM pcTableName     AS CHAR NO-UNDO.

    DEF VAR iCount      AS INT          NO-UNDO.
    DEF VAR lok         AS LOG          NO-UNDO.

    DEF VAR Qh          AS HANDLE   NO-UNDO.
    DEF VAR bh          AS HANDLE   NO-UNDO.
    DEF VAR bcopy       AS HANDLE   NO-UNDO.
    DEF VAR lfAudit     AS DEC      NO-UNDO.
    
    DEF VAR cPhrase     AS CHAR     NO-UNDO.

    CREATE BUFFER bh    FOR TABLE pcTableName.
    CREATE BUFFER bcopy FOR TABLE pcTableName.

    ASSIGN cPhrase = "for each " + pcTableName + " where companyCode = '" + pcFromCompCode + "' exclusive-lock".

   
    CREATE QUERY qh.

    qh:SET-BUFFERS(bh).

    qh:QUERY-PREPARE(cPhrase).

    qh:QUERY-OPEN().

    DO WHILE TRUE TRANSACTION:
        qh:GET-NEXT(EXCLUSIVE-LOCK).
        IF qh:QUERY-OFF-END THEN LEAVE.
        iCount = iCount + 1.

        RUN SendStatus ( pcTableName, iCount ).

        lok = bcopy:BUFFER-CREATE.


        IF pcTableName = "slaHead" THEN
        DO:
            lok = bcopy:BUFFER-COPY(bh,"companyCode,SLAID",?).
            DO WHILE TRUE:
                RUN lib/makeaudit.p ( "", OUTPUT lfAudit ).
                IF CAN-FIND(FIRST SLAHead WHERE SLAHead.SLAID = lfAudit NO-LOCK) THEN NEXT.
                LEAVE.
            END.
            bcopy:BUFFER-FIELD("SLAID"):BUFFER-VALUE = lfAudit.

        END.
        ELSE
        IF pcTableName = "webAction" THEN
        DO:
            lok = bcopy:BUFFER-COPY(bh,"companyCode,ActionID",?).
            DO WHILE TRUE:
                RUN lib/makeaudit.p ( "", OUTPUT lfAudit ).
                IF CAN-FIND(FIRST Webaction WHERE webAction.ActionID = lfAudit NO-LOCK) THEN NEXT.
                LEAVE.
            END.
            bcopy:BUFFER-FIELD("ActionID"):BUFFER-VALUE = lfAudit.

        END.
        ELSE
        DO:
            lok = bcopy:BUFFER-COPY(bh,"companyCode",?).
        END.

        bcopy:BUFFER-FIELD("companyCode"):BUFFER-VALUE = pcToCompCode.


    END.

    qh:QUERY-CLOSE.

    DELETE OBJECT qh NO-ERROR.
    DELETE OBJECT bh NO-ERROR.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-PrimaryData) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrimaryData Procedure 
PROCEDURE PrimaryData :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

    
    FIND company WHERE company.CompanyCode = pcToCompCode EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAIL company THEN
    DO:
        CREATE company.
    END.
    ASSIGN 
        company.companycode = pcToCompCode
        company.NAME = pcToCompName.


    FIND WebUser WHERE WebUser.LoginID = pcToCompCode EXCLUSIVE-LOCK NO-ERROR.

    IF NOT AVAIL WebUser THEN
    DO:
        CREATE WebUser.
    END.
    ASSIGN 
        WebUser.LoginID = pcToCompCode
        WebUser.companycode = pcToCompCode
        WebUser.NAME = pcToCompName
        webUser.SUPERUser = TRUE
        webUser.Passwd = ENCODE(LC(passwd))

        .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-SendStatus) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SendStatus Procedure 
PROCEDURE SendStatus :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAM pcTableName      AS CHAR NO-UNDO.
    DEFINE INPUT PARAM piCount          AS INT  NO-UNDO.


    DEF VAR cmsg        AS CHAR         NO-UNDO.

    ASSIGN
        cMsg = "Creating " + pcTableName + "..." + STRING(piCount).

    PUBLISH "StatusMsg" ( INPUT cMsg ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

