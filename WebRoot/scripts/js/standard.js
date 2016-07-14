var HlpWinHdl = null
var PopUpWinHdl = null
var RepWinHdl = null
var LookupWinHdl = null

function ClosePage() {

	CloseHelpWindow()
	ClosePopUpWindow()
	CloseRepWindow()
	CloseLookupWindow()

}

function ClosePageRefreshParent() {

	var ParentWindow = opener
	var ParentLocation = ParentWindow.location

	ClosePage()

	ParentLocation += "&addnote=done"

	ParentWindow.location = ParentLocation

}

function LookupWindow(URL, FieldName, Desc) {

	var tim = new Date().valueOf();

	URL += "?FieldName=" + FieldName
	URL += "&Description=" + Desc
	URL += "&wsrndnum=" + Math.random()
        URL += "&wsrndtme=" + tim
	LookupWinHdl = window.open(URL,"LookupWindow","width=700,height=500,scrollbars=yes,resizable")
	LookupWinHdl.focus()

}

function CloseLookupWindow () {

	if (LookupWinHdl == null)
	        return

	if (LookupWinHdl.closed)
	        return

    	LookupWinHdl.close()
}

function HelpWindow(HelpPageURL) {

	HlpWinHdl = window.open(HelpPageURL,"HelpWindow","width=700,height=500,scrollbars=yes,resizable")
	HlpWinHdl.focus()

}

function CloseHelpWindow () {

	if (HlpWinHdl == null)
	        return

	if (HlpWinHdl.closed)
	        return

    	HlpWinHdl.close()
}


function PopUpWindow(HelpPageURL) {

	PopUpWinHdl = window.open(HelpPageURL,"PopupWindow","width=700,height=500,scrollbars=yes,resizable")
	PopUpWinHdl.focus()

}

function ClosePopUpWindow () {

	if (PopUpWinHdl == null)
	        return

	if (PopUpWinHdl.closed)
	        return

    	PopUpWinHdl.close()
}

function OpenNewWindow(URL) {
	var WindowHdl = null
	WindowHdl = window.open(URL,"NewWindow","width=600,height=400,menubar=yes,statusbar=yes,scrollbars=yes,resizable")
	WindowHdl.focus()

}

function RepWindow(HelpPageURL) {

	RepWinHdl = window.open(HelpPageURL,"ReportWindow","width=700,height=500,scrollbars=yes,resizable")
	RepWinHdl.focus()

}

function CloseRepWindow () {

	if (RepWinHdl == null)
	        return

	if (RepWinHdl.closed)
	        return

    	RepWinHdl.close()
}

function SubmitThePage(SubmitValue) {
	var FieldName = "submitsource"
	document.mainform.elements[FieldName].value = SubmitValue
	document.mainform.submit()

}

function ahahBegin(target) {

   if ( document.getElementById(target).innerHTML == "" )
   {
   	document.getElementById(target).innerHTML = '<img src="/images/ajax/load.gif" border=0">'
   }

}

function ahah(url,target) {
// native XMLHttpRequest object
   var RandomTime = new Date().valueOf()
   url = url + "&RandMath=" + Math.random()
   url = url + "&RandomTime=" + RandomTime
   ahahBegin(target)
   if (window.XMLHttpRequest) {
       req = new XMLHttpRequest();
       req.onreadystatechange = function() {ahahDone(target);};
       req.open("GET", url, true);
       req.send(null);
   // IE/Windows ActiveX version
   } else if (window.ActiveXObject) {
       req = new ActiveXObject("Microsoft.XMLHTTP");
       if (req) {
           req.onreadystatechange = function() {ahahDone(target);};
           req.open("GET", url, true);
           req.send();
       }
   }
}

function ahahPost(url,target) {
// native XMLHttpRequest object

if (window.XMLHttpRequest) {
       req = new XMLHttpRequest();
       req.onreadystatechange = function() {ahahDone(target);};
       req.open("POST", url, true);
       req.send(null);
   // IE/Windows ActiveX version
   } else if (window.ActiveXObject) {
       req = new ActiveXObject("Microsoft.XMLHTTP");
       if (req) {
           req.onreadystatechange = function() {ahahDone(target);};
           req.open("POST", url, true);
           req.send();
       }
   }
}

