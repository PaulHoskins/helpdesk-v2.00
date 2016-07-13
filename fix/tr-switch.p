/*------------------------------------------------------------------------
    File        : tr-switch.p
    Purpose     : 

    Syntax      :

    Description : Transfer switch records

    Author(s)   : paul
    Created     : Sun Aug 17 07:01:11 BST 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE VARIABLE cFromCompany AS CHARACTER NO-UNDO.
DEFINE VARIABLE cToCompany   AS CHARACTER NO-UNDO.

DEFINE BUFFER frCust      FOR Customer.
DEFINE BUFFER toCust      FOR Customer.
DEFINE BUFFER custiv      FOR CustIv.
DEFINE BUFFER ivClass     FOR ivClass.
DEFINE BUFFER ivSub       FOR ivSub.
DEFINE BUFFER ivField     FOR ivField.
DEFINE BUFFER CustField   FOR CustField.
DEFINE BUFFER toCustiv    FOR CustIv.
DEFINE BUFFER frcustiv    FOR CustIv.
DEFINE BUFFER toIvClass   FOR ivClass.
DEFINE BUFFER ToIvSub     FOR ivSub.
DEFINE BUFFER frIvSub     FOR ivSub.
DEFINE BUFFER ToIvField   FOR ivField.
DEFINE BUFFER frIvField   FOR ivField.
DEFINE BUFFER ToCustField FOR CustField.
DEFINE BUFFER frCustField FOR CustField.
DEFINE BUFFER frTick      FOR Ticket.
DEFINE BUFFER toTick      FOR Ticket.
DEFINE BUFFER ticket      FOR Ticket.
DEFINE BUFFER frdoch      FOR doch.
DEFINE BUFFER frdocl      FOR docl.
DEFINE BUFFER todoch      FOR doch.
DEFINE BUFFER todocl      FOR docl.
DEFINE BUFFER tous        FOR WebUser.
DEFINE BUFFER frus        FOR WebUser.
DEFINE BUFFER frsla       FOR slahead.
DEFINE BUFFER tosla       FOR slahead.

        

DEFINE VARIABLE icount      AS INTEGER   LABEL '#' NO-UNDO.
DEFINE VARIABLE cPref       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lf-CustIVID LIKE custField.CustIVID NO-UNDO.
DEFINE VARIABLE lf-tickid   LIKE ticket.tickID NO-UNDO.
DEFINE VARIABLE li-docid    LIKE doch.docid NO-UNDO.
DEFINE VARIABLE lc-user     AS CHARACTER LABEL 'IT1 User' NO-UNDO.

 

DEFINE STREAM slog .
  

/* ********************  Preprocessor Definitions  ******************** */

/* ************************  Function Prototypes ********************** */


FUNCTION WriteLog RETURNS LOGICAL
    ( pcmsg AS CHARACTER ) FORWARD.


/* ***************************  Main Block  *************************** */

OUTPUT STREAM slog TO value("c:/temp/switch.log").

DYNAMIC-FUNCTION("writeLog","Starting transfer").

RUN ipInit.

DYNAMIC-FUNCTION("writeLog","Copy Data").

RUN ipProcess.

DYNAMIC-FUNCTION("writeLog","End transfer").

OUTPUT STREAM slog CLOSE.






  

/* **********************  Internal Procedures  *********************** */


PROCEDURE ipInit:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    ASSIGN 
        cFromCompany = "OURIT2"
        CToCompany   = "OURITDEPT"
        cPref        = "IT2.".
        
END PROCEDURE.

PROCEDURE ipProcess:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lr AS ROWID NO-UNDO.
    

    FOR EACH toCust NO-LOCK
        WHERE toCust.CompanyCode = cToCompany
        AND tocust.AccountNumber BEGINS cpref
        WITH FRAME frep DOWN STREAM-IO WIDTH 255:
        
        FIND frcust WHERE frcust.Companycode = cFromCompany
            AND frcust.Name = tocust.Name NO-LOCK NO-ERROR.
           
        IF NOT AVAILABLE frCust THEN NEXT.
                     
        
            
        FOR EACH toCustIv NO-LOCK
            WHERE toCustIv.Companycode = tocust.CompanyCode
            AND tocustIv.AccountNumber = tocust.accountNumber 
            ,
            FIRST toivsub NO-LOCK
            WHERE toivsub.ivSubID = tocustiv.ivsubid
            AND toivsub.ClassCode = "HARDWARE"
            AND toivsub.subcode = "SWITCH" 
            ,FIRST toIvField NO-LOCK
            WHERE toivField.ivsubid = toivsub.ivSubID
            AND toivfield.dorder = 3
                  
                   
            WITH FRAME frep DOWN STREAM-IO WIDTH 255:
           
            FIND tocustField
                WHERE tocustfield.CustIvID = tocustiv.CustIvID
                AND tocustfield.ivFieldID = toivfield.ivFieldID EXCLUSIVE-LOCK NO-ERROR.
                      
            IF NOT AVAILABLE tocustfield THEN
            DO:
                CREATE toCustField.
                ASSIGN
                    tocustField.CustIvID  = tocustiv.CustIvID
                    tocustfield.ivFieldID = toivfield.ivFieldID.
                ASSIGN
                    tocustfield.FieldData = "AUTOC".
                
                     
            END.
            lr = ROWID(tocustfield).
            DEFINE VARIABLE lc-f AS CHAR    NO-UNDO.
            lc-f = ?.
            
            FOR EACH frcustIv NO-LOCK
                WHERE frcustIv.Companycode = frcust.CompanyCode
                AND frcustIv.AccountNumber = frcust.accountNumber 
                AND frcustiv.ref = tocustiv.Ref
                ,
                FIRST frivsub NO-LOCK
                WHERE frivsub.ivSubID = frcustiv.ivsubid
                AND frivsub.ClassCode = "HARDWARE"
                AND frivsub.subcode = "SWITCH" 
                ,FIRST frivField NO-LOCK
                WHERE frivField.ivsubid = frivsub.ivSubID
                AND frivfield.dorder = 3
                  
                   
                WITH FRAME frep2 DOWN STREAM-IO WIDTH 255:
           
                FIND frcustField
                    WHERE frcustfield.CustIvID = frcustiv.CustIvID
                    AND frcustfield.ivFieldID = frivfield.ivFieldID EXCLUSIVE-LOCK NO-ERROR.
                    
                IF AVAILABLE frcustfield 
                THEN lc-f = frcustfield.FieldData.     
                      
            END.
                                            
            DISPLAY STREAM slog
                toCust.accountNumber tocust.Name frcust.AccountNumber.
            
              
            DISPLAY STREAM slog tocustiv.ref FORMAT 'x(30)'
                toivfield.dLabel tocustfield.FieldData FORMAT 'x(20)' COLUMN-LABEL "IT Data"
                lc-f FORMAT 'x(20)' COLUMN-LABEL "IT2 Data"
                
                . 
                
        END.
                        
                         
                          
    END.
    

END PROCEDURE.


/* ************************  Function Implementations ***************** */

FUNCTION WriteLog RETURNS LOGICAL 
    ( cMsg AS CHARACTER ):
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/	

    cmsg = STRING(NOW) + ' ' + cmsg.

    PUT 
        STREAM slog UNFORMATTED SKIP(1)
        cmsg SKIP(1).
                     
		
    RETURN TRUE.
		
		
END FUNCTION.

