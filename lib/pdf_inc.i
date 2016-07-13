/******************************************************************************

    Program:        pdf_inc.i
    
    Written By:     Gordon Campbell - PRO-SYS Consultants Ltd.
    Written On:     June 2002
    
    Description:    Contains function and variable definitions for 
                    generating a PDF document from within Progress

    Note:           This can only be included once per program

    --------------------- Revision History ------------------
    
    Date:     Author        Change Description
    
    07/12/02  G Campbell    Initial Release
    
    09/05/02  G Campbell    Fixed issue regarding the first call to pdf_set_font
                              - wasn't actually setting the font, had to be 
                                called twice before accepting changes
                            Fixed annoying 'rebuild' message 
                              - caused by inappropriate offset values when 
                                producing XREF table
                                
    09/10/02  G Campbell    Due to previous XREF changes, the pdf_load_image
                            and pdf_load_images functions had to change also
                            
    10/14/02  G Campbell    Changed the element setting functions to procedures
                              - older versions of Progress were reaching the
                                64K Segment issue.  
                                
    10/18/02  G Campbell    Added routine called pdf_replace_text and call from
                            appropriate text procedures.  Used to handle special
                            characters in text strings.

    10/22/02  G Campbell    As per Steven L. Jellin (sjellin@elcb.co.za)
    
                            Added two procedure pdf_reset_all and 
                            pdf_reset_stream.
    
    11/04/02  G Campbell    As per Julian Lyndon-Smith (jmls@tessera.co.uk)
    
                            Modified the Font/Image import procedures to use
                            the OS-APPEND command.

******************************************************************************/

/* The following defines are used to determine the JPEG Image Height and Width */
&GLOBAL-DEFINE M_SOF0  "0xC0"		/* Start Of Frame N */
&GLOBAL-DEFINE M_SOF1  "0xC1"		/* N indicates which compression process */
&GLOBAL-DEFINE M_SOF2  "0xC2"       /* Only SOF0-SOF2 are now in common use */
&GLOBAL-DEFINE M_SOF3  "0xC3"
&GLOBAL-DEFINE M_SOF5  "0xC5"		/* NB: codes C4 and CC are NOT SOF markers */
&GLOBAL-DEFINE M_SOF6  "0xC6"
&GLOBAL-DEFINE M_SOF7  "0xC7"
&GLOBAL-DEFINE M_SOF9  "0xC9"
&GLOBAL-DEFINE M_SOF10 "0xCA"
&GLOBAL-DEFINE M_SOF11 "0xCB"
&GLOBAL-DEFINE M_SOF13 "0xCD"
&GLOBAL-DEFINE M_SOF14 "0xCE"
&GLOBAL-DEFINE M_SOF15 "0xCF"
&GLOBAL-DEFINE M_SOI   "0xD8"		/* Start Of Image (beginning of datastream) */
&GLOBAL-DEFINE M_EOI   "0xD9"		/* End Of Image (end of datastream) */
&GLOBAL-DEFINE M_SOS   "0xDA"		/* Start Of Scan (begins compressed data) */
&GLOBAL-DEFINE M_APP0  "0xE0"		/* Application-specific marker, type N */
&GLOBAL-DEFINE M_APP12 "0xEC"		/* (we don't bother to list all 16 APPn's) */
&GLOBAL-DEFINE M_COM   "0xFE"		/* COMment */
&GLOBAL-DEFINE M_MARK  "0xFF"       /* Marker */

/* ---------------------------- Define TEMP-TABLES ------------------------- 
   The temp-tables are used to store the PDF streams and resources used when
   generating a PDF document */
DEFINE TEMP-TABLE TT_pdf_stream
    FIELD obj_stream    AS CHARACTER
    FIELD obj_file      AS CHARACTER.

/* The following temp-table is used to store/track parameters per stream */
DEFINE TEMP-TABLE TT_pdf_param
    FIELD obj_stream    AS CHARACTER
    FIELD obj_parameter AS CHARACTER
    FIELD obj_valid     AS CHARACTER
    FIELD obj_value     AS CHARACTER
INDEX obj_parameter AS PRIMARY
      obj_parameter
INDEX obj_stream
      obj_stream.

DEFINE TEMP-TABLE TT_pdf_error
  FIELD obj_stream  AS CHARACTER
  FIELD obj_func    AS CHARACTER FORMAT "x(20)"
  FIELD obj_error   AS CHARACTER FORMAT "x(40)".

/* The following temp-table is used to build a list of objects that will appear 
   in the PDF document */
DEFINE TEMP-TABLE TT_pdf_object
  FIELD obj_stream  AS CHARACTER
  FIELD obj_nbr     AS INTEGER
  FIELD obj_desc    AS CHARACTER
  FIELD obj_offset  AS DECIMAL DECIMALS 0 FORMAT "9999999999"
  FIELD gen_nbr     AS INTEGER FORMAT "99999"
  FIELD obj_type    AS CHARACTER FORMAT "X"
INDEX obj_nbr AS PRIMARY
      obj_nbr.

/* The following temp-table is used to store the actual content that will appear
   in the PDF document */
DEFINE TEMP-TABLE TT_pdf_content
    FIELD obj_stream    AS CHARACTER
    FIELD obj_seq       AS INTEGER
    FIELD obj_type      AS CHARACTER
    FIELD obj_content   AS CHARACTER FORMAT "X(60)"
    FIELD obj_page      AS INTEGER
    FIELD obj_line      AS INTEGER
    FIELD obj_length    AS INTEGER
INDEX obj_seq AS PRIMARY
      obj_stream
      obj_seq
INDEX obj_page
      obj_page
INDEX obj_stream
      obj_stream
INDEX obj_type
      obj_type.

/* The following temp-table is used to track Document Information */
DEFINE TEMP-TABLE TT_pdf_info
    FIELD obj_stream    AS CHARACTER
    FIELD info_attr     AS CHARACTER
    FIELD info_value    AS CHARACTER.

/* The following temp-table is used to track Images loaded into a PDF stream */
DEFINE TEMP-TABLE TT_pdf_image
    FIELD obj_stream    AS CHARACTER
    FIELD image_name    AS CHARACTER
    FIELD image_file    AS CHARACTER
    FIELD image_tag     AS CHARACTER
    FIELD image_obj     AS INTEGER
    FIELD image_len     AS INTEGER
    FIELD image_h       AS INTEGER
    FIELD image_w       AS INTEGER.

/* The following temp-table is used to track Fonts loaded into a PDF stream */
DEFINE TEMP-TABLE TT_pdf_font
    FIELD obj_stream    AS CHARACTER
    FIELD font_name     AS CHARACTER
    FIELD font_file     AS CHARACTER
    FIELD font_afm      AS CHARACTER
    FIELD font_type     AS CHARACTER
    FIELD font_width    AS CHARACTER
    FIELD font_obj      AS INTEGER
    FIELD font_descr    AS INTEGER
    FIELD font_stream   AS INTEGER
    FIELD font_len      AS INTEGER
    FIELD font_tag      AS CHARACTER
INDEX font_name AS PRIMARY
      font_name
INDEX obj_stream
      obj_stream.

/* ---------------------- Define LOCAL VARIABLES -------------------------- */
DEFINE VARIABLE pdf_inc_ContentSequence AS INTEGER NO-UNDO.
DEFINE VARIABLE pdf_inc_ObjectSequence  AS INTEGER NO-UNDO.

/* The following variables are used to store the Image Height Width */
DEFINE VARIABLE pdf_width     AS INTEGER NO-UNDO.
DEFINE VARIABLE pdf_height    AS INTEGER NO-UNDO.

DEFINE VARIABLE pdf_CurrentLine         AS INTEGER NO-UNDO.

DEFINE VARIABLE pdf-Res-Object      AS INTEGER NO-UNDO.
DEFINE VARIABLE Vuse-font           AS CHARACTER NO-UNDO.
DEFINE VARIABLE pdf-Stream-Start    AS INTEGER NO-UNDO.
DEFINE VARIABLE pdf-Stream-End      AS INTEGER NO-UNDO.

DEFINE STREAM S_pdf_inc.
DEFINE STREAM S_pdf_inp.

DEFINE BUFFER B_TT_pdf_content FOR TT_pdf_content.
DEFINE BUFFER B_TT_pdf_param   FOR TT_pdf_param.

/* ---------------------------- Define FUNCTIONS -------------------------- */

/* The following functions are used to determine the Images Width/Height */

FUNCTION hex RETURNS CHARACTER (INPUT asc-value AS INTEGER).
  DEF VAR j AS INT  NO-UNDO.
  DEF VAR h AS CHAR NO-UNDO.
  DO WHILE TRUE:
    j = asc-value MODULO 16.
    h = (IF j < 10 THEN STRING(j) ELSE CHR(ASC("A") + j - 10)) + h.
    IF asc-value < 16 THEN LEAVE.
      asc-value = (asc-value - j) / 16.
    END.
  RETURN ("0x" + h).
END FUNCTION. /* hex */

FUNCTION nextbyte RETURNS INTEGER ():
  DEFINE VARIABLE L_data    AS RAW NO-UNDO.

  LENGTH(L_data) = 1.

  IMPORT STREAM S_pdf_inp UNFORMATTED L_data.
  RETURN GET-BYTE(L_data,1).

END FUNCTION. /* nextbyte */

FUNCTION next2bytes RETURNS INTEGER ():
  DEFINE VARIABLE L_c1      AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_c2      AS INTEGER NO-UNDO.

  L_c1 = nextbyte().
  L_c2 = nextbyte().

  RETURN INT(L_c1 * EXP(2, 8) + L_c2).

END FUNCTION. /* next2bytes */

FUNCTION first_marker RETURN LOGICAL ():
  DEFINE VARIABLE L_c1        AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_c2        AS INTEGER NO-UNDO.

  L_c1 = nextbyte().
  L_c2 = nextbyte().

  IF hex(L_c1) <> {&M_Mark} AND hex(L_c2) <> {&M_SOI} THEN
    RETURN FALSE.
  ELSE RETURN TRUE.
END FUNCTION. /* first_marker */

FUNCTION next_marker RETURN INTEGER():
  DEFINE VARIABLE L_data    AS RAW NO-UNDO.

  LENGTH(L_data) = 1.
  DEFINE VARIABLE L_c       AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_discard AS INTEGER NO-UNDO.

  L_c = nextbyte().
  DO WHILE hex(L_c) <> {&M_MARK}:
    L_discard = L_discard + 1.
    L_c = nextbyte().
  END. /* <> 0xFF */

  DO WHILE hex(L_c) = {&M_MARK}:
    L_c = nextbyte().
  END.

  RETURN L_c.
END FUNCTION. /* next_marker */

FUNCTION skip_variable RETURN LOGICAL ():
  DEFINE VARIABLE L_Length  AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_Loop    AS INTEGER NO-UNDO.

  L_length = next2bytes().

  DO L_Loop = 1 TO (L_Length - 2):
    nextbyte().
  END. /* Loop */
END FUNCTION. /* skip_variable */

FUNCTION process_SOF RETURNS LOGICAL ():
  DEFINE VARIABLE L_Length  AS INTEGER NO-UNDO.

  next2bytes().       /* Skip Length */
  nextbyte().         /* Skip Data Precision */ 
  pdf_height = next2bytes().
  pdf_width  = next2bytes().

END FUNCTION. /* process_SOF */

/* end of Functions used to determine Image Height/Width */

FUNCTION pdf_inc_ContentSequence RETURNS INTEGER():
  pdf_inc_ContentSequence = pdf_inc_ContentSequence + 1.

  RETURN pdf_inc_ContentSequence.
END. /* pdf_inc_ContentSequence */

PROCEDURE pdf_error :
  DEFINE INPUT PARAMETER pdfStream     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFunction   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfError      AS CHARACTER NO-UNDO.
  
  CREATE TT_pdf_error.
  ASSIGN TT_pdf_error.obj_stream = pdfStream
         TT_pdf_error.obj_func   = pdfFunction
         TT_pdf_error.obj_error  = pdfError.

END. /* RUN pdf_error */

