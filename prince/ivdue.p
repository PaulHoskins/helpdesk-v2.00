/***********************************************************************

    Program:        prince/ivdue.p
    
    Purpose:        Customer Inventory - Prince Report
    
    Notes:
    
    
    When        Who         What
    10/07/2006  phoski      Initial
***********************************************************************/
                                          
{lib/htmlib.i}
{lib/princexml.i}


&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-user             AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pd-lodate           AS DATE NO-UNDO.
DEFINE INPUT PARAMETER pd-hidate           AS DATE  NO-UNDO.
DEFINE OUTPUT PARAMETER pc-pdf             AS CHARACTER NO-UNDO.

&ELSE

DEFINE VARIABLE pc-user                    AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-CompanyCode             AS CHARACTER NO-UNDO.
DEFINE VARIABLE pd-lodate                    AS DATE NO-UNDO.
DEFINE VARIABLE pd-hidate                    AS DATE  NO-UNDO.
DEFINE VARIABLE pc-pdf                     AS CHARACTER NO-UNDO.

ASSIGN 
    pc-CompanyCode = "MICAR"
    pd-lodate        = TODAY - 100
    pd-hidate        = TODAY + 100.


&ENDIF



DEFINE VARIABLE lc-html         AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
DEFINE VARIABLE ll-ok           AS LOG      NO-UNDO.
DEFINE VARIABLE li-ReportNumber AS INTEGER      NO-UNDO.


{prince/ivdue.i}




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


ASSIGN
    pc-pdf = ?
    li-ReportNumber = NEXT-VALUE(ReportNumber).
ASSIGN 
    lc-html = SESSION:TEMP-DIR + caps(pc-CompanyCode) + "-ivDue-" + string(li-ReportNumber).

ASSIGN 
    lc-pdf = lc-html + ".pdf"
    lc-html = lc-html + ".html".

OS-DELETE value(lc-pdf) no-error.
OS-DELETE value(lc-html) no-error.


DYNAMIC-FUNCTION("pxml-Initialise").

CREATE tt-pxml.
ASSIGN 
    tt-pxml.PageOrientation = "LANDSCAPE".

DYNAMIC-FUNCTION("pxml-OpenStream",lc-html).
DYNAMIC-FUNCTION("pxml-Header", pc-CompanyCode).

RUN ip-BuildTT.
RUN ip-Print.

DYNAMIC-FUNCTION("pxml-Footer",pc-CompanyCode).
DYNAMIC-FUNCTION("pxml-CloseStream").


ll-ok = DYNAMIC-FUNCTION("pxml-Convert",lc-html,lc-pdf).

IF ll-ok
    THEN ASSIGN pc-pdf = lc-pdf.
    
&IF DEFINED(UIB_is_Running) ne 0 &THEN

OS-COMMAND SILENT START VALUE(lc-pdf).
&ENDIF



/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-ip-BuildTT) = 0 &THEN

PROCEDURE ip-BuildTT :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE ld-date     AS DATE         NO-UNDO.

    FOR EACH ivField NO-LOCK
        WHERE ivField.dType = "date"
        AND ivField.dWarning > 0,
        FIRST ivSub OF ivField NO-LOCK:

        IF ivSub.Company <> pc-CompanyCode THEN NEXT.

        
        FOR EACH CustField NO-LOCK
            WHERE CustField.ivFieldID = ivField.ivFieldID:

            
            IF custField.FieldData = "" 
                OR custField.FieldData = ? THEN NEXT.

            ASSIGN
                ld-date = DATE(custfield.FieldData) no-error.
            IF ERROR-STATUS:ERROR 
                OR ld-date = ? THEN NEXT.

            
            IF ld-date < pd-lodate
                OR ld-date > pd-hidate THEN NEXT.
            

            FIND CustIV 
                WHERE custIV.custIvID = custField.custIvID NO-LOCK NO-ERROR.
            IF NOT AVAILABLE custIV THEN NEXT.
           
            FIND customer 
                WHERE customer.CompanyCode = pc-CompanyCode
                AND customer.AccountNumber = custIv.AccountNumber NO-LOCK NO-ERROR.
            IF NOT AVAILABLE customer THEN NEXT.

            CREATE tt.
            ASSIGN
                tt.CustFieldRow     = ROWID(CustField)
                tt.ivFieldRow       = ROWID(ivField)
                tt.ivDate           = ld-date
                tt.AccountNumber    = customer.AccountNumber
                tt.name             = customer.name
                tt.Ref              = custiv.Ref
                tt.dLabel           = ivField.dLabel
                .


        END.

       
            
    END.

END PROCEDURE.


&ENDIF

&IF DEFINED(EXCLUDE-ip-Print) = 0 &THEN

PROCEDURE ip-Print :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

  
    {&prince}
    '<p style="text-align: center; font-size: 14px; font-weight: 900;">Customer Inventory Due Report - '
    'From ' STRING(pd-lodate,"99/99/9999")
    ' To ' STRING(pd-hidate,"99/99/9999") 
      
    '</div>'.


    {&prince}
    '<table class="landrep">'
    '<thead>'
    '<tr>'
    '<th>Account</th>'
    '<th>Name</th>'
    '<th>Reference</th>'
    '<th>Field</th>'
    '<th>Renewal</th>'
                
    '</tr>'
    '</thead>'
        skip.


    FOR EACH tt NO-LOCK:

        {&prince} 
        '<tr>'
        '<td>' pxml-safe(tt.AccountNumber) '</td>'
        '<td>' pxml-safe(tt.name) '</td>'
        '<td>' pxml-safe(tt.Ref)  '</td>'
        '<td>' pxml-safe(tt.dLabel)  '</td>'
        '<td>' STRING(tt.ivDate,"99/99/9999") '</td>'
        '</tr>' skip
        .

    END.

    {&prince} 
    '</table>'.


END PROCEDURE.


&ENDIF

