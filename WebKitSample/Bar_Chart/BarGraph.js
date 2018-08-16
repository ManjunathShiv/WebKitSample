
var margin = {top: 20, right: 10, bottom: 100, left:50},
    width = 700 - margin.right - margin.left,
    height = 700 - margin.top - margin.bottom;

/*------------------------------------------------------------------------------
define SVG
------------------------------------------------------------------------------*/
var svg = d3.select("body")
    .append("svg")
      .attr ({
        "width": width + margin.right + margin.left,
        "height": height + margin.top + margin.bottom
      })
    .append("g")
      .attr("transform","translate(" + margin.left + "," + margin.right + ")");


/* -----------------------------------------------------------------------------
SCALE and AXIS are two different methods of D3. See D3 API Refrence for info on
AXIS and SCALES. See D3 API Refrence to understand the difference between
Ordinal vs Linear scale.
------------------------------------------------------------------------------*/
// define x and y scales
var xScale = d3.scale.ordinal()
    .rangeRoundBands([0,width], 0.2, 0.2);

var yScale = d3.scale.linear()
    .range([height, 0]);

// define x axis and y axis
var xAxis = d3.svg.axis()
    .scale(xScale)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(yScale)
    .orient("left");

/* -----------------------------------------------------------------------------
To understand how to import data. See D3 API refrence on CSV. Understand
the difference between .csv, .tsv and .json files. To import a .tsv or
.json file use d3.tsv() or d3.json(), respectively.
------------------------------------------------------------------------------*/
var rawData = "[{\"country\": \"Brazil\",\"gdp\": \"2.14\"}, {\"country\": \"Italy\",\"gdp\": \"2.04\"}, {\"country\": \"India\",\"gdp\": \"1.70\"}, {\"country\": \"Canada\",\"gdp\": \"1.57\"}, {\"country\": \"Russian Federation\",\"gdp\": \"1.52\"}, {\"country\": \"Spain\",\"gdp\": \"1.37\"}, {\"country\": \"Australia\",\"gdp\": \"1.14\"}, {\"country\": \"Mexico\",\"gdp\": \"1.04\"}, {\"country\": \"Korea\",\"gdp\": \"1.01\"}, {\"country\": \"United States\",\"gdp\": \"14.9\"}, {\"country\": \"China\",\"gdp\": \"5.93\"}, {\"country\": \"Japan\",\"gdp\": \"5.49\"}, {\"country\": \"Germany\",\"gdp\": \"3.28\"}, {\"country\": \"France\",\"gdp\": \"2.54\"}, {\"country\": \"United Kingdom\",\"gdp\": \"2.28\"}]"

function loadGraph()
 {
     var data = JSON.parse(rawData)
  //if(error) console.log("Error: data not loaded!");

  /*----------------------------------------------------------------------------
  Convert data if necessary. We want to make sure our gdp vaulues are
  represented as integers rather than strings. Use "+" before the variable to
  convert a string represenation of a number to an actual number. Sometimes
  the data will be in number format, but when in doubt use "+" to avoid issues.
  ----------------------------------------------------------------------------*/
  data.forEach(function(d) {
    d.country = d.country;
    d.gdp = +d.gdp;       // try removing the + and see what the console prints
    console.log(d.gdp);   // use console.log to confirm
  });

  // sort the gdp values
  data.sort(function(a,b) {
    return b.gdp - a.gdp;
  });

  // Specify the domains of the x and y scales
  xScale.domain(data.map(function(d) { return d.country; }) );
  yScale.domain([0, d3.max(data, function(d) { return d.gdp; } ) ]);

  svg.selectAll('rect')
    .data(data)
    .enter()
    .append('rect')
    .attr("height", 0)
    .attr("y", height)
//     .transition().duration(3000)
//     .delay( function(d,i) { return i * 200; })
    // attributes can be also combined under one .attr
    .attr({
      "x": function(d) { return xScale(d.country); },
      "y": function(d) { return yScale(d.gdp); },
      "width": xScale.rangeBand(),
      "height": function(d) { return  height - yScale(d.gdp); }
    })
    //     .style("fill", function(d,i) { return 'rgb(20, 20, ' + ((i * 30) + 100) + ')'});


        svg.selectAll('text')
            .data(data)
            .enter()
            .append('text')

            .text(function(d){
                return d.gdp;
            })
            .attr({
                "x": function(d){ return xScale(d.country) +  xScale.rangeBand()/2; },
                "y": function(d){ return yScale(d.gdp)+ 12; },
                "font-family": 'sans-serif',
                "font-size": '13px',
                "font-weight": 'bold',
                "fill": 'white',
                "text-anchor": 'middle'
            });

    // Draw xAxis and position the label
    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
        .selectAll("text")
        .attr("dx", "-.8em")
        .attr("dy", ".25em")
        .attr("transform", "rotate(-60)" )
        .style("text-anchor", "end")
        .attr("font-size", "10px");


    // Draw yAxis and postion the label
    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("x", -height/2)
        .attr("dy", "-3em")
        .style("text-anchor", "middle")
        .text("Trillions of US Dollars ($)");
}

loadGraph();
