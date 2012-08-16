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
* Title : String - Title of the Polygon, also used when removing the polygon.
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
* Title : String - Title of the Circle, also used when removing the Circle.
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

<h2>Using the example</h2>

The examples shown in the demonstration videos are included in the module's example folder or downloadable [here](https://github.com/benbahrenburg/benCoding.Map/tree/master/example).

<h2>User Tracking</h2>
The User Tracking is the native MKUserTrackingMode implementation made available for Titanium, it will only work with iOS5 or greater.

simply call:
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

<h2>FAQ</h2>

* Is there an Android version?  - Sorry this is an iOS only module. Check the Appcelerator Marketplace for other options.

* Can I add a click event to the overlay? - Sorry, this is not supported at this time.

<h2>Legal Stuff</h2>

Appcelerator is a registered trademark of Appcelerator, Inc. Appcelerator Titanium is a trademark of Appcelerator, Inc.

<h2>Licensing</h2>

Please see the Titanium licensing located [here](https://github.com/appcelerator/titanium_mobile).

Any module specific modifications not covered by the Titanium license are available under the OSI approved Apache Public License (version 2).

<h2>Contributing</h2>

The benCoding.Map is a open source project.  Please help us by contributing to documentation, reporting bugs, forking the code to add features or make bug fixes or promoting on twitter, etc.

<h2>Learn More</h2>

<h3>Twitter</h3>

Please consider following the [@benCoding Twitter](http://www.twitter.com/benCoding) for updates and more about Titanium.

<h3>Blog</h3>

For module updates, Titanium tutorials and more please check out my blog at [benCoding.Com](http://benCoding.com). 
