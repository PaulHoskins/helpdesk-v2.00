/***********************************************************************

    Program:        lib/holidayservice.p
    
    Purpose:        Holiday Service load
    
    Notes:
    
    
    When        Who         What
    24/11/2014  phoski      Initial
***********************************************************************/
DEFINE VARIABLE hWebService                   AS HANDLE      NO-UNDO.
DEFINE VARIABLE hHolidayService2Soap          AS HANDLE      NO-UNDO.
DEFINE VARIABLE gCountryCode                  AS CHARACTER   INITIAL "GreatBritain" NO-UNDO.
DEFINE VARIABLE gStartDate                    AS DATETIME-TZ NO-UNDO.
DEFINE VARIABLE gEndDate                      AS DATETIME-TZ NO-UNDO.
DEFINE VARIABLE GetHolidaysForDateRangeResult AS LONGCHAR    NO-UNDO.
DEFINE VARIABLE hTT                           AS HANDLE      NO-UNDO.
DEFINE VARIABLE lok                           AS LOG         NO-UNDO.
DEFINE VARIABLE cMessageList                  AS CHAR        NO-UNDO.

/*
***
*** Exact name map only!!
***
*/ 
DEF TEMP-TABLE ttHoliday NO-UNDO
    NAMESPACE-URI "http://www.holidaywebservice.com/HolidayService_v2/" 
    XML-NODE-NAME "holiday"
    FIELD Country            AS CHAR FORMAT 'x(10)'
    FIELD HolidayCode        AS CHAR FORMAT 'x(20)'
    FIELD Descriptor         AS CHAR FORMAT 'x(20)'
    FIELD DateType           AS CHAR FORMAT 'x(20)'
    FIELD BankHoliday        AS CHAR FORMAT 'x(20)'
    FIELD Date               AS CHAR FORMAT 'x(20)'
    FIELD RelatedHolidayCode AS CHAR FORMAT 'x(20)'
    FIELD rDate              AS DATE.
  


CREATE SERVER hWebService.

hWebService:CONNECT("-WSDL 'http://www.holidaywebservice.com/HolidayService_v2/HolidayService2.asmx?WSDL'") NO-ERROR.

IF ERROR-STATUS:ERROR THEN
DO:
    RETURN ERROR-STATUS:GET-MESSAGE(1).
END.
IF hWebService:CONNECTED() = FALSE  THEN
DO:
    RETURN "Unable to connect to web service at http://www.holidaywebservice.com/HolidayService_v2/HolidayService2.asmx".

END.

RUN HolidayService2Soap SET hHolidayService2Soap ON hWebService.



ASSIGN
    gStartDate = DATETIME-TZ( TODAY - 365 ).
gEndDate =   DATETIME-TZ( TODAY + ( 365 * 2 ) ).


RUN GetHolidaysForDateRange IN hHolidayService2Soap(INPUT gCountryCode, INPUT gStartDate, INPUT gEndDate, OUTPUT GetHolidaysForDateRangeResult).

htt = TEMP-TABLE ttHoliday:HANDLE.
                  
lok = htt:READ-XML('Longchar',GetHolidaysForDateRangeResult,'empty','',NO).

FOR EACH ttHoliday :
    ttHoliday.rdate = DATE(
        INT(SUBSTR(DATE,6,2)),
        INT(SUBSTR(DATE,9,2)),
        INT(SUBSTR(DATE,1,4))
        ) NO-ERROR.
END.


FOR EACH Company NO-LOCK:
    FOR EACH ttHoliday NO-LOCK WHERE ttHoliday.bankholiday = "Recognized":

        IF CAN-FIND(holiday WHERE holiday.companyCode = Company.CompanyCode
            AND holiday.hDate = ttHoliday.rdate NO-LOCK) THEN NEXT.

        CREATE holiday.
        ASSIGN 
            holiday.companyCode = Company.CompanyCode
            holiday.hDate       = ttHoliday.rdate
            holiday.descr       = ttHoliday.Descriptor
            holiday.observed    = TRUE.

    END.
END.

hWebService:DISCONNECT() NO-ERROR.

RETURN.