FUNCTION ObjectSequence RETURNS INTEGER ( INPUT pdfStream     AS CHARACTER,
                                          INPUT pdfSequence   AS INTEGER,
                                          INPUT pdfObjectDesc AS CHARACTER ):
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"ObjectSequence","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  CREATE TT_pdf_object.
  ASSIGN TT_pdf_object.obj_stream = pdfStream
         TT_pdf_object.obj_nbr    = pdfSequence
         TT_pdf_object.obj_desc   = pdfObjectDesc
         TT_pdf_object.obj_offset = IF pdfSequence <> 0 THEN 
                                      SEEK(S_pdf_inc) + 1 
                                    ELSE 0
         TT_pdf_object.gen_nbr   = IF pdfSequence <> 0 THEN 0 
                                   ELSE 65535
         TT_pdf_object.obj_type  = IF pdfSequence = 0 THEN "f" 
                                   ELSE "n".

  pdf_inc_ObjectSequence = pdfSequence.

  RETURN pdf_inc_ObjectSequence.

END FUNCTION. /* ObjectSequence */

PROCEDURE pdf_new :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFileName AS CHARACTER NO-UNDO.

  IF INDEX(pdfStream, " ") > 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_new","Cannot have a space in the Stream Name!").
    RETURN.
  END.

  CREATE TT_pdf_stream.
  ASSIGN TT_pdf_stream.obj_stream = pdfStream
         TT_pdf_stream.obj_file   = pdfFileName.

  RUN pdf_LoadBase14 (pdfStream).
  RUN pdf_init_param (pdfStream).
  
END. /* pdf_new */

FUNCTION pdf_VerticalSpace RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_VerticalSpace","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "VerticalSpace"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 10.

END FUNCTION. /* pdf_VerticalSpace */


FUNCTION pdf_PointSize RETURN DECIMAL ( INPUT pdfStream AS CHARACTER ):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_PointSize","Cannot find Stream!").
    RETURN ERROR.
  END.

  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "PointSize"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN DEC(TT_pdf_param.obj_value).
  ELSE 
    RETURN 10.0.
  
END FUNCTION. /* pdf_PointSize */

PROCEDURE pdf_set_TextRed :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextRed","Cannot find Stream!").
    RETURN ERROR.
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "TextRed" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "TextRed".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_TextRed */

PROCEDURE pdf_set_TextGreen :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextGreen","Cannot find Stream!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "TextGreen" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "TextGreen".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_TextGreen */

PROCEDURE pdf_set_TextBlue :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextBlue","Cannot find Stream!").
    RETURN.
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "TextBlue" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "TextBlue".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_TextBlue */

