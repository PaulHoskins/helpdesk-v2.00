/***********************************************************************

    Program:       lib/gantt-build-js.i
    
    Purpose:       Create js variable
    
    Notes:
    
    
    When        Who         What
    16/04/2015  phoski      Initial
    

***********************************************************************/
 
/*
***
*** All this does is create a javascript var called tasks, this gets eval'ed in the issue/custom.js ganttBuild function
***
*/
{&out} 
'var tasks = ~{' SKIP
        '   data:[' SKIP.
       
FOR EACH tt-proj-tasks NO-LOCK:
    ASSIGN
        li-this = li-this + 1.
        
    ASSIGN
        lc-string = REPLACE(STRING(tt-proj-tasks.startDate,"99/99/9999"),"/","-").
    {&out}
    '   ~{id:' tt-proj-tasks.id ', text:"' tt-proj-tasks.txt '", start_date:"' lc-string '", duration:' tt-proj-tasks.duration
    ', datatype:"'  tt-proj-tasks.dataType '"'
    ', users:"'  tt-proj-tasks.EngName '"'
    ', engcode:"'  tt-proj-tasks.EngCode '"'
    ', crow:"'  tt-proj-tasks.cRow '"'
    ', cduration:"'  tt-proj-tasks.cDuration '"'
    ', progress:' STRING(tt-proj-tasks.prog) ', open: true'.
        
    IF tt-proj-tasks.parentID = 0
        THEN {&out} '~}'.
        else {&out} ', parent:' tt-proj-tasks.parentID '~}'.
        
    IF li-this = li-count[1]
        THEN {&out} SKIP.
        ELSE {&out} ',' SKIP. /* end of rec */
     
        
        
END.    
      
{&out} skip
        '],' SKIP /*end of data */
        '   links:[' SKIP.
ASSIGN
    li-this = 0.
FOR EACH tt-proj-tasks NO-LOCK
    WHERE tt-proj-tasks.parentid > 0 
    BY tt-proj-tasks.rno:
    ASSIGN
        li-this = li-this + 1.
        
    {&out}
    '~{id:' li-this ', source:' tt-proj-tasks.parentid ', target:' tt-proj-tasks.id ' , type:"1" ~}'.
        
    IF li-this = li-count[2]
        THEN {&out} SKIP.
        ELSE {&out} ',' SKIP. /* end of rec */
        
   
END.
           
    
{&out} SKIP
        ']' SKIP /* end of links */
    '~};' SKIP /* end of tasks */
    
    .