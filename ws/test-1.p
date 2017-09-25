DEFINE VARIABLE hWebService AS HANDLE NO-UNDO.
DEFINE VARIABLE hhelpdeskObj AS HANDLE NO-UNDO.


CREATE SERVER hWebService.


hWebService:CONNECT("-WSDL 'http://localhost:8080/wsa/wsa1/wsdl?targetURI=urn:tempuri-org'").

RUN helpdeskObj SET hhelpdeskObj ON hWebService.

DEFINE VARIABLE pcLoginId AS CHARACTER NO-UNDO.
DEFINE VARIABLE pcPasswd AS CHARACTER NO-UNDO.
DEFINE VARIABLE result AS CHARACTER NO-UNDO.
DEFINE VARIABLE plOk AS LOGICAL NO-UNDO.
DEFINE VARIABLE pcToken AS CHARACTER NO-UNDO.


RUN login IN hhelpdeskObj(INPUT pcLoginId, INPUT pcPasswd, OUTPUT result, OUTPUT plOk, OUTPUT pcToken).


DISP plok pcToken.

/*
wsdl /language:VB /out:HelpDeskProxyClass.vb http://localhost:8080/wsa/wsa1/wsdl?targetURI=urn:tempuri-org
*/

