/***********************************************************************

    Program:        lib/toolbar.i
    
    Purpose:        Toolbar library 
    
    Notes:
    
    
    When        Who         What
    01/01/2006  phoksi      Standard
    23/08/2010  DJS         3677 Added remote connection ability image
    23/08/2010  DJS         3678 Modified map facility to use google 
                                maps instead of streetmaps added image
    02/09/2010  DJS         3674 - Added toolbar for Quickview toggle
    26/04/2014  phoski      Asset Toolbar
    26/11/2014  phoski      nofind option on standard toolbar
    27/03/2015  phoski      project related link
    18/06/2016  phoksi      survey link
    
    
***********************************************************************/


/* ***************************  Definitions  ************************** */







/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-tbar-Begin) = 0 &THEN

FUNCTION tbar-Begin RETURNS CHARACTER
    ( pc-RightPanel AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginHidden) = 0 &THEN

FUNCTION tbar-BeginHidden RETURNS CHARACTER
    ( pr-rowid AS ROWID )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginID) = 0 &THEN

FUNCTION tbar-BeginID RETURNS CHARACTER
    ( pc-ID AS CHARACTER,
    pc-RightPanel AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginOption) = 0 &THEN

FUNCTION tbar-BeginOption RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginOptionID) = 0 &THEN

FUNCTION tbar-BeginOptionID RETURNS CHARACTER
    ( pc-ToolID AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-End) = 0 &THEN

FUNCTION tbar-End RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-EndHidden) = 0 &THEN

FUNCTION tbar-EndHidden RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-EndOption) = 0 &THEN

FUNCTION tbar-EndOption RETURNS CHARACTER
    ( /* parameter-definitions */ )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-Find) = 0 &THEN

FUNCTION tbar-Find RETURNS CHARACTER
    ( pc-url AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-FindCustom) = 0 &THEN

FUNCTION tbar-FindCustom RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-name AS CHARACTER,
    pc-action AS CHARACTER,
    pc-label AS CHARACTER,
    pi-size AS INTEGER
    )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-FindLabel) = 0 &THEN

FUNCTION tbar-FindLabel RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-label AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-FindLabelIssue) = 0 &THEN

FUNCTION tbar-FindLabelIssue RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-label AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-ImageLink) = 0 &THEN

FUNCTION tbar-ImageLink RETURNS CHARACTER
    ( 
    pc-image AS CHARACTER,
    pc-url AS CHARACTER,
    pc-alt AS CHARACTER)  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-JavaScript) = 0 &THEN

FUNCTION tbar-JavaScript RETURNS CHARACTER
    ( pc-ToolBarID        AS CHARACTER  )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-Link) = 0 &THEN

FUNCTION tbar-Link RETURNS CHARACTER
    ( pc-mode AS CHARACTER,
    pr-rowid AS ROWID,
    pc-url AS CHARACTER,
    pc-other-params AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-StandardBar) = 0 &THEN

FUNCTION tbar-StandardBar RETURNS CHARACTER
    ( pc-find-url AS CHARACTER,
    pc-add-url  AS CHARACTER,
    pc-link AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-StandardRow) = 0 &THEN

FUNCTION tbar-StandardRow RETURNS CHARACTER
    ( pr-rowid AS ROWID,
    pc-user  AS CHARACTER,
    pc-url AS CHARACTER,
    pc-delete AS CHARACTER,
    pc-link AS CHARACTER )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-tr) = 0 &THEN

FUNCTION tbar-tr RETURNS CHARACTER
    ( pr-rowid AS ROWID )  FORWARD.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-trID) = 0 &THEN

FUNCTION tbar-trID RETURNS CHARACTER
    ( pc-ToolID AS CHARACTER,
    pr-rowid AS ROWID )  FORWARD.


&ENDIF


/* *********************** Procedure Settings ************************ */



/* *************************  Create Window  ************************** */

/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 15
         WIDTH              = 60.
/* END WINDOW DEFINITION */
                                                                        */

 




/* ***************************  Main Block  *************************** */



/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-tbar-Begin) = 0 &THEN

FUNCTION tbar-Begin RETURNS CHARACTER
    ( pc-RightPanel AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF pc-RightPanel = ""
        OR pc-RightPanel = ?
        THEN RETURN '<div id="toolbar" style="clear: both;" class="toolbar">&nbsp;'.
    ELSE RETURN '<div id="toolbar" style="clear: both;" class="toolbar"><span id="tbright" class="tbright">' + pc-RightPanel + '&nbsp;</span>&nbsp;'. 


END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginHidden) = 0 &THEN

