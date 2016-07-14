


var hdcontractsymbol='/images/general/minus.gif' //Path to image to represent contract state.
var hdexpandsymbol='/images/general/plus.gif' //Path to image to represent expand state.


function hdexpandcontent(curobj, cid){
	
//if (ccollect.length>0){
document.getElementById(cid).style.display=(document.getElementById(cid).style.display!="none")? "none" : ""
curobj.src=(document.getElementById(cid).style.display=="none")? hdexpandsymbol : hdcontractsymbol
//}
}

