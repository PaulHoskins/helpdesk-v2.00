
def var i as int.
def var c as char.
for each webstatus:
    
    if num-entries(description,".") < 2  then next.
    c = entry(1,description,".").
   display description.
   i = int(c) no-error.
   if error-status:error then next.

   webstatus.DisplayOrder = i.
end.