FUNCTION tbar-BeginHidden RETURNS CHARACTER
    ( pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-rowobj  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-toolobj AS CHARACTER NO-UNDO.

    ASSIGN
        lc-rowobj  = "ROW" + string(pr-rowid)
        lc-toolobj = "TOOL" + string(pr-rowid).
        
    RETURN
        '<div id="' 
        + lc-toolobj 
        + '" style="display: none;">'.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginID) = 0 &THEN

FUNCTION tbar-BeginID RETURNS CHARACTER
    ( pc-ID AS CHARACTER,
    pc-RightPanel AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-return = tbar-Begin(pc-RightPanel).

    RETURN REPLACE(lc-return,'id="toolbar"','id="' + pc-ID + '"').

   

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginOption) = 0 &THEN

FUNCTION tbar-BeginOption RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '<span id="tboption" class="tboption">'.  

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-BeginOptionID) = 0 &THEN

FUNCTION tbar-BeginOptionID RETURNS CHARACTER
    ( pc-ToolID AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '<span id="' + pc-ToolID + 'tboption" class="tboption">'.  

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-End) = 0 &THEN

FUNCTION tbar-End RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '</div>'.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-EndHidden) = 0 &THEN

FUNCTION tbar-EndHidden RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '</div>'.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-EndOption) = 0 &THEN

FUNCTION tbar-EndOption RETURNS CHARACTER
    ( /* parameter-definitions */ ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN '</span>'.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-Find) = 0 &THEN

FUNCTION tbar-Find RETURNS CHARACTER
    ( pc-url AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    IF pc-url = ""
    OR pc-url MATCHES "*nofind*"
    THEN RETURN "".
    RETURN
        '<input style="font-size: 12px;" name="search" size="20" value="' + dynamic-function("get-value","search") + '">'
        + '&nbsp;' 
        + '<a alt="Find" href="javascript:MntButtonPress(~'search~',~'' + pc-url + '~')">'
        + '<img src="/images/toolbar/find.gif" class="tbarimg" border="0" alt="Find"></a>'.
/*
     dynamic-function("htmlib-MntButton",pc-url,"search","Search").
  */

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-FindCustom) = 0 &THEN

FUNCTION tbar-FindCustom RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-name AS CHARACTER,
    pc-action AS CHARACTER,
    pc-label AS CHARACTER,
    pi-size AS INTEGER
    ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN
        '<span style="font-size: 12px;">' 
        + pc-label +
        '</span><input style="font-size: 12px;" name="' + pc-name + '" size="' + string(pi-size) + 
        '" value="' + dynamic-function("get-value",pc-name) + '">'
        + '&nbsp;' 
        + '<a alt="Find" href="javascript:MntButtonPress(~''  + pc-action + '~',~'' + pc-url + '~')">'
        + '<img src="/images/toolbar/find.gif" class="tbarimg" border="0" alt="Find"></a>'.
/*
     dynamic-function("htmlib-MntButton",pc-url,"search","Search").
  */

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-FindLabel) = 0 &THEN

FUNCTION tbar-FindLabel RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-label AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN      '<b>' + pc-label + ':</b>&nbsp;' + 
        '<input style="font-size: 12px;" name="search" size="20" value="' + dynamic-function("get-value","search") + '">'
        + '&nbsp;' 
        + '<a alt="Find" href="javascript:MntButtonPress(~'search~',~'' + pc-url + '~')">'
        + '<img src="/images/toolbar/find.gif" class="tbarimg" border="0" alt="Find"></a>'.
    

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-FindLabelIssue) = 0 &THEN

FUNCTION tbar-FindLabelIssue RETURNS CHARACTER
    ( pc-url AS CHARACTER,
    pc-label AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN      '<b>' + pc-label + ':</b>&nbsp;' + 
        '<input style="font-size: 12px;" name="search" size="20" value="' + dynamic-function("get-value","search") + '">'
        + '&nbsp;' 
        + '<a alt="Find" href="javascript:IssueButtonPress(~'search~',~'' + pc-url + '~')">'
        + '<img src="/images/toolbar/find.gif" class="tbarimg" border="0" alt="Find"></a>'.
    


END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-ImageLink) = 0 &THEN

