<h1>benCoding.Map</h1>
 
Welcome to the benCoding.Map Titanium project.

This project is a fork of the iOS Titanium Native Map module.  The goal of this project is to add Polgyon overlay support.

<h2>Features</h2>

This module provides Polgyon overlay support in addition to all of the same features contained within the native Titanium Map module and also UserTracking functionality.

For a list of all the features supported by the Titanium Map module, please reference the documentation [here](http://docs.appcelerator.com/titanium/2.1/index.html#!/api/Titanium.Map.View).

<h2>See it in action</h2>

<h4>Polygon Example</h4>
Video of the module running a Polygon example [http://www.youtube.com/watch?v=1rudu6S9-rc](http://www.youtube.com/watch?v=1rudu6S9-rc).

![Screenshot](http://farm8.staticflickr.com/7268/7528456398_7395bb0906_o.png)

<h4>Circle Example</h4>

Video of the module running a Circle example [http://www.youtube.com/watch?v=jwnByWz1eJo](http://www.youtube.com/watch?v=jwnByWz1eJo).

![Screenshot](http://farm8.staticflickr.com/7113/7558754232_7091e30030_o.png)

<h4>KML File Example</h4>

Video of the module running a KML example [http://www.youtube.com/watch?v=vjD8UkCGVHk](http://www.youtube.com/watch?v=vjD8UkCGVHk).

![Screenshot](http://farm8.staticflickr.com/7259/7824132160_24a9f9975c.jpg)

<h2>Before you start</h2>
* You need Titanium 1.8.2 or greater.
* This module will only work with iOS 5 or great.  

<h2>Setup</h2>

* Download the latest release from the [dist folder](https://github.com/benbahrenburg/benCoding.Map/tree/master/dist) or you can build it yourself 
* Install the bencoding.map module. If you need help here is a "How To" [guide](https://wiki.appcelerator.org/display/guides/Configuring+Apps+to+Use+Modules). 
* You can now use the module via the commonJS require method, example shown below.

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');

</code></pre>

Now we have the module installed and avoid in our project we can start to use the components, see below for details.

<h2>Using Polygon Overlays</h2>

<h3>addPolygon</h3>

This method adds a Polygon to the MapView.

Parameters:
* title : String - Title of the Polygon, also used when removing the polygon.
* alpha : Float  - The alpha value for the Polygon.
* lineWidth : Float - The width of the Polygon outline.
* strokeColor : Color - The color of the Polygon stroke.
* color : Color - The FillColor of the Polygon.
* points : Arrary - The points as coordinates used when creating the Polygon.

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Below is a polygon for the state of Colorado
var myPolygon = {title:'Colorado',
                color:'#880000',
                alpha:0.5,
                lineWidth:1.2,
                strokeColor:'#000',                    
                points:[
                    {
                        latitude:37.0004,
                        longitude:-109.0448
                    },
                    {
                        latitude:36.9949,
                        longitude:-102.0424
                    },
                    {
                        latitude:41.0006,
                        longitude:-102.0534
                    },
                    {
                        latitude:40.9996,
                        longitude:-109.0489
                    },
                    {
                        latitude:37.0004,
                        longitude:-109.0448
                    }
                ]
            };
//Add Colorado polgyon to MapView
map.addPolygon(myPolygon);
</code></pre>

<h3>removePolygon</h3>

This method removes a specific Polygon using the Polygon's title property.

Parameters:
* title : String - The title of the Polygon you would like to remove

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Below is a polygon for the state of Colorado
var myPolygon = {title:'Colorado'};
//Remove the Colorado polgyon from the MapView
map.removePolygon(myPolygon);
</code></pre>

<h3>removeAllPolygons</h3>

This method removes all Polygons added to the MapView.  Please note this will only remove Polygons, other overlays or annotations must be handled separately. 

Parameters:
* None

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Remove all polygons added to the MapView
map.removeAllPolygons();
</code></pre>

<h3>Handling Multipart Polygons</h3>

When working with country borders and other complex boundaries it is useful to use multipart Polygons.

To create multipart Polygons simply create each Polygon with the same name. This allows you to remove them by referencing the same Polygon title.

The United Kingdom sample provided in the example folder demonstrates how to create Polygons in this way.

<h2>Using Circle Overlays</h2>

<h3>addCircle</h3>

This method adds a Circle to the MapView.

Parameters:
* title : String - Title of the Circle, also used when removing the Circle.
* alpha : Float  - The alpha value for the Circle.
* lineWidth : Float - The width of the Circle outline.
* strokeColor : Color - The color of the Circle stroke.
* color : Color - The FillColor of the Circle.
* latitude : Float - Latitude used in creating the center point of the Circle
* longitude : Float - Longitude used in creating the center point of the Circle
* radius : Float -  The radius of the circular area, measured in meters

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Create a circle 100 meters around Time Square 
var myCircle = {title:'Time Square',
                color:'#880000',
                alpha:0.5,
                lineWidth:1.2,
                strokeColor:'#000',
                latitude:40.75773,
                longitude:-73.985708,
                radius:100
            };
//Add the circle around Time Square to the MapView
map.addCircle(myCircle);
</code></pre>

<h3>removeCircle</h3>

This method removes a specific Circle using the Circle's title property.

Parameters:
* title : String - The title of the Circle you would like to remove

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Create an object with the same title as our Time Square Circle
var myCirlce = {title:'Time Square'};
//Remove the pass the above object with our title property into the remove method
//This will remove all circles with the title provided
map.removeCircle(myCirlce);
</code></pre>

<h3>removeAllCircles</h3>

This method removes all Circles added to the MapView.  Please note this will only remove Circles, other overlays or annotations must be handled separately. 

Parameters:
* None

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Remove all circles added to the MapView
map.removeAllCircles();
</code></pre>


<h2>User Tracking</h2>
The User Tracking is the native MKUserTrackingMode implementation made available for Titanium, it will only work with iOS5 or greater.

<b>Sample</b>
<pre><code>

var map = Ti.UI.Map.createView({
   //whatever extra options
   userTrackingMode:{
    mode: 2, //you can use 0, 1 or 2
    animated: true, //or false
    } 
});

//or
map.setUserTrackingMode({
    mode: 2,
    animated: true
})    
</code></pre>

userTrackingMode options: 
0 - No tracking at all
1 - Tracking (follow user's position)
2 - Tracking with compass heading (follow user's position and map rotation according to compass heading)

I recommend to keep track of the UserTrackingMode since it can change suddenly (e.g. if user drags the map, userTrackingMode will pass to state 0);
You can keep track with this eventListener:

<pre><code>
map.addEventListener("userTrackingMode",function(e){
    var trackingMode = e.mode;
    //whatever you want to do with the tracking mode
}
</code></pre>

<h2>How to work with KML</h2>

You can now use kml files to create your polygons and annotations.

<h3>addKML</h3>

The addKML method allows you to provide a path to a KML file and a few options on how to handle the parsing.  The Map Module will then parse the KML file and create annotations and polygons using the details provided.

PLEASE NOTE : You can easily add more polygons then the mapView can handle, using this method. You will want to test your different KML files to make sure they are sized correctly.

iOS Simulator Issue: There is a simulator issue that can cause a crash if you have to many polygons. This is related to the double click to zoom nature of the simulator and will not impact the device.

Parameters:
* path : String -
* flyTo : Boolean - Will set your zoom to show all of your points added (false by default)  
* overlayInfo : Dictionary containgin the below properties
-- title : String - Title of the Circle, also used when removing the Circle.
-- alpha : Float  - The alpha value for the Circle.
-- lineWidth : Float - The width of the Circle outline.
-- strokeColor : Color - The color of the Circle stroke.
-- color : Color - The FillColor of the Circle.
-- useRandomColor : Boolean - Greater a random color, this overrides color if provided (False by default)
* annotationInfo : Dictionary containgin the below properties
-- tagId : Integer - An identifier used to associate an annotation to the KML job.
-- pincolor : Number - Pin color. Specify one of: Titanium.Map.ANNOTATION_GREEN, Titanium.Map.ANNOTATION_PURPLE or Titanium.Map.ANNOTATION_RED.

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
map.addKML({
    path:'MID_SIZED_SAMPLE.kml', //Path to your KML file
    flyTo:false, //Will set your zoom to show all of your points added (false by default)        
    //Contains all of the details used to process overlays from your KML file
    overlayInfo:{
        title:'my kml batch key', //This identifies all of the overlay elements in your kml file. This is also used for delete or query operations.
        alpha:0.5, //Alpha value of your overlays
        lineWidth:1.2, //Line Width of your overlays
        strokeColor:'#000', //Stroke Color of your overlays
        color:'yellow', //Sets the color of all your overlays ( if left off, a random color will be selected)
        useRandomColor:true, //If true, a random color will be selected, this overrides the color provided if true              
    },
    //Contains all of the details used to process annotations from your KML file
    annotationInfo:{
        tagId:41, //Integer value used as the tag for all annotations. If you want use remove you need to set this to a known value. By default it is 1
        pincolor:Ti.Map.ANNOTATION_GREEN //(Optional) pincolor for your annotations             
    }     
}); 
</code></pre>

<h3>KML Loaded Listener</h3>

KML files can be large and take time to process.  The "kmlCompleted" event will be fired on the mapView object after the file has been loaded and the objects atteched.

A common use of this function would be to display a "Waiting..." message when calling the addKML method, then removing the message on reciept of the "kmlCompleted" event.

<pre><code>
function onComplete(){
    alert("KML File Loaded");
};

//Add event handler to let us know when the KML file has been loaded
map.addEventListener('kmlCompleted',onComplete);
</code></pre>

<h3>removeKML</h3>

The removeKML method provides an easy helper function to remove all of the polygons and annotations added using the addKML function. The delete uses the title parameter to remove any circles or polygons and the tagId value to remove any annotations.

For best results you will need to provide the same title and tagId used during the creation process.  In the ablve addKML example we used a title of 'my kml batch key' and a tagId of 41.  To remove these objects, we call the removeKML method and provide those values, as shown below.

Parameters:
* overlayInfo : Dictionary containgin the below properties
-- title : String - Title of the Circle, also used when removing the Circle.
* annotationInfo : Dictionary containgin the below properties
-- tagId : Integer - An identifier used to associate an annotation to the KML job. 

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
map.removeKML({
    overlayInfo:{
        title:'my kml batch key'
   },
   annotationInfo:{
    tagId:41 //Integer value used as the tag for all annotations. If you want use remove you need to set this to a known value. By default it is 1
   }
}); 
</code></pre>

<h2>Helper Methods</h2>

The below outlines a list of helper functions designed to make life easier when using the mapView.

<h3>clear</h3>

This method removes all annotations, polygons, circles, routes, etc.

Parameters:
* None

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Remove all objects added to the map
map.clear();
</code></pre>

<h3>ZoomOutFull</h3>

This method zooms out all of the way out, to display the full world region where available.

Parameters:
* None

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Zoom all of the way out to show full world
map.ZoomToWorld();
</code></pre>

<h3>ZoomToFit</h3>

This method zooms the mapview in to focus on a region containing your annotations, polgyons, and other objects.

Parameters:
* None

<b>Sample</b>

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');
//Zoom to focus on objects added to your mapview
map.ZoomToFit();
</code></pre>

<h2>Using the example</h2>

The examples shown in the demonstration videos are included in the module's example folder or downloadable [here](https://github.com/benbahrenburg/benCoding.Map/tree/master/example).

<h2>FAQ</h2>

* Is there an Android version?  - Sorry this is an iOS only module. Check the Appcelerator Marketplace for other options.

* Can I add a click event to the overlay? - Sorry, this is not supported at this time.

<h2>Legal Stuff</h2>

Appcelerator is a registered trademark of Appcelerator, Inc. Appcelerator Titanium is a trademark of Appcelerator, Inc.

<h2>Licensing</h2>

Please see the Titanium licensing located [here](https://github.com/appcelerator/titanium_mobile).

Any module specific modifications not covered by the Titanium license are available under the OSI approved Apache Public License (version 2).

The KML functions contains modified code provided by Apple in their KML Viewer sample project. For questions please read their license [here](http://developer.apple.com/library/ios/#samplecode/KMLViewer/Listings/ReadMe_txt.html)

<h2>Contributing</h2>

The benCoding.Map is a open source project.  Please help us by contributing to documentation, reporting bugs, forking the code to add features or make bug fixes or promoting on twitter, etc.

<h2>Other Contributors</h2>

User Tracking was added by Jose Carlos Andreu [@Joscandreu](https://twitter.com/Joscandreu)

<h2>Learn More</h2>

<h3>Twitter</h3>

Please consider following the [@benCoding Twitter](http://www.twitter.com/benCoding) for updates and more about Titanium.

<h3>Blog</h3>

For module updates, Titanium tutorials and more please check out my blog at [benCoding.Com](http://benCoding.com). 
