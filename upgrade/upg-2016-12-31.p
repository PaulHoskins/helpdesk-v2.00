
/***********************************************************************

    Program:        upgrade/upg-2016-12-31.p
   
    Purpose:        Upgrade
    
    Notes:
    
    
    When        Who         What
    18/12/12/2016  phoski      Initial
   
***********************************************************************/


FOR EACH op_master:
    
    FIND FIRST op_status OF op_master NO-LOCK NO-ERROR.
    IF AVAILABLE op_status THEN NEXT.
    
     CREATE op_Status.
    ASSIGN
        op_status.companyCode  = op_master.CompanyCode
        op_status.op_id        = op_master.op_id
        op_status.loginid      = op_master.createLoginid
        op_status.ChangeDate   = op_master.createDate
        op_status.FromOPStatus = ""
        op_status.ToOpStatus   = "OP".
        
    IF op_master.OpStatus <> "OP" THEN
    DO:
        CREATE op_Status.
        ASSIGN
            op_status.companyCode  = op_master.CompanyCode
            op_status.op_id        = op_master.op_id
            op_status.loginid      = op_master.createLoginid
            op_status.ChangeDate   = ADD-INTERVAL(op_master.createDate,1,"hour")
            op_status.FromOPStatus = ""
            op_status.ToOpStatus   = op_master.OpStatus.
     END.
     
                
        
END.

FOR EACH Customer:
    Customer.iss_survey = FALSE.
END.




        