FUNCTION tbar-ImageLink RETURNS CHARACTER
    ( 
    pc-image AS CHARACTER,
    pc-url AS CHARACTER,
    pc-alt AS CHARACTER) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN
        SUBSTITUTE(
        '<a href="&1"><img border="0" src="&2" alt="&3" title="&3" class="tbarimg"></a>',
        pc-url,
        pc-image,
        pc-alt).
      

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-JavaScript) = 0 &THEN

FUNCTION tbar-JavaScript RETURNS CHARACTER
    ( pc-ToolBarID        AS CHARACTER  ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-return AS CHARACTER NO-UNDO.

    ASSIGN 
        lc-return = "<script>" + "~n" + 
        replace(
                '/* JS for toolbar ID TOOLSUB */':U + '~n' +
                'var TOOLSUBobjRowSelected = null':U + '~n' +
                'var TOOLSUBobjRowInit = false':U + '~n' +
                'var TOOLSUBobjRowDefault = null':U + '~n' +
                'function TOOLSUBrowInit () ~{':U + '~n' +
                '       if ( TOOLSUBobjRowInit ) ~{':U + '~n' +
                '               return':U + '~n' +
                '       }':U + '~n' +
                '       TOOLSUBobjRowInit = true':U + '~n' +
                '       var objtoolBarOption = document.getElementById("TOOLSUBtboption")':U + '~n' +
                
                
                '       TOOLSUBobjRowDefault = objtoolBarOption.innerHTML':U + '~n' +
                '       return':U + '~n' +
                '}':U + '~n' +
                'function TOOLSUBrowSelect (rowObject, rowToolIDName) ~{':U + '~n' +
                '       var objRowToolBar = document.getElementById(rowToolIDName)':U + '~n' +
                '       var objtoolBarOption = document.getElementById("TOOLSUBtboption")':U + '~n' +
                '       TOOLSUBrowInit()':U + '~n' +
                '       if ( TOOLSUBobjRowSelected != null ) ~{':U + '~n' +
                '               TOOLSUBobjRowSelected.className = "tabrow1"':U + '~n' +
                '       }':U + '~n' +
                
                
                '       if ( TOOLSUBobjRowSelected == rowObject ) ~{':U + '~n' +
                '               TOOLSUBobjRowSelected = null':U + '~n' +
                '               rowObject.className = "tabrow1"':U + '~n' +
                '               // Was space':U + '~n' +
                '               objtoolBarOption.innerHTML = TOOLSUBobjRowDefault':U + '~n' +
                '               return':U + '~n' +
                '       }':U + '~n' +
                '       rowObject.className = "tabrowselected"':U + '~n' +
                '       TOOLSUBobjRowSelected = rowObject':U + '~n' +
                '       objtoolBarOption.innerHTML = objRowToolBar.innerHTML':U + '~n' +
                
                
                '}':U + '~n' +
                'function TOOLSUBrowOver (rowObject) ~{':U + '~n' +
                '       if ( TOOLSUBobjRowSelected != rowObject ) ~{':U + '~n' +
                '               rowObject.className = "tabrowover"':U + '~n' +
                '               return':U + '~n' +
                '       }':U + '~n' +
                '       rowObject.className = "tabrowselected"':U + '~n' +
                '}':U + '~n' +
                'function TOOLSUBrowOut (rowObject) ~{':U + '~n' +
                '       if ( TOOLSUBobjRowSelected != rowObject ) ~{':U + '~n' +
                
                
                '               rowObject.className = "tabrow1"':U + '~n' +
                '               return':U + '~n' +
                '       }':U + '~n' +
                '       rowObject.className = "tabrowselected"':U + '~n' +
                '}':U + '~n' +
                '/* END OF JS */':U + '~n'
            ,
            "TOOLSUB",
            pc-ToolBarID

            
            ) + "~n" + '</script>'.



    RETURN lc-return.

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-Link) = 0 &THEN

