/***********************************************************************

    Program:        prince/ivdue.i
    
    Purpose:        Customer Inventory - Prince Report
    
    Notes:
    
    
    When        Who         What
    10/07/2006  phoski      Initial
    01/05/2017  phoski      Site info
***********************************************************************/

DEFINE TEMP-TABLE tt NO-UNDO
    FIELD CustFieldRow  AS ROWID
    FIELD ivFieldRow    AS ROWID
    FIELD AccountNumber LIKE customer.AccountNumber
    FIELD name          LIKE customer.name
    FIELD site          AS CHARACTER
    FIELD ivDate        AS DATE
    FIELD ref           LIKE custiv.Ref
    FIELD dLabel        LIKE ivField.dLabel

    INDEX AccountNumber
    AccountNumber
    ivDate


    .