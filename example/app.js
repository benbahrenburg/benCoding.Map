//We load our state data, this is a big file...
var meta = require('poly_meta');

//Bring the module into the example
var map = require('bencoding.map');
//Create our window, the usual stuff
var win  = Ti.UI.createWindow({backgroundColor:'#fff',tabBarHidden:true});

var bLoadStates = Ti.UI.createButton({
	style:Ti.UI.iPhone.SystemButtonStyle.BORDERED, title:'Load All States'
});
win.leftNavButton = bLoadStates;

var bRemoveAll = Ti.UI.createButton({
	style:Ti.UI.iPhone.SystemButtonStyle.BORDERED, title:'Remove All'
});
win.rightNavButton = bRemoveAll;

//Create mapView
//We support all of the same functions the native Ti.Map.View does
var mapView = map.createView({
	mapType: Ti.Map.STANDARD_TYPE,
	animate:true, 
	userLocation:true
});

//Add to Window
win.add(mapView);

//Remove all polygons added
bRemoveAll.addEventListener('click', function(){
	mapView.removeAllPolygons();
});

//Load each state as a polgyon
bLoadStates.addEventListener('click', function(){
	//This is just a demo, please don't try this in your production apps....	
	var iLength = meta.statesPolygons.states.length; //Should be 50 unless something changed...
	
	//Now we start looping...
	for (var iLoop=0;iLoop<iLength;iLoop++){
		Ti.API.info("Adding State " + meta.statesPolygons.states[iLoop].title);
		mapView.addPolygon(meta.statesPolygons.states[iLoop]);	
	}
});

function fetchNY(){
	var iLength = meta.statesPolygons.states.length; //Should be 50 unless something changed...
	
	//Now we start looping...until we find NY
	for (var iLoop=0;iLoop<iLength;iLoop++){
		if(meta.statesPolygons.states[iLoop].title=='New York'){
			return meta.statesPolygons.states[iLoop];
		}
	}
};


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
	mapView.addPolygon(fetchNY());
});

var bRemoveNY = Ti.UI.createButton({
	title:'- NY', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bRemoveNY.addEventListener('click',function() {
	mapView.removePolygon(fetchNY());
});

// button to zoom-in
var bZoomIn = Ti.UI.createButton({
	title:'+', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});
// button to zoom-out
var bZoomOut = Ti.UI.createButton({
	title:'-', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});
bZoomIn.addEventListener('click',function() {
	mapView.zoom(1);
});

bZoomOut.addEventListener('click',function() {
	mapView.zoom(-1);
});

var flexSpace = Ti.UI.createButton({ systemButton:Ti.UI.iPhone.SystemButton.FLEXIBLE_SPACE });
win.setToolbar([bAddNY,bRemoveNY,flexSpace,bAddUK,bRemoveUK,flexSpace,bZoomIn,bZoomOut]);

// create tab group
var tabGroup = Titanium.UI.createTabGroup();
var tab1 = Titanium.UI.createTab({ window:win });
tabGroup.addTab(tab1);
tabGroup.open();
