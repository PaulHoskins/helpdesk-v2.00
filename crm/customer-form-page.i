/***********************************************************************

    Program:        crm/customer-form-page.i
    
    Purpose:        Customer Maintenance - CRM Master Page   
    
    Notes:
    
    
    When        Who         What
    21/10/2016  phoski      Initial
    
   
***********************************************************************/

    {&out} htmlib-StartTable("mnt",
        100,
        0,
        0,
        0,
        "center").
        
    IF get-value("source") <> "crmview" THEN
    DO:    
        {&out} '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
            ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
            THEN htmlib-SideLabelError("Account Number")
            ELSE htmlib-SideLabel("Account Number"))
        '</TD>' skip
        .
    
        IF lc-mode = "ADD" THEN
            {&out} '<TD VALIGN="TOP" ALIGN="left">'
        htmlib-InputField("accountnumber",8,lc-accountnumber) skip
               '</TD>'.
        else
        {&out} htmlib-TableField(html-encode(lc-accountnumber),'left')
               skip.
    
        {&out} '<td valign="top" align="right" >' skip
               '<div id="contracts" name="contracts" style="position:absolute;float:right;width:450px;right:20px;">&nbsp;' skip
               '</div>'
               '</td>' skip.
    
    
    
        {&out} '</TR>' skip.
    END.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("name",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Name")
        ELSE htmlib-SideLabel("Name"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("name",40,lc-name) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-name),'left')
           skip.

    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address1",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Address")
        ELSE htmlib-SideLabel("Address"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("address1",40,lc-address1) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-address1),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("address2",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("")
        ELSE htmlib-SideLabel(""))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("address2",40,lc-address2) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-address2),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("city",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("City/Town")
        ELSE htmlib-SideLabel("City/Town"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("city",40,lc-city) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-city),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("county",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("County")
        ELSE htmlib-SideLabel("County"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("county",40,lc-county) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-county),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("country",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Country")
        ELSE htmlib-SideLabel("Country"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("country",40,lc-country) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-country),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("postcode",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Post Code")
        ELSE htmlib-SideLabel("Post Code"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("postcode",20,lc-postcode) 
    '</TD>' skip.
    
    {&out} '</TR>' skip.
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("website",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Web Site")
        ELSE htmlib-SideLabel("Web Site"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("website",40,lc-website) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-website),'left')
           skip.
    {&out} '</TR>' skip.
    

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("contact",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Contact")
        ELSE htmlib-SideLabel("Contact"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("contact",40,lc-contact) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-contact),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("telephone",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Telephone")
        ELSE htmlib-SideLabel("Telephone"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("telephone",20,lc-telephone) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-telephone),'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Account Status")
    '</TD>'.
 
    IF NOT CAN-DO("view,delete",lc-mode) AND  get-value("source") <> "crmview" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("accstatus",lc-global-accStatus-code,lc-global-accStatus-code,lc-accstatus)
    '</TD>' skip.
    else 
    IF  get-value("source") = "crmview" THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("accstatus","CRM","CRM",lc-accstatus)
    '</TD>' skip.
    else
    {&out} htmlib-TableField(lc-accStatus,'left')
           skip.
    {&out} '</TR>' skip.
    
   
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("accountref",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Reference")
        ELSE htmlib-SideLabel("Account Reference"))
    '</TD>'.
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("accountref",15,lc-accountref) 
    '</TD>' skip.
    else 
 {&out} htmlib-TableField(html-encode(lc-accountref),'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("SalesManager",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Sales Rep")
        ELSE htmlib-SideLabel("Sales Rep"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("salesmanager",lc-sm-Code,lc-sm-desc,lc-SalesManager)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-SalesManager,'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Sales Contact")
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("salescontact",lc-cu-Code,lc-cu-desc,lc-salescontact)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-salescontact,'left')
           skip.
    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("noemp",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("No Of Employees")
        ELSE htmlib-SideLabel("No Of Employees"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("noemp",6,lc-noemp) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-noemp),'left')
           skip.

    {&out} '</TR>' skip.
    
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("turn",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Annual Turnover")
        ELSE htmlib-SideLabel("Annual Turnover"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("turn",8,lc-turn) 
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(html-encode(lc-turn),'left')
           skip.

    {&out} '</TR>' skip.
        
    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("indsector",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Industry Sector")
        ELSE htmlib-SideLabel("Industry Sector"))
    '</TD>'.

    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-Select("indsector",lc-ind-Code,lc-ind-desc,lc-indsector)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(lc-indsector,'left')
           skip.
    {&out} '</TR>' skip.

    {&out} '<TR><TD VALIGN="TOP" ALIGN="right">' 
        (IF LOOKUP("salesnote",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Sales Note")
        ELSE htmlib-SideLabel("Sales Note"))
    '</TD>'.
    
    IF NOT CAN-DO("view,delete",lc-mode) THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-TextArea("salesnote",lc-salesnote,5,60)
    '</TD>' skip.
    else 
    {&out} htmlib-TableField(replace(html-encode(lc-salesnote),"~n",'<br>'),'left')
           skip.
    {&out} '</TR>' skip.
        
   
    
    
    {&out} htmlib-EndTable() skip.
    