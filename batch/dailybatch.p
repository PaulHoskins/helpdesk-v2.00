/***********************************************************************

    Program:        batch/dailybatch.p
   
    Purpose:        Run daily system jobs.
    
    Notes:
    
    
    When        Who         What
    22/07/2017  phoski      Initial
    04/08/2017  phoski      run seessionClean  
***********************************************************************/



DEFINE STREAM rp.


OUTPUT STREAM rp TO c:\temp\dailybatch.log unbuffered.


PUT STREAM rp UNFORMATTED NOW " Run Issuecheck" SKIP.

RUN batch/issuecheck.p.

PUT STREAM rp UNFORMATTED NOW " End Issuecheck" SKIP.

PUT STREAM rp UNFORMATTED NOW " Run Issuearchive" SKIP.

RUN batch/issuearchive.p.

PUT STREAM rp UNFORMATTED NOW " End Issuearchive" SKIP.


PUT STREAM rp UNFORMATTED NOW " Run SeesionClean" SKIP.

RUN batch/sessionclean.p.

PUT STREAM rp UNFORMATTED NOW " End SessionClean" SKIP.

OUTPUT STREAM rp CLOSE.

