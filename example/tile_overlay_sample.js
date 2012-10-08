var win = Titanium.UI.currentWindow;
var flexSpace = Ti.UI.createButton({ systemButton:Ti.UI.iPhone.SystemButton.FLEXIBLE_SPACE });

//Bring the module into the example
var map = require('bencoding.map');

//Create mapView
//We support all of the same functions the native Ti.Map.View does
var mapView = map.createView({
	mapType: Ti.Map.STANDARD_TYPE,
	region: {
	  latitude : -37.819955,
	  longitude : 144.983397,
	  latitudeDelta : 0.005,
	  longitudeDelta : 0.005
    },
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

var zoomControl = Ti.UI.iOS.createToolbar({
	items:[bZoomIn,bZoomOut],
	top:0,width:Ti.UI.FILL
});	
win.add(zoomControl);

var levels = ["1", "2" , "3" , "4"];
var currentLevel = 0;

var bShowTile = Ti.UI.createButton({
	title:'Level+', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bShowTile.addEventListener('click',function() {
	currentLevel++;
	if( currentLevel == levels.length){
		currentLevel = 0;
	}
	//Remove in case they already exist
	mapView.removeTileOverlayDirectory({tag:currentLevel});

    mapView.addTileOverlayDirectory({
    	tag:currentLevel,	
    	directory:'/tiles/Level' + levels[currentLevel]
    });
});

var bHideTile = Ti.UI.createButton({
	title:'Hide', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bHideTile.addEventListener('click',function() {
	mapView.removeAllAnnotations();
    mapView.removeAllTileOverlayDirectory();
});


var bShowAnnotations = Ti.UI.createButton({
	title:'Show Pins', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bShowAnnotations.addEventListener('click',function() {
   var points = [
     { latitude : -37.818891,
       longitude :	144.983343 },
     { latitude : -37.818717,
       longitude :	144.983515 },
     { latitude : -37.818925,
       longitude :	144.983665 }];
   var annotations = [];
   for( var i = 0; i < points.length; i++ ){
     annotations.push( Ti.Map.createAnnotation(points[i]));	
   }
   mapView.setAnnotations( annotations );
});

var bHideAnnotations = Ti.UI.createButton({
	title:'Hide Pins', style:Ti.UI.iPhone.SystemButtonStyle.BORDERED
});

bHideAnnotations.addEventListener('click',function() {
   mapView.removeAllAnnotations();
});


win.addEventListener('open', function(){
    mapView.addTileOverlayDirectory({
    	tag:currentLevel,	
    	directory:'/tiles/Level' + levels[currentLevel]
    });
});

win.setToolbar([bShowTile, bHideTile, bShowAnnotations, bHideAnnotations]);
