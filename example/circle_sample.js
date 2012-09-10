var win = Titanium.UI.currentWindow;
var flexSpace = Ti.UI.createButton({ systemButton:Ti.UI.iPhone.SystemButton.FLEXIBLE_SPACE });

//We load our state data, this is a big file...
var meta = require('power_plants');

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

var bAddPlants = Ti.UI.createButton({
	title:'Add Plants', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bRemoveUSPlants = Ti.UI.createButton({
	title:'Remove US Plants', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bClearMap = Ti.UI.createButton({
	title:'Clear Map', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bAddPlants.addEventListener('click',function() {
	//Remove all circles so we are starting fresh
	mapView.removeAllCircles();
	//Remove all annotations so we are starting fresh
	mapView.removeAllAnnotations();
	
	var iLength = meta.powerPlantsList.length; 
		   	
	//Loop and add each plant
	for (var iLoop=0;iLoop<iLength;iLoop++){
		Ti.API.info("Adding Power Plant " + meta.powerPlantsList[iLoop].name);
		//Add Yellow Zone
		mapView.addCircle({
			latitude:meta.powerPlantsList[iLoop].latitude,
			longitude:meta.powerPlantsList[iLoop].longitude,
			title:meta.powerPlantsList[iLoop].name,
			radius:80000,
			color:'yellow'
		});		
		//Add Red Zone
		mapView.addCircle({
			latitude:meta.powerPlantsList[iLoop].latitude,
			longitude:meta.powerPlantsList[iLoop].longitude,
			title:meta.powerPlantsList[iLoop].name,
			radius:16000,
			color:'red'
		});
		
		//Add annotation
		mapView.addAnnotation(Ti.Map.createAnnotation({
			latitude:meta.powerPlantsList[iLoop].latitude,
			longitude:meta.powerPlantsList[iLoop].longitude,
			title:meta.powerPlantsList[iLoop].name,
			subtitle:meta.powerPlantsList[iLoop].country + '\nCapacity:' + meta.powerPlantsList[iLoop].capacity + ' MW',
			pincolor:Ti.Map.ANNOTATION_PURPLE,
			animate:true
		}));		
	}	
});

bRemoveUSPlants.addEventListener('click',function() {
	var iLength = meta.powerPlantsList.length; 

	//Now we start looping...until we find circle data related to the US
	for (var iLoop=0;iLoop<iLength;iLoop++){
		if(meta.powerPlantsList[iLoop].country=="United States"){
			Ti.API.info("Removing plant " + meta.powerPlantsList[iLoop].name);
			//Remove all circles related to this title
			mapView.removeCircle({title:meta.powerPlantsList[iLoop].name});
			//Remove our annotation that is associated with this entry
			mapView.removeAnnotation(meta.powerPlantsList[iLoop].name);
		}
	}	
});

bClearMap.addEventListener('click',function() {
	//Remove all circles
	mapView.removeAllCircles();
	//Remove all annotations
	mapView.removeAllAnnotations();
});

win.setToolbar([bAddPlants,flexSpace,bRemoveUSPlants,flexSpace,bClearMap]);

setTimeout(function()
{
	Ti.UI.createAlertDialog({
			title:'Information',
			message:"This demonstration shows how to use the MKCircle overlay with Titanium.  Press the Add Plants button to circle each Nuclear Power Plant at a radius of 10 and 50 miles." 
		}).show();
},1000);


