/***********************************************************************

    Program:        rep/crmpipelinett.i
    
    Purpose:        CRM Pipeline Report Temp Table def
    
    Notes:
    
    
    When        Who         What
    
    23/12/2016  phoski      Initial
    
***********************************************************************/

DEFINE TEMP-TABLE   tt-pipe     NO-UNDO
    FIELD loginid   AS CHARACTER    
    FIELD opStatus  AS CHARACTER 
    FIELD opDesc    AS CHARACTER
    FIELD Rev       AS DECIMAL EXTENT 13
    FIELD Cost      AS DECIMAL EXTENT 13
    FIELD gpProf    AS DECIMAL EXTENT 13
    FIELD projRev   AS DECIMAL EXTENT 13
    FIELD projGP    AS DECIMAL EXTENT 13
    FIELD oCount    AS DECIMAL EXTENT 13
    INDEX prim loginid opStatus.
    
    
