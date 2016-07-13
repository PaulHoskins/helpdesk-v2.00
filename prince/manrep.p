/***********************************************************************

    Program:        prince/manrep.p
    
    Purpose:        Management PDF Report     
    
    Notes:
    
    
    When        Who         What
    10/07/2006  phoski      Initial
***********************************************************************/
                                          
{lib/htmlib.i}
{lib/princexml.i}
{rep/manreptt.i}

&IF DEFINED(UIB_is_Running) EQ 0 &THEN

DEFINE INPUT PARAMETER pc-user             AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-CompanyCode      AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pd-date             AS DATE NO-UNDO.
DEFINE INPUT PARAMETER pi-days             AS INTEGER  NO-UNDO.
DEFINE INPUT PARAMETER table FOR tt-mrep.
DEFINE OUTPUT PARAMETER pc-pdf            AS CHARACTER NO-UNDO.

&ELSE

DEFINE VARIABLE pc-user                    AS CHARACTER NO-UNDO.
DEFINE VARIABLE pc-CompanyCode             AS CHARACTER NO-UNDO.
DEFINE VARIABLE pd-date                    AS DATE NO-UNDO.
DEFINE VARIABLE pi-days                    AS INTEGER  NO-UNDO.
DEFINE VARIABLE pc-pdf                     AS CHARACTER NO-UNDO.

ASSIGN 
    pc-CompanyCode = "MICAR"
    pd-date        = TODAY
    pi-days        = 150.
RUN rep/manrepbuild.p 
    ( pc-companyCode,
    pd-date,
    pi-days,
    OUTPUT table tt-mrep ).

&ENDIF



DEFINE VARIABLE lc-html         AS CHARACTER     NO-UNDO.
DEFINE VARIABLE lc-pdf          AS CHARACTER     NO-UNDO.
DEFINE VARIABLE ll-ok           AS LOG      NO-UNDO.
DEFINE VARIABLE li-ReportNumber AS INTEGER      NO-UNDO.




ASSIGN
    pc-pdf = ?
    li-ReportNumber = NEXT-VALUE(ReportNumber).
ASSIGN 
    lc-html = SESSION:TEMP-DIR + caps(pc-CompanyCode) + "-ManagementReport-" + string(li-ReportNumber).

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

&IF DEFINED(EXCLUDE-ip-Print) = 0 &THEN

