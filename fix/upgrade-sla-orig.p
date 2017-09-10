
/*------------------------------------------------------------------------
    File        : upgrade-sla-orig.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sat Aug 05 08:09:01 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/


OUTPUT TO c:\temp\upgrade-sla.txt UNBUFFERED.

FOR EACH Issue EXCLUSIVE-LOCK WITH DOWN STREAM-IO:
    
    PAUSE 0.
    
    DISPLAY Issue.CompanyCode Issue.IssueNumber Issue.link-SLAID Issue.orig-SLAID.
    DOWN.
   
   
   RUN iss/lib/issue-orig-sla.p ( ROWID(issue) ).
   
    
END.
OUTPUT CLOSE.
