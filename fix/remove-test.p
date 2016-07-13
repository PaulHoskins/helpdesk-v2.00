{iss/issue.i}
{lib/common.i}


 lc-global-company = "OURITDEPT".
 lc-global-user = "phoski-it".

 for each issue 
     where issue.companyCode = lc-global-company
       and issue.BriefDescription begins "test request":

     if issue.AccountNumber = "9999" then NEXT.

     RUN x ( rowid(issue), "9999").

 end.
 
 procedure x:
     def input param pr-rowid        as rowid        no-undo.
     def input param pc-account      as char         no-undo.


     find issue
         where rowid(issue) = pr-rowid exclusive-lock.

     for each issAlert of Issue exclusive-lock:
         delete issAlert.
     end.


     run islib-CreateNote(
         lc-global-company,
         issue.IssueNumber,
         lc-global-user,
         "SYS.ACCOUNT",
         "Issue moved from customer " + 
         dynamic-function("com-CustomerName",Issue.CompanyCode,Issue.AccountNumber)
         ).
     assign
         Issue.AccountNumber = pc-account
         Issue.link-SLAID    = 0
         Issue.SLADate       = ?
         Issue.SLALevel      = ?
         Issue.SLAStatus     = "OFF"
         Issue.SLATime       = 0.

     if com-IsCustomer(Issue.CompanyCode,Issue.CreateBy) 
     then issue.CreateBy = "".

     if com-IsCustomer(Issue.CompanyCode,Issue.RaisedLoginId) 
     then issue.RaisedLoginId = "".


 end procedure.
