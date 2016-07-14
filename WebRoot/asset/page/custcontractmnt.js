/*
	phoski 07/06/2015 initial
*/
function changeSelectType () {


	var copy = document.getElementById("contractcode");
	var dest = document.getElementById("descr");
	var copytext = copy.options[copy.selectedIndex].text;
	dest.value = copytext;
	
	
}