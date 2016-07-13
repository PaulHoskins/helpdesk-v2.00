
/*
FOR EACH acs_rq NO-LOCK.

FOR EACH acs_res OF acs_rq:
    DISP acs_res.

END.

END
  */
  OUTPUT TO c:\temp\rep.txt.

FOR EACH acs_res NO-LOCK:
    DISP rq_id FORMAT 'x(70)' acs_res.acs_line_id.
END.

FOR EACH acs_rq NO-LOCK:
    DISP rq_id FORMAT 'x(70)' rq_status.
END.





