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

var flexSpace = Ti.UI.createButton({ systemButton:Ti.UI.iPhone.SystemButton.FLEXIBLE_SPACE });

var zoomControl = Ti.UI.iOS.createToolbar({
	items:[bZoomIn,bZoomOut],
	top:0,width:Ti.UI.FILL
});	
win.add(zoomControl);

var bAddTower = Ti.UI.createButton({
	title:'Add Tower', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

var bRemoveTower = Ti.UI.createButton({
	title:'Remove Tower', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bRemoveAll.addEventListener('click',function(){
	mapView.removeAllImageOverlays();
});	

bRemoveTower.addEventListener('click',function(){
	mapView.removeImageOverlay({tag:42});
});	

bAddTower.addEventListener('click',function() {

	var paris = {latitude:48.85995,longitude:2.2957,animate:true,latitudeDelta:0.04, longitudeDelta:0.04};	
	mapView.setLocation(paris);

	mapView.addImageOverlay(
	{
		tag:42,
		title:'foo',
		image:'eiffel_tower2.png', //Image path
		coordBox:{
			coords:
			{
				upperRight:{
					latitude:48.85995,
					longitude:2.2957
				},
				bottomLeft:{
					latitude:48.85758,
					longitude:2.2933
				}			
			}
		}
	});	
});


win.setToolbar([bAddTower,flexSpace,bRemoveTower,flexSpace,bRemoveAll]);
