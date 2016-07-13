/*------------------------------------------------------------------------
    File        : trf-customer.p
    Purpose     : 

    Syntax      :

    Description : Transfer customer from one company to another	

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
DEFINE BUFFER toIvClass   FOR ivClass.
DEFINE BUFFER ToIvSub     FOR ivSub.
DEFINE BUFFER ToIvField   FOR ivField.
DEFINE BUFFER ToCustField FOR CustField.
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

OUTPUT STREAM slog TO value(SESSION:TEMP-DIR + "/transfer.log").

DYNAMIC-FUNCTION("writeLog","Starting transfer").

RUN ipInit.

DYNAMIC-FUNCTION("writeLog","Reset Data").

RUN ipClean.

DYNAMIC-FUNCTION("writeLog","Copy Data").

RUN ipProcess.

DYNAMIC-FUNCTION("writeLog","End transfer").

OUTPUT STREAM slog CLOSE.






  

/* **********************  Internal Procedures  *********************** */

PROCEDURE ipClean:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    FOR EACH toCust EXCLUSIVE-LOCK
        WHERE toCust.companyCode = cToCompany
        AND tocust.AccountNumber BEGINS cPref:
        
        FOR EACH tous EXCLUSIVE-LOCK
            WHERE tous.CompanyCode   = cToCompany
            AND tous.AccountNumber = toCust.AccountNumber
            AND tous.UserClass = "CUSTOMER":
              
            DELETE tous.
          
        END.
              
          
        
        FOR EACH todoch EXCLUSIVE-LOCK
            WHERE todoch.CompanyCode = cToCompany
            AND todoch.RelType = "customer"
            AND todoch.RelKey  = toCust.AccountNumber:
            FOR EACH todocl OF todoch EXCLUSIVE-LOCK:
                DELETE todocl.
            END.
            DELETE todoch.           
                    
        END.
            
        FOR EACH totick OF tocust EXCLUSIVE-LOCK:
            DELETE totick.
        END.
        FOR EACH toCustIv 
            OF tocust EXCLUSIVE-LOCK:
            
            FOR EACH tocustfield OF tocustiv EXCLUSIVE-LOCK:
                DELETE tocustfield.
            END.    
            DELETE toCustIv.
        END.        
        
        DELETE tocust.      
    END.
    

