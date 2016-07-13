
for each _file no-lock where _file-number > 0,
    first _field of _file where _field-name = "accountnumber":

    disp _file-name.

    run fix\ac-fix2.p _file-name.
end.
