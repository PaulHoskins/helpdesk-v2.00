/***********************************************************************

    Program:        lib/syseclib.i
    
    Purpose:        Security Lib     
    
    Notes:
    
    
    When        Who         What
    25/09/2014  phoski      initial
    04/07/2016  phoski      Two Factor Authorisation

***********************************************************************/

/* ***************************  Definitions  ************************** */


/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */

DEFINE VARIABLE lc-global-cookie-name    AS CHARACTER    
    INITIAL 'LoginInfo' NO-UNDO.
DEFINE VARIABLE li-global-pass-max-retry AS INTEGER 
    INITIAL 10 NO-UNDO.
DEFINE VARIABLE lc-global-pack-key      AS CHARACTER 
    INITIAL 'abcEFghi>'                 NO-UNDO.
       

FUNCTION syec-CreateTwoFactorPinForUser RETURNS CHARACTER 
	(pc-LoginID AS CHARACTER) FORWARD.

FUNCTION syec-GeneratePinValue RETURNS CHARACTER 
	(pi-len AS INTEGER) FORWARD.

FUNCTION syec-GetCurrentPinForUser RETURNS CHARACTER 
	(pc-LoginID AS CHARACTER) FORWARD.

FUNCTION syec-UserHasAcessToObject RETURNS LOGICAL 
    (pc-loginid AS CHARACTER,
    pc-objType AS CHARACTER,
    pc-objInfo AS CHARACTER,
     pc-ObjOther AS CHARACTER) FORWARD.

FUNCTION syec-useTwoFactor RETURNS LOGICAL 
	(pc-loginID AS  CHARACTER) FORWARD.

FUNCTION sysec-DecodeValue RETURNS CHARACTER 
    (pc-loginid AS CHARACTER,
    pd-date  AS DATE,
    pc-other AS CHARACTER,
    pc-value AS CHARACTER) FORWARD.

FUNCTION sysec-EncodeValue RETURNS CHARACTER 
    (pc-loginid AS CHARACTER,
    pd-date  AS DATE,
    pc-other AS CHARACTER,
    pc-value AS CHARACTER) FORWARD.

FUNCTION sysec-GeneratePBE-Password RETURNS CHARACTER 
    (pc-loginid AS CHARACTER,
    pd-date  AS DATE,
    pc-other AS CHARACTER) FORWARD.

/* ***************************  Main Block  *************************** */

/* ************************  Function Implementations ***************** */


FUNCTION syec-CreateTwoFactorPinForUser RETURNS CHARACTER 
	    ( pc-LoginID AS CHARACTER  ):
    
    DEFINE BUFFER webUser   FOR WebUser.
    DEFINE BUFFER Company   FOR Company.
    DEFINE BUFFER webSecPin FOR webSecPin.
    
    DEFINE VARIABLE MyUUID      AS RAW       NO-UNDO.
    DEFINE VARIABLE lc-PinId    AS CHARACTER NO-UNDO.
    
    
    
     FOR FIRST WebUser NO-LOCK
        WHERE WebUser.LoginID = pc-LoginID:
       
        
        FOR FIRST Company NO-LOCK
            WHERE Company.CompanyCode = WebUser.CompanyCode:
                
            DO WHILE TRUE:
                    
                ASSIGN  
                    MyUUID = GENERATE-UUID  
                    lc-PinID  = GUID(MyUUID).     
               
               IF CAN-FIND(FIRST WebSecPin WHERE WebSecPin.Pin_id = lc-PinID NO-LOCK) THEN NEXT.
               CREATE WebSecPin.
               ASSIGN
                    WebSecPin.Pin_id = lc-PinId
                    WebSecPin.LoginID = pc-loginID
                    WebSecPin.dtCreated = NOW
                    .
               ASSIGN
                    WebSecPin.Pin = DYNAMIC-FUNCTION("syec-GeneratePinValue",Company.TwoFactor_PinLength).
                RELEASE WebSecPin.    
                RETURN lc-PinId.      
               
            END.
        END.         
    END.
    
		
END FUNCTION.

FUNCTION syec-GeneratePinValue RETURNS CHARACTER 
	    (  pi-len AS INTEGER):

    DEFINE VARIABLE li-loop AS INTEGER  NO-UNDO.
    DEFINE VARIABLE li-bit  AS INTEGER  NO-UNDO.
    DEFINE VARIABLE MyUUID      AS RAW       NO-UNDO.
    DEFINE VARIABLE cGUID       AS CHARACTER NO-UNDO.
    
    ASSIGN  
        MyUUID = GENERATE-UUID  
        cGUID  = GUID(MyUUID). 

    /*
    *** 
    *** Remove all letters and "-"
    ***
    */
    
    cGuid = REPLACE(cguid,"-","").
    ASSIGN
        li-bit = ASC("A").
   
    DO li-loop = 0 TO 25:
        cGuid = REPLACE(cguid,CHR( li-bit + li-loop),"").
    END.
    cGuid = REPLACE(cguid,"0","").
    IF LENGTH (cGuid) > pi-len THEN
    DO:
        cGuid = SUBSTR(cguid, LENGTH(cguid) - ( pi-len + 1),pi-len).
    END.
    RETURN cGuID.
		
END FUNCTION.

FUNCTION syec-GetCurrentPinForUser RETURNS CHARACTER 
	(  pc-LoginID AS CHARACTER  ):
    
    DEFINE BUFFER webUser   FOR WebUser.
    DEFINE BUFFER Company   FOR Company.
    DEFINE BUFFER webSecPin FOR webSecPin.
    
    FOR LAST WebSecPin NO-LOCK
        WHERE WebSecPin.LoginID = pc-LoginID:
            
       RETURN WebSecPin.Pin.
        
    END.
    
    RETURN "bing bong".


		