PROCEDURE ip-Print :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lf-bfwd         LIKE tt-mrep.bfwd       NO-UNDO.
    DEFINE VARIABLE lf-openper      LIKE tt-mrep.openper    NO-UNDO.
    DEFINE VARIABLE lf-closeper     LIKE tt-mrep.closeper   NO-UNDO.
    DEFINE VARIABLE lf-outst        LIKE tt-mrep.outst      NO-UNDO.
    DEFINE VARIABLE lf-duration     LIKE tt-mrep.duration   NO-UNDO.

    DEFINE VARIABLE li-other        AS INTEGER                  NO-UNDO.
    DEFINE VARIABLE lc-other-code   AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE lc-other-desc   AS CHARACTER                 NO-UNDO.
    DEFINE VARIABLE li-other-total  AS INTEGER EXTENT 10        NO-UNDO.
    DEFINE VARIABLE li-temp         AS INTEGER                  NO-UNDO.

    DEFINE BUFFER b-rep        FOR tt-mrep.
    

    FOR EACH WebIssCat
        WHERE WebIssCat.CompanyCode = pc-companyCode
        BY WebIssCat.description:

        IF WebIssCat.CatCode = "Support" THEN NEXT.

        IF lc-other-code = ""
            THEN ASSIGN lc-other-code = WebIssCat.CatCode
                lc-other-desc = WebIssCat.description.
        ELSE ASSIGN lc-other-code = lc-other-code + "|" + WebIssCat.CatCode
                lc-other-desc = lc-other-desc + "|" + WebIssCat.description.
    END.

    {&prince}
    '<p style="text-align: center; font-size: 14px; font-weight: 900;">Management Report - '
    'From ' STRING(pd-date - pi-days,"99/99/9999")
    ' To ' STRING(pd-date,"99/99/9999") 
    ' - Days ' pi-days ' Days'
    '</div>'.

    {&prince}
    '<table class="landrep">'
    '<thead>'
    '<tr>'
    '<th colspan=2>&nbsp;</th>'
    '<th colspan=5 style="text-align: center; border-bottom: 1px solid black;">Support</th>' skip.

    DO li-other = 1 TO NUM-ENTRIES(lc-other-code,"|"):
        {&prince}
        '<th>&nbsp;</th>'.
    END.
    {&prince}
    '</tr>'
    '<tr>'
    '<th>Account</th>'
    '<th>Name</th>'
    '<th style="text-align: right;">Brought Forward</th>'
    '<th style="text-align: right;">Opened This Period</th>'
    '<th style="text-align: right;">Closed This Period</th>'
    '<th style="text-align: right;">Carried Forward</th>'
    '<th style="text-align: right;">Time Spent<br>(Hours:Mins)</th>'.
    DO li-other = 1 TO NUM-ENTRIES(lc-other-code,"|"):
        {&prince}
        '<th style="text-align: right;">' pxml-safe(ENTRY(li-other,lc-other-desc,'|')) '<br>' pxml-safe("C/Forward") '</th>'.
    END.
    {&prince}
    '</tr>'
    '</thead>'
        skip.



    FOR EACH tt-mrep NO-LOCK
        WHERE tt-mrep.CatCode <> "SUPPORT":
        FIND b-rep 
            WHERE b-rep.AccountNumber = tt-mrep.AccountNumber
            AND b-rep.CatCode = "SUPPORT"
            NO-LOCK NO-ERROR.
        IF AVAILABLE b-rep THEN NEXT.
        CREATE b-rep.
        ASSIGN 
            b-rep.CatCode = "SUPPORT"
            b-rep.AccountNumber = tt-mrep.AccountNumber.

    END.
    FOR EACH tt-mrep NO-LOCK
        WHERE tt-mrep.CatCode = "SUPPORT":

        FIND customer WHERE customer.companycode    = pc-companycode
            AND customer.AccountNumber  = tt-mrep.AccountNumber NO-LOCK NO-ERROR.

        {&prince} 
        '<tr>'
        '<td>' tt-mrep.AccountNumber '</td>'
        '<td>' pxml-safe(IF AVAILABLE customer THEN customer.name ELSE "") '</td>'
        '<td style="text-align: right;">' tt-mrep.Bfwd '</td>'
        '<td style="text-align: right;">' tt-mrep.OpenPer '</td>'
        '<td style="text-align: right;">' tt-mrep.ClosePer '</td>'
        '<td style="text-align: right;">' tt-mrep.OutSt '</td>'
        '<td style="text-align: right;">' com-TimeToString(tt-mrep.Duration) '</td>'
                
            .

        DO li-other = 1 TO NUM-ENTRIES(lc-other-code,"|"):
            ASSIGN
                li-temp = 0.
            
            FIND b-rep WHERE b-rep.AccountNumber = tt-mrep.AccountNumber
                AND b-rep.CatCode       = entry(li-other,lc-other-Code,'|')
                NO-LOCK NO-ERROR.
            IF AVAILABLE b-rep
                THEN ASSIGN li-temp = b-rep.OutSt.

            {&prince}
            '<td style="text-align: right;">' li-temp '</td>'.

            ASSIGN
                li-other-total[li-other] = li-other-total[li-other] + li-temp.
        END.
        {&prince} 
        '</tr>'.

        ASSIGN
            lf-bfwd         = lf-bfwd + tt-mrep.bfwd
            lf-openper      = lf-openper + tt-mrep.openper
            lf-closeper     = lf-closeper + tt-mrep.closeper
            lf-outst        = lf-outst + tt-mrep.outst
            lf-duration     = lf-duration + tt-mrep.duration.

    END.
    
    

    {&prince}
    '<tfoot>'
    '<tr>'
    '<th colspan="2" style="background-color: none; border-top: 1px solid black;">Total</th>'
    '<th style="text-align: right; border-top: 1px solid black;">' lf-Bfwd '</th>'
    '<th style="text-align: right; border-top: 1px solid black;">' lf-OpenPer '</th>'
    '<th style="text-align: right; border-top: 1px solid black;">' lf-ClosePer '</th>'
    '<th style="text-align: right; border-top: 1px solid black;">' lf-OutSt '</th>'
    '<th style="text-align: right; border-top: 1px solid black;">' com-TimeToString(lf-Duration) '</th>'.
    DO li-other = 1 TO NUM-ENTRIES(lc-other-code,"|"):
        {&prince}
        '<th style="text-align: right; border-top: 1px solid black;">' li-other-total[li-other] '</th>'.
    END.
    {&prince}
    '</tr>'
    '</tfoot>' skip.

    {&prince} 
    '</table>'.

END PROCEDURE.


&ENDIF

