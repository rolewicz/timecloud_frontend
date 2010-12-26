var entries = pv.entries(data.records)

/* Chart dimensions and scales. */
var w = 780,
    h = 300,
    fx = function(d) d.timestamp,
    fy = function(d) d.value,
    x = pv.Scale.linear(data.startTs, data.endTs).range(0, w),
    y = pv.Scale.linear(data.minValue, data.maxValue).range(0, h);

/* The root panel. */
var vis = new pv.Panel()
    .width(w)
    .height(h)
    .bottom(120)
    .left(30)
    .right(10)
    .top(5);

/* Y-ticks. */
vis.add(pv.Rule)
    .data(y.ticks())
    .visible(function() !(this.index % 2))
    .bottom(function(d) Math.round(y(d)) - .5)
    .strokeStyle(function(d) d ? "#aaa" : "#000")
  .anchor("left").add(pv.Label)
    .text(function(d) d.toFixed(1));

/* X-ticks. */
vis.add(pv.Rule)
    .data(x.ticks())
    .visible(function(d) d > 0)
    .left(function(d) Math.round(x(d)) - .5)
    .strokeStyle(function(d) d ? "#aaa" : "#000")
  .anchor("bottom").add(pv.Label)
    .text(function(d) d.toFixed());

/* A panel for each data series. */
var panel = vis.add(pv.Panel)
    .data(entries);

/* The line and the dot showing the name of the data used */
var line = panel.add(pv.Line)
    .data(function(d) d.value)
    .left(function(d) x(fx(d)))
    .bottom(function(d) y(fy(d)))
    .lineWidth(2)
    .strokeStyle(pv.Colors.category19().by(function() panel.index))
  .add(pv.Dot)
    .left(function() 10 + (w/2)*(this.parent.index%2) )
    .bottom(function() this.parent.index%2 == 0 ? (this.parent.index/2)*(-14)-25 : ((this.parent.index - 1)/2)*(-14)-25)
    //.fillStyle(function() line.strokeStyle())
  .anchor("right").add(pv.Label)
    .font(function() "12px sans-serif")
    .text(function() entries[this.parent.index].key.substr(3));



vis.render();
