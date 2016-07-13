/*
  BatchWork run program - session parameter is batch id number.
  
  04/01/2011  DJS   First cut
  
*/

DEFINE VARIABLE vx AS INTEGER NO-UNDO.

FIND FIRST BatchWork WHERE BatchID = integer(SESSION:PARAMETER) NO-ERROR.

DO vx = 20 TO 1 BY -1:
    IF BatchParams[vx] <> "" THEN LEAVE.
END.
 

IF vx = 1 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1]).

IF vx = 2 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2]).

IF vx = 3 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3]).

IF vx = 4 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4]).

IF vx = 5 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])],
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5]).

IF vx = 6 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6]).

IF vx = 7 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7]).
IF vx = 8 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1],
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8]).

IF vx = 9 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9]).
IF vx = 10 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9],
        BatchParams[10]).
IF vx = 11 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9],
        BatchParams[10],
        BatchParams[11]).

IF vx = 12 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9],
        BatchParams[10],
        BatchParams[11],
        BatchParams[12]).

IF vx = 13 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9],
        BatchParams[10],
        BatchParams[11],
        BatchParams[12],
        BatchParams[13]).  
 
IF vx = 14 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9],
        BatchParams[10],
        BatchParams[11],
        BatchParams[12],
        BatchParams[13],
        BatchParams[14]).  
 
IF vx = 15 THEN 
    RUN value(BatchProg) (SESSION:PARAMETER,
        BatchParams[1])
        BatchParams[2],
        BatchParams[3],
        BatchParams[4],
        BatchParams[5],
        BatchParams[6],
        BatchParams[7],
        BatchParams[8],
        BatchParams[9],
        BatchParams[10],
        BatchParams[11],
        BatchParams[12],
        BatchParams[13],
        BatchParams[14],
        BatchParams[15]).  





QUIT.
