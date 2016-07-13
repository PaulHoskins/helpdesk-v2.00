/***********************************************************************

    Program:        rep/custprofit-tt.i
    
    Purpose:        Customer Profit Report Temp Table
    
    Notes:
    
    
    When        Who         What
    15/06/2015  phoski      Initial
    25/10/2015  phoski      Revenue and Costs fields
    10/11/2015  phoski      Report on contract per period
    15/03/2016  phoski      conActive flag
   
***********************************************************************/
DEFINE VARIABLE cc-TotalKey     AS CHARACTER INITIAL "zzzzz_total_zzzzz" NO-UNDO.

DEFINE TEMP-TABLE tt-custp NO-UNDO
    FIELD SortField         AS CHARACTER 
    FIELD AccountNumber     LIKE Customer.AccountNumber
    FIELD ContractCode      LIKE ContractRate.ContractCode
    FIELD cbegin            LIKE ContractRate.cBegin
    
    FIELD cValue            LIKE ContractRate.cValue
    FIELD contract_no       LIKE WebissCont.Contract_no
    FIELD ConActive         LIKE WebissCont.ConActive
    
    FIELD cend              AS DATE
    
          
    FIELD name              LIKE Customer.Name
    FIELD GrossProfit%      LIKE ContractType.GrossProfit
    FIELD GrossProfitV      AS DECIMAL 
    FIELD hBill-Time        AS INTEGER   EXTENT 2
    FIELD hNonB-Time        AS INTEGER   EXTENT 2
            
    FIELD ndays             AS INTEGER   EXTENT 2
    FIELD rdays             AS INTEGER   EXTENT 2
    FIELD drate             AS DECIMAL   EXTENT 2
    FIELD Revenue           AS DECIMAL   EXTENT 2
    FIELD Cost              AS DECIMAL   EXTENT 2
    
    INDEX AccountNumber AccountNumber ContractCode cbegin
    INDEX SortField     SortField.
    

DEFINE TEMP-TABLE tt-custt NO-UNDO
    FIELD AccountNumber LIKE Customer.AccountNumber
    FIELD cValue        LIKE ContractRate.cValue
    FIELD ContractCode  LIKE ContractRate.ContractCode
    FIELD cbegin        LIKE ContractRate.cBegin
    FIELD isDefault     AS LOG
    
    FIELD contract_no       LIKE WebissCont.Contract_no
    FIELD ConActive         LIKE WebissCont.ConActive
    
    FIELD cend              AS DATE
      
     
    FIELD GrossProfit%  LIKE ContractType.GrossProfit
    FIELD GrossProfitV      AS DECIMAL 
    FIELD Bill-Time     AS INTEGER EXTENT 2
    FIELD NonB-Time     AS INTEGER EXTENT 2
    
    
    /* 
    ***
    *** in rounded up Hours
    ***
    */
    FIELD hBill-Time    AS INTEGER EXTENT 2
    FIELD hNonB-Time    AS INTEGER EXTENT 2
    
    
 
    FIELD ndays         AS INTEGER   EXTENT 2
    FIELD rdays         AS INTEGER   EXTENT 2
    FIELD drate         AS DECIMAL   EXTENT 2
     
    FIELD Revenue       AS DECIMAL EXTENT 2
    FIELD Cost          AS DECIMAL EXTENT 2
     
    
    INDEX AccountNumber AccountNumber ContractCode cbegin.
    
    