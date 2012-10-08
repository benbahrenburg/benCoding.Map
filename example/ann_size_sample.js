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

var bAddAnnotations = Ti.UI.createButton({
	title:'Add Pins', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bAddAnnotations.addEventListener('click',function(){
  var annOne = Titanium.Map.createAnnotation({
    title: 'sample 1',
	latitude:48.85995,
	longitude:2.2957,
	tag:1,
	scaleTo:{
		x:3,
		y:3
	} 
  });
  mapView.addAnnotation(annOne);  
  var annTwo = Titanium.Map.createAnnotation({
    title: 'sample 2',
	latitude:40.75773,
	longitude:-73.985708,
	tag:2,
    image: "city2.png",
	scaleTo:{
		x:1.5,
		y:1.5
	} 
  });
  mapView.addAnnotation(annTwo);  	
});

var bRemoveAll = Ti.UI.createButton({
	title:'Remove', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});
bRemoveAll.addEventListener('click',function() {
	mapView.removeAllAnnotations();
});

win.setToolbar([bZoomIn,bZoomOut,flexSpace,bAddAnnotations, bRemoveAll]);
