&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


{gui/inc/standard-gui.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS lfromCompany lToCompany lcompanyName lDelete ~
BtnOK 
&Scoped-Define DISPLAYED-OBJECTS lfromCompany lToCompany lcompanyName ~
lDelete lStatus 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON BtnOK AUTO-GO DEFAULT 
     LABEL "Copy" 
     SIZE 15 BY 1.12
     BGCOLOR 8 .

DEFINE VARIABLE lfromCompany AS CHARACTER FORMAT "X(256)":U INITIAL "NONE" 
     LABEL "Copy Static From Company" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "No Copy","NONE"
     DROP-DOWN-LIST
     SIZE 47 BY 1 NO-UNDO.

DEFINE VARIABLE lcompanyName AS CHARACTER FORMAT "X(256)":U 
     LABEL "Company Name" 
     VIEW-AS FILL-IN 
     SIZE 45 BY 1 NO-UNDO.

DEFINE VARIABLE lStatus AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 68 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE lToCompany AS CHARACTER FORMAT "X(256)":U 
     LABEL "New Company Code" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE lDelete AS LOGICAL INITIAL no 
     LABEL "Delete Existing Data?" 
     VIEW-AS TOGGLE-BOX
     SIZE 42 BY .77 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     lfromCompany AT ROW 2.08 COL 28 COLON-ALIGNED WIDGET-ID 2
     lToCompany AT ROW 3.15 COL 28 COLON-ALIGNED WIDGET-ID 4
     lcompanyName AT ROW 4.23 COL 28 COLON-ALIGNED WIDGET-ID 8
     lDelete AT ROW 5.35 COL 30 WIDGET-ID 10
     lStatus AT ROW 6.38 COL 2 NO-LABEL WIDGET-ID 12
     BtnOK AT ROW 6.38 COL 71 WIDGET-ID 6
     SPACE(1.56) SKIP(0.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Create New HelpDesk"
         DEFAULT-BUTTON BtnOK WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN lStatus IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Create New HelpDesk */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BtnOK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BtnOK Dialog-Frame
ON CHOOSE OF BtnOK IN FRAME Dialog-Frame /* Copy */
DO:
    DEF VAR lok AS LOG NO-UNDO.

    DO WITH FRAME {&FRAME-NAME}:


        ASSIGN {&DISPLAYED-OBJECTS}.

        IF lToCompany = ""
        OR lcompanyName = "" THEN
        DO:

            MESSAGE "You must enter all fields" VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.

        IF CAN-FIND(company WHERE company.companyCode = ltoCompany NO-LOCK)
        AND lDelete = FALSE THEN
        DO:
            MESSAGE "The company already exists" VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.

        END.

        IF lToCompany = lfromCompany THEN
        DO:

            MESSAGE "Copy and new company must be different" VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.

        
        ASSIGN
            lok = NO.

        MESSAGE "Are you sure? " VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
                UPDATE lok.

        IF NOT lok THEN RETURN NO-APPLY.

        RUN StatusMsg ("").

        SESSION:SET-WAIT-STATE("GENERAL").

        RUN gui/proc/createCompany.p ( lFromCompany, lToCompany, lcompanyName).


        SESSION:SET-WAIT-STATE("").


            

    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  RUN initialise.
  RUN enable_UI.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY lfromCompany lToCompany lcompanyName lDelete lStatus 
      WITH FRAME Dialog-Frame.
  ENABLE lfromCompany lToCompany lcompanyName lDelete BtnOK 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initialise Dialog-Frame 
PROCEDURE initialise :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF VAR lok AS LOG      NO-UNDO.

    SUBSCRIBE TO "StatusMsg" ANYWHERE RUN-PROCEDURE "StatusMsg" NO-ERROR.

    DO WITH FRAME {&FRAME-NAME}:

        FOR EACH company NO-LOCK:
            ASSIGN
                lok = lfromCompany:ADD-LAST(company.companyCode + " - " + company.NAME,company.companyCode).
        END.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE StatusMsg Dialog-Frame 
PROCEDURE StatusMsg :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    DEF INPUT PARAM pcMsg       AS CHAR NO-UNDO.

    DO WITH FRAME {&FRAME-NAME}:

        ASSIGN 
            lStatus:SCREEN-VALUE = pcMsg.
        PROCESS EVENTS.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

