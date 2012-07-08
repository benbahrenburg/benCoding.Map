<h1>benCoding.Map</h1>
 
Welcome to the benCoding.Map Titanium project.

This project is a fork of the iOS Titanium Native Map module.  The goal of this project is to add Polgyon overlay support.

<h2>Features</h2>

This module provides Polgyon overlay support in addition to all of the same features contained within the native Titanium Map module.

For a list of all the features supported by the Titanium Map module, please reference the documentation [here](http://docs.appcelerator.com/titanium/2.1/index.html#!/api/Titanium.Map.View).

<h2>See it in action</h2>

See a video of the module in action [http://www.youtube.com/watch?v=1rudu6S9-rc](http://www.youtube.com/watch?v=1rudu6S9-rc).

![Screenshot](http://farm8.staticflickr.com/7268/7528456398_7395bb0906_o.png)

<h2>Before you start</h2>
* You need Titanium 1.8.2 or greater.
* This module will only work with iOS 5 or great.  

<h2>Setup</h2>

* Download the latest release from the [dist folder](https://github.com/benbahrenburg/benCoding.Map/tree/master/dist) or you can build it yourself 
* Install the bencoding.basicGeo module. If you need help here is a "How To" [guide](https://wiki.appcelerator.org/display/guides/Configuring+Apps+to+Use+Modules). 
* You can now use the module via the commonJS require method, example shown below.

<pre><code>
//Add the core module into your project
var map = require('bencoding.map');

</code></pre>

Now we have the module installed and avoid in our project we can start to use the components, see below for details.

<h2>Using Polygons</h2>

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

This method removes all Polygons added to the MapView.  Please note this will only remove Polygons, other overlay or annotations must be handled separately. 

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

<h2>Using the example</h2>

The example app shown in the demonstration video is included in the module's example folder or downloadable [here](https://github.com/benbahrenburg/benCoding.Map/tree/master/example).

<h2>FAQ</h2>

* Is there an Android version?  - Sorry this is an iOS only module. Check the Appcelerator Marketplace for other options.

* How about Circle overlaps? - Coming soon.

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
