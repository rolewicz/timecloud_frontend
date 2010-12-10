var entries = pv.entries(data.records);

var w = 350,
    h = 40,
    fx = function(d) d.timestamp,
    fy = function(d) d.value,
    x = pv.Scale.linear(data.startTs, data.endTs).range(0, w);

/* Tile the visualization for each job. */
var vis = new pv.Panel()
    .data(entries)
    .width(w)
    .height(h + 8)
    .margin(6);

/* A panel instance to store scales (x, y). */
var panel = vis.add(pv.Panel)
    .bottom(10)
    .def("y", function(d) pv.Scale.linear(pv.min([0, pv.min(d.value, fy)]), pv.max([0, pv.max(d.value, fy)])).range(0, h))
    .events("all")
    .event("mousemove", pv.Behavior.point().collapse("y"));

/* The area. */
var area = panel.add(pv.Area)
    .def("i", -1)
    .data(function(d) d.value)
    .left(function(d) x(fx(d)))
    .height(function(d) panel.y()(fy(d)))
    .bottom(0)
    .fillStyle(pv.Colors.category19().by(function() panel.parent.index))
    .event("point", function() this.i(this.index).parent)
    .event("unpoint", function() this.i(-1).parent);

/* The x-axis. */
panel.add(pv.Rule)
    .bottom(-1);

/* The mouseover dot and label. */
panel.add(pv.Dot)
    .data(function(d) [d.value[area.i()]])
    .visible(function(d) d)
    .left(function(d) x(fx(d)))
    .bottom(function(d) panel.y()(fy(d)))
    .fillStyle("#ff0e0e")
    .strokeStyle(null)
    .size(10)
  .add(pv.Label)
    .left(w)
    .bottom(-1)
    .textBaseline("top")
    .textAlign("right")
    .text(function(d) "time: " + d.timestamp + " - value: " + d.value);

/* The job name label. */
panel.add(pv.Label)
    .visible(function() area.i() < 0)
    .bottom(-1)
    .textBaseline("top")
    .textStyle("#444")
    .text(function(d) d.key);

vis.render();
