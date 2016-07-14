
function replace(string,text,by) {
    var strLength = string.length, txtLength = text.length;
    if ((strLength == 0) || (txtLength == 0)) return string;

    var i = string.indexOf(text);
    if ((!i) && (text != string.substring(0,txtLength))) return string;
    if (i == -1) return string;

    var newstr = string.substring(0,i) + by;

    if (i+txtLength < strLength)
        newstr += replace(string.substring(i+txtLength,strLength),text,by);

    return newstr;
}

function MntButtonPress(ButtonEvent,NewURL) {
	 var tim = new Date().valueOf();

	 var FieldName = "firstrow"


	 var pFirstRow =  document.mainform.elements[FieldName].value

	 FieldName = "lastrow"

	 var pLastRow =  document.mainform.elements[FieldName].value


	 var pSearch =  document.mainform.search.value


         NewURL += "?search=" + pSearch
         NewURL += "&firstrow=" + pFirstRow
         NewURL += "&lastrow=" + pLastRow
         NewURL += "&navigation=" + ButtonEvent
         NewURL += "&wsrndnum=" + Math.random()
         NewURL += "&wsrndtme=" + tim

         if ( ButtonEvent == "add" ) {
         	NewURL += "&mode=add"
         }

         obj = document.getElementById("urlinfo")
         if ( obj == null ) {
         	this.location = NewURL
         	return
         }
         var u = document.getElementById("urlinfo").innerHTML
         var n = replace(u,'|','&')
         NewURL += n
         this.location = NewURL



}

function IssueButtonPress(ButtonEvent,NewURL) {

	 var FieldName = "firstrow"

	 var pFirstRow =  document.mainform.elements[FieldName].value

	 FieldName = "lastrow"

	 var pLastRow =  document.mainform.elements[FieldName].value


	 var pSearch =  document.mainform.search.value

	 var pAccount = document.mainform.account.value

	 var pStatus = document.mainform.status.value
	 var pAssign = document.mainform.assign.value
	 var pArea = document.mainform.area.value
	 var plodate = document.mainform.lodate.value
	 var phidate = document.mainform.hidate.value

     var psortfield = document.mainform.sortfield.value
     var psortorder = document.mainform.sortorder.value

     var piclass = document.mainform.iclass.value

     var paccountmanager = document.mainform.accountmanager.checked

     var paccm = ''
     if ( paccountmanager ) {
		 paccm='on'
	}

         NewURL += "?search=" + pSearch
         NewURL += "&firstrow=" + pFirstRow
         NewURL += "&lastrow=" + pLastRow
         NewURL += "&navigation=" + ButtonEvent
         NewURL += "&account=" + pAccount
         NewURL += "&status=" + pStatus
         NewURL += "&assign=" + pAssign
         NewURL += "&area=" + pArea
         NewURL += "&hidate=" + phidate
         NewURL += "&lodate=" + plodate
		 NewURL += "&sortfield=" + psortfield
		 NewURL += "&sortorder=" + psortorder
		 NewURL += "&iclass=" + piclass
		 NewURL += "&accountmanager=" + paccm




         if ( ButtonEvent == "add" ) {
         	NewURL += "&mode=add"
         }

         this.location = NewURL



}

function IssueViewButtonPress(ButtonEvent,NewURL) {


	 var FieldName = "firstrow"


	 var pFirstRow =  document.mainform.elements[FieldName].value

	 FieldName = "lastrow"

	 var pLastRow =  document.mainform.elements[FieldName].value


	 var pSearch =  document.mainform.search.value

	 var pStatus = document.mainform.status.value
	 var pArea = document.mainform.area.value


         NewURL += "?search=" + pSearch
         NewURL += "&firstrow=" + pFirstRow
         NewURL += "&lastrow=" + pLastRow
         NewURL += "&navigation=" + ButtonEvent
         NewURL += "&status=" + pStatus
         NewURL += "&area=" + pArea


         this.location = NewURL



}
