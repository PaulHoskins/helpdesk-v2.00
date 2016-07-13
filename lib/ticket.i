/***********************************************************************

    Program:        lib/ticket.i
    
    Purpose:        Ticket Library
    
    Notes:
    
    
    When        Who         What
    16/07/2006  phoski      Initial   
    02/07/2016  phoski      Removed customer ticket balance as always
                            calculated now
***********************************************************************/


DEFINE TEMP-TABLE tt-ticket NO-UNDO LIKE ticket.


PROCEDURE tlib-IssueChanged :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER pr-rowid        AS ROWID                NO-UNDO.
    DEFINE INPUT PARAMETER pc-loginid      LIKE webuser.loginid    NO-UNDO.
    DEFINE INPUT PARAMETER pl-from         AS LOG                  NO-UNDO.
    DEFINE INPUT PARAMETER pl-to           AS LOG                  NO-UNDO.

    DEFINE BUFFER Issue       FOR Issue.
    DEFINE BUFFER Customer    FOR Customer.
    DEFINE BUFFER IssActivity FOR IssActivity.

    DEFINE VARIABLE li-TicketAmount LIKE IssActivity.Duration   NO-UNDO.
    DEFINE VARIABLE lc-Reference    LIKE Ticket.Reference       NO-UNDO.

    IF pl-to = pl-from THEN RETURN.

    FIND Issue WHERE ROWID(Issue) = pr-rowid EXCLUSIVE-LOCK.
    

    
    FIND Customer WHERE Customer.CompanyCode = Issue.Companycode
        AND Customer.AccountNumber = Issue.AccountNumber
        EXCLUSIVE-LOCK.

    /*
    ***
    *** Moving to a ticket based issue
    ***
    */
    IF pl-to THEN
    DO:
        /*
        ***
        *** Sum up all activities
        ***
        */
        FOR EACH IssActivity OF Issue NO-LOCK:
            IF DYNAMIC-FUNCTION("com-IsActivityChargeable",IssActivity.IssActivityID)
            THEN ASSIGN li-TicketAmount = li-TicketAmount + IssActivity.Duration.
        END.
        IF li-TicketAmount = 0 THEN RETURN.

        ASSIGN
            lc-Reference    = "Issue Changed To Ticket"
            li-TicketAmount = li-TicketAmount * -1.

    END.
    /*
    ***
    *** From a ticket base issue to nonticket
    ***
    */ 
    ELSE
    DO:
        /*
        ***
        *** Need to reverse the ticket balance
        ***
        */
        ASSIGN 
            lc-reference    = "Issue Changed To Non-Ticket".
            li-ticketAmount = 0.
            
        FOR EACH IssActivity OF Issue NO-LOCK:
            IF DYNAMIC-FUNCTION("com-IsActivityChargeable",IssActivity.IssActivityID)
            THEN ASSIGN li-TicketAmount = li-TicketAmount + IssActivity.Duration.
        END.
        
    END.

    EMPTY TEMP-TABLE tt-ticket.

    CREATE tt-ticket.
    ASSIGN
        tt-ticket.CompanyCode   = issue.CompanyCode
        tt-ticket.AccountNumber = issue.AccountNumber
        tt-ticket.Amount        = li-TicketAmount
        tt-ticket.CreateBy      = pc-LoginID
        tt-ticket.CreateDate    = TODAY
        tt-ticket.CreateTime    = TIME
        tt-ticket.IssueNumber   = Issue.IssueNumber
        tt-ticket.Reference     = lc-Reference
        tt-ticket.TickID        = ?
        tt-ticket.TxnDate       = TODAY
        tt-ticket.TxnTime       = TIME
        tt-ticket.TxnType       = "ADJ".

    IF li-TicketAmount <> 0
    THEN RUN tlib-PostTicket.


    
END PROCEDURE.


PROCEDURE tlib-PostTicket :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    
    DEFINE BUFFER ticket   FOR ticket.
    DEFINE BUFFER customer FOR customer.
    DEFINE BUFFER Issue    FOR Issue.


    DEFINE VARIABLE lf-tickid LIKE ticket.tickID NO-UNDO.

    SAVE-BLOCK:
    REPEAT TRANSACTION ON ERROR UNDO , LEAVE:

        FOR EACH tt-ticket EXCLUSIVE-LOCK:
                    
            FIND customer WHERE customer.companycode = tt-ticket.companycode
                AND customer.AccountNumber = tt-ticket.AccountNumber
                EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE customer THEN
            DO:
                MESSAGE PROGRAM-NAME(1) " Missing Account " tt-ticket.AccountNumber.
                NEXT.
            END.

            FIND LAST ticket NO-LOCK NO-ERROR.
            ASSIGN
                lf-TickID = IF AVAILABLE ticket THEN ticket.TickID + 1 ELSE 1.
            
            CREATE ticket.
            BUFFER-COPY 
                tt-ticket EXCEPT tt-ticket.TickID
                TO ticket
                ASSIGN 
                ticket.TickID = lf-TickID.

            

            RELEASE ticket.
            RELEASE customer.
            DELETE tt-ticket.

        END.


        LEAVE.
    END.
END PROCEDURE.