function ahahDone(target) {
   // only if req is "loaded"
   if (req.readyState == 4) {
       // only if "OK"
       if (req.status == 200 || req.status == 304) {
           results = req.responseText;
           document.getElementById(target).innerHTML = results;
       } else {
           document.getElementById(target).innerHTML = "";
       }
   }
}

var objRowSelected = null
var objRowInit = false
var objRowDefault = null

function rowInit () {

	if ( objRowInit ) {
		return
	}
	objRowInit = true

	var objtoolBarOption = document.getElementById("tboption")

	objRowDefault = objtoolBarOption.innerHTML


	return

}
function rowSelect (rowObject, rowToolIDName) {


	var objRowToolBar = document.getElementById(rowToolIDName)
	var objtoolBarOption = document.getElementById("tboption")

	rowInit()

	if ( objRowSelected != null ) {
		objRowSelected.className = "tabrow1"
	}

	if ( objRowSelected == rowObject ) {
		objRowSelected = null
		rowObject.className = "tabrow1"
		// Was space
		objtoolBarOption.innerHTML = objRowDefault

		return
	}

	rowObject.className = "tabrowselected"
	objRowSelected = rowObject

	objtoolBarOption.innerHTML = objRowToolBar.innerHTML


}

function rowOver (rowObject) {

	if ( objRowSelected != rowObject ) {
		rowObject.className = "tabrowover"
		return
	}
	rowObject.className = "tabrowselected"
}

function rowOut (rowObject) {

	if ( objRowSelected != rowObject ) {
		rowObject.className = "tabrow1"
		return
	}
	rowObject.className = "tabrowselected"

}

function AjaxSimpleDescription ( formField, AppURL , CompanyCode, FieldType, ObjectName ) {

	var fieldContent = escape(formField.value)

	var AjaxURL = AppURL
	AjaxURL += "/lib/ajaxsimplevalidate.p?simple=yes"
	AjaxURL += "&value=" + fieldContent
	AjaxURL += "&type=" + FieldType
	AjaxURL += "&companycode=" + CompanyCode

	ahah(AjaxURL,ObjectName)



}

function GrowOver (rowObject) {


	rowObject.className = "overbargraph"
}

function GrowOut (rowObject) {


	rowObject.className = "bargraph"

}
// NEW STUFF - DJS 2010-2011 ///////////////////////////////////////////////////////////////////////////////


// MOVE UP
function SMoveUp (currObj)
{
	var switchObj = parseInt(currObj) - 1;
	var newObj = document.getElementById("contract" + currObj);
	var oldObj = document.getElementById("contract" + switchObj);
	var submitObj = document.getElementById("savedcontracts");
	var newChg = newObj.value;
	var oldChg = oldObj.value;
	submitObj.value = SwapString(submitObj.value,currObj,oldChg,switchObj,newChg);
	for (var i=0; i < newObj.length; i++)
	{
	 if (newObj[i].value == oldChg)
	 {
	  newObj[i].selected = true;
	 }
	}
	for (var i=0; i < oldObj.length; i++)
	{
	 if (oldObj[i].value == newChg)
	 {
	  oldObj[i].selected = true;
	 }
	}
}


// MOVE DOWN
function SMoveDown (currObj)
{
	var switchObj = parseInt(currObj) + 1;
	var newObj = document.getElementById("contract" + switchObj);
	var oldObj = document.getElementById("contract" + currObj);
	var submitObj = document.getElementById("savedcontracts");
	var newChg = newObj.value;
	var oldChg = oldObj.value;
	submitObj.value = SwapString(submitObj.value,currObj,oldChg,switchObj,newChg);
	for (var i=0; i < newObj.length; i++)
	{
	 if (newObj[i].value == oldChg)
	 {
	  newObj[i].selected = true;
	 }
	}
	for (var i=0; i < oldObj.length; i++)
	{
	 if (oldObj[i].value == newChg)
	 {
	  oldObj[i].selected = true;
	 }
	}
}


// SWAP STRINGS
function SwapString (oldString,newHash,newTxt,oldHash,oldTxt)
{
  var TxtArray = oldString.split('|');
  for(var i = 0 ; i < TxtArray.length ; i++)   {
    if(i + 1 == newHash) { TxtArray[i] = newTxt }
    if(i + 1 == oldHash) { TxtArray[i] = oldTxt }
  }
  return TxtArray.join("|");
}



