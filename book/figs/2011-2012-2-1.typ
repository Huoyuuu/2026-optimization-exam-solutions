#import "@preview/cetz:0.5.3"
#align(center, cetz.canvas(length: 0.0172cm, {
  import cetz.draw: *
  let P(x, y) = (x, -y)
  let lab(p, body, anchor: "center") = content(p, anchor: anchor, padding: 5, box(fill: white, inset: 1pt, text(size: 8pt, body)))
  let ell = (paint: black, thickness: 0.6pt)
  // 等值线
  circle(P(302, 259), radius: (207, 151), stroke: ell)
  circle(P(301, 260), radius: (139, 95), stroke: ell)
  circle(P(300, 260), radius: (75, 45), stroke: ell)
  circle(P(298, 258), radius: (26, 17), stroke: ell)
  lab(P(155, 140), $f=9$)
  lab(P(210, 180), $f=6$)
  lab(P(262, 218), $f=1$)
  // 初始点
  circle(P(432, 147), radius: 3, fill: black)
  lab(P(432, 147), $overline(x)_0$, anchor: "south-west")
}))
