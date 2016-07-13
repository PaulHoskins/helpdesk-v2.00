/***********************************************************************

    Program:        rep/manreptt.i
    
    Purpose:        Management Report - Temp Table Def  
    
    Notes:
    
    
    When        Who         What
    10/07/2006  phoski      Initial     
***********************************************************************/


DEFINE TEMP-TABLE tt-mrep NO-UNDO
    FIELD AccountNumber LIKE customer.AccountNumber
    FIELD CatCode       LIKE Issue.CatCode
    FIELD Bfwd          AS INTEGER FORMAT 'zzzzzz9'
    FIELD OpenPer       AS INTEGER FORMAT 'zzzzzz9'
    FIELD ClosePer      AS INTEGER FORMAT 'zzzzzz9'
    FIELD OutSt         AS INTEGER FORMAT 'zzzzzz9'
    FIELD Duration      LIKE IssActivity.Duration
    
    INDEX AccountNumber
    AccountNumber.


