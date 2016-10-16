
FOR EACH _file NO-LOCK WHERE _file-number > 0,
    FIRST _field OF _file WHERE _field-name = "accountnumber":

    DISP _file-name.

    
END.
