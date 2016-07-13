/*------------------------------------------------------------------------
    File        : inv-report.p
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

OUTPUT STREAM slog TO value("c:/temp/inv-report.txt") paged.



RUN ipInit.

RUN ipProcess.


OUTPUT STREAM slog CLOSE.






  

/* **********************  Internal Procedures  *********************** */


PROCEDURE ipInit:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    
    ASSIGN 
        
        CToCompany   = "OURITDEPT"
         CToCompany  = "OURIT2" 
        .
        
END PROCEDURE.

PROCEDURE ipProcess:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lr AS ROWID NO-UNDO.
    

    FOR EACH toCust NO-LOCK
        WHERE toCust.CompanyCode = cToCompany,
        EACH toCustIv NO-LOCK
            WHERE toCustIv.Companycode = tocust.CompanyCode
            AND tocustIv.AccountNumber = tocust.accountNumber 
            
       
        WITH FRAME frepc SIDE-LABELS STREAM-IO WIDTH 255:
        
        FIND FIRST toivsub
            WHERE toivsub.ivSubID = tocustiv.ivsubid
           NO-LOCK NO-ERROR.
          
        IF toivsub.ClassCode <> "hardware" THEN NEXT.
        
        IF toivsub.subcode <> "switch" THEN NEXT.
         
                
        DISPLAY STREAM slog
                tocust.companyCode
                toCust.accountNumber tocust.Name SKIP
                toivsub.ClassCode
                toivsub.subcode 
                tocustiv.Ref FORMAT 'x(40)'
                .
                
                
            
        FOR EACH toivsub NO-LOCK
            WHERE toivsub.ivSubID = tocustiv.ivsubid
           
            ,EACH toIvField NO-LOCK
            
            WHERE toivField.ivsubid = toivsub.ivSubID
            BY toivfield.dOrder
            WITH FRAME frep DOWN STREAM-IO WIDTH 255:
           
            FIND tocustField
                WHERE tocustfield.CustIvID = tocustiv.CustIvID
                AND tocustfield.ivFieldID = toivfield.ivFieldID EXCLUSIVE-LOCK NO-ERROR.
                      
            
              
            DISPLAY STREAM slog toivfield.dOrder
                toivfield.dLabel tocustfield.FieldData 
                WHEN AVAILABLE tocustfield 
                
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

