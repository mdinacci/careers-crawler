/* 
 This file initialise the Google Visualization API and perform the AJAX calls
 to retrieve the data for all the charts.
 It requires JQuery, Google Visualization API and ArborJS
 */

function handleError(response) {
    alert('Error in query: ' + response.getMessage() + ' ' + response.getDetailedMessage());
}

function load() {
    google.load("visualization", "1", {packages:["corechart"]});
}

function fetchData(vizURL) {
    return $.ajax({
        type: "GET",
        url: "/code/careers/proxy.php?v=" + vizURL,
        dataType:"json",
        async: false
        }).responseText;
}

// Display a country based intensity map 
function drawJobsByCountry() {
}

// Display data regarding remote and local jobs as a pie chart
function drawJobsRemoteVsLocal() {
    var data = new google.visualization.DataTable(fetchData('remotevslocal'));
    var visualization = new google.visualization.PieChart(document.getElementById('remote_vs_local_chart'));
    visualization.draw(data, {is3D:true});
}

// This also requires swfobject.js, currently unused as it's not very useful (though pretty...)
function drawJobsByTagCumulus() {
    var data = new google.visualization.DataTable(fetchData('tagcumulus'));
    var visualization = new gviz_word_cumulus.WordCumulus(document.getElementById('tag_chart_cumulus'));
    visualization.draw(data, {text_color: '#000000', speed: 30, width:400, height:400});
}

// Display the occurrence of tags as a term cloud. Nothing particularly fancy, the style is defined externally.
function drawJobsByTagCloud() { 
    var data = new google.visualization.DataTable(fetchData('tagcloud'));
    var visualization = new TermCloud(document.getElementById("tag_chart_cloud"));
    visualization.draw(data, null);
}

function drawTagsRelated() {
    var data = fetchData('tagsgraph');

    var row_height = 60;
    var row_width = 400;

    if(data != null && data.length > 0) {
        var paper = Raphael(0, 0, 400, row_height * data.length);

        var x,y,i = 0;
        for (var main_tag in data) {
            paper.text(0, row_height*i++, main_tag);
        }
    }
}