// ACTION DEFCON
function SDefCon (currObj)
{
  var submitObj = document.getElementById("saveddefcons");
  var list = submitObj.value;
  var TxtArray = list.split('|');
  for(var i = 0 ; i < TxtArray.length ; i++)
  {
    if(i + 1 == currObj) { TxtArray[i] = "yes"; document.getElementById("defcon" + (i + 1)).checked = true; }
    if(i + 1 != currObj) { TxtArray[i] = "no"; document.getElementById("defcon" + (i + 1)).checked = false; }
  }
  var newlist = TxtArray.join("|");
  submitObj.value = newlist;
}


// ACTION BILLABLE
function SBillable (currObj)
{
  var submitObj = document.getElementById("savedbillables");
  var list = submitObj.value;
  var TxtArray = list.split('|');
  for(var i = 0 ; i < TxtArray.length ; i++)
  {
    if(i + 1 == currObj) { TxtArray[i] = document.getElementById("billable" + currObj).checked ? "yes" : "no" }
  }
  var newlist = TxtArray.join("|");
  submitObj.value = newlist;
}

// ACTION ACTIVE CONTRACT
function SConActive (currObj)
{
  var submitObj = document.getElementById("savedconactives");
  var list = submitObj.value;
  var TxtArray = list.split('|');
  for(var i = 0 ; i < TxtArray.length ; i++)
  {
    if(i + 1 == currObj) { TxtArray[i] = document.getElementById("conactive" + currObj).checked ? "yes" : "no" }
  }
  var newlist = TxtArray.join("|");
  submitObj.value = newlist;
}


// CHANGE CONTRACT
function SContract (intId,strValue)
{
  var submitObj = document.getElementById("savedcontracts");
  var list = submitObj.value;
  var nums = parseInt(intId) - 1;
  var TxtArray = list.split('|');
  TxtArray[nums]=strValue;
  var newlist = TxtArray.join("|");
  submitObj.value = newlist;
}

// CHANGE NOTES
function SNotes (intId,strValue)
{
  var submitObj = document.getElementById("savedconnotes");
  var list = submitObj.value;
  var nums = parseInt(intId) - 1;
  var TxtArray = list.split('|');
  TxtArray[nums]=strValue;
  var newlist = TxtArray.join("|");
  submitObj.value = newlist;
}

// CHANGE BILLABLE
function SBillable2 (intId,strValue)
{
  var submitObj = document.getElementById("savedbillables");
  var list = submitObj.value;
  var nums = parseInt(intId) - 1;
  var TxtArray = list.split('|');
  TxtArray[nums]=strValue;
  var newlist = TxtArray.join("|");
  submitObj.value = newlist;
}


// ADD CONTRACT
function addContract(newCon,newNote,newBill,newDefCon,newActive)
{
  var newlistC;
  var newlistN;
  var newlistB;
  var newlistD;
  var newlistA;
  var submitObjC = document.getElementById("savedcontracts");
  var submitObjN = document.getElementById("savedconnotes");
  var submitObjB = document.getElementById("savedbillables");
  var submitObjD = document.getElementById("saveddefcons");
  var submitObjA = document.getElementById("savedconactives");
  var submitObjT = document.getElementById("totalcontracts");
  var listC = submitObjC.value;
  var listN = submitObjN.value;
  var listB = submitObjB.value;
  var listD = submitObjD.value;
  var listA = submitObjA.value;
  var listT = submitObjT.value;

  if ( listC == "" )
  {
	  newlistC = newCon;
	  newlistN = newNote;
	  newlistB = newBill;
	  newlistD = newDefCon;
	  newlistA = newActive;
  }
  else
  {
	  var TxtArrayC = listC.split('|');
	  var TxtArrayN = listN.split('|');
	  var TxtArrayB = listB.split('|');
	  var TxtArrayD = listD.split('|');
	  var TxtArrayA = listA.split('|');
	  TxtArrayC.push(newCon);
	  TxtArrayN.push(newNote);
	  TxtArrayB.push(newBill);
	  TxtArrayD.push(newDefCon);
	  TxtArrayA.push(newActive);
	  newlistC = TxtArrayC.join("|");
	  newlistN = TxtArrayN.join("|");
	  newlistB = TxtArrayB.join("|");
	  newlistD = TxtArrayD.join("|");
	  newlistA = TxtArrayA.join("|");
  }
  var newlistT = parseInt(listT) + 1;
  submitObjC.value = newlistC;
  submitObjN.value = newlistN;
  submitObjB.value = newlistB;
  submitObjD.value = newlistD;
  submitObjA.value = newlistA;
  submitObjT.value = newlistT;

}

