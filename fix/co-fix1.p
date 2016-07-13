
for each _file no-lock where _file-number > 0,
    first _field of _file where _field-name = "companycode":

    disp _file-name.

    run fix\co-fix2.p _file-name.
end.
