
/***********************************************************************

    Program:        batch/sessionclean.p
    
    Purpose:        Delete old session logs
    
    Notes:
    
    
    When        Who         What
    21/03/2015  phoski      Initial

***********************************************************************/


DEFINE VARIABLE ld-Date AS DATE    NO-UNDO.

DEFINE VARIABLE li-Del  AS INTEGER EXTENT 3 NO-UNDO.

ASSIGN
    ld-date = TODAY - 1.
OUTPUT TO c:\temp\sesssionclean.log.   
    
FOR EACH webUser NO-LOCK:

    FOR EACH websalt EXCLUSIVE-LOCK
        WHERE websalt.LoginID = WebUser.LoginID
        AND websalt.sdate <= ld-date:
            
        ASSIGN
            li-del[1] = li-del[1] + 1.
        DELETE websalt.
       
    END.
            
    
END.  
FOR EACH webSession EXCLUSIVE-LOCK
    WHERE webSession.wsdate <= ld-date:
            
    ASSIGN
        li-del[2] = li-del[2] + 1.
    DELETE WebSession.   
END.
ASSIGN
    li-del[3] = li-del[1] + li-del[2].
    
DO WITH FRAME f DOWN STREAM-IO:
    DISPLAY ld-date COLUMN-LABEL 'Clear Date'
        li-del[1] COLUMN-LABEL 'Salt'
        li-del[2] COLUMN-LABEL 'Session'    
        li-del[3] COLUMN-LABEL 'Total'.
    DOWN.        
END.

  
OUTPUT CLOSE.
    