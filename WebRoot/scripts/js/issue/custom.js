var gBuild = 0;

var gbdone = false;

function actionExpand (curobj,cname) {
	var sn = "." + cname;
	var img = curobj.src;
	var open = img.indexOf('open');
	
	var detailinfo = $(sn);
	for(var i=0; i<detailinfo.length; i++){
    	var cid = detailinfo.eq(i);
   		cid.show()
    	if ( open == -1 ) {
				cid.hide()
		}
        	
	}
	
	sn = ".i" + cname;
	
	detailinfo = $(sn);
	for(var i1=0; i1<detailinfo.length; i1++){
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
function actionTableBuild () {
	ahah(ActionAjax,'IDAction')
}
function actionCreated () {
	actionTableBuild()
	ClosePopUpWindow()
}
function GanttContainer (iRecords, ih) {
	var $content = $('#gantt_here');
    $content.height(ih);
}
function ganttBuild () {
	//alert ("paul here = " + ganttURL);
	$.get(ganttURL, function(data, status){
       // alert("Data: " + data + "\nStatus: " + status);
        jQuery.globalEval( data );
        gBuild = gBuild + 1;
       
        gantt.config.row_height = 24;
		gantt.config.min_column_width = 50;
	    gantt.locale.labels.section_template = "Details";
    	gantt.config.lightbox.sections = [
        {name: "description", height: 16, map_to: "text", type: "textarea", focus: true},
        {name:"template", height:16, type:"template", map_to:"my_template"},
        {name: "time", type: "duration", map_to: "auto"}
    	];

		gantt.templates.scale_cell_class = function(date){
			if(date.getDay()==0||date.getDay()==6){
			return "weekend";
			}
		};
		gantt.templates.task_cell_class = function(item,date){
			if(date.getDay()==0||date.getDay()==6){
			return "weekend" ;
			}
		};

		gantt.config.columns = [
			{name:"text", label:"Phase/Action", width:"*", tree:true },
			{name:"start_time", label:"Start Date", template:function(obj){
				return gantt.templates.date_grid(obj.start_date);
			}, align: "center", width:60 },
			{name:"duration", label:"Duration", align:"center", width:60},
			{name:"add", label:"", width:44 }
		];

		gantt.config.grid_width = 390;
		gantt.config.date_grid = "%F %d";
		gantt.config.scale_height  = 60;
		gantt.config.subscales = [
			{ unit:"week", step:1, date:"Week #%W"}
		];


		(function(){
			gantt.config.font_width_ratio = 7;
			gantt.templates.leftside_text = function leftSideTextTemplate(start, end, task) {
				if (getTaskFitValue(task) === "left") {
					return task.text;
				}
				return "";
			};
			gantt.templates.rightside_text = function rightSideTextTemplate(start, end, task) {
				if (getTaskFitValue(task) === "right") {
					return task.text;
				}
				return "";
			};
			gantt.templates.task_text = function taskTextTemplate(start, end, task){
				if (getTaskFitValue(task) === "center") {
					return task.text;
				}
				return "";
			};

			function getTaskFitValue(task){
				var taskStartPos = gantt.posFromDate(task.start_date),
					taskEndPos = gantt.posFromDate(task.end_date);

				var width = taskEndPos - taskStartPos;
				var textWidth = (task.text || "").length * gantt.config.font_width_ratio;

				if(width < textWidth){
					var ganttLastDate = gantt.getState().max_date;
					var ganttEndPos = gantt.posFromDate(ganttLastDate);
					if(ganttEndPos - taskEndPos < textWidth){
						return "left"
					}
					else {
						return "right"
					}
				}
				else {
					return "center";
				}
			}
		})();

		// only declare functions on first build
		if (gBuild == 1) {

			gantt.attachEvent("onBeforeTaskDelete", function(id,item){
	    		var updurl = ganttupdURL;
		    	updurl += "&mode=delete";
		    	updurl += "&id=" + item.id;
		   
		    	$.get(updurl, function(data, status){
		        	//alert("Data: " + data + "\nStatus: " + status);
		        	jQuery.globalEval( data );
		        	gantt.clearAll();
		        	gantt.parse(tasks);
		        	if (igoto != 0) {
		        		gantt.selectTask(igoto);
		        	}


		    	});
	    		return false;
			});

		    gantt.attachEvent("onBeforeTaskAdd", function(id,item){
		    	//any custom logic here
		    	//var myObject = JSON.stringify(item);
		    	
		    	var updurl = ganttupdURL;
		    	updurl += "&mode=Add";
		    	updurl += "&parent=" + item.parent;
		    	updurl += "&text=" + item.text;
		    	updurl += "&start_date=" + item.start_date;
		    	updurl += "&duration=" + item.duration;

	    	
		    	$.get(updurl, function(data, status){
		        	//alert("Data: " + data + "\nStatus: " + status);
		        	jQuery.globalEval( data );
		        	gantt.clearAll();
		        	gantt.parse(tasks);
		        	gantt.selectTask(igoto);
		        	
		        	
		    	});

		    	
		    	return false;
			});
			gantt.attachEvent("onBeforeTaskUpdate", function(id,new_item){
    			//any custom logic here
    			    			
    			var updurl = ganttupdURL;
		    	updurl += "&mode=update";
		    	updurl += "&id=" + id;
		    	//updurl += "&parent=" + new_item.parent;
		    	updurl += "&text=" + new_item.text;
		    	updurl += "&start_date=" + new_item.start_date;
		    	updurl += "&duration=" + new_item.duration;
		    	

		    	$.get(updurl, function(data, status){
		        	//alert("Data: " + data + "\nStatus: " + status);
		        	jQuery.globalEval( data );
		        	gantt.clearAll();
		        	gantt.parse(tasks);
		        	gantt.selectTask(igoto);
		        	
		        	//alert("redraw done");

		    	});


    			return false;
			});
			gantt.attachEvent("onBeforeLinkAdd", function(id,link){
    			//any custom logic here
    			dhtmlx.alert("Link not allowed");
    			return false;
			});


			gantt.attachEvent("onBeforeLightbox", function(id) {
		    var task = gantt.getTask(id);
		    if ( task.datatype == "PH") {
		    	dhtmlx.message({type:"error", text:"You can not edit a project phase"});
		   		return false; 	
		    }
		    task.my_template = "<span id='title1'>Engineer(s): </span>"+ task.users + "<span id='title2'>  Duration: </span>"+ task.cduration;
		    return true;
			});
			gantt.init("gantt_here");
		}
	   
	    gantt.clearAll();
	    gantt.parse(tasks);
	    
	        
    });

}
function mainPageBuild () {
	var FieldName = "currentstatus"
	var pvalue =  document.mainform.elements[FieldName].value
	var callURL = ''
	callURL = ActionBox1URL
	callURL += "&currentstatus=" + pvalue
	ahah(callURL,'actionbox1')
}


var tabberOptions = {
	'onClick':function(argsObj) {
		var t = argsObj.tabber; /* Tabber object */
		var i = argsObj.index; /* Which tab was clicked (0..n) */
    		var div = this.tabs[i].div; /* The tab content div */

    		if ( i == 0 ) {
				mainPageBuild()
			}
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
    		}
    		if ( i == 5 ) {
    			customerInfo()
    			return
    		}
    		if ( i == 6 ) {
    			if (gbdone == false) {
    				//alert("paul build");
    				ganttBuild();
    				gbdone = true;
    			}
    			return

    		}

	}
};