// ADD SCONTRACT
function SAddContract (currObj)
{
  var addObj = document.getElementById("totalcontracts").value;
  addObj = parseInt(addObj) + 1;
  var newValC = document.getElementById("contract" + currObj).value;
  var newValN = document.getElementById("cnotes" + currObj).value;
  var newValB = document.getElementById("billable" + currObj).checked ? "yes" : "no" ;
  var newValD = document.getElementById("defcon" + currObj).checked ? "yes" : "no" ;
  var newValA = document.getElementById("conactive" + currObj).checked ? "yes" : "no" ;

 addContract(newValC,newValN,newValB,newValD,newValA);

 SMoveNewUp (addObj,newValC,newValN,newValB,newValD,newValA);

  if (addObj < 10)
  {
	 document.getElementById("contract" + currObj).selectedIndex = 0;
	 document.getElementById("cnotes" + currObj).value = "" ;
	 document.getElementById("conactive" + currObj).checked = true ;
	 document.getElementById("billable" + currObj).checked = false ;
	 document.getElementById("defcon" + currObj).checked = false ;
  }
  else
  {
	  document.getElementById("DD20").style.display = 'none';
   }

     if (newValD == "yes") { SDefCon (addObj); }
	 displayBalloon('balloon','on',"Contract Added Successfully");
}


// MOVE NEW ONE UP
function SMoveNewUp (addObj,newValC,newValN,newValB,newValD,newValA)
{
	var changeObj = document.getElementById("DD" + addObj);
	changeObj.style.display = "block";
	document.getElementById("contract" + addObj).value = newValC ;
	document.getElementById("cnotes" + addObj).value = newValN  ;
	document.getElementById("billable" + addObj).checked = (newValB == "yes") ? true : false;
	document.getElementById("defcon" + addObj).checked = (newValD == "yes") ? true : false;
	document.getElementById("conactive" + addObj).checked = (newValA == "yes") ? true : false;
}



// ACTION CONTRACT NOTES
function SNewContract (currObj)
{
  var thisObj = "contract" + currObj;
  var s = document.getElementById(thisObj);
  var selectedObj = s.selectedIndex - 1;
  var notesObj = document.getElementById("contractnotes");
  var notesList = notesObj.value;
  var notesArray = notesList.split('|');

  var billObj = document.getElementById("contractbilling");
  var billList = billObj.value;
  var billArray = billList.split('|');

  for(var y = 0; y < notesList.length; y++)
  {
    if (y == selectedObj)
    {
		document.getElementById("cnotes" + currObj).value = notesArray[y];
        document.getElementById("billable" + currObj).checked = ((billArray[y] == "yes") ? true : false)
    };
  }
}



// REMOVE CONTRACT
function SRemove (Rdx)
{
	if (Rdx.parentNode&&Rdx.parentNode.id)
	var pid=Rdx.parentNode.id;

	Idx = parseInt(pid.substring(2));
	Cid = parseInt(Rdx.id.substring(2));

  var submitObj = document.getElementById("savedcontracts");
  var list = submitObj.value;
  var IdxLeft = 0;
  var values = list.split("|");
  for(var i = 0 ; i < values.length ; i++)
  {
    if(i == parseInt(Cid) - 1 )
    {
      values[i] = "NONE"  //.splice(i, 1);
    }
  }
  var newList = values.join("|");
  submitObj.value = newList;
  var RMObj = document.getElementById("contract" + Cid);
  RMObj.options.length = 0;
  var TotalList = parseInt(document.getElementById("totalcontracts").value,10);
  for(var y = parseInt(Idx) ; y < TotalList + 1; y++)
  {
    var z = y + 1;
    var newInner = "";
    if (document.getElementById("DD" + z)) { newInner = document.getElementById("DD" + z).innerHTML };
    if (document.getElementById("DD" + y)) { document.getElementById("DD" + y).innerHTML = newInner };
    IdxLeft = y;
  }
  if (document.getElementById("DD" + IdxLeft)) { document.getElementById("DD" + IdxLeft).style.display = "none"} ;
  TotalList = TotalList - 1;
  document.getElementById("totalcontracts").value = TotalList;
  document.getElementById("DD20").style.display = 'none';  //  temp measure to stop ****
}


