function actionTableBuild () {
	ahah(ActionAjax,'IDAction')
}

function initialise() {
	
	alert ("paulh");
	actionTableBuild();
	
	alert ("paulh ok");

}

$(document).ready( function() {
	initialise();
});