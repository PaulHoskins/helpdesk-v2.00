
/*------------------------------------------------------------------------
    File        : fix-92005.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Mon Sep 25 08:24:12 BST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */


DEFINE BUFFER a FOR issactivity.

FIND issue WHERE issue.companyCode = "ouritdept"
        AND issue.issuenumber = 92005 EXCLUSIVE-LOCK.


DEF VAR i AS INT NO-UNDO.
OUTPUT TO c:\temp\data.d APPEND.
FOR EACH a EXCLUSIVE-LOCK
        WHERE  a.companyCode = issue.companyCode
        AND a.issueNumber = issue.issuenumber
        AND a.actdate = 08/29/2017
        AND  a.activityby BEGINS "uw":

    i = i + 1.
    IF i > 1 THEN
    DO:
        EXPORT A.
        DELETE A.
    END.


END.