// CHANGE CONTRACT
function ChangeContract()
{
	var submitObj = document.getElementById("contract");
	var billingObj = document.getElementById("billcheck");
	var ContractObj = document.getElementById("selectcontract");
	var list = ContractObj.value;
	var TxtArray = list.split("|");
	submitObj.value = TxtArray[0];
	document.getElementById("billcheck").checked = ((TxtArray[1] == "yes") ? true : false)  ;
	ChangeBilling(billingObj);
}


// CHANGE BILLING
function ChangeBilling (currObj)
{
	var submitObj = document.getElementById("billable");
	var newlist = currObj.checked ? "on" : "";
	submitObj.value = newlist;
}



// DISPLAY 'BALLOON' MESSAGE
function displayBalloon(id,toggle,text)
{
  if (toggle == "on")
  {
    document.getElementById(id).innerHTML = text;
    document.getElementById(id).style.display = "inline";
  }
  else
  {
    document.getElementById(id).style.display = "none";
  }
}

// ACTION ACTIVITY TYPES
function ChangeActivityDesc(Indx)
{
	if ( Indx == null || Indx == 0 ) Indx = ""
	var tFA = Indx + "actdescription";
	var djs = document.getElementById(tFA).value;
	//alert(djs);
	document.getElementById(tFA).value = djs;

}



// ACTION ACTIVITY TYPES
function ChangeActivityType(Indx)
{
  if ( Indx == null || Indx == 0 ) Indx = ""
  var thisObj = Indx + "activitytype" ;
  var s = document.getElementById(thisObj);
  var selectedObj = s.selectedIndex ;
  var descObj = document.getElementById("actDesc");
  var descList = descObj.value;
  var descArray = descList.split('|');
  var actIDObj = document.getElementById("actID");
  var actIDList = actIDObj.value;
  var actIDArray = actIDList.split('|');
  var timeObj = document.getElementById("actTime");
  var timeList = timeObj.value;
  var timeArray = timeList.split('|');
  var thisForm;
  var tFM = "ff" + Indx + "mins";
  var tFA = Indx + "actdescription";
  var tFS = Indx + "savedactivetype";
  var tFX = "mainform" + (Indx < 10 ? "0" : "") + Indx  ;
  var tFZ = Indx + "manualTime"  ;
  var manTime = "";
  var txtMatch	= 0;
  var txtSaved  = parseInt(document.getElementById(tFS).value,10) ;
  var txtPicked = actIDArray[selectedObj];


  var djs = document.getElementById(tFA).value;

 //  lc-list-actid     = 1|15|17|19|21|23|25|27|29|31|33|35|37|39
 //  lc-list-activtype = Take Call|Travel To|Travel From|Meeting|Telephone Call|Survey|Config/Install|Diagnosis|Project Work|Research|Testing|Client Take-On|Administration|Other
 //  lc-list-activdesc = Logging Issue|Travelling to Client|Travelling from Client|Meeting with Client|Telephone Contact with Client|Network/Site Survey|Configuration and Installation|Diagnosis of Problem|Project Work|Research|Testing|Client Take-On|Administration|Other
 //  lc-list-activtime = 5|1|1|1|1|1|1|1|1|1|1|1|1|1


  for(var y = 0; y <= descList.length; y++)
  {
	if (document.getElementById(tFA).value == descArray[y]) { txtMatch = actIDArray[y]; };
  }

  if ( document.forms["mainform"] ) { thisForm = document.forms["mainform"];}
  else { thisForm = document.forms[tFX];}


  if ( thisForm.elements[tFZ] ) { manTime =  thisForm.elements[tFZ].checked ? "yes" : "no"; }
  else { manTime = "yes"; }

  for(var y = 0; y < descList.length; y++)
  {
    if (y == selectedObj)
	{
		if ( txtSaved != 0 || ( txtMatch == 0 || txtMatch == txtSaved ) )
		{
			//alert("IN IF  " + txtMatch +  "  -  " +  y);
			var answer = confirm("Do you want to change the Activity description as well?\n                 (Cancel for no change)");
			if (answer) { document.getElementById(tFA).value = descArray[y];  }
		}
		else
		{
			//alert("IN ELSE  " + txtMatch +  "  -  " +  y);
			document.getElementById(tFA).value = descArray[y];
		}
		if ( document.getElementById(tFM).value <= parseInt(timeArray[y],10) || manTime == "no" )
		{
			defaultTime = parseInt(timeArray[y],10);
		}
		else
		{
			defaultTime = parseInt(document.getElementById(tFM).value,10);
		}
	}
  }
  if ( document.getElementById(tFS) ) document.getElementById(tFS).value = s.value;
  if ( document.getElementById("defaultTime") ) document.getElementById("defaultTime").value = defaultTime;
  if ( document.getElementById("timeMinuteSet") ) document.getElementById("timeMinuteSet").value = timeMinuteSet;
  if ( document.getElementById("clockface") ) document.getElementById("clockface").innerHTML =  ((timeHourSet  < 10) ? "0" : "") + timeHourSet + ((defaultTime < 10) ? ":0" : ":") + defaultTime  + ":"  + "00"
  if ( document.getElementById(tFM) ) document.getElementById(tFM).value = (defaultTime < 10 ? "0" : "") + defaultTime ;
}


