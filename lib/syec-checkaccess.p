/***********************************************************************

    Program:        lib/syec-checkaccess.p
    
    Purpose:        Can a user run an object               
    
    Notes:
    
    
    When        Who         What
    27/09/2014  phoski      initial
    08/03/2015  phoski      Allow access to issuelog.p
***********************************************************************/

/* ***************************  Definitions  ************************** */

DEFINE INPUT PARAMETER  pc-loginid  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER  pc-objType  AS CHARACTER     NO-UNDO.
DEFINE INPUT PARAMETER  pc-objInfo  AS CHARACTER     NO-UNDO. 
DEFINE INPUT PARAMETER  pc-objOther AS CHARACTER     NO-UNDO. 
DEFINE OUTPUT PARAMETER pl-Allow    AS LOG           NO-UNDO.

    

/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */

DEFINE BUFFER webuser FOR WebUser.

FUNCTION FindApplicationObject RETURNS CHARACTER 
    (pc-ObjName AS CHARACTER) FORWARD.

FUNCTION FindObjectInMenu RETURNS CHARACTER 
    (pc-PageName AS CHARACTER,
    pc-ObjectID AS CHARACTER) FORWARD.

FUNCTION RunObjectExcludeFromCheck RETURNS LOGICAL 
    (pc-ObjName AS CHARACTER) FORWARD.


/* ***************************  Main Block  *************************** */


FIND WebUser WHERE WebUser.LoginID = pc-loginid NO-LOCK NO-ERROR.
IF NOT AVAILABLE WebUser 
    OR WebUser.Disabled THEN
DO:
    pl-Allow = NO.
    RETURN.
END.
CASE pc-ObjType: 
    WHEN "RunObject" THEN RUN ipRunObject.
END CASE.
 
RETURN.

/* **********************  Internal Procedures  *********************** */

PROCEDURE ipRunObject:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-baseObj  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-sObj     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-PageName AS CHARACTER NO-UNDO.
    
    DEFINE BUFFER WebObject FOR WebObject.
 
    ASSIGN
        pl-allow = TRUE
        lc-sObj  = REPLACE(pc-objInfo,".p","").
    
    IF DYNAMIC-FUNCTION("RunObjectExcludeFromCheck",pc-ObjInfo)
        THEN RETURN.
    
    ASSIGN
        lc-BaseObj = DYNAMIC-FUNCTION("FindApplicationObject",lc-sObj).
    
    IF lc-BaseObj = ?
        THEN RETURN.
    
    /*
    *** Got a menu object so need to see if it's in the users menu's
    ***
    */
    
    FIND FIRST WebObject
        WHERE WebObject.ObjURL = lc-BaseObj NO-LOCK NO-ERROR.
    
    ASSIGN
        lc-PageName = DYNAMIC-FUNCTION("FindObjectInMenu",WebUser.PageName,WebObject.ObjectID).
    
   
    ASSIGN 
        pl-allow = lc-pagename <> "".
    
    
/* webObject.ObjURL */
 
END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION FindApplicationObject RETURNS CHARACTER 
    ( pc-ObjName AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE lc-ObjURL AS CHARACTER NO-UNDO.
    DEFINE BUFFER WebObject FOR WebObject.

    DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.
		
    DO iLoop = LENGTH(pc-Objname) TO 3 BY -1:
        lc-ObjURL = SUBSTRING(pc-Objname,1,iLoop).
        IF CAN-FIND(FIRST WebObject WHERE WebObject.ObjURL = lc-ObjURL NO-LOCK)
            THEN RETURN lc-ObjURL.
        lc-ObjURL = lc-ObjURL + ".p".
        IF CAN-FIND(FIRST WebObject WHERE WebObject.ObjURL = lc-ObjURL NO-LOCK)
            THEN RETURN lc-ObjURL.
            
        lc-ObjURL = "/" + SUBSTRING(pc-Objname,1,iLoop).
        IF CAN-FIND(FIRST WebObject WHERE WebObject.ObjURL = lc-ObjURL NO-LOCK)
            THEN RETURN lc-ObjURL.
        lc-ObjURL = lc-ObjURL + ".p".
        IF CAN-FIND(FIRST WebObject WHERE WebObject.ObjURL = lc-ObjURL NO-LOCK)
            THEN RETURN lc-ObjURL.
            
		    
    END.
		
    RETURN ?.
		


		
END FUNCTION.

FUNCTION FindObjectInMenu RETURNS CHARACTER 
    ( pc-PageName AS CHARACTER ,
    pc-ObjectID AS CHARACTER):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE BUFFER menuLine FOR WebMLine.
    
    DEFINE VARIABLE lc-PageName AS CHARACTER NO-UNDO.
    
    FOR EACH menuline NO-LOCK
        WHERE MENUline.PageName = pc-pageName:
        IF MENUline.LinkType = "PAGE" THEN 
        DO:
            lc-PageName = DYNAMIC-FUNCTION("FindObjectInMenu",menuline.LinkObject,pc-ObjectID). 
            IF lc-pageName = "" THEN NEXT.
            RETURN lc-pageName.
        END.
        ELSE
            IF menuline.LinkObject = pc-ObjectID
                THEN RETURN MENUline.PageName.
        
    END.
    
    
    RETURN "".


		
END FUNCTION.

FUNCTION RunObjectExcludeFromCheck RETURNS LOGICAL 
    (  pc-ObjName AS CHARACTER):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	   
    IF pc-objName BEGINS "iss" THEN RETURN TRUE.
    
    IF pc-objname MATCHES "*ajax*" THEN RETURN TRUE.
    
    IF pc-objname = "cust/custview.p" THEN RETURN TRUE.
    
    IF pc-objname = "cust/custequiplist.p" THEN RETURN TRUE.
    
    IF pc-objname = "cust/custequipmnt.p" THEN RETURN TRUE.
    
    IF pc-objname = "sys/webuserpref.p" THEN RETURN TRUE.
    
   
    IF pc-objname = "rep/issuelog.p" 
    AND WebUser.UserClass = "CUSTOMER" THEN RETURN TRUE.
        
    RETURN FALSE.
		


		
END FUNCTION.

