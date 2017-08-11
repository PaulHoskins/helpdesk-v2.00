
 
 DEFINE TEMP-TABLE crm 
    FIELD OP_NO AS INT
    FIELD ACCOUNTnUMBER AS CHAR
    FIELD CREATEdATE AS DATETIME.


 DEFINE DATASET ds
     FOR crm.
     
 FOR EACH op_master NO-LOCK:
        CREATE crm.
        BUFFER-COPY op_master TO crm.
 END.


 DATASET ds:WRITE-XML ("FILE","c:\temp\crm.xml",FALSE,?,?,NO,NO).
