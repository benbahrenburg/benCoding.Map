var win = Titanium.UI.currentWindow;
var flexSpace = Ti.UI.createButton({ systemButton:Ti.UI.iPhone.SystemButton.FLEXIBLE_SPACE });

//Bring the module into the example
var map = require('bencoding.map');

//Create mapView
//We support all of the same functions the native Ti.Map.View does
var mapView = map.createView({
	mapType: Ti.Map.STANDARD_TYPE,
	animate:true, 
	userLocation:true
});

//Add to Window
win.add(mapView);

var bZoomIn = Ti.UI.createButton({
	title:'+', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bZoomOut = Ti.UI.createButton({
	title:'-', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bZoomIn.addEventListener('click',function() {
	mapView.zoom(1);
});

bZoomOut.addEventListener('click',function() {
	mapView.zoom(-1);
});

var zoomControl = Titanium.UI.iOS.createToolbar({
	items:[bZoomIn,bZoomOut],
	top:0,width:70,left:0, borderRadius:5,
	borderTop:true, borderBottom:false, translucent:true
});	
win.add(zoomControl);

var bAddKML = Ti.UI.createButton({
	title:'Load KML', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bRemoveKML = Ti.UI.createButton({
	title:'Remove KML', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bMore = Ti.UI.createButton({
	title:'More', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

function onComplete(){
	alert("KML File Loaded");
};

//Add event handler to let us know when the KML file has been loaded
mapView.addEventListener('kmlCompleted',onComplete);
	
bAddKML.addEventListener('click',function() {
	
	mapView.addKML({
		path:"MID_SIZED_SAMPLE.kml", //Path to our kml file
		tag : 55, //Integer value used as the tag for all polygons and annotations. If you want use remove you need to set this to a known value.
        flyTo:false, //Will set your zoom to show all of your points added (false by default)        
  		//Contains all of the details used to process overlays from your KML file
  		overlayInfo:{
	        title:'my kml batch key', //This identifies all of the overlay elements in your kml file. This is also used for delete or query operations.
	        alpha:0.5, //Alpha value of your overlays
	        lineWidth:1.2, //Line Width of your overlays
	       	strokeColor:'#000', //Stroke Color of your overlays
	        color:'yellow', //Sets the color of all your overlays ( if left off, a random color will be selected)
	        useRandomColor:true, //If true, a random color will be selected, this overrides the color provided if true  			
  		},
  		//Contains all of the details used to process annotations from your KML file
  		annotationInfo:{
	        pincolor:Ti.Map.ANNOTATION_GREEN //(Optional) pincolor for your annotations  			
  		}     
	});	
		   	
});

bRemoveKML.addEventListener('click',function() {
	//The tag is used to remove polygons, circles, and annotations.  You will need to set both when you call 
	//the addKML method if you want to later use removeKML
	mapView.removeKML({tag:55});		
});

bMore.addEventListener('click',function() {

	var dialog = Ti.UI.createOptionDialog({
		options:['Zoom Out To World', 'Zoom To Overlays', 'Clear Map'],
		title:'More Options'
	});	

	dialog.addEventListener('click',function(e){
		if(e.index===0){
			mapView.ZoomOutFull();
		}
		if(e.index===1){
			mapView.ZoomToFit();
		}
		if(e.index===2){
			//Remove everything
			mapView.clear();				
		}				
	});	
	dialog.show();
});

win.setToolbar([bAddKML,flexSpace,bRemoveKML,flexSpace,bMore]);

