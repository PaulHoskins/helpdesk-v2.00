
FOR EACH op_Activity /*WHERE startDate > TODAY */:
    DISPLAY op_id startDate.
    
    FIND op_master WHERE op_master.op_id = op_Activity.op_id.
    DISPLAY op_master.op_no last_act
    .
    
    
END.

    