FUNCTION tbar-Link RETURNS CHARACTER
    ( pc-mode AS CHARACTER,
    pr-rowid AS ROWID,
    pc-url AS CHARACTER,
    pc-other-params AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-image    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-alt-text AS CHARACTER NO-UNDO.

    CASE pc-mode:
        WHEN 'add':U
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/add.gif'
                lc-alt-text = 'Add'.
        WHEN 'addissue'
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/add.gif'
                lc-alt-text = 'Add Issue'.
        WHEN 'delete':U
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/delete.gif'
                lc-alt-text = 'Delete'.
        WHEN 'update':U
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/update.gif'
                lc-alt-text = 'Update'.
        WHEN 'view':u
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/view.gif'
                lc-alt-text = 'View'.
        WHEN 'documentview':u
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/view.gif'
                lc-alt-text = 'View'.
        WHEN 'genpassword' 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/lock.gif'
                lc-alt-text = 'Generate password'.
        WHEN "contaccess" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/contaccess.gif'
                lc-alt-text = 'Contractor account access'.
        WHEN "doclist" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/doclist.gif'
                lc-alt-text = 'Documents'.
        WHEN "eqsubclass"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/eqsubedit.gif'
                lc-alt-text = 'Inventory subclassifications'.
        WHEN "customfield"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/customfield.gif'
                lc-alt-text = 'Define custom fields'.
        WHEN "custequip"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/custequip.gif'
                lc-alt-text = 'Customer equipment'.
        WHEN "addnote"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/addnote.gif'
                lc-alt-text = 'Add note'.
        WHEN "addactivity"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/activity.gif'
                lc-alt-text = 'Add activity'.
        WHEN "updateactivity"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/editactivity.gif'
                lc-alt-text = 'Update activity'.
        WHEN "pdf"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/pdf.gif'
                lc-alt-text = 'PDF report'.
        WHEN "equipview"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/equipview.gif'
                lc-alt-text = 'View equipment'.
        WHEN "ticketadd"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/ticketadd.gif'
                lc-alt-text = 'Add support ticket'.
        WHEN "emaildelete"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/email_delete.gif'
                lc-alt-text = 'Delete email'.
        WHEN "emailissue"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/emailissue.gif'
                lc-alt-text = 'Create an issue from this email'.
        WHEN "emailview"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/emailview.gif'
                lc-alt-text = 'View original email'.
        WHEN "emailsave"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/email_go.gif'
                lc-alt-text = 'Save attachments in customer documents'.
        WHEN "kbissue"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/kbissue.gif'
                lc-alt-text = 'Create KB item from issue'.
        WHEN "moveiss" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/moveiss.gif'
                lc-alt-text = 'Move issue to different customer'.
        WHEN "statement"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/statement.gif'
                lc-alt-text = 'Statement'.
        WHEN "customerview"
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/cview.gif'
                lc-alt-text = 'Toggle customer view'.
        WHEN "quickview"  /* 3674 */
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/qview.gif'
                lc-alt-text = 'Toggle quick view'.
        WHEN "Gmap"   /* 3678 */
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/Gmap.gif'
                lc-alt-text = 'View map'.
        WHEN "RDP"  /* 3677 */
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/winrdp.gif'
                lc-alt-text = 'Connect to customer'.   
        WHEN "multiiss" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/multi.gif'
                lc-alt-text = 'Multiple issue editor'.
        WHEN "conttime" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/time-admin2.gif'
                lc-alt-text = 'Engineers Time editor'.
        WHEN "CustAsset" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/fa.gif'
                lc-alt-text = 'Customer Asset'.
        WHEN "TestV" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/testv.gif'
                lc-alt-text = 'Test Template'.
        WHEN "MailIssue" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/mailiss.gif'
                lc-alt-text = 'Mail Open Issues'.
        WHEN "wrk-hr" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/wrk-hr.gif'
                lc-alt-text = 'Working Hours'.
        WHEN "wshol" 
        THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/wshol.gif'
                lc-alt-text = 'Load public holidays from webservice (www.holidaywebservice.com)'.
         WHEN "phase"   THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/phase.gif'
                lc-alt-text = 'Project Phases'.
         WHEN "ptask"   THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/phase.gif'
                lc-alt-text = 'Project Actions'.
         WHEN "recdown"   THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/recdown.gif'
                lc-alt-text = 'Move Down Order'.
                
         WHEN "recup"   THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/recup.gif'
                lc-alt-text = 'Move Up Order'.
         WHEN "CustContract" THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/contract.gif'
                lc-alt-text = 'Customer Contracts'.
          WHEN "Survq" THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/survq.gif'
                lc-alt-text = 'Survey Questions'.
           WHEN "SurvSend" THEN 
            ASSIGN 
                lc-image    = '/images/toolbar3/surv-send.gif'
                lc-alt-text = 'Test Survey'.
                
                  
  
    END CASE.
    
  

    IF pc-url = "off" THEN
    DO:
        ASSIGN
            lc-image = REPLACE(lc-image,"toolbar3","toolbar3off").
        ASSIGN
            pc-url      = 'javascript:alert(~'Please selected a record before clicking this button~');'
            lc-alt-text = "Disabled".
        RETURN '<img  class="tbarimg" border=0 src="' 
            + lc-image + '">'.
       
    END.
    ELSE 
    DO:
        IF pc-url BEGINS "javascript" THEN
        DO:

        END.
        ELSE
        DO:
        
            ASSIGN 
                pc-url = pc-url + '?mode=' + pc-mode
                    + '&rowid=' + IF pr-rowid = ? THEN "" ELSE STRING(pr-rowid).

            IF pc-other-params <> ""
                AND pc-other-params <> ?
                THEN ASSIGN pc-url = pc-url + "&" + pc-other-params.
        END.

        RETURN DYNAMIC-FUNCTION("tbar-ImageLink",lc-image,pc-url,
            lc-alt-text).
    END.
END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-StandardBar) = 0 &THEN

