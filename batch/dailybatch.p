/***********************************************************************

    Program:        batch/dailybatch.p
   
    Purpose:        Run daily system jobs.
    
    Notes:
    
    
    When        Who         What
    22/07/2017  phoski      Initial
   
***********************************************************************/

/*
mbpro -db helpdesk -S 6500 -H localhost -d dmy -s 4000 -rand 2 -T C:\Development\temp -p batch/dailybatch.p
*/

OUTPUT TO c:\temp\dailybatch.log.


PUT UNFORMATTED NOW " Run Issuecheck" SKIP.

RUN batch/issuecheck.p.

PUT UNFORMATTED NOW " End Issuecheck" SKIP.


PUT UNFORMATTED NOW " Run Issuearchive" SKIP.

RUN batch/issuearchive.p.

PUT UNFORMATTED NOW " End Issuearchive" SKIP.