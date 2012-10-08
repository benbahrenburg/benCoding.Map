//Create our window, the usual stuff
var win  = Ti.UI.createWindow({backgroundColor:'#fff',title:'Map Samples Menu', tabBarHidden:true});
var tabGroup = Ti.UI.createTabGroup();
var tab1 = Titanium.UI.createTab({ window:win });

var introLabel = Ti.UI.createLabel({
	text:'Welcome to the benCoding.Map module. The below samples for a wide range of advanced functions. Please read the documentation for details.',
	top:10,height:90,left:10,right:10
});
win.add(introLabel);


var data =[
	{title:'Polygon Samples',itemId:0,url:'polygon_sample.js',winTitle:'Polygon Sample'},
	{title:'Circle Samples',itemId:1,url:'circle_sample.js',winTitle:'Circle Sample'},
	{title:'KML File Sample',itemId:2,url:'kml_sample.js',winTitle:'KML Sample'},
	{title:'Image Overlay Sample 1',itemId:3,url:'big_ben_overlay_sample.js',winTitle:'Image Overlay Sample 1'},
	{title:'Image Overlay Sample 2',itemId:4,url:'eiffel_tower_sample.js',winTitle:'Image Overlay Sample 2'},
	{title:'Image Overlay File',itemId:5,url:'image_overlay_file.js',winTitle:'Image Overlay File'},	
	{title:'Tile Overlay Sample',itemId:6,url:'tile_overlay_sample.js',winTitle:'Tile Overlay Sample'},
	{title:'GeoJSON Sample',itemId:7,url:'geojson_sample.js',winTitle:'GeoJSON Sample'},
	{title:'Sizeable Pins',itemId:8,url:'ann_size_sample.js',winTitle:'Sizeable Annotations'}						
];


function loadSample(selectedObject){

	var win = Ti.UI.createWindow({
					url:selectedObject.url,
					backgroundColor:'#fff',
					title:selectedObject.winTitle, 
					backButtonTitle:'Menu',
					tabBarHidden:true
			});	
				
	tab1.open(win);
};

var tableView = Ti.UI.createTableView({
	top:100,bottom:0, width:Ti.UI.FILL, data:data
});
win.add(tableView);

tableView.addEventListener('click',function(e){
	loadSample(e.rowData);
});

tabGroup.addTab(tab1);
tabGroup.open();
