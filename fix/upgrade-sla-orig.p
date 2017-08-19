
/*------------------------------------------------------------------------
    File        : upgrade-sla-orig.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sat Aug 05 08:09:01 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/


FOR EACH Issue EXCLUSIVE-LOCK:
   
   
   RUN iss/lib/issue-orig-sla.p ( ROWID(issue) ).
   
    
END.