END PROCEDURE.

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
    DEFINE VARIABLE cnewAccount AS CHARACTER FORMAT 'x(10)' LABEL 'New Account' NO-UNDO.
    

    FOR EACH frcust EXCLUSIVE-LOCK
        WHERE frcust.companycode = cfromCompany
        WITH SIDE-LABELS STREAM-IO:
        
        ASSIGN
            icount      = icount + 1
            cNewAccount = cPref + string(iCount,"999").
          
        PAUSE 0.
        PUT STREAM slog 
            UNFORMATTED SKIP(2) FILL('*',200) SKIP.
        DISPLAY STREAM 
            slog    icount SKIP
            frcust.AccountNumber frcust.name cNewAccount.
        CREATE toCust.
        BUFFER-COPY frcust 
            EXCEPT frcust.companycode frcust.AccountNumber frcust.old-accountNumber 
            TO tocust
            ASSIGN 
            tocust.AccountNumber = cNewAccount
            tocust.CompanyCode = cToCompany
            tocust.old-AccountNumber = frCust.AccountNumber.
        /*
        ***
        *** SLA 
        ***
        */
       
        IF frcust.DefaultSLAID <> 0 
            AND frcust.DefaultSLAID <> ? THEN
        DO:
            FIND frsla WHERE frsla.SLAID = frcust.DefaultSLAID NO-LOCK NO-ERROR.
            IF AVAIL frsla THEN
            DO:
                FIND FIRST tosla
                    WHERE tosla.companycode = tocust.companycode
                    AND tosla.SLACode = frsla.SLACode  NO-LOCK NO-ERROR.
                IF AVAILABLE tosla THEN 
                DO:
                    DISPLAY STREAM slog 
                        tosla.SLACode LABEL 'SLA'.
                        
                    ASSIGN 
                        tocust.defaultSLAID = tosla.SLAID.
                END.
                        
            END.
        END.
            
        /*
        *** 
        *** Inventory 
        ***
        */
        FOR EACH CustIv OF frcust NO-LOCK WITH SIDE-LABELS WIDTH 255 STREAM-IO:
            
            FIND ivSub WHERE ivSub.ivSubID = CustIv.ivSubID NO-LOCK NO-ERROR.
            IF NOT AVAILABLE ivSub THEN NEXT.
            
            FIND toivsub 
                WHERE toivsub.CompanyCode = cToCompany
                AND toivsub.ClassCode = ivSub.ClassCode
                AND toivsub.SubCode = ivSub.SubCode NO-LOCK NO-ERROR.
                  
            DISPLAY STREAM slog
                ivSub.ivSubID
                CustIv.ref
                ivSub.ClassCode ivSub.SubCode AVAILABLE toivsub LABEL 'Found'.
            DOWN STREAM slog.
             
            IF NOT AVAILABLE toivsub THEN NEXT.
             
            
            CREATE toCustIV.
            ASSIGN 
                toCustIV.accountnumber = tocust.accountnumber
                toCustIV.CompanyCode   = tocust.CompanyCode
                toCustIV.CustIvID      = ?
                toCustIV.ivSubID       = toivsub.ivsubid.                .
            DO WHILE TRUE:
                RUN lib/makeaudit.p (
                    "",
                    OUTPUT lf-custIVID
                    ).
                IF CAN-FIND(FIRST CustIV
                    WHERE CustIV.CustIvID = lf-custIVID NO-LOCK)
                    THEN NEXT.
                ASSIGN
                    toCustIV.CustIvID = lf-CustIvID.
                LEAVE.
            END.
            
            ASSIGN 
                toCustIV.Ref = CustIv.Ref.
             
            FOR EACH ivField OF ivsub NO-LOCK 
                WITH DOWN STREAM-IO WIDTH 255:
             
                FIND toIvField 
                    WHERE toivField.ivsubid = toivsub.ivSubID
                    AND toivfield.dorder = ivField.dOrder 
                    AND toivfield.dLabel = ivField.dLabel NO-LOCK NO-ERROR.
                             
                DISPLAY STREAM slog
                    ivField.dLabel ivField.dOrder 
                    ivField.dType
                    AVAILABLE toivfield LABEL 'Avail'
                    ToivField.dLabel 
                    WHEN AVAILABLE toIvField ToivField.dOrder 
                    WHEN AVAILABLE toIvField.
                IF AVAILABLE toivfield THEN
                DO:
                    FIND CustField WHERE CustField.CustIvID = CustIv.CustIvID
                        AND CustField.ivFieldID = ivField.ivFieldID NO-LOCK NO-ERROR.
                    DISPLAY STREAM slog
                        REPLACE(IF AVAIL custField THEN CustField.FieldData ELSE "","~n","<n>") FORMAT 'x(50)' LABEL 'Data' 
                        WHEN  AVAILABLE CustField 
                        AVAILABLE CustField LABEL 'Avail Data'.
                                               
                END.   
                DOWN STREAM slog.
                IF NOT AVAILABLE toivField THEN NEXT.
                                         
                CREATE toCustField.
                ASSIGN
                    tocustField.CustIvID  = tocustiv.CustIvID
                    tocustfield.ivFieldID = toivfield.ivFieldID.
                IF AVAIL custfield THEN
                ASSIGN
                    tocustfield.FieldData = CustField.FieldData.
                    
                                          
            END.
                 
                      
        END. /* custiv */
        
        /*
        ***
        *** Tickets 
        ***
        */
        FOR EACH frtick OF frcust EXCLUSIVE-LOCK
            WITH DOWN STREAM-IO WIDTH 255:
            
            FIND LAST ticket NO-LOCK NO-ERROR.
            ASSIGN
                lf-TickID = IF AVAILABLE ticket THEN ticket.TickID + 1 ELSE 1.
            CREATE totick.
            BUFFER-COPY frtick 
                EXCEPT frtick.companycode frtick.AccountNumber frtick.TickID 
                TO totick
                ASSIGN 
                totick.companycode = tocust.companycode
                totick.accountnumber = tocust.accountnumber
                totick.tickid = lf-tickid.
                    
            DISPLAY STREAM slog
                tocust.accountnumber
                tocust.name
                frtick.tickid
                frtick.Reference
                frtick.TxnDate
                frtick.TxnType
                frtick.amount
                totick.TickID.                         
                
            
        END.
        /*
        ***
        *** Documents
        ***
        */
        FOR EACH frdoch 
            WHERE frdoch.CompanyCode = frCust.CompanyCode
            AND frdoch.RelType = "customer"
            AND frdoch.RelKey  = frCust.AccountNumber
            EXCLUSIVE-LOCK
            WITH DOWN STREAM-IO WIDTH 255:
            
            REPEAT:
                ASSIGN
                    li-docid = NEXT-VALUE(docid).
                IF CAN-FIND(doch WHERE doch.docid = li-docid NO-LOCK) THEN NEXT.
                LEAVE.
            END.      
            
            CREATE todoch.
            BUFFER-COPY frdoch 
                EXCEPT 
                frdoch.companyCode frdoch.RelKey frdoch.docid
                TO todoch
                ASSIGN 
                todoch.CompanyCode = tocust.companyCode
                todoch.RelKey = tocust.AccountNumber
                todoch.DocID = li-docid.
             
            DISPLAY STREAM slog
                tocust.accountnumber
                tocust.name
                
                frdoch.DocID frdoch.descr frdoch.DocType todoch.DocID.    
                    
            FOR EACH frdocl OF frdoch EXCLUSIVE-LOCK:
                CREATE todocl.
                BUFFER-COPY frdocl 
                    EXCEPT frdocl.docid
                    TO todocl
                    ASSIGN 
                    todocl.docid = li-docid.
            END.                     
                    
        END. 
        
        /*
        ***
        *** Users
        ***
        */
        FOR EACH frus EXCLUSIVE-LOCK
            WHERE frus.CompanyCode   = frcust.companyCode
            AND frus.AccountNumber = frCust.AccountNumber
            AND frus.UserClass = "CUSTOMER"
            BY frus.name
            WITH DOWN STREAM-IO WIDTH 255:
         
            IF frus.LoginID BEGINS cPref THEN
            DO:
                lc-user = substr(frus.loginid,LENGTH(cPref) + 1).
            END.
            ELSE 
            DO:
                lc-user = frus.loginid.
                
                ASSIGN 
                    frus.loginid = cPref + frus.loginid.
                FOR EACH Issue EXCLUSIVE-LOCK
                    WHERE Issue.CompanyCode = frcust.companyCode
                    AND issue.AccountNumber = frCust.AccountNumber:
                    
                    IF Issue.RaisedLoginID = lc-user
                        THEN ASSIGN
                            Issue.RaisedLoginID = frus.loginid.
                         
                END.
                            
                
            END.
            CREATE tous.
            BUFFER-COPY frus 
                EXCEPT frus.companycode frus.AccountNumber frus.Loginid 
                TO tous
                ASSIGN 
                tous.companycode = tocust.companycode
                tous.accountnumber = tocust.accountnumber
                tous.Loginid = lc-user.
                
            DISPLAY STREAM slog
                tocust.accountnumber
                tocust.name
                frus.loginid  COLUMN-LABEL 'IT2 Login' frus.name lc-user.
              
                
            
            
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

