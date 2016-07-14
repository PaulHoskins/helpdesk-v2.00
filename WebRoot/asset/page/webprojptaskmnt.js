/*
	phoski 29/03/2015 initial
*/
function changeSelectTask () {

	var copy = document.getElementById("copytask");
	var dest = document.getElementById("ffdescription");
	var copytext = copy.options[copy.selectedIndex].text;
	
	if ( copy.value != '') {
		dest.value = copytext;
	}

	
}