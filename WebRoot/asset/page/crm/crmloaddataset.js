
function DoSubmit () {
  
    if (document.forms[0].filename.value == "")
    {
          alert("The daata file name must be entered.");
            
    } 
    else    
    {            
           document.forms[0].submit();
    }                        
}

