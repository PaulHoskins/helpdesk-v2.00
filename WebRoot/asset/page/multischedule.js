/*
	phoski 10/05/2015 initial
*/


function drawSchedule () {

	scheduler.config.readonly_form = true;
	//scheduler.config.readonly = true;

	/*
	scheduler.createTimelineView({
				name:	"timeline",
				x_unit:	"minute",
				x_date:	"%H:%i",
				x_step:	30,
				x_size: 24,
				x_start: 16,
				x_length:	48,
				y_unit:	sections,
				y_property:	"section_id",
				render:"bar"
			});
	*/
	scheduler.config.lightbox.sections=[
				{name:"description", height:16, map_to:"text", type:"textarea" , focus:true},
				{name:"Issue", height:16, map_to:"issue", type:"textarea" },
				{name:"Issue Desc", height:16, map_to:"bdesc", type:"textarea" },
				{name:"Engineer", height:16, map_to:"engname", type:"textarea" },
				//{name:"Engineer", height:23, type:"select", options:sections, map_to:"section_id" },
				{name:"Customer", height:16, map_to:"custname", type:"textarea" },


				{name:"time", height:72, type:"time", map_to:"auto"}
			];

     //block all modifications
	scheduler.attachEvent("onBeforeDrag",function(){return false;})
	scheduler.attachEvent("onClick",function(){return false;})
	scheduler.config.details_on_dblclick = true;
	scheduler.config.dblclick_create = false;

   //scheduler.config.buttons_left=["dhx_cancel_btn"];
   //scheduler.config.buttons_right = [];

	scheduler.locale.labels.year_tab ="Year";
	scheduler.config.year_x = 2; //2 months in a row
	scheduler.config.year_y = 6; //3 months in a column
	scheduler.init('scheduler_here', new Date(),"month");
	scheduler.parse(events, "json");
	
}