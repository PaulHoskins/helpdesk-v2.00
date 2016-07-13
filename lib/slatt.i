/***********************************************************************

    Program:        lib/slatt.i
    
    Purpose:             
    
    Notes:
    
    
    When        Who         What
    10/04/2006  phoski      Initial
    
***********************************************************************/

&if defined(slattdef-library-defined) = 0 &then

&glob slattdef-library-defined yes

DEFINE TEMP-TABLE tt-sla-sched                 NO-UNDO
    FIELD Level         AS INTEGER
    FIELD Note          AS CHARACTER
    FIELD sDate         AS DATE
    FIELD sTime         AS INTEGER

    INDEX Level 
            Level.

&endif
