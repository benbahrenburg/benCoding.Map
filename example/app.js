//Create our window, the usual stuff
var win  = Ti.UI.createWindow({backgroundColor:'#fff',title:'Map Samples Menu', tabBarHidden:true});
var tabGroup = Ti.UI.createTabGroup();
var tab1 = Titanium.UI.createTab({ window:win });

var introLabel = Ti.UI.createLabel({
	text:'Welcome to the benCoding.Map module. The below demonstrate on how to use Polygons, Circles, ImageOverlays, and KML Files in your MapView projects.',
	top:20,height:120,left:10,right:10
});
win.add(introLabel);


var data =[
	{title:'Polygon Samples',itemId:0},
	{title:'Circle Samples',itemId:1},
	{title:'KML File Sample',itemId:2},
	{title:'Image Overlay Sample 1',itemId:3},
	{title:'Image Overlay Sample 2',itemId:4},
	{title:'Tile Overlay Sample',itemId:5}				
];


function loadSample(itemId){
	var win = null;

	if(itemId===0){
		win = Ti.UI.createWindow({
					url:'polygon_sample.js',
					backgroundColor:'#fff',
					title:'Polygon Sample', 
					backButtonTitle:'Menu',
					tabBarHidden:true
			});		
	}	
	if(itemId===1){
		win = Ti.UI.createWindow({
					url:'circle_sample.js',
					backgroundColor:'#fff',
					title:'Circle Sample',
					backButtonTitle:'Menu', 
					tabBarHidden:true
			});		
	}	
	if(itemId===2){
		win = Ti.UI.createWindow({
					url:'kml_sample.js',
					backgroundColor:'#fff',
					title:'KML Sample',
					backButtonTitle:'Menu', 
					tabBarHidden:true
			});		
	}	
	if(itemId===3){
		win = Ti.UI.createWindow({
					url:'big_ben_overlay_sample.js',
					backgroundColor:'#fff',
					title:'Image Overlay Sample 1',
					backButtonTitle:'Menu', 
					tabBarHidden:true
			});		
	}	

	if(itemId===4){
		win = Ti.UI.createWindow({
					url:'eiffel_tower_sample.js',
					backgroundColor:'#fff',
					title:'Image Overlay Sample 2',
					backButtonTitle:'Menu', 
					tabBarHidden:true
			});		
	}
	
	if(itemId===5){
		win = Ti.UI.createWindow({
					url:'tile_overlay_sample.js',
					backgroundColor:'#fff',
					title:'Tile Overlay Sample',
					backButtonTitle:'Menu', 
					tabBarHidden:true
			});		
	}	
				
	tab1.open(win);
};

var tableView = Ti.UI.createTableView({
	top:130,bottom:0, width:Ti.UI.FILL, data:data
});
win.add(tableView);

tableView.addEventListener('click',function(e){
	loadSample(e.rowData.itemId);
});
// create tab group

tabGroup.addTab(tab1);
tabGroup.open();
