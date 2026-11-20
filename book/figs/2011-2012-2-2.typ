#import "@preview/cetz:0.5.3"
#align(center, cetz.canvas(length: 0.0172cm, {
  import cetz.draw: *
  let P(x, y) = (x, -y)
  let lab(p, body, anchor: "center") = content(p, anchor: anchor, padding: 5, box(fill: white, inset: 1pt, text(size: 8pt, body)))
  let ell = (paint: black, thickness: 0.6pt)
  // 等值线
  circle(P(805, 275), radius: (197, 143), stroke: ell)
  circle(P(799, 272), radius: (131, 88), stroke: ell)
  circle(P(802, 270), radius: (80, 42), stroke: ell)
  lab(P(886, 147), $f=8$)
  lab(P(870, 205), $f=5$)
  lab(P(860, 268), $f=0$)
  // 极小点 x-bar 及初始点
  circle(P(800, 270), radius: 3, fill: black)
  lab(P(800, 270), $overline(x)$, anchor: "north-east")
  circle(P(665, 168), radius: 3, fill: black)
  lab(P(665, 168), $overline(x)_0$, anchor: "south-east")
}))
