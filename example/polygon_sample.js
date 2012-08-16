var win = Titanium.UI.currentWindow;

//We load our state data, this is a big file...
var meta = require('poly_meta');
//Bring the module into the example
var map = require('bencoding.map');

var bClearMap = Ti.UI.createButton({
	title:'Clear Map', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

win.setRightNavButton(bClearMap);

//Remove all polygons added
bClearMap.addEventListener('click', function(){
	mapView.removeAllPolygons();
});

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
	
var flexSpace = Ti.UI.createButton({ systemButton:Ti.UI.iPhone.SystemButton.FLEXIBLE_SPACE });

var bAddUK = Ti.UI.createButton({
	title:'+ UK', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bRemoveUK = Ti.UI.createButton({
	title:'- UK', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bAddUK.addEventListener('click',function() {
	var ukData = meta.ukPolygons();
	var iLength = ukData.length; //Should be 50 unless something changed...
	
	//Now we start looping...
	for (var iLoop=0;iLoop<iLength;iLoop++){
		mapView.addPolygon(ukData[iLoop]);
	}
});

bRemoveUK.addEventListener('click',function() {
	//UK is a multi part polygon
	//But, since we use the title to delete the polygon
	//We just need to pass in any part to remove the polygon from the map
	var poly = { title:'United Kingdom' };
	mapView.removePolygon(poly);
});


var bAddNY = Ti.UI.createButton({
	title:'+ NY', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bAddNY.addEventListener('click',function() {
	var iLength = meta.statesPolygons.states.length; //Should be 50 unless something changed...
	
	//Now we start looping...until we find NY
	for (var iLoop=0;iLoop<iLength;iLoop++){
		if(meta.statesPolygons.states[iLoop].title=='New York'){
			mapView.addPolygon(meta.statesPolygons.states[iLoop]);
			break;
		}
	}	
});

var bRemoveNY = Ti.UI.createButton({
	title:'- NY', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bRemoveNY.addEventListener('click',function() {
	//Provide title of the polygon to be deleted
	var poly = { title:'New York' };	
	mapView.removePolygon(poly);
});

var bAddStates = Ti.UI.createButton({
	title:'+ States', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

//Load each state as a polgyon
bAddStates.addEventListener('click', function(){
	//This is just a demo, please don't try this in your production apps....	
	var iLength = meta.statesPolygons.states.length; //Should be 50 unless something changed...
	
	//Now we start looping...
	for (var iLoop=0;iLoop<iLength;iLoop++){
		Ti.API.info("Adding State " + meta.statesPolygons.states[iLoop].title);
		mapView.addPolygon(meta.statesPolygons.states[iLoop]);	
	}
});

var bottomToolbar = Ti.UI.iOS.createToolbar({
	items:[bAddStates,bAddNY,bRemoveNY,bAddUK,bRemoveUK],
	bottom:0
});
win.add(bottomToolbar);
