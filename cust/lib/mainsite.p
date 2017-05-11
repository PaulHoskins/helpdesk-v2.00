
/***********************************************************************

    Program:       cust/lib/mainsite.p
   
    Purpose:       Create main
    
    Notes:
    
    
    When        Who         What
    30/04/2017  phoski      Initial
    09/05/2017  phoski      Name field on Site
   
***********************************************************************/

DEFINE INPUT PARAMETER pr-rowid AS ROWID        NO-UNDO.

DEFINE BUFFER Customer FOR Customer.
DEFINE BUFFER CustSite FOR CustSite.

FIND Customer WHERE ROWID(Customer) = pr-rowid EXCLUSIVE-LOCK.


FIND custsite
    WHERE CustSite.CompanyCode = Customer.CompanyCode
    AND CustSite.AccountNumber = Customer.AccountNumber
    AND CustSite.Site = "" EXCLUSIVE-LOCK NO-ERROR.
IF NOT AVAILABLE CustSite THEN
DO:
    CREATE CustSite.
    ASSIGN
        CustSite.CompanyCode   = Customer.CompanyCode
        CustSite.AccountNumber = Customer.AccountNumber
        CustSite.Site          = "".
           
END.
 
ASSIGN
    CustSite.Address1  = Customer.Address1
    CustSite.Address2  = Customer.Address2
    CustSite.City      = Customer.city
    CustSite.county    = Customer.county
    CustSite.country   = Customer.country
    CustSite.postcode  = Customer.postcode
    CustSite.telephone = Customer.telephone
    CustSite.contact   = Customer.contact
    CustSite.notes     = Customer.notes
    CustSite.Name      = Customer.Name.
      