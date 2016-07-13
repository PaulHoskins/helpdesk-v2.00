/***********************************************************************

    Program:        lib/dashlib.i
    
    Purpose:        Dashboard Lib
    
    Notes:
    
    
    When        Who         What
    19/05/2015  phoski      Initial
    
***********************************************************************/

DEFINE TEMP-TABLE   tt-dashlib  NO-UNDO
    FIELD panelCode     AS CHARACTER LABEL 'Panel Code'
    FIELD descr         AS CHARACTER LABEL 'Description'
    FIELD ipRun         AS CHARACTER LABEL 'Run Procedure'
    FIELD PanelOptions  AS CHARACTER LABEL 'Options'
    
    INDEX panelCodeIDX  panelCode.
    
    

/*
*** SetUp 
***
*/
RUN dashlib-Initialise.

FUNCTION dashlib-CreateLib RETURNS ROWID 
	(pc-panelCode AS CHARACTER,
	 pc-descr AS CHARACTER,
	 pc-iprun AS CHARACTER) FORWARD.

/* **********************  Internal Procedures  *********************** */

PROCEDURE dashlib-Initialise:
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/
    DEFINE BUFFER tt-row  FOR tt-dashlib.
    DEFINE VARIABLE lr-row AS ROWID NO-UNDO.
    
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-L20I","Latest 20 Issues","ip-LatestIssue").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-O20IOpen","Oldest 20 Open Issues","ip-OldestIssue").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-IToday","Todays Issues","ip-TodayIssue").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-ITodayClass","Todays Issues By Class","ip-TodayIssueClass").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","000-AStats","HelpDesk Statistics","ip-HelpdeskStatistics").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","001-EStats","Engineer Statistics","ip-EngineerStatistics").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    
END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION dashlib-CreateLib RETURNS ROWID 
	    ( pc-panelCode AS CHARACTER ,
	      pc-descr AS CHARACTER ,
	      pc-iprun AS CHARACTER  ):
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	
    
    DEFINE BUFFER tt-row  FOR tt-dashlib.
	
	CREATE tt-row.
	ASSIGN 
	   tt-row.panelCode = pc-panelCode
	   tt-row.descr = pc-descr
	   tt-row.ipRun = pc-iprun.
	       
	RETURN ROWID(tt-row).
	       
	   	
        

		
END FUNCTION.