FUNCTION tbar-StandardBar RETURNS CHARACTER
    ( pc-find-url AS CHARACTER,
    pc-add-url  AS CHARACTER,
    pc-link AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/
    
    RETURN  
        tbar-Begin(
        tbar-Find(pc-find-url)
        ) 
        + tbar-Link("add",?,pc-add-url,pc-link)
        + tbar-BeginOption()
        + tbar-Link("view",?,"off",pc-link)
        + tbar-Link("update",?,"off",pc-link)
        + tbar-Link("delete",?,"off",pc-link)
        + tbar-EndOption()
        + tbar-End().
           
END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-StandardRow) = 0 &THEN

FUNCTION tbar-StandardRow RETURNS CHARACTER
    ( pr-rowid AS ROWID,
    pc-user  AS CHARACTER,
    pc-url AS CHARACTER,
    pc-delete AS CHARACTER,
    pc-link AS CHARACTER ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    RETURN
        tbar-BeginHidden(pr-rowid)
        + tbar-Link("view",pr-rowid,pc-url,pc-link)
        + tbar-Link("update",pr-rowid,pc-url,pc-link)
        + tbar-Link("delete",pr-rowid,
        IF DYNAMIC-FUNCTION('com-CanDelete':U,pc-user,pc-delete,pr-rowid)
        THEN pc-url ELSE "off",pc-link)
               
        + tbar-EndHidden().

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-tr) = 0 &THEN

FUNCTION tbar-tr RETURNS CHARACTER
    ( pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-rowobj  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-toolobj AS CHARACTER NO-UNDO.

    ASSIGN
        lc-rowobj  = "ROW" + string(pr-rowid)
        lc-toolobj = "TOOL" + string(pr-rowid).
        
  
    RETURN
        '<tr class="tabrow1" id="' + lc-rowobj 
        + '" onClick="javascript:rowSelect(this,~'' 
        + lc-toolobj 
        + '~')"'
        + ' onmouseover="javascript:rowOver(this)"' 
        + ' onmouseout="javascript:rowOut(this)"'       
        + '>' 
        .

END FUNCTION.


&ENDIF

&IF DEFINED(EXCLUDE-tbar-trID) = 0 &THEN

FUNCTION tbar-trID RETURNS CHARACTER
    ( pc-ToolID AS CHARACTER,
    pr-rowid AS ROWID ) :
    /*------------------------------------------------------------------------------
      Purpose:  
        Notes:  
    ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lc-rowobj  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lc-toolobj AS CHARACTER NO-UNDO.

    ASSIGN
        lc-rowobj  = "ROW" + string(pr-rowid)
        lc-toolobj = "TOOL" + string(pr-rowid).
        
  
    RETURN
        REPLACE(
        DYNAMIC-FUNCTION('tbar-tr':U,pr-rowid),
        'javascript:',
        'javascript:' + pc-ToolID).
/*
    '<tr class="tabrow1" id="' + lc-rowobj 
            + '" onClick="javascript:rowSelect(this,~'' 
            + lc-toolobj 
            + '~')"'
            + ' onmouseover="javascript:rowOver(this)"' 
            + ' onmouseout="javascript:rowOut(this)"'       
            + '>' 
            .
  */
END FUNCTION.


&ENDIF

