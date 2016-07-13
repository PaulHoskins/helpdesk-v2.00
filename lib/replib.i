/***********************************************************************

    Program:        lib/replib.i
    
    Purpose:        Standard HTML for reports
    
    Notes:
    
    
    When        Who         What
    22/11/2014  phoski      Initial                    
    
***********************************************************************/

FUNCTION replib-RepField RETURNS CHARACTER 
    (pc-data AS CHARACTER,
     pc-align AS CHARACTER,
     pc-style AS CHARACTER) FORWARD.

FUNCTION replib-TableHeading RETURNS CHARACTER 
    (pc-param AS CHARACTER) FORWARD.


/* ************************  Function Implementations ***************** */

FUNCTION replib-RepField RETURNS CHARACTER 
    ( pc-data AS CHARACTER,
      pc-align AS CHARACTER,
      pc-style AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    IF pc-data = ""
    THEN pc-data = "&nbsp;".
    ASSIGN 
        lc-return = '<td class="tablefield" valign="top"'.

    IF pc-align = "" 
    THEN pc-align = "left".
    lc-return = lc-return + ' align="' + pc-align + '"'.
    IF pc-style = ''
    THEN pc-style = "padding-left:5px;padding-right:5px;".
    ELSE pc-style = pc-style + ";padding-left:5px;padding-right:5px;".
    
    
    IF pc-style <> ''
    THEN lc-return = lc-return + 'style="' + pc-style + '"'.
    
    lc-return = lc-return + '>'.

    ASSIGN 
        lc-return = lc-return + pc-data + '</td>'.

    RETURN lc-return.

		
END FUNCTION.

FUNCTION replib-TableHeading RETURNS CHARACTER 
    ( pc-param AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-loop    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE lc-entry   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-return  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-label   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-align   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-colspan AS CHARACTER NO-UNDO.


    ASSIGN 
        lc-return = '<tr>'.


    DO li-loop = 1 TO NUM-ENTRIES(pc-param,'|'):
        ASSIGN 
            lc-entry = ENTRY(li-loop,pc-param,'|').

        ASSIGN 
            lc-label = ENTRY(1,lc-entry,'^')
            lc-align = ''.
        IF NUM-ENTRIES(lc-entry,'^') > 1 
            THEN ASSIGN lc-align = ' style=" text-align: ' + entry(2,lc-entry,'^') + '"'.

        /*
        IF li-loop = num-entries(pc-param,'|')
            THEN ASSIGN lc-colspan = " colspan='8'".
        ELSE ASSIGN lc-colspan = "".
        */
        ASSIGN 
            lc-return = lc-return + '<th valign="bottom" ' + lc-align + lc-colspan + '>' + lc-label + '</th>'.


    END.

    ASSIGN 
        lc-return = lc-return + '</tr>'.

    RETURN lc-return.

		
END FUNCTION.
