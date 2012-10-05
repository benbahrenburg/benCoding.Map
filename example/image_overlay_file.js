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

var bRemoveAll = Ti.UI.createButton({
	title:'Remove All', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});
bRemoveAll.addEventListener('click',function(){
	mapView.removeAllImageOverlays();
});	

var zoomControl = Ti.UI.iOS.createToolbar({
	items:[bZoomIn,bZoomOut,flexSpace,bRemoveAll],
	top:0,width:Ti.UI.FILL
});	
win.add(zoomControl);


var bAddFile = Ti.UI.createButton({
	title:'Add File', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bAddFile.addEventListener('click',function(e){
	mapView.addImageOverlayFile('./image_overlay_file_sample.json');	
});

var bBen = Ti.UI.createButton({
	title:'Ben', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});
bBen.addEventListener('click',function(e){
	var regionBigBen = {latitude:51.500611,longitude:-0.124611,animate:true,latitudeDelta:0.04, longitudeDelta:0.04};
	mapView.setLocation(regionBigBen);	
});
var bEiffel = Ti.UI.createButton({
	title:'Eiffel', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});
bEiffel.addEventListener('click',function(e){
	var regionEiffelTower = {latitude:48.85995,longitude:2.2957,animate:true,latitudeDelta:0.04, longitudeDelta:0.04};
	mapView.setLocation(regionEiffelTower);	
});
var bRemove = Ti.UI.createButton({
	title:'Remove', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bRemove.addEventListener('click',function(){
	//Remove Eiffel Tower
	mapView.removeImageOverlay({tag:42});
	//Remove Big Ben
	mapView.removeImageOverlay({tag:21});	
});	

var bottomToolbar = Ti.UI.iOS.createToolbar({
	items:[bAddFile,bBen,bEiffel,bRemove],
	bottom:0
});
win.add(bottomToolbar);
