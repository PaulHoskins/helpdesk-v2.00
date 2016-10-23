
/*------------------------------------------------------------------------
    File        : crm-set-date.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Paul
    Created     : Sun Oct 23 09:04:32 BST 2016
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */



/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

FOR EACH op_master:
     crtdate = DATE(createDate).
  