FUNCTION pdf_TextRed RETURN DECIMAL ( INPUT pdfStream AS CHARACTER):
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_TextRed","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "TextRed"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN DEC(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.0.

END FUNCTION. /* pdf_TextRed */

FUNCTION pdf_TextGreen RETURN DECIMAL ( INPUT pdfStream AS CHARACTER):
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_TextGreen","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "TextGreen"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN DEC(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.0.

END FUNCTION. /* pdf_TextGreen */

FUNCTION pdf_TextBlue RETURN DECIMAL ( INPUT pdfStream AS CHARACTER):
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_TextBlue","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "TextBlue"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN DEC(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.0.

END FUNCTION. /* pdf_TextBlue */

PROCEDURE pdf_set_PageWidth :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_PageWidth","Cannot find Stream!").
    RETURN .
  END.

  IF pdfValue = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_PageWidth","Page Width cannot be zero!").
    RETURN.
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "PageWidth" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "PageWidth".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_PageWidth */

PROCEDURE pdf_set_PageHeight :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_PageHeight","Cannot find Stream!").
    RETURN .
  END.

  IF pdfValue = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_PageHeight","Page Height cannot be zero!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "PageHeight" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "PageHeight".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_PageHeight */


PROCEDURE pdf_set_Page :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_page","Cannot find Stream!").
    RETURN.
  END.

  IF pdfValue = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_page","Value passed cannot be zero!").
    RETURN.
  END.
  
  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "Page" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "Page".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_Page */

FUNCTION pdf_Page RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  FIND FIRST TT_pdf_stream 
       WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_stream THEN DO:
    RUN pdf_error(pdfStream,"pdf_Page","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "Page"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.
  
END FUNCTION. /* pdf_Page */

FUNCTION pdf_PageWidth RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_PageWidth","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "PageWidth"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 612.
  
END FUNCTION. /* pdf_PageWidth */

FUNCTION pdf_Pageheight RETURN INTEGER ( INPUT pdfStream AS CHARACTER):
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"PageHeight","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "PageHeight"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 792.

END FUNCTION. /* pdf_PageHeight */

PROCEDURE pdf_set_TextX :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextX","Cannot find Stream (" + pdfStream + ")!").
    RETURN.
  END.

  IF pdfValue < 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextX","Value cannot be less than or equal to zero!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "TextX" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "TextX".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_TextX */

PROCEDURE pdf_set_TextY :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextY","Cannot find Stream!").
    RETURN.
  END.

  IF pdfValue <= 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TextY","Value cannot be less than or equal to zero!").
    RETURN.
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "TextY" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "TextY".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_TextY */


PROCEDURE pdf_set_GraphicX :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_GraphicX","Cannot find Stream!").
    RETURN.
  END.

  IF pdfValue < 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_GraphicX","Value cannot be less than 0!").
    RETURN.
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "GraphicX" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "GraphicX".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_GraphicX */

PROCEDURE pdf_set_GraphicY :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_GraphicY","Cannot find Stream!").
    RETURN.
  END.

  IF pdfValue < 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_GraphicY","Value cannot be less than zero!").
    RETURN.
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "GraphicY" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "GraphicY".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_GraphicY */

FUNCTION pdf_TextX RETURN INTEGER ( INPUT pdfStream AS CHARACTER):
  
  IF NOT CAN-FIND (FIRST TT_pdf_stream 
                   WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_TextX","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "TextX"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.
  
END FUNCTION. /* pdf_TextX*/

FUNCTION pdf_TextY RETURN INTEGER ( INPUT pdfStream AS CHARACTER):
  
  FIND FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_stream THEN DO:
    RUN pdf_error(pdfStream,"pdf_TextY","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "TextY"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.
  
END FUNCTION. /* pdf_TextY */

FUNCTION pdf_GraphicX RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_GraphicX","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "GraphicX"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.
  
END FUNCTION. /* pdf_GraphicX */

FUNCTION pdf_GraphicY RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_GraphicY","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "GraphicY"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 0.
  
END. /* pdf_GraphicY */

PROCEDURE pdf_set_info :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfAttribute AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfvalue     AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_info","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_option  AS CHARACTER NO-UNDO.
  L_Option = "Author,Creator,Producer,Keywords,Subject,Title".

  IF LOOKUP(pdfAttribute,L_option) = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_info","Invalid Attribute passed!").
    RETURN .
  END.
  
  IF NOT CAN-FIND( FIRST TT_pdf_info
                   WHERE TT_pdf_info.obj_stream = pdfStream
                     AND TT_pdf_info.info_attr  = pdfAttribute NO-LOCK)
  THEN DO:
    CREATE TT_pdf_info.
    ASSIGN TT_pdf_info.obj_stream = pdfStream
           TT_pdf_info.info_attr  = pdfAttribute.
  END.

  TT_pdf_info.info_value = pdfValue.

END. /* pdf_set_info */

FUNCTION pdf_get_info RETURNS CHARACTER ( INPUT pdfStream    AS CHARACTER,
                                          INPUT pdfAttribute AS CHARACTER):                                         

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_get_info","Cannot find Stream!").
    RETURN ERROR.
  END.

  DEFINE VARIABLE L_option  AS CHARACTER NO-UNDO.
  L_Option = "Author,Creator,Producer,Keywords,Subject,Title".

  IF LOOKUP(pdfAttribute,L_option) = 0 THEN DO:
    RUN pdf_error(pdfStream,"ObjectSequence","Invalid Attribute passed!").
    RETURN ERROR.
  END.

  FIND FIRST TT_pdf_info WHERE TT_pdf_info.obj_stream = pdfStream
                           AND TT_pdf_info.info_attr  = pdfAttribute 
                           NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_info THEN 
    RETURN TT_pdf_info.info_value.

END FUNCTION. /* pdf_get_info */

FUNCTION pdf_LeftMargin RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_LeftMargin","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "LeftMargin"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 10.
  
END FUNCTION. /* pdf_LeftMargin */

FUNCTION pdf_TopMargin RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_TopMargin","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "TopMargin"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN INT(TT_pdf_param.obj_value).
  ELSE 
    RETURN 50.

END FUNCTION. /* pdf_TopMargin */

PROCEDURE pdf_move_to :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfToX       AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfToY       AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_move_to","Cannot find Stream!").
    RETURN .
  END.
                                      
  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_content = STRING(pdfToX) + " " + STRING(pdfToY) + " m" + CHR(13).
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

END. /* pdf_moveto */

PROCEDURE pdf_rect :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFromX     AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFromY     AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfWidth     AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfHeight    AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_rect","Cannot find Stream!").
    RETURN.
  END.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_content = STRING(pdfFromX) + " " + STRING(pdfFromY) + " " 
                                    + STRING(pdfWidth) + " " + STRING(pdfHeight)
                                    + " re" + CHR(13)
                                    + "B" + CHR(13).
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  RUN pdf_set_GraphicY (pdfStream,pdfFromY + pdfHeight).
  RUN pdf_set_GraphicX (pdfStream, pdfFromX + pdfWidth).

END. /* pdf_rect */

PROCEDURE pdf_stroke_color :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRed       AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pdfGreen     AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pdfBlue      AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_stroke_color","Cannot find Stream!").
    RETURN .
  END.
  
  pdfRed   = IF pdfRed < 0 THEN 0
             ELSE IF pdfRed > 1 THEN 1
             ELSE pdfRed.
  pdfGreen = IF pdfGreen < 0 THEN 0
             ELSE IF pdfGreen > 1 THEN 1
             ELSE pdfGreen.
  pdfBlue  = IF pdfBlue < 0 THEN 0
             ELSE IF pdfBlue > 1 THEN 1
             ELSE pdfBlue.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_content = " " + STRING(pdfRed) + " " + STRING(pdfGreen) 
                                    + " " + STRING(pdfBlue) + " RG ".
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

END. /* pdf_rect */

PROCEDURE pdf_stroke_fill :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRed       AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pdfGreen     AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pdfBlue      AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_stroke_fill","Cannot find Stream!").
    RETURN .
  END.
  
  pdfRed   = IF pdfRed < 0 THEN 0
             ELSE IF pdfRed > 1 THEN 1
             ELSE pdfRed.
  pdfGreen = IF pdfGreen < 0 THEN 0
             ELSE IF pdfGreen > 1 THEN 1
             ELSE pdfGreen.
  pdfBlue  = IF pdfBlue < 0 THEN 0
             ELSE IF pdfBlue > 1 THEN 1
             ELSE pdfBlue.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_content = " " + STRING(pdfRed) + " " + STRING(pdfGreen) 
                                    + " " + STRING(pdfBlue) + " rg ".
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

END. /* pdf_rect */

PROCEDURE pdf_set_dash :
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfOn      AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfOff     AS INTEGER NO-UNDO.

  IF pdfOn  < 0 THEN pdfOn = 1.
  IF pdfOff < 0 THEN pdfOff = 1.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_dash","Cannot find Stream!").
    RETURN .
  END.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_content = " [" + STRING(pdfOn) + " " + STRING(pdfOff) 
                                    + "] 0  d ".
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

END. /* pdf_set_dash */

PROCEDURE pdf_line :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFromX     AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFromY     AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfToX       AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfToY       AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfWeight    AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_line","Cannot find Stream!").
    RETURN.
  END.

  DEFINE VARIABLE L_FromY   AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_ToY     AS INTEGER NO-UNDO.

  ASSIGN L_FromY =  /* pdf_PageHeight - */ (pdfFromY) /*(pdfFromY + pdf_TopMargin) * -1 */
         L_ToY   =  /* pdf_PageHeight - */ (pdfToY ) /* (pdfToY + pdf_TopMargin) * -1 */.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_content = STRING(pdfWeight) + " w" + CHR(13)
                                    + STRING(pdfFromX) + " " + STRING(L_FromY) + " m" + CHR(13)
                                    + STRING(pdfToX) + " " + STRING(L_ToY) + " l" + CHR(13)
                                    + "S" + CHR(13).
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  RUN pdf_set_GraphicX(pdfStream, pdfToX ).
  RUN pdf_set_GraphicY(pdfstream, pdfToY).

END. /* pdf_line */

PROCEDURE pdf_text :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfText     AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text","Cannot find Stream!").
    RETURN .
  END.

  RUN pdf_replace_text (INPUT-OUTPUT pdfText).

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "TEXT"
         TT_pdf_content.obj_content = "(" + pdfText + ") Tj"
         TT_pdf_content.obj_line    = pdf_CurrentLine.
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

END. /* pdf_text */

FUNCTION pdf_Font RETURN CHARACTER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_Font","Cannot find Stream!").
    RETURN ERROR.
  END.

  FIND TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                      AND TT_pdf_param.obj_parameter = "Font"
                      NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN 
    RETURN TT_pdf_param.obj_value.
  ELSE 
    RETURN "Courier".

END FUNCTION. /* pdf_Font */

PROCEDURE pdf_set_font :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFont     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfSize     AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_font","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_PointSize   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_LeftMargin  AS CHARACTER NO-UNDO.
  L_PointSize  = STRING(pdf_PointSize(pdfStream)).
  L_LeftMargin = STRING(pdf_LeftMargin(pdfStream)).

  FIND FIRST TT_pdf_font WHERE TT_pdf_font.obj_stream = pdfStream
                           AND TT_pdf_font.font_name = pdfFont 
                           NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_font THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_font","Font has not been loaded!").
    RETURN .
  END.
    
  FIND FIRST B_TT_pdf_content 
       WHERE B_TT_pdf_content.obj_stream = pdfStream
         AND B_TT_pdf_content.obj_page   = pdf_Page(pdfStream)
         AND B_TT_pdf_content.obj_line   = pdf_CurrentLine NO-ERROR.
  IF AVAIL B_TT_pdf_content THEN DO:
    ASSIGN B_TT_pdf_content.obj_content = B_TT_pdf_content.obj_content
                                        + CHR(13) + TT_pdf_font.font_tag + " " 
                                        + STRING(pdfSize) +  " Tf" + CHR(13).
  END.

  ELSE DO:
    CREATE TT_pdf_content.
    ASSIGN TT_pdf_content.obj_stream  = pdfStream.
           TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
           TT_pdf_content.obj_type    = "TEXTFONT".
           TT_pdf_content.obj_line    = pdf_CurrentLine.
           TT_pdf_content.obj_page    = pdf_Page(pdfStream).
           TT_pdf_content.obj_content = "1 0 0 1 " + L_LeftMargin + " " 
                                      + STRING( pdf_CurrentLine ) + " Tm" + CHR(13)
                                      + TT_pdf_font.font_tag + " " 
                                      + STRING(pdfSize) +  " Tf".

  END. 

  /* Set the Stream Font Parameter */
  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "Font" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "Font".
  END.

  TT_pdf_param.obj_value = pdfFont.

  /* Set the Stream Font Size */
  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "PointSize" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "PointSize".
  END.
  TT_pdf_param.obj_value = STRING(pdfSize).

END. /* pdf_set_font*/

PROCEDURE pdf_text_render :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRender   AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_render","Cannot find Stream!").
    RETURN .
  END.
    
  IF pdfRender < 0 OR pdfRender > 3 THEN pdfRender = 0.
    
  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "TEXTRENDER"
         TT_pdf_content.obj_content = STRING(pdfRender) +  " Tr"
         TT_pdf_content.obj_line    = pdf_CurrentLine.
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "Render" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "Render".
  END.

  TT_pdf_param.obj_value = STRING(pdfRender).

END. /* pdf_text_render */

PROCEDURE pdf_text_color :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRed      AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pdfGreen    AS DECIMAL NO-UNDO.
  DEFINE INPUT PARAMETER pdfBlue     AS DECIMAL NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_color","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_PointSize   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_LeftMargin  AS CHARACTER NO-UNDO.
  L_PointSize  = STRING(pdf_PointSize(pdfStream)).
  L_LeftMargin = STRING(pdf_LeftMargin(pdfStream)).

  FIND FIRST B_TT_pdf_content 
       WHERE B_TT_pdf_content.obj_stream = pdfStream
         AND B_TT_pdf_content.obj_page   = pdf_Page(pdfStream)
         AND B_TT_pdf_content.obj_line   = pdf_CurrentLine NO-ERROR.
  IF AVAIL B_TT_pdf_content THEN DO:
    ASSIGN B_TT_pdf_content.obj_content = B_TT_pdf_content.obj_content + CHR(13)
                                        + STRING(pdfRed) + " " + STRING(pdfGreen) 
                                        + " " + STRING(pdfBlue) + " rg ".
  END.
  ELSE DO:
    CREATE TT_pdf_content.
    ASSIGN TT_pdf_content.obj_stream  = pdfStream.
           TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
    ASSIGN TT_pdf_content.obj_type    = "TEXTCOLOR"
           TT_pdf_content.obj_line    = pdf_CurrentLine.
           TT_pdf_content.obj_page    = pdf_Page(pdfStream).
           TT_pdf_content.obj_content = "1 0 0 1 " + L_LeftMargin + " " 
                                      + STRING( pdf_CurrentLine ) + " Tm" + CHR(13)
                                      + STRING(pdfRed) + " " + STRING(pdfGreen) 
                                      + " " + STRING(pdfBlue) + " rg ".
  END.

  RUN pdf_set_TextRed(pdfStream, pdfRed).
  RUN pdf_set_TextGreen(pdfStream, pdfGreen).
  RUN pdf_set_TextBlue(pdfStream, pdfBlue).
  
END. /* pdf_text_color */

FUNCTION pdf_text_width RETURNS INTEGER ( INPUT pdfStream   AS CHARACTER,
                                          INPUT pdfText     AS CHARACTER):

  DEFINE VARIABLE L_width  AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_font    AS CHARACTER NO-UNDO.
    
  L_font = pdf_Font(pdfStream).

  DEFINE VARIABLE L_Loop    AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_tot     AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_width","Cannot find Stream!").
    RETURN ERROR.
  END.

  FIND FIRST TT_pdf_font WHERE TT_pdf_font.obj_stream = pdfStream
                           AND TT_pdf_font.font_name  = L_Font
                           NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_font THEN DO:
    IF TT_pdf_Font.font_type = "FIXED" THEN
      L_width = INT((LENGTH(pdfText) * INT(TT_pdf_font.font_width) / 1000) * pdf_PointSize(pdfStream)). 

    ELSE DO: 
      DO L_loop = 1 TO LENGTH(pdfText):
        L_tot = L_tot + INT(ENTRY(ASC(SUBSTR(pdfText,L_Loop,1)),TT_pdf_Font.font_width, " ")) NO-ERROR.
      END.
     
      l_width = INT(L_tot / 1000) * pdf_PointSize(pdfStream).
    END. /* Variable Width Font */
  END. /* Found the current font */

  RETURN l_width.
END FUNCTION. /* pdf_text_color */

PROCEDURE pdf_load_font :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFontName AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFontFile AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfFontAFM  AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_load_font","Cannot find Stream!").
    RETURN .
  END.

  IF INDEX(pdfFontName," ") > 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_load_font","Font Name cannot contains spaces!").
    RETURN .
  END.

  IF SEARCH(pdfFontFile) = ? THEN DO:
    RUN pdf_error(pdfStream,"pdf_load_font","Cannot find Font File for Loading!").
    RETURN .
  END.
  
  IF SEARCH(pdfFontAFM) = ? THEN DO:
    RUN pdf_error(pdfStream,"ObjectSequence","Cannot find Font AFM file for loading!").
    RETURN .
  END.

  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.obj_stream  = pdfStream
         TT_pdf_font.font_name   = pdfFontName
         TT_pdf_font.font_file   = pdfFontFile
         TT_pdf_font.font_afm    = pdfFontAFM.
  TT_pdf_font.font_tag    = "/" + STRING(TT_pdf_font.font_name). 

END. /* pdf_load_font */

PROCEDURE pdf_load_image :
  DEFINE INPUT PARAMETER pdfStream      AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfImageName   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfImageFile   AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_load_image","Cannot find Stream!").
    RETURN .
  END.

  IF INDEX(pdfImageName," ") > 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_load_image","Image Name cannot contain spaces!").
    RETURN .
  END.

  IF SEARCH(pdfImageFile) = ? THEN DO:
    RUN pdf_error(pdfStream,"pdf_load_image","Cannot find Image File when Loading!").
    RETURN .
  END.

  RUN pdf_get_image_wh (INPUT pdfStream,
                        INPUT pdfImageFile).


  CREATE TT_pdf_image.
  ASSIGN TT_pdf_image.obj_stream    = pdfStream
         TT_pdf_image.image_name    = pdfImageName
         TT_pdf_image.image_file    = pdfImageFile
         TT_pdf_image.image_h       = pdf_Height
         TT_pdf_image.image_w       = pdf_Width.
  TT_pdf_image.image_tag    = "/Im" + STRING(TT_pdf_image.image_name). 

END. /* pdf_load_image */

PROCEDURE pdf_place_image :
  DEFINE INPUT PARAMETER pdfStream    AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfImageName AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfColumn    AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRow       AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfWidth     AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfHeight    AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_place_image","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_PageHeight  AS INTEGER NO-UNDO.
  L_PageHeight  = pdf_PageHeight(pdfStream).

  FIND FIRST TT_pdf_image 
       WHERE TT_pdf_image.image_name = pdfImageName NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_image THEN DO:
    RUN pdf_error(pdfStream,"pdf_place_image","Cannot find Image Name for Placement!").
    RETURN .
  END.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "IMAGE"
         TT_pdf_content.obj_content = STRING(pdfWidth) + " 0 0 " + STRING(pdfHeight)
                                    + " " + STRING(pdfColumn) + " " 
                                    + STRING(L_PageHeight - pdfRow) + " cm " 
                                    + TT_pdf_image.image_tag + " Do" + CHR(13).
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  RUN pdf_set_GraphicX(pdfStream,pdfColumn).
  RUN pdf_set_GraphicY(pdfStream,pdfRow).

END. /* pdf_place_image */

PROCEDURE pdf_new_page :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_new_page","Cannot find Stream!").
    RETURN .
  END.
   
   RUN pdf_set_Page(pdfStream,pdf_Page(pdfStream) + 1).
   
   /* pdf_set_Page        = pdf_Page + 1 */
   pdf_CurrentLine = pdf_PageHeight(pdfStream) - pdf_TopMargin(pdfStream).

   RUN pdf_set_TextX(pdfStream, 0).
   RUN pdf_set_TextY(pdfStream, pdf_CurrentLine).
   RUN pdf_set_GraphicX(pdfStream, 0).
   RUN pdf_set_GraphicY(pdfStream, 0).

END. /* pdf_begin_page */

PROCEDURE pdf_skip :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_skip","Cannot find Stream!").
    RETURN .
  END.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "TEXTSKIP"
         TT_pdf_content.obj_content = "T*"
         TT_pdf_content.obj_line    = pdf_CurrentLine.
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  pdf_CurrentLine  = pdf_CurrentLine - pdf_VerticalSpace(pdfStream).
  RUN pdf_set_TextX (pdfStream, pdf_LeftMargin(pdfStream)).
  RUN pdf_set_TextY (pdfStream, pdf_TextY(pdfStream) - pdf_VerticalSpace(pdfStream)).

END. /* pdf_skip */

PROCEDURE pdf_text_xy :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfText     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfColumn   AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRow      AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_xy","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_color   AS CHARACTER NO-UNDO.
  L_color = STRING(pdf_TextRed(pdfStream)) + " "
          + STRING(pdf_TextGreen(pdfStream)) + " "
          + STRING(pdf_TextBlue(pdfStream)) + " rg" + CHR(13).

  DEFINE VARIABLE L_PointSize   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_LeftMargin  AS CHARACTER NO-UNDO.
  L_PointSize  = STRING(pdf_PointSize(pdfStream)).
  L_LeftMargin = STRING(pdf_LeftMargin(pdfStream)).

  DEFINE VARIABLE L_Font        AS CHARACTER NO-UNDO.
  L_font = pdf_Font(pdfStream).

  FIND FIRST TT_pdf_font 
       WHERE TT_pdf_font.obj_stream = pdfStream 
         AND TT_pdf_font.font_name  = L_Font NO-LOCK NO-ERROR.
  L_Font = IF AVAIL TT_pdf_font THEN TT_pdf_Font.font_tag ELSE "/F1".

  DEFINE VARIABLE L_orig_text   AS CHARACTER NO-UNDO.
  L_orig_text = pdfText.

  IF pdfColumn = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_xy","Column cannot be zero!").
    RETURN .
  END.
  
  IF pdfRow    = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_xy","Row cannot be zero!").
    RETURN .
  END.

  RUN pdf_replace_text (INPUT-OUTPUT pdfText).
    
  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "TEXTXY"
         TT_pdf_content.obj_line    = pdfRow
         TT_pdf_content.obj_content = /* "BT" + CHR(13) */
                                    L_Font + " " + L_PointSize + " Tf" + CHR(13)
                                    + L_color 
                                    + "1 0 0 1 " + STRING(pdfColumn) + " "
                                    + STRING(pdfRow) + " Tm" + CHR(13)
                                    + L_LeftMargin + " TL" + CHR(13)
                                    + "(" + pdfText + ") Tj" + CHR(13)
                                    /* + "ET" + CHR(13) */
         TT_pdf_content.obj_length  = LENGTH( L_orig_text) .
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  RUN pdf_set_textY(pdfStream, pdfRow).

END. /* pdf_text_xy */

PROCEDURE pdf_text_boxed_xy :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfText     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfColumn   AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfRow      AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfWidth    AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfHeight   AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER pdfJustify  AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfWeight   AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_boxed_xy","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_color   AS CHARACTER NO-UNDO.
  L_color = STRING(pdf_TextRed(pdfStream)) + " "
          + STRING(pdf_TextGreen(pdfStream)) + " "
          + STRING(pdf_TextBlue(pdfStream)) + " rg" + CHR(13).

  DEFINE VARIABLE L_PointSize   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_LeftMargin  AS CHARACTER NO-UNDO.
  L_PointSize  = STRING(pdf_PointSize(pdfStream)).
  L_LeftMargin = STRING(pdf_LeftMargin(pdfStream)).

  DEFINE VARIABLE L_Font        AS CHARACTER NO-UNDO.
  L_Font = pdf_Font(pdfStream).
  FIND FIRST TT_pdf_font 
       WHERE TT_pdf_font.obj_stream = pdfStream
         AND TT_pdf_font.font_name  = L_Font
         NO-LOCK NO-ERROR.
  L_Font = IF AVAIL TT_pdf_font THEN TT_pdf_Font.font_tag ELSE "/F1".

  DEFINE VARIABLE L_orig_text   AS CHARACTER NO-UNDO.
  L_orig_text = pdfText.

  IF pdfColumn = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_boxed_xy","Column cannot be zero!").
    RETURN .
  END.
  
  IF pdfRow    = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_boxed_xy","Row cannot be zero!").
    RETURN .
  END.
  
  IF pdfHeight = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_boxed_xy","Height cannot be zero!").
    RETURN .
  END.
  
  IF pdfWidth  = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_boxed_xy","Width cannot be zero!").
    RETURN .
  END.

  IF LOOKUP(pdfJustify,"Left,Right,Center") = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_boxed_xy","Invalid Justification option passed!").
    RETURN .
  END.

  RUN pdf_replace_text (INPUT-OUTPUT pdfText).

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "TEXTXY"
         TT_pdf_content.obj_line    = pdfRow
         TT_pdf_content.obj_content = /* "BT" + CHR(13)
                                    + */ L_Font + " " + L_PointSize + " Tf" + CHR(13)
                                    + L_color
                                    + "1 0 0 1 " + STRING(pdfColumn) + " "
                                    + STRING(pdfRow) + " Tm" + CHR(13)
                                    + L_LeftMargin + " TL" + CHR(13)
                                    + "(" + pdfText + ") Tj" + CHR(13)
                                    /* + "ET" + CHR(13) */
         TT_pdf_content.obj_length  = LENGTH( L_orig_text).
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  IF pdfWeight = 0 THEN pdfWeight = 1.

  CREATE TT_pdf_content.
  ASSIGN TT_pdf_content.obj_stream  = pdfStream.
         TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
  ASSIGN TT_pdf_content.obj_type    = "GRAPHIC"
         TT_pdf_content.obj_line    = pdfRow
         TT_pdf_content.obj_content = "q" + CHR(13)
                                    + STRING(pdfWeight) + " w" + CHR(13)
                                    + STRING(pdfColumn) + " " + STRING(pdfRow) + " " 
                                    + STRING(pdfWidth) + " " + STRING(pdfHeight)
                                    + " re" + CHR(13)
                                    + "B" + CHR(13)         
                                    + "Q" + CHR(13)
         TT_pdf_content.obj_length  = LENGTH( L_orig_text) .
         TT_pdf_content.obj_page    = pdf_Page(pdfStream).

  RUN pdf_set_TextY(pdfStream, pdfRow).
  RUN pdf_set_GraphicY(pdfStream, pdfRow).
  
END. /* pdf_text_boxed_xy */

PROCEDURE pdf_text_at :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfText     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfColumn   AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_at","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_TextY       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_LeftMargin  AS CHARACTER NO-UNDO.
  L_TextY      = STRING(pdf_TextY(pdfStream)).
  L_LeftMargin = STRING(pdf_LeftMargin(pdfStream)).

  DEFINE VARIABLE L_orig_text   AS CHARACTER NO-UNDO.
  L_orig_text = pdfText.

  IF pdfColumn = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_at","Column cannot be zero!").
    RETURN .
  END.

  RUN pdf_replace_text (INPUT-OUTPUT pdfText).

  FIND FIRST B_TT_pdf_content 
       WHERE B_TT_pdf_content.obj_stream = pdfStream
         AND B_TT_pdf_content.obj_page   = pdf_Page(pdfStream)
         AND B_TT_pdf_content.obj_line   = pdf_TextY(pdfStream) NO-ERROR.
  IF AVAIL B_TT_pdf_content THEN DO:
    ASSIGN B_TT_pdf_content.obj_content = B_TT_pdf_content.obj_content
                                        + " " 
                                        + "(" + FILL(" ", pdfColumn - B_TT_pdf_content.obj_length - 1) 
                                        + pdfText + ") Tj "
           B_TT_pdf_content.obj_length  = B_TT_pdf_content.obj_length
                                        + LENGTH(FILL(" ", pdfColumn - B_TT_pdf_content.obj_length - 1) + L_orig_text).
  END.
  ELSE DO:
    CREATE TT_pdf_content.
    ASSIGN TT_pdf_content.obj_stream  = pdfStream.
           TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
    ASSIGN TT_pdf_content.obj_type    = "TEXTAT".
           TT_pdf_content.obj_line    = pdf_TextY(pdfStream).
           TT_pdf_content.obj_page    = pdf_Page(pdfStream).
    ASSIGN TT_pdf_content.obj_content = "1 0 0 1 " + L_LeftMargin + " " 
                                      + L_TextY + " Tm" + CHR(13)
                                      + "(" + FILL(" ", pdfColumn - 1) + pdfText + ") Tj "
           TT_pdf_content.obj_length  = LENGTH( FILL(" ",pdfColumn - 1) + L_orig_text) .
  END.

END. /* pdf_text_at */

PROCEDURE pdf_text_to :
  DEFINE INPUT PARAMETER pdfStream   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfText     AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfColumn   AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_to","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_TextY       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_LeftMargin  AS CHARACTER NO-UNDO.
  L_TextY      = STRING(pdf_TextY(pdfStream)).
  L_LeftMargin = STRING(pdf_LeftMargin(pdfStream)).

  DEFINE VARIABLE L_orig_text   AS CHARACTER NO-UNDO.
  L_orig_text = pdfText.

  IF pdfColumn = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_text_to","Column cannot be zero!").
    RETURN .
  END.

  RUN pdf_replace_text (INPUT-OUTPUT pdfText).

  FIND FIRST B_TT_pdf_content 
       WHERE B_TT_pdf_content.obj_stream = pdfStream
         AND B_TT_pdf_content.obj_page   = pdf_Page(pdfStream)
         AND B_TT_pdf_content.obj_line   = pdf_TextY(pdfStream) NO-ERROR.
  IF AVAIL B_TT_pdf_content THEN DO:
    ASSIGN B_TT_pdf_content.obj_content = B_TT_pdf_content.obj_content
                                        + " " 
                                        + "(" + FILL(" ", pdfColumn - (B_TT_pdf_content.obj_length + LENGTH(L_Orig_text))) 
                                        + pdfText + ") Tj "
           B_TT_pdf_content.obj_length  = B_TT_pdf_content.obj_length
                                        + LENGTH(FILL(" ", pdfColumn - (B_TT_pdf_content.obj_length + LENGTH(L_orig_text))) + L_orig_text).
  END.
  ELSE DO:
    CREATE TT_pdf_content.
    ASSIGN TT_pdf_content.obj_stream  = pdfStream.
           TT_pdf_content.obj_seq     = pdf_inc_ContentSequence().
    ASSIGN TT_pdf_content.obj_type    = "TEXTAT"
           TT_pdf_content.obj_content = "1 0 0 1 " + L_LeftMargin + " " 
                                      + L_TextY + " Tm" + CHR(13)
                                      + "(" + FILL(" ", pdfColumn - LENGTH( L_orig_text) - 1) + pdfText + ") Tj "
           TT_pdf_content.obj_length  = LENGTH( FILL(" ",pdfColumn - LENGTH(L_orig_text) - 1) + L_orig_text) .
           TT_pdf_content.obj_line    = pdf_TextY(pdfStream).
           TT_pdf_content.obj_page    = pdf_Page(pdfStream).
  END.

END. /* pdf_text_to */


PROCEDURE pdf_close :
  DEFINE INPUT PARAMETER pdfStream AS CHARACTER NO-UNDO.
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_close","Cannot find Stream!").
    RETURN .
  END.
  
  DEFINE VARIABLE L_pdf_obj AS INTEGER NO-UNDO.

  FIND FIRST TT_pdf_stream WHERE TT_pdf_stream.obj_stream = pdfStream
       NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_stream THEN 
    RETURN .
  
  OUTPUT STREAM S_pdf_inc TO VALUE( TT_pdf_stream.obj_file ) UNBUFFERED.
    /* Output PDF Header Requirements */
    RUN pdf_Header (INPUT TT_pdf_stream.obj_stream).

    /* Load 12 Base Fonts - exclude wingdings etc */
    RUN pdf_Encoding (pdfStream).
    RUN pdf_Fonts (pdfStream).

    IF CAN-FIND (FIRST TT_pdf_error 
                 WHERE TT_pdf_error.obj_stream = pdfStream NO-LOCK) THEN DO:
      FOR EACH TT_pdf_error.
        DISPLAY TT_pdf_error.
      END.
    END.
    ELSE DO:
      /* Load Embedded Fonts */
      IF CAN-FIND( FIRST TT_pdf_font WHERE TT_pdf_font.obj_stream = pdfStream
                                       AND TT_pdf_font.font_file <> "PDFBASE14" NO-LOCK)
      THEN RUN pdf_Load_Fonts (pdfStream).

      /* Load Embedded Images */
      IF CAN-FIND( FIRST TT_pdf_image NO-LOCK)
      THEN RUN pdf_Load_Images (pdfStream).

      RUN pdf_Resources (pdfStream).
      RUN pdf_Content (pdfStream).
      RUN pdf_Xref (pdfStream).
    END.

  OUTPUT STREAM S_pdf_inc CLOSE.

END PROCEDURE.

PROCEDURE pdf_set_Orientation :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS CHARACTER NO-UNDO.

  DEFINE VARIABLE L_width   AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_height  AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_Orientation","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_option  AS CHARACTER NO-UNDO.
  L_Option = "Portrait,Landscape".

  IF LOOKUP(pdfValue,L_option) = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_Orientation","Invalid Orientation option passed!").
    RETURN .
  END.

  FIND FIRST B_TT_pdf_param 
       WHERE B_TT_pdf_param.obj_stream    = pdfStream
         AND B_TT_pdf_param.obj_parameter = "Orientation" NO-LOCK NO-ERROR.
  IF NOT AVAIL B_TT_pdf_param THEN DO:
    CREATE B_TT_pdf_param.
    ASSIGN B_TT_pdf_param.obj_stream    = pdfStream
           B_TT_pdf_param.obj_parameter = "Orientation".
  END.

  IF B_TT_pdf_param.obj_value <> pdfValue THEN DO:
    L_width  = pdf_PageWidth("Spdf").
    L_height = pdf_PageHeight("Spdf").

    IF pdfValue = "Landscape" THEN DO:
      RUN pdf_set_PageWidth(pdfStream,L_height).
      RUN pdf_set_PageHeight(pdfStream,L_width).
    END.
    ELSE DO:
      RUN pdf_set_PageWidth(pdfStream,L_width).
      RUN pdf_set_PageHeight(pdfStream,L_height).
    END.
  END.

  B_TT_pdf_param.obj_value = pdfValue.

END. /* pdf_set_Orientation */

PROCEDURE pdf_set_VerticalSpace :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_VerticalSpace","Cannot find Stream!").
    RETURN .
  END.

  IF pdfValue = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_VerticalSpace","Vertical Space cannot be zero!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "VerticalSpace" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "VerticalSpace".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_VerticalSpace */

PROCEDURE pdf_set_LeftMargin :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_LeftMargin","Cannot find Stream!").
    RETURN .
  END.

  IF pdfValue = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_LeftMargin","Left Margin cannot be zero!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "LeftMargin" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "LeftMargin".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_LeftMargin */

PROCEDURE pdf_set_TopMargin :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS INTEGER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TopMargin","Cannot find Stream!").
    RETURN .
  END.

  IF pdfValue = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_TopMargin","Top Margin cannot be zero!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "TopMargin" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "TopMargin".
  END.

  TT_pdf_param.obj_value = STRING(pdfValue).

END. /* pdf_set_TopMargin */

FUNCTION pdf_Orientation RETURN CHARACTER ( INPUT pdfStream AS CHARACTER):
  
  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_Orientation","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "Orientation"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN RETURN TT_pdf_param.obj_value.
  ELSE RETURN "Portrait".

END. /* pdf_Orientation */

PROCEDURE pdf_set_PaperType :
  DEFINE INPUT PARAMETER pdfStream          AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pdfValue           AS CHARACTER NO-UNDO.

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_PaperType","Cannot find Stream!").
    RETURN .
  END.

  DEFINE VARIABLE L_option  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_width   AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_height  AS INTEGER NO-UNDO.
  
  L_Option = "A0,A1,A2,A3,A4,A5,A6,B5,LETTER,LEGAL,LEDGER".

  IF LOOKUP(pdfValue,L_option) = 0 THEN DO:
    RUN pdf_error(pdfStream,"pdf_set_PaperType","Invalid Paper Type option passed!").
    RETURN .
  END.

  FIND FIRST TT_pdf_param 
       WHERE TT_pdf_param.obj_stream    = pdfStream
         AND TT_pdf_param.obj_parameter = "PaperType" NO-LOCK NO-ERROR.
  IF NOT AVAIL TT_pdf_param THEN DO:
    CREATE TT_pdf_param.
    ASSIGN TT_pdf_param.obj_stream    = pdfStream
           TT_pdf_param.obj_parameter = "PaperType".
  END.
  
  /* Set the Paper Type */
  TT_pdf_param.obj_value = pdfValue.

  /* Determine the Paper Height and Width */
  CASE pdfValue:
    WHEN "A0" THEN
      ASSIGN L_width  = 2380
             L_height = 3368.
    WHEN "A1" THEN
      ASSIGN L_width  = 1684
             L_height = 2380.
    WHEN "A2" THEN
      ASSIGN L_width  = 1190
             L_height = 1684.
    WHEN "A3" THEN
      ASSIGN L_width  = 842
             L_height = 1190.
    WHEN "A4" THEN
      ASSIGN L_width  = 595
             L_height = 842.
    WHEN "A5" THEN
      ASSIGN L_width  = 421
             L_height = 595.
    WHEN "A6" THEN
      ASSIGN L_width  = 297
             L_height = 421.
    WHEN "B5" THEN
      ASSIGN L_width  = 501
             L_height = 709.
    WHEN "LETTER" THEN
      ASSIGN L_width  = 612
             L_height = 792.
    WHEN "LEGAL" THEN
      ASSIGN L_width  = 612
             L_height = 1008.
    WHEN "LEDGER" THEN
      ASSIGN L_width  = 1224
             L_height = 792.
    OTHERWISE
      ASSIGN L_width  = 612
             L_height = 792.
  END CASE.

  /* Now Set the Page Height and Width Parameters */
  IF pdf_Orientation(pdfStream) = "Portrait" THEN DO:
    RUN pdf_set_PageWidth(pdfStream,L_width).
    RUN pdf_set_PageHeight(pdfStream,L_height).
  END.
  ELSE DO:  
    RUN pdf_set_PageWidth(pdfStream,L_height).
    RUN pdf_set_PageHeight(pdfStream,L_width).
  END.

END. /* pdf_set_PaperType */

FUNCTION pdf_PaperType RETURN CHARACTER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_PaperType","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "PaperType"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN RETURN TT_pdf_param.obj_value.
  ELSE RETURN "LETTER".
  
END. /* pdf_PaperType */

FUNCTION pdf_Render RETURN INTEGER ( INPUT pdfStream AS CHARACTER):

  IF NOT CAN-FIND(FIRST TT_pdf_stream 
                  WHERE TT_pdf_stream.obj_stream = pdfStream NO-LOCK)
  THEN DO:
    RUN pdf_error(pdfStream,"pdf_Render","Cannot find Stream!").
    RETURN ERROR.
  END.
  
  FIND FIRST TT_pdf_param WHERE TT_pdf_param.obj_stream    = pdfStream
                            AND TT_pdf_param.obj_parameter = "Render"
                            NO-LOCK NO-ERROR.
  IF AVAIL TT_pdf_param THEN RETURN INT(TT_pdf_param.obj_value).
  ELSE RETURN 0.
  
END. /* pdf_Render */

/* ---------------------- Define INTERNAL PROCEDURES ----------------------- */
PROCEDURE pdf_init_param:
  DEFINE INPUT PARAMETER pdfStream AS CHARACTER NO-UNDO.

  /* Create Parameters */
  RUN pdf_set_Orientation(pdfStream,"Portrait").
  RUN pdf_set_PaperType(pdfStream,"LETTER").  /* This also default the PageWidth
                                             and PageHeight Parameters */
  RUN pdf_set_Font(pdfStream,"Courier",10.0). /* This also sets the PointSize */
  RUN pdf_set_VerticalSpace(pdfStream,10).
  RUN pdf_set_LeftMargin(pdfStream,10).
  RUN pdf_set_TopMargin(pdfStream,50).
  RUN pdf_set_TextY(pdfStream,pdf_PageHeight(pdfStream) - pdf_TopMargin(pdfStream)).
  RUN pdf_set_TextX(pdfStream,0).  
  RUN pdf_set_GraphicY(pdfStream,0).
  RUN pdf_set_GraphicX(pdfStream,0).
  RUN pdf_set_TextRed(pdfStream,.0).
  RUN pdf_set_TextGreen(pdfStream,.0).
  RUN pdf_set_TextBlue(pdfStream,.0).

END. /* pdf_init_param */

PROCEDURE pdf_Header :
  DEFINE INPUT PARAMETER P_Stream AS CHARACTER NO-UNDO.
  
  /* Version Compatibilities */
  PUT STREAM S_pdf_inc UNFORMATTED
      "%PDF-1.4" SKIP.

  /* Output 4 Binary Characters (greater than ASCII 128) to indicate to a binary
     file -- randomly selected codes */
  PUT STREAM S_pdf_inc UNFORMATTED
      "%" CHR(244) CHR(244) CHR(244) CHR(244) SKIP.

  /* Display Creation, Title, Producer etc Information */
  ObjectSequence( p_Stream,1, "Info" ).
  PUT STREAM S_pdf_inc UNFORMATTED
      /* pdf_inc_ObjectSequence */ "1 0 obj" SKIP
      "<<" SKIP
      "/Author (" pdf_get_info(P_Stream,"Author") ")" SKIP
      "/CreationDate (D:" TRIM(STRING(YEAR(TODAY),"9999")) TRIM(STRING(MONTH(TODAY),"99"))
                          TRIM(STRING(DAY(TODAY),"99")) 
                          REPLACE(STRING(TIME,"hh:mm:ss"),":","")
                          "-0800)"
                          SKIP
      "/Producer (" pdf_get_info(P_Stream,"Producer") ")" SKIP
      "/Creator (" pdf_get_info(P_Stream,"Creator") ")" SKIP
      "/Subject (" pdf_get_info(P_Stream,"Subject") ")" SKIP
      "/Title (" pdf_get_info(P_Stream,"Title") ")" SKIP
      "/Keywords (" pdf_get_info(P_Stream,"Keywords") ")" SKIP
      ">>" SKIP
      "endobj" SKIP.

END. /* pdf_header */

PROCEDURE pdf_LoadBase14:

  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.

  /* ---- Beginning of Courier Fonts ---- */

  /* ObjectSequence(pdfStream, 5, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Courier"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 5
         TT_pdf_font.font_tag   = "/F1"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "FIXED"
         TT_pdf_font.font_width = "600".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Courier-Oblique"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 6
         TT_pdf_font.font_tag   = "/F2"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "FIXED"
         TT_pdf_font.font_width = "600".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Courier-Bold"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 7
         TT_pdf_font.font_tag   = "/F3"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "FIXED"
         TT_pdf_font.font_width = "600".
    
  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Courier-BoldOblique"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 8
         TT_pdf_font.font_tag   = "/F4"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "FIXED"
         TT_pdf_font.font_width = "600".

  /* ---- End of Courier Fonts ---- */

  /* ---- Beginning of Helvetica Fonts ---- */

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Helvetica"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 9
         TT_pdf_font.font_tag   = "/F5"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width = FILL("788 ", 31) + "278 278 355 556 556 889 "
                                + "667 222 333 333 389 584 278 333 278 278 556 "
                                + "556 556 556 556 556 556 556 556 556 278 278 "
                                + "584 584 584 556 1015 667 667 722 667 611 778 "
                                + "722 278 500 667 556 833 722 778 667 778 722 "
                                + "667 611 722 667 944 667 667 611 278 278 278 "
                                + "469 556 222 556 556 500 556 556 278 556 556 "
                                + "222 222 500 222 833 556 556 556 556 333 500 "
                                + "278 556 500 722 500 500 500 334 260 334 584 "
                                + "333 556 556 167 556 556 556 556 191 333 556 "
                                + "333 333 500 500 556 556 556 278 537 350 222 "
                                + "333 333 556 1000 1000 611 333 333 333 333 333 "
                                + "333 333 333 333 333 333 333 333 1000 1000 370 "
                                + "556 778 1000 365 889 278 222 611 944 611".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Helvetica-Oblique"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 10
         TT_pdf_font.font_tag   = "/F6"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width = FILL("788 ", 31) + "278 278 355 556 556 889 "
                                + "667 222 333 333 389 584 278 333 278 278 556 "
                                + "556 556 556 556 556 556 556 556 556 278 278 "
                                + "584 584 584 556 1015 667 667 722 722 667 611 "
                                + "778 722 278 500 667 556 833 722 778 667 778 "
                                + "722 667 611 722 667 944 667 667 611 278 278 "
                                + "278 469 556 222 556 556 500 556 556 278 556 "
                                + "556 222 222 500 222 833 556 556 556 556 333 "
                                + "500 278 556 500 722 500 500 500 334 260 334 "
                                + "584 333 556 556 167 556 556 556 556 191 333 "
                                + "556 333 333 500 500 556 556 556 278 537 350 "
                                + "222 333 333 556 1000 1000 611 333 333 333 333 "
                                + "333 333 333 333 333 333 333 333 333 1000 "
                                + "1000 370 556 778 1000 365 889 278 222 611 "
                                + "944 611".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Helvetica-Bold"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 11
         TT_pdf_font.font_tag   = "/F7"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width = FILL("788 ", 31) + "278 333 474 556 556 889 "
                                + "722 278 333 333 389 584 278 333 278 278 556 "
                                + "556 556 556 556 556 556 556 556 556 333 333 "
                                + "584 584 584 611 975 722 722 722 722 667 611 "
                                + "778 722 278 556 722 611 833 722 778 667 778 "
                                + "722 667 611 722 667 944 667 667 611 333 278 "
                                + "333 584 556 278 556 611 556 611 556 333 611 "
                                + "611 278 278 556 278 889 611 611 611 611 389 "
                                + "556 333 611 556 778 556 556 500 389 280 389 "
                                + "584 333 556 556 167 556 556 556 556 238 500 "
                                + "556 333 333 611 611 556 556 556 278 556 350 "
                                + "278 500 500 556 1000 1000 611 333 333 333 333 "
                                + "333 333 333 333 333 333 333 333 333 1000 "
                                + "1000 370 611 778 1000 365 889 278 278 611 "
                                + "944 611".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Helvetica-BoldOblique"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 12
         TT_pdf_font.font_tag   = "/F8"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width = FILL("788 ", 31) + "278 333 474 556 556 889 "
                                + "722 278 333 333 389 584 278 333 278 278 556 "
                                + "556 556 556 556 556 556 556 556 556 333 333 "
                                + "584 584 584 611 975 722 722 722 722 667 611 "
                                + "778 722 278 556 722 611 833 722 778 667 778 "
                                + "722 667 611 722 667 944 667 667 611 333 278 "
                                + "333 584 556 278 556 611 556 611 556 333 611 "
                                + "611 278 278 556 278 889 611 611 611 611 389 "
                                + "556 333 611 556 778 556 556 500 389 280 389 "
                                + "584 333 556 556 167 556 556 556 556 238 500 "
                                + "556 333 333 611 611 556 556 556 278 556 350 "
                                + "278 500 500 556 1000 1000 611 333 333 333 "
                                + "333 333 333 333 333 333 333 333 333 333 "
                                + "1000 1000 370 611 778 1000 365 889 278 278 "
                                + "611 944 611".

  /* ---- End of Helvetica Fonts ---- */
  
  /* ---- Beginning of Times Roman Fonts ---- */ 

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Times-Roman"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 13
         TT_pdf_font.font_tag   = "/F9"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width =   FILL("788 ", 31) + "250 " + "333 " + "408 "
                                + "500 500 833 778 180 333 333 500 564 250 "
                                + "333 250 278 500 500 500 500 500 500 500 "
                                + "500 500 500 278 278 564 564 564 444 921 "
                                + "722 667 667 722 611 556 722 722 333 389 "
                                + "722 611 889 722 722 556 722 667 556 611 "
                                + "722 722 944 722 722 611 333 278 333 469 "
                                + "500 333 444 500 444 500 444 333 500 500 "
                                + "278 278 500 278 778 500 500 500 500 333 "
                                + "389 278 500 500 722 500 500 444 480 200 "
                                + "480 541 778 500 578 333 500 444 1000 500 "
                                + "500 333 1000 556 333 889 667 611 722 444 "
                                + "333 333 444 444 350 500 1000 333 980 389 "
                                + "333 722 486 444 722 250 333 500 500 500 "
                                + "500 200 500 333 760 276 500 564 333 760 "
                                + "500 400 549 300 300 333 576 453 250 333 "
                                + "300 310 500 750 750 750 444 722 722 722 "
                                + "722 722 722 889 667 611 611 611 611 333 "
                                + "333 333 333 722 722 722 722 722 722 722 "
                                + "564 722 722 722 722 722 722 556 500 444 "
                                + "444 444 444 444 444 667 444 444 444 444 "
                                + "444 278 278 278 278 500 500 500 500 500 "
                                + "500 500 549 500 500 500 500 500 500 500 "
                                + "500".


  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Times-Italic"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 14
         TT_pdf_font.font_tag   = "/F10"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width =   FILL("788 ", 31) + "250 333 420 500 500 "
                                + "833 778 333 333 333 500 675 250 333 250 278 "
                                + "500 500 500 500 500 500 500 500 500 500 333 "
                                + "333 675 675 675 500 920 611 611 667 722 611 "
                                + "611 722 722 333 444 667 556 833 667 722 611 "
                                + "500 559 722 611 833 611 556 556 389 278 389 "
                                + "422 500 333 500 500 444 500 444 278 500 500 "
                                + "278 278 444 278 722 500 500 500 500 389 389 "
                                + "278 500 444 667 444 444 389 400 278 400 541 "
                                + "389 500 500 167 500 500 500 500 214 556 500 "
                                + "333 333 500 500 500 500 500 250 523 350 333 "
                                + "556 556 500 889 1000 500 333 333 333 333 333 "
                                + "333 333 333 333 333 333 333 333 889 889 276"
                                + "556 722 944 310 667 278 278 500 667 500".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Times-Bold"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 15
         TT_pdf_font.font_tag   = "/F11"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width =  FILL("788 ", 31) + "250 333 555 500 500 "
                                + "1000 833 333 333 333 500 570 250 333 250 "
                                + "278 500 500 500 500 500 500 500 500 500 500 "
                                + "333 333 570 570 570 500 930 722 667 722 722 "
                                + "667 611 778 778 389 500 778 667 944 722 778 "
                                + "611 778 722 556 667 722 722 1000 722 722 667 "
                                + "333 278 333 581 500 333 500 556 444 556 444 "
                                + "333 500 556 278 333 556 278 833 556 500 556 "
                                + "556 444 389 333 556 500 722 500 500 444 394 "
                                + "220 394 520 333 500 500 167 500 500 500 500 "
                                + "278 500 500 333 333 556 556 500 500 500 250 "
                                + "540 350 333 500 500 500 1000 1000 500 333 333 "
                                + "333 333 333 333 333 333 333 333 333 333 333 "
                                + "1000 1000 300 667 778 1000 330 722 278 278 "
                                + "500 722 556".

  /* ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font"). */
  /* Create Associated Object */
  CREATE TT_pdf_font.
  ASSIGN TT_pdf_font.font_name  = "Times-BoldItalic"
         TT_pdf_font.font_file  = "PDFBASE14"
         TT_pdf_font.font_afm   = ""
         TT_pdf_font.font_obj   = 16
         TT_pdf_font.font_tag   = "/F12"
         TT_pdf_font.obj_stream = pdfStream
         TT_pdf_font.font_type  = "VARIABLE"
         TT_pdf_font.font_width = FILL("788 ", 31) + "250 389 555 500 500 833 "
                                + "778 333 333 333 500 570 250 333 250 278 500 "
                                + "500 500 500 500 500 500 500 500 500 333 333 "
                                + "570 570 570 500 832 667 667 667 722 667 667 "
                                + "722 778 389 500 667 611 889 722 722 611 722 "
                                + "667 556 611 722 667 889 667 611 611 333 278 "
                                + "333 570 500 333 500 500 444 500 444 333 500 "
                                + "556 278 278 500 278 778 556 500 500 500 389 "
                                + "278 556 444 667 500 444 389 348 220 348 570 "
                                + "389 500 500 167 500 500 500 500 278 500 500 "
                                + "333 333 556 556 500 500 500 250 500 350 333 "
                                + "500 500 500 1000 1000 500 333 333 333 333 333 "
                                + "333 333 333 333 333 333 333 333 1000 944 266 "
                                + "611 722 944 300 722 278 278 500 722 500".
                                                                                                                  
  /* ---- End of Times Roman Fonts ---- */

  pdf_inc_ObjectSequence = 16.

END. /* pdf_LoadBase14 */

PROCEDURE pdf_Encoding:
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.

  ObjectSequence(pdfStream,4, "Encoding"). 
  PUT STREAM S_pdf_inc UNFORMATTED
      /* pdf_inc_ObjectSequence */ "4 0 obj" SKIP
      "<<" SKIP
      "/Type /Encoding" SKIP
      "/BaseEncoding /WinAnsiEncoding" SKIP
      ">>" SKIP
      "endobj" SKIP.

END. /* pdf_Encoding */

PROCEDURE pdf_Resources:
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE L_fontobj AS CHARACTER NO-UNDO.
  
  FOR EACH TT_pdf_font NO-LOCK:
    ASSIGN L_fontobj = L_fontobj + " " + TT_pdf_font.font_tag + " "
                     + STRING(TT_pdf_font.font_obj) + " 0 R".
  END.

  Vuse-font = "/F1".

  ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Resource").
  pdf-Res-Object = pdf_inc_ObjectSequence.
  PUT STREAM S_pdf_inc UNFORMATTED
      pdf_inc_ObjectSequence " 0 obj" SKIP
      "<<" SKIP
      "  /Font << " L_fontobj " >>" SKIP
      "  /ProcSet [ /PDF /Text /ImageC ]" SKIP
      "  /XObject << " .

  /* Output Image Definitions */
  FOR EACH TT_pdf_image:
    PUT STREAM S_pdf_inc UNFORMATTED
        TT_pdf_image.image_tag " " TT_pdf_image.image_obj " 0 R ".
  END.

  PUT STREAM S_pdf_inc UNFORMATTED
      " >>" SKIP
      ">>" SKIP
      "endobj" SKIP.
  
END. /* pdf_Resources */

PROCEDURE pdf_Content:
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE L_font    AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE L_Loop    AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_Page    AS INTEGER NO-UNDO.

  /* Produce each Page one at a time */
  DO L_Loop = 1 TO pdf_Page(pdfStream):
    IF CAN-FIND(FIRST TT_pdf_content WHERE TT_pdf_content.obj_page = L_Loop)
    THEN DO:

      L_page = L_page + 1.
      /* Start Page Definition */
      RUN pdf_Definition (pdfStream ,L_page, IF L_page = 1 THEN FALSE ELSE TRUE).
      ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Content").
      PUT STREAM S_pdf_inc UNFORMATTED
          pdf_inc_ObjectSequence " 0 obj" SKIP
          "<<" SKIP
          "/Length " (pdf_inc_ObjectSequence + 1) " 0 R" SKIP
          ">>" SKIP
          "stream" SKIP.
      pdf-Stream-Start = SEEK(S_pdf_inc).

      /* Process Rectangle Content */
      IF CAN-FIND(FIRST TT_pdf_content 
                  WHERE TT_pdf_content.obj_page = L_page
                    AND TT_pdf_content.obj_type BEGINS "GRAPHIC" NO-LOCK)
      THEN DO:
        PUT STREAM S_pdf_inc UNFORMATTED
            "q" CHR(13).
        FOR EACH TT_pdf_content WHERE TT_pdf_content.obj_page        = L_page 
                                  AND TT_pdf_content.obj_type BEGINS "GRAPHIC" 
                                  NO-LOCK
                                  BREAK BY TT_pdf_content.obj_seq:
          PUT STREAM S_pdf_inc UNFORMATTED
             TT_pdf_content.obj_content CHR(13).
        END.
        PUT STREAM S_pdf_inc UNFORMATTED
            "Q" CHR(13).
      END. /* Cand find Graphic Content */

      /* Process Image Content */
      FOR EACH TT_pdf_content WHERE TT_pdf_content.obj_page        = L_page 
                                AND TT_pdf_content.obj_type BEGINS "IMAGE" 
                                NO-LOCK
                                BREAK BY TT_pdf_content.obj_seq:
        PUT STREAM S_pdf_inc UNFORMATTED
           "q " TT_pdf_content.obj_content " Q" CHR(13).
      END.

      /* Process Text (at, inline, to) Content */
      PUT STREAM S_pdf_inc UNFORMATTED
          "BT" CHR(13)
          Vuse-font " 10 Tf" CHR(13)
          "1 0 0 1 " pdf_LeftMargin(pdfStream) " " (pdf_PageHeight(pdfStream) - pdf_TopMargin(pdfStream)) " Tm" CHR(13)
          "10 TL" CHR(13).

      FOR EACH TT_pdf_content WHERE TT_pdf_content.obj_page = L_page 
                                AND TT_pdf_content.obj_type BEGINS "TEXT"
                                /* AND TT_pdf_content.obj_type <> "TEXTXY" */ NO-LOCK
          BREAK BY TT_pdf_content.obj_line DESC 
                BY TT_pdf_content.obj_seq:

        PUT STREAM S_pdf_inc UNFORMATTED
           TT_pdf_content.obj_content CHR(13).

      END. /* each text object on page */

      PUT STREAM S_pdf_inc UNFORMATTED
          "ET" CHR(13).

      /* End Page Definition */
      pdf-Stream-End = SEEK(S_pdf_inc). 
      PUT STREAM S_pdf_inc UNFORMATTED
          "endstream" SKIP
          "endobj" SKIP.

      /* Output Length */
      RUN pdf_length (pdfStream, pdf-Stream-End - pdf-Stream-Start).

    END. /* Can-find page content */
  END. /* loop for each page */
  
  /* This will set the PDF Page to the max actual Page number */
  RUN pdf_set_Page(pdfStream, L_page).

  RUN pdf_catalog (pdfStream).
  RUN pdf_ListPages (pdfStream).
END. /* pdf_Content */

PROCEDURE pdf_definition:
  DEFINE INPUT PARAMETER pdfStream      AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER P_page         AS INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER P_incl-annot   AS LOGICAL NO-UNDO.
  
  ObjectSequence (pdfStream, pdf_inc_ObjectSequence + 1, "Definition").
  PUT STREAM S_pdf_inc UNFORMATTED
      pdf_inc_ObjectSequence " 0 obj" SKIP
      "<<" SKIP
      "/Type /Page" SKIP
      "/Parent 3 0 R" SKIP
      "/Resources " pdf-Res-Object " 0 R" SKIP
      "/Contents " (pdf_inc_ObjectSequence + 1) " 0 R" SKIP
      "/Rotate 0" SKIP.

  PUT STREAM S_pdf_inc UNFORMATTED
      ">>" SKIP
      "endobj" SKIP.

END. /* pdf_definition */

PROCEDURE pdf_Length:
  
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER P_length   AS INTEGER NO-UNDO.
  
  ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Length").
  PUT STREAM S_pdf_inc UNFORMATTED
      pdf_inc_ObjectSequence " 0 obj" SKIP
      P_length SKIP
      "endobj" SKIP.

END. /* pdf_Length */

PROCEDURE pdf_Catalog :
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  
  ObjectSequence(pdfStream, 2, "Catalog").
  PUT STREAM S_pdf_inc UNFORMATTED
      "2 0 obj" SKIP
      "<<" SKIP
      "/Type /Catalog" SKIP
      "/Pages 3 0 R" SKIP
      /* "/PageLayout /OneColumn" SKIP */
      ">>" SKIP
      "endobj" SKIP.

END. /* pdf_Catalog */

PROCEDURE pdf_ListPages :

  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  
  ObjectSequence(pdfStream, 3, "Pages").
  PUT STREAM S_pdf_inc UNFORMATTED
      "3 0 obj" SKIP
      "<<" SKIP
      "/Type /Pages" SKIP
      "/Count " pdf_Page(pdfStream) SKIP
      "/MediaBox [ 0 0 " pdf_PageWidth(pdfStream) " " pdf_PageHeight(pdfStream) " ]" SKIP
      "/Kids [ ".

  FOR EACH TT_pdf_object WHERE TT_pdf_object.obj_stream = pdfStream
                           AND TT_pdf_object.obj_desc = "Content" NO-LOCK:
    PUT STREAM S_pdf_inc UNFORMATTED
        (TT_pdf_object.obj_nbr - 1) " 0 R ".
  END. /* Display Pages */

  PUT STREAM S_pdf_inc UNFORMATTED
      "]" SKIP
      ">>" SKIP
      "endobj" SKIP.

END. /* pdf_ListPages */

PROCEDURE pdf_xref :

  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE L_ctr AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_obj AS INTEGER NO-UNDO.
  
  ObjectSequence(pdfStream, 0, "Xref").
  FOR EACH TT_pdf_object WHERE TT_pdf_object.obj_stream = pdfStream:
    L_ctr = L_ctr + 1.
  END.

  /* Get the Xref start point */
  pdf-Stream-Start = SEEK(S_pdf_inc).

  PUT STREAM S_pdf_inc UNFORMATTED
      "xref" SKIP
      "0 " L_ctr SKIP.

  FOR EACH TT_pdf_object BREAK BY TT_pdf_object.obj_nbr:
    IF FIRST( TT_pdf_object.obj_nbr) THEN
      PUT STREAM S_pdf_inc
          "0000000000"
          " " 
          TT_pdf_object.gen_nbr " "
          TT_pdf_object.obj_type SKIP.
    ELSE DO:
      TT_pdf_object.obj_off = TT_pdf_object.obj_off - 1.
      PUT STREAM S_pdf_inc 
          TT_pdf_object.obj_off
          " " 
          TT_pdf_object.gen_nbr " "
          TT_pdf_object.obj_type SKIP.
    END.
  END.
  
  FIND LAST TT_pdf_object NO-LOCK NO-ERROR.
  
  PUT STREAM S_pdf_inc UNFORMATTED
      "trailer" SKIP
      "<<" SKIP
      "/Size " (TT_pdf_object.obj_nbr + 1) SKIP
      "/Root 2 0 R" SKIP
      "/Info 1 0 R" SKIP
      ">>" SKIP
      "startxref" SKIP
      pdf-Stream-Start SKIP
      "%%EOF" SKIP.

END. /* pdf_xref */

PROCEDURE pdf_Fonts:

  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.

  FOR EACH TT_pdf_font WHERE TT_pdf_font.font_file = "PDFBASE14"
      BY TT_pdf_font.font_obj:
    
    ObjectSequence(pdfStream, TT_pdf_font.font_obj, "Font").
    PUT STREAM S_pdf_inc UNFORMATTED
          TT_pdf_font.FONT_obj " 0 obj" SKIP
          "<<" SKIP
          "/Type /Font" SKIP
          "/Subtype /Type1" SKIP
          "/Name " TT_pdf_font.font_tag SKIP
          "/Encoding 4 0 R" SKIP
          "/BaseFont /" TT_pdf_font.font_name SKIP
          ">>" SKIP
          "endobj" SKIP.
  END.

END. /* pdf_Fonts */

PROCEDURE pdf_Load_fonts :
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE L_data  AS RAW NO-UNDO.
  DEFINE VARIABLE L_start AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_end   AS INTEGER NO-UNDO.
  
  DEFINE VARIABLE L_afm_ItalicAngle  AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_afm_Ascender     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_afm_Descender    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_afm_FontBBox     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_afm_FirstChar    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_afm_LastChar     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_afm_Widths       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_afm_IsFixedPitch AS CHARACTER NO-UNDO INIT "0".
  DEFINE VARIABLE L_afm_flags        AS CHARACTER NO-UNDO.

  FOR EACH TT_pdf_font WHERE TT_pdf_font.obj_stream = pdfStream
                         AND TT_pdf_font.font_file <> "PDFBASE14":

    RUN pdf_ParseAFMFile 
        (OUTPUT L_afm_ItalicAngle,
         OUTPUT L_afm_Ascender,
         OUTPUT L_afm_Descender,
         OUTPUT L_afm_FontBBox,
         OUTPUT L_afm_FirstChar,
         OUTPUT L_afm_LastChar,
         OUTPUT L_afm_Widths,
         OUTPUT L_afm_IsFixedPitch,
         OUTPUT L_afm_Flags) NO-ERROR.
    
    /* If any errors occur while parsing AFM file then ignore the font */
    IF ERROR-STATUS:ERROR THEN NEXT.

    FILE-INFO:FILE-NAME = TT_pdf_font.font_file.

    /* igc - Added Sept 10, 2002 */
    ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "FontDescriptor").
    TT_pdf_font.font_descr  = pdf_inc_ObjectSequence.

    /* Output the Font Descriptor */
    PUT STREAM S_pdf_inc UNFORMATTED
        TT_pdf_font.font_descr " 0 obj" SKIP
        "<< /Type /FontDescriptor" SKIP
        "   /Ascent " L_afm_Ascender SKIP
        "   /Descent " L_afm_Descender SKIP
        "   /Flags " L_afm_Flags SKIP
        "   /FontBBox [ " L_afm_FontBBox " ]" SKIP
        "   /FontName /" TT_pdf_font.font_name SKIP
        "   /ItalicAngle " L_afm_ItalicAngle  SKIP
        "   /FontFile2 " (TT_pdf_font.font_descr + 2) " 0 R" SKIP
        ">>" SKIP
        "endobj" SKIP.
    
    /* igc - Added Sept 10, 2002 */
    ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Font").
    TT_pdf_font.font_obj    = pdf_inc_ObjectSequence.
    
    PUT STREAM S_pdf_inc UNFORMATTED 
      TT_pdf_font.font_obj " 0 obj" SKIP
      "<<" SKIP
      "/Type /Font" SKIP
      "/Subtype /TrueType" SKIP
      "/FirstChar " L_afm_FirstChar SKIP
      "/LastChar " L_afm_LastChar SKIP
      "/Widths [ " L_afm_widths " ]" SKIP
      "/Encoding /WinAnsiEncoding" SKIP 
      "/BaseFont /" TT_pdf_font.font_name SKIP
      "/FontDescriptor " TT_pdf_font.font_descr " 0 R" SKIP
      ">>" SKIP
      "endobj" SKIP.

    /*** igc - Nov 4, 2002 - removed. Now uses OS-APPEND
    /* Determine the File Size -- cannot use FILE-INFO:FILE-SIZE since that is
       V9 specific code */
    INPUT STREAM S_pdf_inp FROM VALUE(TT_pdf_font.font_file) BINARY NO-MAP NO-CONVERT UNBUFFERED.
      SEEK STREAM S_pdf_inp TO END.
      LENGTH(L_data) = IF SEEK(S_pdf_inp) > 16832 THEN 16832 ELSE SEEK(S_pdf_inp).
    INPUT STREAM S_pdf_inp CLOSE.
    ****/

    /* igc - Added Sept 10, 2002 */
    ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "FontStream").
    TT_pdf_font.font_stream = pdf_inc_ObjectSequence.

    /* Display Embedded Font Stream */
    PUT STREAM S_pdf_inc UNFORMATTED
        TT_pdf_font.font_stream " 0 obj" SKIP
        "<< /Length " (TT_pdf_font.font_stream + 1) " 0 R /Length1 " (TT_pdf_font.font_stream + 1) " 0 R >>" SKIP 
        "stream" SKIP.

    /* Get PDF Stream Start Offset */
    L_start = SEEK(S_pdf_inc).
  
    /*** igc - Nov 4, 2002 - removed. Now Uses OS-APPEND
    INPUT STREAM S_pdf_inp FROM VALUE(TT_pdf_font.font_file) BINARY NO-MAP NO-CONVERT UNBUFFERED.
      REPEAT:
        IMPORT STREAM S_pdf_inp UNFORMATTED L_data.
        PUT STREAM S_pdf_inc CONTROL L_data.
      END.
    INPUT STREAM S_pdf_inp CLOSE.
    ****/
    
    OUTPUT STREAM S_pdf_inc CLOSE.
    OS-APPEND VALUE(FILE-INFO:FILE-NAME) VALUE(TT_pdf_stream.obj_file ).
    OUTPUT STREAM S_pdf_inc TO VALUE( TT_pdf_stream.obj_file ) UNBUFFERED APPEND.

    /* Get PDF Stream End Offset */
    L_end = SEEK(S_pdf_inc).

    PUT STREAM S_pdf_inc UNFORMATTED
        SKIP(1) "endstream" SKIP
        "endobj" SKIP.

    /* igc - Added Sept 10, 2002 */
    ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "FontLength").
    TT_pdf_font.font_len = pdf_inc_ObjectSequence.

    /* Put out Length */
    PUT STREAM S_pdf_inc UNFORMATTED
        TT_pdf_font.font_len " 0 obj" SKIP
        "  " (L_end - L_start) SKIP
        "endobj" SKIP.

  END. /* each TTfont */
  
END. /* pdf_Load_fonts */

PROCEDURE pdf_ParseAFMFile:
  DEFINE OUTPUT PARAMETER P_afm_ItalicAngle  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_Ascender     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_Descender    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_FontBBox     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_FirstChar    AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_LastChar     AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_Widths       AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER P_afm_IsFixedPitch AS CHARACTER NO-UNDO INIT "0".
  DEFINE OUTPUT PARAMETER P_afm_flags        AS CHARACTER NO-UNDO.

  DEFINE VARIABLE L_data  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_key   AS CHARACTER NO-UNDO.
  DEFINE VARIABLE L_flag  AS CHARACTER NO-UNDO
         INIT "00000000000000000000000000100010".
  /* Bit 6 (above) is set to identify NonSymbolic Fonts -- or Fonts that use
     the Standard Latin Character Set */

  DEFINE VARIABLE L_int   AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_Loop  AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_exp   AS INTEGER NO-UNDO.

  ASSIGN P_afm_ItalicAngle  = 0
         P_afm_Descender    = ""
         P_afm_FontBBox     = ""
         P_afm_IsFixedPitch = ""
         P_afm_FirstChar    = ""
         P_afm_LastChar     = ""
         P_afm_Widths       = "".

  INPUT STREAM S_pdf_inp FROM VALUE(TT_pdf_font.font_afm) BINARY NO-CONVERT NO-MAP NO-ECHO.
    
    REPEAT:
      IMPORT STREAM S_pdf_inp UNFORMATTED L_data.
      L_Key = ENTRY(1, L_data, " ") NO-ERROR.
      IF ERROR-STATUS:ERROR THEN NEXT.
      
      CASE L_key:
        WHEN "ItalicAngle" THEN
          P_afm_ItalicAngle = INT(ENTRY( 2, L_data, " ")) NO-ERROR.
        
        WHEN "Ascender" THEN
          P_afm_Ascender = ENTRY( 2, L_data, " ") NO-ERROR.
          
        WHEN "Descender" THEN 
          P_afm_Descender = ENTRY( 2, L_data, " ") .
        
        WHEN "FontBBox" THEN
          ASSIGN P_afm_FontBBox = REPLACE(L_data,"FontBBox ","").

        WHEN "IsFixedPitch" THEN
          P_afm_IsFixedPitch = IF ENTRY(2,L_data, " ") = "True" THEN "1" ELSE "0".

        WHEN "C" THEN DO:
          IF P_afm_FirstChar = "" THEN
            P_afm_FirstChar = ENTRY(2, L_data, " ") NO-ERROR.

          ASSIGN P_afm_Widths = P_afm_widths + " "
                              + ENTRY(5, L_data, " ") NO-ERROR.
          
          P_afm_LastChar = ENTRY(2, L_data, " ") NO-ERROR.
        END.
      END CASE.
    END. /* REPEAT */

  INPUT STREAM S_pdf_inp CLOSE.

  /* Determine Font Flags */
  IF P_afm_IsFixedPitch = "0" THEN
    OVERLAY( L_Flag, 32, 1, "CHARACTER") = "1".

  DO L_loop = LENGTH(L_Flag) TO 1 BY -1 :
    IF SUBSTR(L_flag,L_loop,1) = "1" THEN
      L_int = L_int + EXP(2, L_exp).

    L_exp = L_exp + 1.
  END.

  P_afm_Flags = STRING( L_int ).
  
END. /* pdf_ParseAFMFile */

PROCEDURE pdf_load_images:

  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.

  DEFINE VARIABLE L_data  AS RAW NO-UNDO.
  DEFINE VARIABLE L_start AS INTEGER NO-UNDO.
  DEFINE VARIABLE L_end   AS INTEGER NO-UNDO.

  FOR EACH TT_pdf_image WHERE TT_pdf_image.obj_stream = pdfStream:

    FILE-INFO:FILE-NAME = TT_pdf_image.image_file.

    /* igc - Added Sept 10, 2002 */
    ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "Image").
    TT_pdf_image.image_obj = pdf_inc_ObjectSequence.

    PUT STREAM S_pdf_inc UNFORMATTED 
        TT_pdf_image.image_obj " 0 obj" SKIP
        "<<" SKIP
        "/Type /XObject" SKIP
        "/Subtype /Image" SKIP
        "/Name " TT_pdf_image.image_tag SKIP
        "/Width " TT_pdf_image.image_w SKIP
        "/Height " TT_pdf_image.image_h SKIP
        "/BitsPerComponent 8" SKIP
        "/ColorSpace /DeviceRGB" SKIP
        "/Length " (TT_pdf_image.image_obj + 1) " 0 R" SKIP
        "/Filter /DCTDecode" SKIP
        ">>" SKIP
        "stream" SKIP.

      /** igc - Nov 4, 2002 - removed now use OS-APPEND 
      /* Determine the File Size -- cannot use FILE-INFO:FILE-SIZE since that is
         V9 specific code */
      INPUT STREAM S_pdf_inp FROM VALUE(TT_pdf_image.image_file) BINARY NO-MAP NO-CONVERT UNBUFFERED.
        SEEK STREAM S_pdf_inp TO END.
        LENGTH(L_data) = IF SEEK(S_pdf_inp) > 16832 THEN 16832 ELSE SEEK(S_pdf_inp).
      INPUT STREAM S_pdf_inp CLOSE.
      ***/

      /* Get PDF Stream Start Offset */
      L_start = SEEK(S_pdf_inc).

      /** igc - Nov 4, 2002 - removed now use OS-APPEND 
      INPUT STREAM S_pdf_inp FROM VALUE(TT_pdf_image.image_file) BINARY NO-MAP NO-CONVERT UNBUFFERED.
        REPEAT:
          IMPORT STREAM S_pdf_inp UNFORMATTED L_data.
          PUT STREAM S_pdf_inc CONTROL L_data.
        END.
      INPUT STREAM S_pdf_inp CLOSE.
      **/

     OUTPUT STREAM S_pdf_inc CLOSE.
     OS-APPEND VALUE(FILE-INFO:FILE-NAME) VALUE(TT_pdf_stream.obj_file ).
     OUTPUT STREAM S_pdf_inc TO VALUE( TT_pdf_stream.obj_file ) UNBUFFERED APPEND.

      /* Get PDF Stream End Offset */
      L_end = SEEK(S_pdf_inc).

      PUT STREAM S_pdf_inc UNFORMATTED
          SKIP(1) "endstream" SKIP
          "endobj" SKIP.

      /* igc - Added Sept 10, 2002 */
      ObjectSequence(pdfStream, pdf_inc_ObjectSequence + 1, "ImageLen").
      TT_pdf_image.image_len = pdf_inc_ObjectSequence.

      PUT STREAM S_pdf_inc UNFORMATTED
          TT_pdf_image.image_len " 0 obj" SKIP
          "  " (L_end - L_start) SKIP
          "endobj" SKIP.

  END. /* each TT_pdf_image */

END. /* pdf_load_images */

PROCEDURE pdf_get_image_wh:
  DEFINE INPUT PARAMETER pdfStream  AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER Pimage     AS CHARACTER NO-UNDO.

  DEFINE VARIABLE pdf_marker    AS INTEGER NO-UNDO.

  INPUT STREAM S_pdf_inp FROM VALUE(Pimage) BINARY NO-MAP NO-CONVERT UNBUFFERED.

    IF NOT first_marker() THEN DO:
      RUN pdf_error(pdfStream,"ObjectSequence","Cannot find Stream!").
      RETURN.
    END.

    DO WHILE TRUE:
      pdf_marker = next_marker().

      CASE hex(pdf_marker):
        WHEN {&M_SOF0} OR WHEN {&M_SOF1} OR WHEN {&M_SOF2} OR WHEN {&M_SOF3}
        OR WHEN {&M_SOF5} OR WHEN {&M_SOF6} OR WHEN {&M_SOF7} OR WHEN {&M_SOF9}
        OR WHEN {&M_SOF10} OR WHEN {&M_SOF11} OR WHEN {&M_SOF13} 
        OR WHEN {&M_SOF14} OR WHEN {&M_SOF15} THEN DO:
          process_SOF().
          LEAVE.
        END.
        WHEN {&M_SOS} OR WHEN {&M_EOI} THEN
          LEAVE.
        OTHERWISE 
          skip_variable().
      END CASE.
    END. /* true loop */

  INPUT STREAM S_pdf_inp CLOSE.

END.

PROCEDURE pdf_replace_text:
  DEFINE INPUT-OUTPUT PARAMETER pdfText AS CHARACTER NO-UNDO.

  /* Replace any special characters in the data string since this
     will create a bad PDF doccument */
  pdfText = REPLACE(pdfText,"(","~\(").
  pdfText = REPLACE(pdfText,")","~\)").
  pdfText = REPLACE(pdfText,"[","~\[").
  pdfText = REPLACE(pdfText,"]","~\]").

END. /* pdf_replace_text */

PROCEDURE pdf_reset_all.
  /* clear out all streams, and reset variables as required */

  /* These are the only two variables that don't apear to be reset anywhere */
  ASSIGN pdf_inc_ContentSequence = 0
         pdf_inc_ObjectSequence  = 0.
       
  /* Clear all temp-tables */
  &IF NOT PROVERSION BEGINS "8" &THEN /* Assume progress versions 8 or above */
    EMPTY TEMP-TABLE TT_pdf_stream.
    EMPTY TEMP-TABLE TT_pdf_param.
    EMPTY TEMP-TABLE TT_pdf_error.
    EMPTY TEMP-TABLE TT_pdf_object.
    EMPTY TEMP-TABLE TT_pdf_content.
    EMPTY TEMP-TABLE TT_pdf_info.
    EMPTY TEMP-TABLE TT_pdf_image.
    EMPTY TEMP-TABLE TT_pdf_font.
  &ELSE
    FOR EACH TT_pdf_stream: 
      DELETE TT_pdf_stream .
    END.

    FOR EACH TT_pdf_param:
      DELETE TT_pdf_param.
    END.

    FOR EACH TT_pdf_error:
      DELETE TT_pdf_error.
    END.

    FOR EACH TT_pdf_object:
      DELETE TT_pdf_object.
    END.

    FOR EACH TT_pdf_content:
      DELETE TT_pdf_content.
    END.

    FOR EACH TT_pdf_info:
      DELETE TT_pdf_info.
    END.

    FOR EACH TT_pdf_image:
      DELETE TT_pdf_image.
    END.

    FOR EACH TT_pdf_font:
      DELETE TT_pdf_font.
    END.
  &ENDIF
END. /* pdf_reset_all */

PROCEDURE pdf_reset_stream .
  /* Clear out an individual stream - reset the variables */
  DEFINE INPUT PARAMETER pdfStream     AS CHARACTER NO-UNDO.  
   
  /* These are the only two variables that don't apear to be reset anywhere */
  ASSIGN pdf_inc_ContentSequence = 0
         pdf_inc_ObjectSequence  = 0.

  /* As far as I know, you gotta do a for each regardless of version */          
  FOR EACH TT_pdf_stream WHERE TT_pdf_stream.obj_stream = pdfStream:
    DELETE TT_pdf_stream .
  END.

  FOR EACH TT_pdf_param WHERE TT_pdf_param.obj_stream = pdfStream:
    DELETE TT_pdf_param.
  END.

  FOR EACH TT_pdf_error WHERE TT_pdf_error.obj_stream = pdfStream:
    DELETE TT_pdf_error.
  END.

  FOR EACH TT_pdf_object WHERE TT_pdf_object.obj_stream = pdfStream:
    DELETE TT_pdf_object.
  END.

  FOR EACH TT_pdf_content WHERE TT_pdf_content.obj_stream = pdfStream:
    DELETE TT_pdf_object.
  END.         

  FOR EACH TT_pdf_info WHERE TT_pdf_info.obj_stream = pdfStream:
    DELETE TT_pdf_info.
  END.

  FOR EACH TT_pdf_image WHERE TT_pdf_image.obj_stream = pdfStream:
    DELETE TT_pdf_image.
  END.

  FOR EACH TT_pdf_font WHERE TT_pdf_font.obj_stream = pdfStream:
    DELETE TT_pdf_font.
  END.
END. /* pdf_reset_stream */

/* end of pdf_inc.i */