// CHANGE REPORT TYPE
function ChangeReportType (objVar)
{
	if ( objVar == "eng" )
	{
		document.getElementById("customerdiv").style.display = 'none';
    //document.getElementById("sortbox").style.display = 'none';
		document.getElementById("engineerdiv").style.display = 'block';
	}
	else
	{
		document.getElementById("engineerdiv").style.display = 'none';
   //document.getElementById("sortbox").style.display = 'block';
		document.getElementById("customerdiv").style.display = 'block';
	}
}


// CHANGE REPORT PERIOD
function ChangeReportPeriod (objVar)
{
	if ( objVar == "week" )
	{
		document.getElementById("monthdiv").style.display = 'none';
		document.getElementById("weekdiv").style.display = 'block';
	}
	else
	{
		document.getElementById("weekdiv").style.display = 'none';
		document.getElementById("monthdiv").style.display = 'block';
	}
}

// ALERT ME
function alertMe(varObj)
{
	if (varObj == "" ) alert("HERE");
	else alert(varObj);
}

//function showHours(varObj)
//{
//	document.getElementById("weekdiv" + varObj).style.display = 'block';
//	document.getElementById("innerdiv" + varObj).innerHTML = '<div id="innerdiv' + varObj + '"  onclick="javascript:updateHours('  + varObj + ');event.cancelBubble=true;" >Commit</div> </td>';
//	forceDisplay("mainform","20","weekdiv" + varObj) ;
//}

// UPDATE HOURS
function updateHours(varObj)
{
	document.mainform.elements["mode"].value = "updateweek";
	document.mainform.elements["submitweek"].value = varObj;

	for(var i = 1 ; i < 8 ; i++)
    {
		var FieldName = "submitday" + i;
		document.mainform.elements[FieldName].value = document.getElementById("weekno" + varObj + "-0" + i).value;
		var FieldName = "submitreason" + i;
		document.mainform.elements[FieldName].value = document.getElementById("reasonno" + varObj + "-0" + i).value;
	}
	document.mainform.submit();
	document.getElementById("weekdiv" + varObj).style.display = 'none';
}

// CHANGE YEAR
function changeYear(varObj)
{

	if (varObj != null)
	{
		document.mainform.elements["mode"].value = "updateyear";
		document.mainform.elements["submityear"].value = varObj.value;
		document.mainform.submit();

	}
	else
	{
		document.getElementById("chgyear").innerHTML = document.getElementById("hiddenyeardiv").innerHTML;
		document.getElementById("chgyear").style.display = "inline";
		document.getElementById("chgyear").onclick = "";
	}
}




//  END OF NEW STUFF

