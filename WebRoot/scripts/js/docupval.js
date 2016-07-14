
function DoSubmit () {
    if (document.forms[0].comment.value == "")
    {
          alert("The description must be entered.");
          return;
            
    } 
    if (document.forms[0].filename.value == "")
    {
          alert("The document name must be entered.");
            
    } 
    else    
    {            
           document.forms[0].submit();
    }                        
}

