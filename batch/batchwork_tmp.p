/*
  BatchWork run program - session parameter is batch id number.
  
  04/01/2011  DJS   First cut
  
*/

def var vx as int no-undo.
DEF VAR cid AS CHAR NO-UNDO.
cid = "185".

find LAST BatchWork where BatchID = integer(cid) 
    no-error.
cid = STRING(batchid).


do vx = 20 to 1 by -1:
  if BatchParams[vx] <> "" then leave.
end.
DISP batchwork.Batchprog vx.
PAUSE.

 

 if vx = 1 then 
    run value(BatchProg) (cid,
                          BatchParams[1]).

 if vx = 2 then 
    run value(BatchProg) (cid,
                          BatchParams[1])
                          BatchParams[2]).

 if vx = 3 then 
    run value(BatchProg) (cid,
                          BatchParams[1])
                          BatchParams[2],
                          BatchParams[3]).

 if vx = 4 then 
    run value(BatchProg) (cid,
                          BatchParams[1])
                          BatchParams[2],
                          BatchParams[3],
                          BatchParams[4]).

 if vx = 5 then 
    run value(BatchProg) (cid,
                          BatchParams[1])],
                          BatchParams[2],
                          BatchParams[3],
                          BatchParams[4],
                          BatchParams[5]).

 if vx = 6 then 
    run value(BatchProg) (cid,
                          BatchParams[1])
                          BatchParams[2],
                          BatchParams[3],
                          BatchParams[4],
                          BatchParams[5],
                          BatchParams[6]).

 if vx = 7 then 
    run value(BatchProg) (cid,
                          BatchParams[1])
                          BatchParams[2],
                          BatchParams[3],
                          BatchParams[4],
                          BatchParams[5],
                          BatchParams[6],
                          BatchParams[7]).
 if vx = 8 then 
    run value(BatchProg) (cid,
                          BatchParams[1],
                          BatchParams[2],
                          BatchParams[3],
                          BatchParams[4],
                          BatchParams[5],
                          BatchParams[6],
                          BatchParams[7],
                          BatchParams[8]).

 if vx = 9 then 
    run value(BatchProg) (cid,
                          BatchParams[1])
                          BatchParams[2],
                          BatchParams[3],
                          BatchParams[4],
                          BatchParams[5],
                          BatchParams[6],
                          BatchParams[7],
                          BatchParams[8],
                          BatchParams[9]).
 if vx = 10 then 
    run value(BatchProg) (cid,
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
 if vx = 11 then 
    run value(BatchProg) (cid,
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

 if vx = 12 then 
    run value(BatchProg) (cid,
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

 if vx = 13 then 
    run value(BatchProg) (cid,
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
 
 if vx = 14 then 
    run value(BatchProg) (cid,
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
 
 if vx = 15 then 
    run value(BatchProg) (cid,
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





quit.
