/***********************************************************************

    Program:        lib/dashlib.i
    
    Purpose:        Dashboard Lib
    
    Notes:
    
    
    When        Who         What
    19/05/2015  phoski      Initial
    23/08/2016  phoski      CRM dashboards
        
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
    
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-L20I","[HD] Latest 20 Issues","ip-LatestIssue").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-O20IOpen","[HD] Oldest 20 Open Issues","ip-OldestIssue").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-IToday","[HD] Todays Issues","ip-TodayIssue").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","002-ITodayClass","[HD] Todays Issues By Class","ip-TodayIssueClass").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","000-AStats","[HD] HelpDesk Statistics","ip-HelpdeskStatistics").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","001-EStats","[HD] Engineer Statistics","ip-EngineerStatistics").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    /* CRM Dashboards */
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","CRM-001-AStats","[CRM] Statistics","ip-CRMStatistics").
    FIND tt-row WHERE ROWID(tt-row) = lr-row EXCLUSIVE-LOCK.
    
    lr-row = DYNAMIC-FUNCTION("dashlib-CreateLib","CRM-002-RepAStats","[CRM] All Sales Rep Statistics","ip-CRMRepStatistics").
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