END FUNCTION.

FUNCTION syec-UserHasAcessToObject RETURNS LOGICAL 
    ( pc-loginid AS CHARACTER,
    pc-objType AS CHARACTER,
    pc-objInfo AS CHARACTER,
    pc-ObjOther AS CHARACTER  ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    DEFINE VARIABLE llok AS LOGICAL NO-UNDO.
    llok = TRUE.

    RUN lib/syec-checkaccess.p 
    (
    INPUT pc-loginid,
    INPUT pc-ObjType,
    INPUT pc-ObjInfo,
    INPUT  pc-ObjOther,
    OUTPUT llok
    ).
   
    
    RETURN llok.

		
END FUNCTION.

FUNCTION syec-useTwoFactorAuth RETURNS LOGICAL 
	    ( pc-loginID AS  CHARACTER  ):
/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	
    DEFINE BUFFER webUser   FOR WebUser.
    DEFINE BUFFER company   FOR Company.
    
    FOR FIRST WebUser NO-LOCK
        WHERE WebUser.LoginID = pc-LoginID:
            
        IF WebUser.TwoFactor_Disable THEN RETURN FALSE.
        
        FOR FIRST Company NO-LOCK
            WHERE Company.CompanyCode = WebUser.CompanyCode:
                
            RETURN Company.TwoFactor_Auth.     
        END.         
    END.
    
    RETURN FALSE.

	
		
END FUNCTION.

FUNCTION sysec-DecodeValue RETURNS CHARACTER 
    ( pc-loginid AS CHARACTER ,
    pd-date  AS DATE ,
    pc-other AS CHARACTER,
    pc-value AS CHARACTER ):
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/    

    DEFINE BUFFER websalt FOR websalt.  
    DEFINE BUFFER websession FOR websession.
     
    DEFINE VARIABLE lr-data AS MEMPTR    NO-UNDO.
    DEFINE VARIABLE lc-data AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lr-mem  AS RAW       NO-UNDO.
    
    IF pc-other = "Inventory"
    OR pc-other = "Document" THEN 
    DO:
        FIND FIRST  websession
             WHERE websession.wsKey = pc-value
                AND websession.wsDate = pd-date NO-LOCK NO-ERROR.
                
        RETURN IF AVAILABLE websession THEN websession.wsValue ELSE ?.
    END.
        
    FIND websalt WHERE websalt.loginid = pc-loginid
        AND websalt.sdate = pd-date
        AND websalt.sother = pc-other NO-LOCK NO-ERROR.
    IF NOT AVAILABLE websalt THEN RETURN ?.
    
    DEFINE VARIABLE lr-pbe-key AS RAW NO-UNDO.
    
 
    lr-pbe-key = GENERATE-PBE-KEY(websalt.sval).
   
    lr-data = BASE64-DECODE(pc-value) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN ?.
        
    ASSIGN
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-ALGORITHM = "AES_OFB_128"
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY       = lr-pbe-key
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-IV        = ?.
            
    
    lc-data = GET-STRING(DECRYPT (lr-data),1).
     
    RETURN lc-data.

		
END FUNCTION.

FUNCTION sysec-EncodeValue RETURNS CHARACTER 
    ( pc-loginid AS CHARACTER ,
    pd-date  AS DATE ,
    pc-other AS CHARACTER,
    pc-value AS CHARACTER ):
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/    

    DEFINE BUFFER websalt FOR websalt. 
    DEFINE BUFFER websession FOR websession.
    
    DEFINE VARIABLE lr-data AS RAW       NO-UNDO.
    DEFINE VARIABLE lc-data AS CHARACTER NO-UNDO.
    
    IF pc-other = "Inventory" 
    OR pc-other = "Document" THEN 
    DO:
        lc-data = DYNAMIC-FUNCTION("sysec-GeneratePBE-Password",pc-loginid,pd-date,pc-other). 
        
        CREATE websession.
        ASSIGN 
            websession.wsKey = lc-data
            websession.wsDate = pd-date
            websession.wsValue = pc-value.
        RELEASE websession.    
        RETURN lc-data.
        
    END.
             
    FIND websalt WHERE websalt.loginid = pc-loginid
        AND websalt.sdate = pd-date
        AND websalt.sother = pc-other NO-LOCK NO-ERROR.
    IF NOT AVAILABLE websalt THEN
    DO:
        CREATE websalt.
        ASSIGN 
            websalt.loginid = pc-loginid
            websalt.sdate   = pd-date
            websalt.sother  = pc-other.
        ASSIGN
            websalt.sval = DYNAMIC-FUNCTION("sysec-GeneratePBE-Password",pc-loginid,pd-date,pc-other).    
    END.    
    
    DEFINE VARIABLE lr-pbe-key AS RAW NO-UNDO.
    
 
    lr-pbe-key = GENERATE-PBE-KEY(websalt.sval).
    
    ASSIGN
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-ALGORITHM = "AES_OFB_128"
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY       = lr-pbe-key
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-IV        = ?.
            
    lr-data = ENCRYPT (pc-value).
    
    lc-data = BASE64-ENCODE(lr-data).

    RETURN lc-data.
    
		
END FUNCTION.

FUNCTION sysec-GeneratePBE-Password RETURNS CHARACTER 
    ( pc-loginid AS CHARACTER ,
    pd-date  AS DATE ,
    pc-other AS CHARACTER):
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/    

    DEFINE VARIABLE MyUUID AS RAW       NO-UNDO.
    DEFINE VARIABLE cGUID  AS CHARACTER NO-UNDO. 
    ASSIGN  
        MyUUID = GENERATE-UUID  
        cGUID  = GUID(MyUUID). 
    
    RETURN cGUID.
        
		
END FUNCTION.

