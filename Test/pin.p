FUNCTION com-CreetePin RETURNS CHARACTER 
    ( pi-len AS INTEGER):


    DEFINE VARIABLE li-loop AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-bit  AS INTEGER  NO-UNDO.


    DEFINE VARIABLE MyUUID      AS RAW       NO-UNDO.
    DEFINE VARIABLE cGUID       AS CHARACTER NO-UNDO.
    

                
    ASSIGN  
        MyUUID = GENERATE-UUID  
        cGUID  = GUID(MyUUID). 


    cGuid = REPLACE(cguid,"-","").
    ASSIGN
        li-bit = ASC("A").
   
    DO li-loop = 0 TO 25:
        cGuid = REPLACE(cguid,CHR( li-bit + li-loop),"").
    END.
    cGuid = REPLACE(cguid,"0","").
    IF LENGTH (cGuid) > pi-len THEN
    DO:
        cGuid = SUBSTR(cguid, LENGTH(cguid) - ( pi-len + 1),pi-len).
    END.
    RETURN cGuID.

END FUNCTION.


DEFINE VARIABLE i AS INTEGER NO-UNDO.

DO  i = 1 TO 40 WITH DOWN:

    DISPLAY com-CreetePin(4) FORMAT 'x(40)'.
    DOWN.
END.
