function LookupButtonPress(ButtonEvent,NewURL) {

	  
	 var FieldName = "firstrow"
	 
	 
	 var pFirstRow =  document.mainform.elements[FieldName].value
	 
	 FieldName = "lastrow"
	 
	 var pLastRow =  document.mainform.elements[FieldName].value
	 
	 FieldName = "fieldname"
	 
	 var pFieldName =  document.mainform.elements[FieldName].value
	 
	 FieldName = "description"
	 	 
	 var pDescription =  document.mainform.elements[FieldName].value
	 	 	 
	 var pSearch =  document.mainform.search.value
	 
	                  
         NewURL += "?search=" + pSearch
         NewURL += "&firstrow=" + pFirstRow
         NewURL += "&lastrow=" + pLastRow
         NewURL += "&navigation=" + ButtonEvent
         NewURL += "&fieldname=" + pFieldName
         NewURL += "&description=" + pDescription
         
         
         
         this.location = NewURL
         
         

}