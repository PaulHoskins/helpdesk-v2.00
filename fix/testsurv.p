
/*------------------------------------------------------------------------
    File        : testsurv.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Paul
    Created     : Mon Jun 20 06:42:03 BST 2016
    Notes       :
  ----------------------------------------------------------------------*/

DEFINE VARIABLE lc-msg AS CHARACTER NO-UNDO.

FIND LAST Issue WHERE Issue.CompanyCode = "OuritDept" 
AND Issue.IssueNumber = 105464 NO-LOCK.



RUN lib/createSurveyRequest.p 
 ( Issue.CompanyCode , "SV.2016.01",
   Issue.IssueNumber, "phoski-it", "paulanhoskins@outlook.com",NO,OUTPUT lc-msg).
   
