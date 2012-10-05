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

var zoomControl = Ti.UI.iOS.createToolbar({
	items:[bZoomIn,bZoomOut,flexSpace,bRemoveAll],
	top:0,width:Ti.UI.FILL
});	
win.add(zoomControl);

var bAddClock = Ti.UI.createButton({
	title:'Add Big Ben', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bRemoveClock = Ti.UI.createButton({
	title:'Remove Big Ben', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bRemoveAll.addEventListener('click',function(){
	mapView.removeAllImageOverlays();
});	

bRemoveClock.addEventListener('click',function(){
	mapView.removeImageOverlay({tag:21});
});	


bAddClock.addEventListener('click',function() {

	var london = {latitude:51.500611,longitude:-0.124611,animate:true,latitudeDelta:0.04, longitudeDelta:0.04};
	
	mapView.setLocation(london);
	
	mapView.addImageOverlay({
		tag:21,
		title:'foo2',
		image:'ben2.png', //Image path
		sizedBox:{
			cellSizeLat:0.00300, //Size of image as it relates to latitude ( this is the size for 240 pixels width) 
			cellSizeLng:0.00400, //Size of image as it relates to longitude ( this is the size for 225 pixels high) 
			coords:
			{
				upperRight:{
					latitude:51.500611,
					longitude:-0.124611
				}
			}
		}
	});	
});


var bottomToolbar = Ti.UI.iOS.createToolbar({
	items:[bAddClock,bRemoveClock,bRemoveAll],
	bottom:0
});
win.add(bottomToolbar);
