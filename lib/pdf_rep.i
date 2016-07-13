&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Include 
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD replib-FileName Include 
FUNCTION replib-FileName RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Include
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: INCLUDE-ONLY
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Include ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Include 


/* ***************************  Main Block  *************************** */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE replib-NewPage Include 
PROCEDURE replib-NewPage :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
    def input param lc-company  as char no-undo.
    def input param lc-report   as char no-undo.
    def input-output param li-current-page    as int  no-undo.

    assign li-current-page = li-current-page + 1.

    RUN pdf_new_page("Spdf").

    RUN pdf_set_font ("Spdf","Times-Bold",16.0).
    run pdf_text_at ("Spdf",lc-company, 1 ).

    RUN pdf_set_font ("Spdf","Courier",10.0).
    run pdf_text_at ("Spdf", "Date: " + string(today,'99/99/9999') + ' ' + string(time,'hh:mm am'),110).
    run pdf_skip("Spdf").

    RUN pdf_set_font ("Spdf","Times-Bold",8.0).
    run pdf_text_at ("Spdf",lc-report, 1 ).

    RUN pdf_set_font ("Spdf","Courier",10.0).
    run pdf_text_at ("Spdf", "Page: " + string(li-current-page),110).
    run pdf_skip("Spdf").

    RUN pdf_set_dash ("Spdf",1,0).
    RUN pdf_line  ("Spdf", pdf_LeftMargin("Spdf"), pdf_TextY("Spdf") + 5, pdf_PageWidth("Spdf") - 20 , pdf_TextY("Spdf") + 5, 2).
    RUN pdf_skip ("Spdf").
   

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION replib-FileName Include 
FUNCTION replib-FileName RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
/*------------------------------------------------------------------------------
  Purpose:  
    Notes:  
------------------------------------------------------------------------------*/

  def var li-count as int no-undo.
  def var lc-file  as char no-undo.

  assign li-count = 1.

  repeat:
      assign lc-file = session:temp-dir  
             + string(etime) + string(li-count) + '.pdf'.
      if search(lc-file) = ? then leave.
      assign li-count = li-count + 1.
  end.
  RETURN lc-file.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

