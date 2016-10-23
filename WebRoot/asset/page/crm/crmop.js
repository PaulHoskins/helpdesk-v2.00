function actionExpand(curobj, cname) {
	var sn = "." + cname;
	var img = curobj.src;
	var open = img.indexOf('open');

	var detailinfo = $(sn);
	for ( var i = 0; i < detailinfo.length; i++) {
		var cid = detailinfo.eq(i);
		cid.show()
		if (open == -1) {
			cid.hide()
		}

	}

	sn = ".i" + cname;

	detailinfo = $(sn);
	for ( var i1 = 0; i1 < detailinfo.length; i1++) {
		cid = detailinfo.eq(i1);
		cid.attr('src', img);

	}

}
function noteTableBuild () {
	ahah(NoteAjax,'IDNoteAjax')
}
function noteAdd () {
	PopUpWindow(NoteAddURL)
}
function noteCreated () {
	noteTableBuild()
}
function customerInfo () {
	ahah(CustomerAjax,'IDCustomerAjax')
}


function actionTableBuild() {
	ahah(ActionAjax, 'IDAction')
}

function actionCreated() {
	actionTableBuild()
	ClosePopUpWindow()
}
function documentTableBuild () {
	ahah(DocumentAjax,'IDDocument')
}
function documentAdd () {
	PopUpWindow(DocumentAddURL)
}
function documentCreated () {
	documentTableBuild()
	ClosePopUpWindow()
}


function initialise() {
	actionTableBuild();
	documentTableBuild();
}
function ChangeAccount() {
	var pAccount = document.mainform.account.value
	
	
	$("#box1").hide();
	$("#box2").hide();
	if ( pAccount == "ADD" ) {
		$("#box1").show();
		$("#box2").show();
	}
}

$(document).ready( function() {
	//initialise();
});
var tabberOptions = {
		'onClick':function(argsObj) {
			var t = argsObj.tabber; /* Tabber object */
			var i = argsObj.index; /* Which tab was clicked (0..n) */
	    		var div = this.tabs[i].div; /* The tab content div */

	    		
	    		if ( i == 1 ) {
	    			actionTableBuild()
	    			return
	    		}
	    		if ( i == 2 ) {	/* Notes */
	    			noteTableBuild()
	    			return
	    		}	    		
	    		if ( i == 3 ) {
				documentTableBuild()
					return
	    		}
	    		if ( i == 4 ) {
	    			customerInfo()
	    			return
	    		}
	    		
	    	

		}
	};
