/***************************************************************************

    Program:    lib/attrib.i    
    
    Purpose:    Library for data tags
            
                Data tags are multiply fields stored in on char field
                The data is stored as
                <Name><Break Delim><Value><Attr Delim><Name2> etc
                
                Use this library to set and read the fields
                
    History

    Job     Date        Who         What
    #642    08/11/2002  phoski      initial
    #877    18/11/2003  phoski      Windows problem

****************************************************************************/
&IF DEFINED(attrlib-library-defined) = 0 &THEN

&GLOB attrlib-library-defined yes


&SCOPE attrlibNull      FieldIsNull     /* Null field */
&SCOPE attrlibDelim     '~t'            /* Delim attributes */
&SCOPE attrlibBreak     '|'             /* Delim attribute name/value */

PROCEDURE attrlib-SetAttribute:

    DEFINE INPUT PARAMETER pc-AttrName         AS CHARACTER             NO-UNDO.
    DEFINE INPUT PARAMETER pc-AttrValue        AS CHARACTER             NO-UNDO.
    DEFINE INPUT-OUTPUT PARAMETER pc-Attribute AS CHARACTER             NO-UNDO.
    
    DEFINE VARIABLE lc-AttrName  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-AttrValue AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-string    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-Attribute AS INTEGER   NO-UNDO.
     
    IF pc-AttrValue = ?
        THEN ASSIGN pc-AttrValue = "{&attrlibNull}".
    
    IF pc-Attribute <> ?
        AND pc-Attribute <> "" THEN
    DO li-Attribute = 1 TO NUM-ENTRIES(pc-Attribute,{&attrlibDelim}):
        ASSIGN 
            lc-String = ENTRY(li-Attribute,pc-Attribute,{&attrlibDelim}).
        IF NUM-ENTRIES(lc-string,{&attrlibBreak}) <> 2
            THEN NEXT.
        ASSIGN 
            lc-AttrName  = ENTRY(1,lc-string,{&attrlibBreak})
            lc-AttrValue = ENTRY(2,lc-string,{&attrlibBreak}).
        IF lc-AttrName <> pc-AttrName THEN NEXT. 
                 
        ASSIGN 
            lc-string = lc-AttrName + {&attrlibBreak} + pc-AttrValue.
                     
                       
        ASSIGN 
            ENTRY(li-Attribute,pc-Attribute,{&attrlibDelim}) = lc-String.
        RETURN.

    END.
    IF pc-Attribute = ""
        OR pc-Attribute = ?
        THEN pc-Attribute = pc-AttrName + {&attrlibBreak} + pc-AttrValue.
    ELSE pc-attribute = pc-attribute + {&attrlibDelim} + 
            pc-AttrName + {&attrlibBreak} + pc-AttrValue.
                        
END PROCEDURE.

PROCEDURE attrlib-GetAttribute:
    DEFINE INPUT PARAMETER pc-AttrName         AS CHARACTER             NO-UNDO.
    DEFINE INPUT PARAMETER pc-Attribute        AS CHARACTER             NO-UNDO.
    DEFINE OUTPUT PARAMETER pc-AttrValue       AS CHARACTER             NO-UNDO.
    
    DEFINE VARIABLE lc-AttrName  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-AttrValue AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-string    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE li-Attribute AS INTEGER   NO-UNDO.
     
    IF pc-Attribute <> ?
        AND pc-Attribute <> "" THEN
    DO li-Attribute = 1 TO NUM-ENTRIES(pc-Attribute,{&attrlibDelim}):
        ASSIGN 
            lc-String = ENTRY(li-Attribute,pc-Attribute,{&attrlibDelim}).
        IF NUM-ENTRIES(lc-string,{&attrlibBreak}) <> 2
            THEN NEXT.
        ASSIGN 
            lc-AttrName  = ENTRY(1,lc-string,{&attrlibBreak})
            lc-AttrValue = ENTRY(2,lc-string,{&attrlibBreak}).
        IF lc-AttrName <> pc-AttrName THEN NEXT. 
        
        IF lc-AttrValue = "{&attrlibNull}"
            THEN lc-attrValue = ?.

        ASSIGN 
            pc-AttrValue = TRIM(lc-AttrValue).
        
    END.


END PROCEDURE.

&ENDIF

