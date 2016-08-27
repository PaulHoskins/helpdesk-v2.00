
/*
FOR EACH acs_rq NO-LOCK.

FOR EACH acs_res OF acs_rq:
    DISP acs_res.

END.

END
  */
 FOR EACH op_master NO-LOCK WHERE op_master.CompanyCode = 'ouritdept' AND op_master.SalesManager = 'SALMAN'




