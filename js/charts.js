/* 
 * Copyright 2011 Marco Dinacci <marco.dinacci@gmail.com> / www.intransitione.com
 * 
 * Hi, this program reads jobs listings from the careers.stackoverflow.com website and 
 * dump it on a file. It then read back the data and output JSON files ready to be 
 * used with the Google Visualization API.
 *
 * You are free to do what you want with it except pretend that you wrote it. 
 * If you redistribute it, keep the copyright line above.
 *
 * This file initialise the Google Visualization API and perform the AJAX calls
 * to retrieve the data for all the charts.
 * It requires JQuery, Google Visualization API and RaphaelJS
 */

// Emulate the behaviour of the homonym PHP function by capitalizing the first letter
// of a string.
String.prototype.ucfirst = function() {
	return this.charAt(0).toUpperCase() + this.slice(1);
}

// Load the google visualization API
function load() {
	google.load("visualization", "1", {packages:["corechart"]});
}

// Fetch data from the server using a synchronous xmlhttp request
function fetchData(vizURL) {
	return $.ajax({
		type: "GET",
		url: "/code/careers/proxy.php?v=" + vizURL,
		dataType:"json",
		async: false
		}).responseText;
}

function handleError(response) {
	alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
}

// Display a country based intensity map 
function drawJobsByCountry() {
	// not yet
}

// Display data regarding remote and local jobs as a pie chart
function drawJobsRemoteVsLocal() {
	var data = new google.visualization.DataTable(fetchData('remotevslocal'));
	var visualization = new google.visualization.PieChart(document.getElementById('remote_vs_local_chart'));
	visualization.draw(data, {is3D:true});
}

// This display a word cloud in 3D. It requires swfobject.js but it's no longer used 
// as it's not very useful (although pretty...).
function drawJobsByTagCumulus() {
	var data = new google.visualization.DataTable(fetchData('tagcumulus'));
	var visualization = new gviz_word_cumulus.WordCumulus(document.getElementById('tag_chart_cumulus'));
	visualization.draw(data, {text_color: '#000000', speed: 30, width:400, height:400});
}

// Display the occurrence of tags as a term cloud. 
// Nothing particularly fancy, the style is defined externally.
function drawJobsByTagCloud() { 
	var data = new google.visualization.DataTable(fetchData('tagcloud'));
	var visualization = new TermCloud(document.getElementById("tag_chart_cloud"));
	visualization.draw(data, null);
}

// Return a random color, stolen without shame from a stackoverflow post
function randomColor() {
	return '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6);
}

// Draw a graph showing the tags that occur together the most among the 
// most frequent tags. Ex. HTML => Javascript, CSS, JQuery ...
function drawTagsRelated() {
	var data = $.parseJSON(fetchData('tagsgraph'));

	var size = 0, max_occurrence = 0, min_occurrence = 999;
	var colors = {};

	// Find out the minimum and maximum occurrence of a tag
	// and build a color lookup table 
	if(data != null) {
		var key;
		for (key in data) {
			if (data.hasOwnProperty(key)) {
				size++;
				 if(colors[key] === undefined)
					   colors[key] = randomColor();
				var length = data[key].length;
				for(var i=0; i < length; i++) {
				   tag = data[key][i][0];
				   if(colors[tag] === undefined)
					   colors[tag] = randomColor();
				   occurrence = data[key][i][1]
				   if(occurrence > max_occurrence)
					   max_occurrence = occurrence;
				   if(occurrence < min_occurrence)
					   min_occurrence = occurrence;
				}
			}
		}

		var row_height = 90; // height of a single visualization row
		var row_width = 600; // width of a single visualization row, and the canvas too.
		var paper = Raphael("tagsgraph", row_width, row_height * (size+1));
		
		var max_radius = 43, min_radius = 9;

		// Used to "scale" the occurrence of a tag in the radius range.
		var factor = (max_radius - min_radius)/max_occurrence ;

		// Used to "scale" the occurrence of a tag in the font-size range.
		var font_factor = (35 - 10)/max_occurrence ;

		// Don't start from 0 or the first circle may partially disappear
		var y = 50;

		// Minimum distance between the circle and the text below
		var voffset_text_circle = 8;

		// Constant distance between two circles
		var hoffset_circle_circle = 10;

		for (key in data) {
		   if (data.hasOwnProperty(key))  {
				// Don't start from 0 to draw the circles or they will overlap
				// with the labels.
			   var x=115;

			   // Write the label, leave a 35px space from the left or it will partially
			   // disappear. Best would be to calculate the length of the label and position
			   // it accordingly but this approximation works almost always.
			   paper.text(35, y, key.ucfirst() + ": ").attr("font-size",15);

			   var length = data[key].length;
			   for(var i=0; i < length; i++) {
			   	    // Ex. data["html"] = [["css",10],["jquery",32]] ...
					occurrence = data[key][i][1]
					tag = data[key][i][0];
					   
					// Shorten some very long tags to improve the aesthetic. hackish.
					if(tag == "ruby-on-rails")
					   tag = "ror";
				   	else if (tag == "objective-c")
					   tag = "obj-c";
				   	else if (tag == "javascript")
					   tag = "js";
						   
					// Calcualate the radius and draw the circle
					radius = occurrence * factor + min_radius;
					paper.circle(x, y, radius).attr("fill",colors[tag]);

					// Now write the occurrence of the tag inside the circle
					// and the tag label just a bit below the circle
					paper.text(x, y, occurrence).attr("font-size",occurrence * font_factor + 10);
					paper.text(x, y+radius+voffset_text_circle, tag);

					// Increase x by: radius current + radius next + constant offset
					if(i < length-1) { 
					   var next_radius = data[key][i+1][1]*factor+min_radius;
					   x+= radius + next_radius + hoffset_circle_circle;
					}
			   }
			   y+=row_height;
		   }
		}
	}
}

function debug(str) {
	document.getElementById('debug').innerHTML += str;
}