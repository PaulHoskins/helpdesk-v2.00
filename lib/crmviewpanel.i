/***********************************************************************

    Program:        lib/crmviewpanel.i
    
    Purpose:        Bottom panel on CRM opportunity  
    
    Notes:
    
    
    When        Who         What
    21/10/2016  phoski      Initial 
    
***********************************************************************/



{&out} htmlib-StartPanel() 
        skip.

    
{&out}  '<tr><td align="left">'.
        

IF lr-first-row <> ? THEN
DO:
    vhLQuery:get-first(NO-LOCK).
    IF ROWID(b-query) = lr-first-row 
        THEN ASSIGN ll-prev = FALSE.
    ELSE ASSIGN ll-prev = TRUE.

    vhLQuery:get-last(NO-LOCK).
    IF ROWID(b-query) = lr-last-row
        THEN ASSIGN ll-next = FALSE.
    ELSE ASSIGN ll-next = TRUE.

    IF ll-prev 
        THEN {&out}
    REPLACE(htmlib-MntButton(appurl + '/' + "{1}","FirstPage","Prev Page")
        ,"MntButtonPress","crmButton") 
    REPLACE(htmlib-MntButton(appurl + '/' + "{1}","PrevPage","Prev Page"),
        "MntButtonPress","crmButton")
        .

  
    IF ll-next 
        THEN {&out} REPLACE(htmlib-MntButton(appurl + '/' + "{1}","NextPage","Next Page"),
        "MntButtonPress","crmButton")
        
    REPLACE(htmlib-MntButton(appurl + '/' + "{1}","LastPage","Last Page"),
        "MntButtonPress","crmButton")
        .

    IF NOT ll-prev
        AND NOT ll-next 
        THEN {&out} "&nbsp;".


END.
ELSE {&out} "&nbsp;".

{&out} '</td><td align="right">' htmlib-ErrorMessage(lc-smessage)
'</td></tr>'.

{&out} htmlib-EndPanel().



