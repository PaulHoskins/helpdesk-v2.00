/***********************************************************************

    Program:        lib/jquery-ui.i
    
    Purpose:        Jquery UI library         
    
    Notes:
    
    
    When        Who         What
    26/03/2016  phoski      Initial
    
    
***********************************************************************/






FUNCTION jqLib-IncludeLibrary RETURNS CHARACTER 
	(  ) FORWARD.



/* ************************  Function Implementations ***************** */








FUNCTION jqLib-IncludeLibrary RETURNS CHARACTER 
	    (  ):

/*------------------------------------------------------------------------------
		Purpose:  																	  
		Notes:  																	  
------------------------------------------------------------------------------*/	
	DEFINE VARIABLE pc-return AS CHARACTER NO-UNDO.
    
    pc-return = 
        '~n<link rel="stylesheet" type="text/css" href="/asset/jquery-easyui-1.4.5/themes/default/easyui.css">' +
        '~n<link rel="stylesheet" type="text/css" href="/asset/jquery-easyui-1.4.5/themes/icon.css">' +
        '~n<link rel="stylesheet" type="text/css" href="/asset/jquery-easyui-1.4.5/themes/color.css">' +
    
        
        '~n<script type="text/javascript" src="/asset/jquery-easyui-1.4.5/jquery.easyui.min.js"></script>~n'
            
        .
        
		RETURN pc-return.

END FUNCTION.

