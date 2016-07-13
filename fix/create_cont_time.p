
/*------------------------------------------------------------------------
    File        : create_cont_time.p
    Purpose     : 

    Syntax      :

    Description : 	

    Author(s)   : paul
    Created     : Sun Dec 21 11:32:55 GMT 2014
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

DEFINE VARIABLE iyear   AS INT    NO-UNDO.
DEFINE VARIABLE iday    AS INT      NO-UNDO.
DEFINE BUFFER b FOR WebStdTime.


FOR EACH WebUser WHERE WebUser.UserClass = "INTERNAL" NO-LOCK:
    
    DO iyear = 2014 TO 2015:
        FIND b WHERE b.companycode = WebUser.CompanyCode
                 AND b.loginid = WebUser.LoginID
                 AND b.StdWkYear = iyear EXCLUSIVE-LOCK NO-ERROR.
        IF NOT AVAILABLE b THEN
        DO:
            CREATE b.
            ASSIGN
                 b.companycode = WebUser.CompanyCode
                 b.loginid = WebUser.LoginID
                 b.StdWkYear = iyear.
           
        END.
        StdAMStTime = 0.
        DO iday = 1 TO 7:
            IF iday > 5
            THEN 
            ASSIGN
                b.StdAMStTime[iday] = 0
                b.StdAMEndTime[iday] = 0
                b.StdPMStTime[iday] = 0
                b.StdPMEndTime[iday] = 0
                .
            ELSE
            ASSIGN
                b.StdAMStTime[iday] = 0900
                b.StdAMEndTime[iday] = 1300
                b.StdPMStTime[iday] = 1400
                b.StdPMEndTime[iday] = 1730.
                
            
                
        END.
        
            
    END.    
END.
    