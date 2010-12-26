    /* Sizing and scales. */
    var w = 780,
        h = 400,
        colName = data.colNames[0], // get the only column name
        x = pv.Scale.linear(data.startTs, data.endTs).range(0, w),
        y = pv.Scale.linear(pv.min(data['records'][colName], function(d) d.value), pv.max(data['records'][colName], function(d) d.value)).range(0, h),
        i = -1; // mouseover index
    
    /* The root panel. */
    var vis = new pv.Panel()
        .width(w)
        .height(h)
        .bottom(50)
        .left(50)
        .right(10)
        .top(10)
        .events("all")
        .event("mousemove", pv.Behavior.point(Infinity).collapse("y"));
    
    /* Y-axis and ticks. */
    vis.add(pv.Rule)
        .data(y.ticks(5))
        .bottom(y)
        .strokeStyle(function(d) d ? "#aaa" : "#000")
      .anchor("left").add(pv.Label)
        .text(y.tickFormat);
    
    /* X-axis and ticks. */
    vis.add(pv.Rule)
        .data(x.ticks())
        .visible(function(d) d)
        .left(x)
        .bottom(-5)
        .height(5)
        .visible(function() this.index & 1)
      .anchor("bottom").add(pv.Label)
        .text(x.tickFormat);
    
    /* The area with top line. */
    var area = vis.add(pv.Area)
        .data(data['records'][colName])
        .bottom(1)
        .left(function(d) x(d.timestamp))
        .height(function(d) y(d.value))
        .fillStyle("rgb(95,165,212)")
        .event("point", function() (i = this.index, vis))
        .event("unpoint", function() (i = -1, vis))
      .anchor("top").add(pv.Line)
        .lineWidth(0);
        
    /* Label at the bottom left displaying the timestamp/values for the corresponding index */    
    vis.add(pv.Label)
        .left(w)
        .bottom(-30)
        .textBaseline("top")
        .textAlign("right")
        .text(function() { if(i != -1) { 
                            return "time : " + data['records'][colName][i]['timestamp'] + ", value : " + data['records'][colName][i]['value'];
                           } else {
                            return "";
                           }});
    
    /* The Dot Chart */    
    area.add(pv.Dot)
        .visible(function() i == this.index)
        .fillStyle("#444444");
    
    /* The labels for the axes */   
    vis.add(pv.Label)
        .left(-35)
        .bottom(h/2)
        .text(this.colName.substr(3))
        .textAlign("center")
        .textAngle(-Math.PI/2)
        .font('12px sans-serif');
    
    vis.add(pv.Label)
        .text("time [ms]")
        .bottom(-35)
        .left(w/2)
        .textAlign("center")
        .font('12px sans-serif');
    
    vis.render();
    