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


DEF INPUT PARAM pcCompCode      AS CHAR     NO-UNDO.

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





FOR EACH _file NO-LOCK,
    EACH _field OF _file NO-LOCK
        WHERE _field-name = "companyCode":

    RUN SendStatus ( _file-name, 0 ).

    RUN DeleteData ( _file-name ).

    
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-DeleteData) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeleteData Procedure 
PROCEDURE DeleteData :
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

    DEF VAR cPhrase     AS CHAR     NO-UNDO.

    CREATE BUFFER bh FOR TABLE pcTableName.

    ASSIGN cPhrase = "for each " + pcTableName + " where companyCode = '" + pcCompCode + "' exclusive-lock".

   
    CREATE QUERY qh.

    qh:SET-BUFFERS(bh).

    qh:QUERY-PREPARE(cPhrase).

    qh:QUERY-OPEN().

    DO WHILE TRUE TRANSACTION:
        qh:GET-NEXT(EXCLUSIVE-LOCK).
        IF qh:QUERY-OFF-END THEN LEAVE.
        iCount = iCount + 1.

        RUN SendStatus ( pcTableName, iCount ).

        lok = bh:BUFFER-DELETE.


    END.

    qh:QUERY-CLOSE.

    DELETE OBJECT qh NO-ERROR.
    DELETE OBJECT bh NO-ERROR.



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
        cMsg = "Deleting " + pcTableName + "..." + STRING(piCount).

    PUBLISH "StatusMsg" ( INPUT cMsg ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

