function crmButton(ButtonEvent, NewURL) {

	
	var FieldName = "firstrow"

	var pFirstRow = document.mainform.elements[FieldName].value

	FieldName = "lastrow"

	var pLastRow = document.mainform.elements[FieldName].value

	var pSearch = document.mainform.search.value

	var pAccount = document.mainform.account.value
    var pRep	= document.mainform.rep.value
    
	var pStatus = document.mainform.status.value
	
	var pType = document.mainform.type.value
	var plodate = document.mainform.lodate.value
	var phidate = document.mainform.hidate.value

	var psort = document.mainform.sort.value
	var psortorder = document.mainform.sortorder.value



	NewURL += "?search=" + pSearch
	NewURL += "&firstrow=" + pFirstRow
	NewURL += "&lastrow=" + pLastRow
	NewURL += "&navigation=" + ButtonEvent
	NewURL += "&account=" + pAccount
	NewURL += "&rep=" + pRep
	NewURL += "&status=" + pStatus
	NewURL += "&type=" + pType

	NewURL += "&hidate=" + phidate
	NewURL += "&lodate=" + plodate
	NewURL += "&sort=" + psort
	NewURL += "&sortorder=" + psortorder


	if (ButtonEvent == "add") {
		NewURL += "&mode=add"
	}
		
	this.location = NewURL

}
