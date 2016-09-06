/***********************************************************************

    Program:        crm/proc/crmloaddatasetok.p
    
    Purpose:        CRM Data Set Load into DB
    
    Notes:
    
    
    When        Who         What
    03/09/2016  phoski      Initial
    
***********************************************************************/

DEFINE INPUT PARAMETER pc-companyCode   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-loginid       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pc-file          AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pr-rowid         AS ROWID     NO-UNDO.

{lib/common.i}
{lib/maillib.i}
DEFINE VARIABLE li-fieldCount       AS INTEGER INITIAL 13 NO-UNDO.

DEFINE TEMP-TABLE ttin NO-UNDO
    FIELD ino AS INTEGER 
    FIELD rec AS CHARACTER
    FIELD msg AS CHARACTER 
    FIELD fld AS CHARACTER EXTENT 13
    INDEX ino ino
    .
    
DEFINE STREAM si.

ASSIGN
    lc-global-company = pc-companyCode.
    

FIND crm_data_load WHERE ROWID(crm_data_load) = pr-rowid NO-LOCK.

FIND WebUser WHERE WebUser.LoginID = pc-loginid NO-LOCK.        
        
        
    
RUN ipLoadDataFile.    
RUN ipValidateData.
RUN ipCreateRecords.
RUN ipGenerateLog.



/* **********************  Internal Procedures  *********************** */

PROCEDURE ipCreateRecords:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE li-rec      AS INTEGER NO-UNDO.
    
    FIND crm_data_load WHERE ROWID(crm_data_load) = pr-rowid NO-LOCK.

    FIND LAST crm_data_acc OF crm_data_load NO-LOCK NO-ERROR.
    
    ASSIGN
        li-rec = ( IF AVAILABLE crm_data_acc THEN crm_data_acc.record_no ELSE 0).
        
    FOR EACH ttin EXCLUSIVE-LOCK WHERE ttin.ino > 1:
        
        FIND crm_data_load WHERE ROWID(crm_data_load) = pr-rowid EXCLUSIVE-LOCK.
        ASSIGN
            li-rec = li-rec + 1
            crm_data_load.no_records = crm_data_load.no_records + 1.
            
        CREATE crm_data_acc.
        ASSIGN 
            ttin.msg                    = "OK"
            crm_data_acc.CompanyCode    = crm_data_load.CompanyCode
            crm_data_acc.load_id        = crm_data_load.load_id
            crm_data_acc.record_status  = "NEW"
            crm_data_acc.record_no      = li-rec. 
            
        ASSIGN
            crm_data_acc.accID   = ttin.fld[1]
            crm_data_acc.Name    = ttin.fld[2]
            crm_data_acc.Address1 = ttin.fld[3]
            crm_data_acc.Address2 = ttin.fld[4]
            crm_data_acc.City = ttin.fld[5]
            crm_data_acc.County = ttin.fld[6]
            crm_data_acc.Postcode = ttin.fld[7]
            crm_data_acc.Telephone = ttin.fld[8]
            crm_data_acc.bus_type = ttin.fld[9]
            crm_data_acc.contact_position = ttin.fld[10]
            crm_data_acc.contact_title = ttin.fld[11]
            crm_data_acc.contact_forename = ttin.fld[12]
            crm_data_acc.contact_surname = ttin.fld[13]
            
            .
        
                
    END.      

END PROCEDURE.

PROCEDURE ipGenerateLog:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE lc-RepFile       AS CHARACTER    NO-UNDO.
    
    
    ASSIGN
        lc-RepFile = "c:\temp\crmdatasetload-" + string(NEXT-VALUE(ReportNumber)) + ".txt".
        
    OUTPUT STREAM si TO value(lc-RepFile) PAGED.
    
    FOR EACH ttin NO-LOCK:
        EXPORT STREAM si DELIMITER ','
            ttin.ino ttin.msg ttin.rec.
    END.
    
    OUTPUT STREAM si CLOSE.
    
    mlib-SendAttEmail 
        ( pc-companyCode,
        "",
        "Data load from " + pc-file + " -  " + crm_data_load.descr,
        "Please find attached the log for this load.",
        webuser.email,
        "",
        "",
        lc-RepFile ).
            
    
        

END PROCEDURE.

PROCEDURE ipLoadDataFile:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-count    AS INTEGER      NO-UNDO.
    DEFINE VARIABLE lc-rec      AS CHARACTER    NO-UNDO.
    
    INPUT STREAM si FROM value(pc-file) NO-ECHO.
    
    REPEAT:
        IMPORT STREAM si UNFORMATTED lc-rec.
        ASSIGN
            li-count = li-count + 1.
            
        CREATE ttin.
        ASSIGN 
            ttin.ino  = li-count
            ttin.rec  = lc-rec
            ttin.msg  = "".
               
    END.
    INPUT CLOSE.
    
    


END PROCEDURE.

PROCEDURE ipValidateData:
    /*------------------------------------------------------------------------------
            Purpose:  																	  
            Notes:  																	  
    ------------------------------------------------------------------------------*/
    DEFINE VARIABLE li-count     AS INTEGER NO-UNDO.
    

    FOR EACH ttin EXCLUSIVE-LOCK:
        ttin.rec = REPLACE(ttin.rec,'"',"").
        li-count = NUM-ENTRIES(ttin.rec,"~t").
        IF li-count <> li-fieldCount THEN
        DO:
            ASSIGN 
                ttin.msg = "Has " + string(li-Count) + " fields".
            NEXT.
        END.
        
        IF ttin.ino = 1 THEN
        DO:
            ASSIGN 
                ttin.msg = "Header - Ignored".
            NEXT.
   
        END.
        
        DO li-count = 1 TO li-fieldCount:
            ASSIGN
                ttin.fld[li-count] = TRIM(ENTRY(li-count,ttin.rec,"~t")).
                   
        END.
                
    END.


END PROCEDURE.
