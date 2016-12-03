/***********************************************************************

    Program:        crm/customer-form-page.i
    
    Purpose:        Customer Maintenance - CRM Master Page   
    
    Notes:
    
    
    When        Who         What
    21/10/2016  phoski      Initial
    26/11/2016  phoski      Sales contact changes for adding new CRM
                            customer
    
   
***********************************************************************/

{&out} htmlib-StartTable("mnt",
    100,
    0,
    0,
    0,
    "center").
        
IF get-value("source") <> "crmview" THEN
DO:    
    {&out} 
        '<TR align="left"><TD VALIGN="TOP" ALIGN="right" width="25%">' 
        ( IF LOOKUP("accountnumber",lc-error-field,'|') > 0 
        THEN htmlib-SideLabelError("Account Number")
        ELSE htmlib-SideLabel("Account Number"))
        '</TD>' SKIP
        .
    
    IF lc-mode = "ADD" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left">'
            htmlib-InputField("accountnumber",8,lc-accountnumber) SKIP
            '</TD>'.
    ELSE
        {&out} htmlib-TableField(html-encode(lc-accountnumber),'left')
            SKIP.
    
    {&out} 
        '<td valign="top" align="right" >' SKIP
        '<div id="contracts" name="contracts" style="position:absolute;float:right;width:450px;right:20px;">&nbsp;' SKIP
        '</div>'
        '</td>' SKIP.
    
    
    
    {&out} 
        '</TR>' SKIP.
END.
    

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("name",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Name")
    ELSE htmlib-SideLabel("Name"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("name",40,lc-name) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-name),'left')
        SKIP.

{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("address1",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Address")
    ELSE htmlib-SideLabel("Address"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("address1",40,lc-address1) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-address1),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("address2",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("")
    ELSE htmlib-SideLabel(""))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("address2",40,lc-address2) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-address2),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("city",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("City/Town")
    ELSE htmlib-SideLabel("City/Town"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("city",40,lc-city) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-city),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("county",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("County")
    ELSE htmlib-SideLabel("County"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("county",40,lc-county) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-county),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("country",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Country")
    ELSE htmlib-SideLabel("Country"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("country",40,lc-country) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-country),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("postcode",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Post Code")
    ELSE htmlib-SideLabel("Post Code"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("postcode",20,lc-postcode) 
        '</TD>' SKIP.
    
{&out} 
    '</TR>' SKIP.
{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("website",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Web Site")
    ELSE htmlib-SideLabel("Web Site"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("website",40,lc-website) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-website),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.
    

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("contact",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Account Contact")
    ELSE htmlib-SideLabel("Account Contact"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("contact",40,lc-contact) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-contact),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("telephone",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Telephone")
    ELSE htmlib-SideLabel("Telephone"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("telephone",20,lc-telephone) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-telephone),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    htmlib-SideLabel("Account Status")
    '</TD>'.
 
IF NOT CAN-DO("view,delete",lc-mode) AND  get-value("source") <> "crmview" THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-Select("accstatus",lc-global-accStatus-code,lc-global-accStatus-code,lc-accstatus)
        '</TD>' SKIP.
ELSE 
    IF  get-value("source") = "crmview" THEN
        {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
            htmlib-Select("accstatus","CRM","CRM",lc-accstatus)
            '</TD>' SKIP.
    ELSE
        {&out} htmlib-TableField(lc-accStatus,'left')
            SKIP.
{&out} 
    '</TR>' SKIP.
    
   
{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("accountref",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Account Reference")
    ELSE htmlib-SideLabel("Account Reference"))
    '</TD>'.
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("accountref",15,lc-accountref) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-accountref),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.
    
{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("SalesManager",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Sales Rep")
    ELSE htmlib-SideLabel("Sales Rep"))
    '</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-Select("salesmanager",lc-sm-Code,lc-sm-desc,lc-SalesManager)
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(lc-SalesManager,'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("SalesContact",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Sales Contact")
    ELSE htmlib-SideLabel("Sales Contact"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
DO:
    
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'.
    
    IF lc-AddMode = "SimpleContact" THEN
    {&out} htmlib-InputField("salescontact",40,lc-salesContact).
    ELSE 
    {&out} htmlib-Select("salescontact",lc-cu-Code,lc-cu-desc,lc-salescontact).
    {&out}   
        '</TD>' SKIP.
END.
ELSE 
    {&out} htmlib-TableField(lc-salescontact,'left')
        SKIP.
{&out} 
    '</TR>' SKIP.
IF NOT CAN-DO("view,delete",lc-mode) AND lc-AddMode = "SimpleContact" THEN
DO:
    {&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("addEmail",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Email")
    ELSE htmlib-SideLabel("Email"))
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("addemail",80,lc-addEmail) '</td></tr>'.
    
     {&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("addMobile",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Mobile/Telephone")
    ELSE htmlib-SideLabel("Mobile/Telephone"))
    '</TD><TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
    htmlib-InputField("addmobile",15,lc-addMobile) '</td></tr>'.
    
        
END.
       
{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("noemp",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("No Of Employees")
    ELSE htmlib-SideLabel("No Of Employees"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("noemp",6,lc-noemp) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-noemp),'left')
        SKIP.

{&out} 
    '</TR>' SKIP.
    
{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("turn",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Annual Turnover")
    ELSE htmlib-SideLabel("Annual Turnover"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-InputField("turn",8,lc-turn) 
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(html-encode(lc-turn),'left')
        SKIP.

{&out} 
    '</TR>' SKIP.
        
{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("indsector",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Industry Sector")
    ELSE htmlib-SideLabel("Industry Sector"))
    '</TD>'.

IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-Select("indsector",lc-ind-Code,lc-ind-desc,lc-indsector)
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(lc-indsector,'left')
        SKIP.
{&out} 
    '</TR>' SKIP.

{&out} 
    '<TR><TD VALIGN="TOP" ALIGN="right">' 
    (IF LOOKUP("salesnote",lc-error-field,'|') > 0 
    THEN htmlib-SideLabelError("Sales Note")
    ELSE htmlib-SideLabel("Sales Note"))
    '</TD>'.
    
IF NOT CAN-DO("view,delete",lc-mode) THEN
    {&out} '<TD VALIGN="TOP" ALIGN="left" COLSPAN="2">'
        htmlib-TextArea("salesnote",lc-salesnote,5,60)
        '</TD>' SKIP.
ELSE 
    {&out} htmlib-TableField(REPLACE(html-encode(lc-salesnote),"~n",'<br>'),'left')
        SKIP.
{&out} 
    '</TR>' SKIP.
        
   
    
    
{&out} htmlib-EndTable() SKIP.
    