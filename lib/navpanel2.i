/***********************************************************************

    Program:        lib/navpanel.i
    
    Purpose:        Bottom panel on maintenance pages     
    
    Notes:
    
    
    When        Who         What
    27/04/2006  phoski      Initial    
***********************************************************************/


{&out} htmlib-StartPanel() 
        skip.

    
{&out}  '<tr><td align="left">'.
        

IF lr-first-row <> ? THEN
DO:
    GET FIRST q NO-LOCK.
    IF ROWID(b-query) = lr-first-row 
        THEN ASSIGN ll-prev = FALSE.
    ELSE ASSIGN ll-prev = TRUE.

    GET LAST q NO-LOCK.
    IF ROWID(b-query) = lr-last-row
        THEN ASSIGN ll-next = FALSE.
    ELSE ASSIGN ll-next = TRUE.

    IF ll-prev 
        THEN {&out}
    htmlib-MntButton(appurl + '/' + "{1}","FirstPage","First Page")
    htmlib-MntButton(appurl + '/' + "{1}","PrevPage","Prev Page").

  
    IF ll-next 
        THEN {&out} 
    htmlib-MntButton(appurl + '/' + "{1}","NextPage","Next Page")
    htmlib-MntButton(appurl + '/' + "{1}","LastPage","Last Page").

    IF NOT ll-prev
        AND NOT ll-next 
        THEN {&out} "&nbsp;".


END.
ELSE {&out} "&nbsp;".

{&out} '</td><td align="right">' htmlib-ErrorMessage(lc-smessage)
'</td></tr>'.

{&out} htmlib-EndPanel().



