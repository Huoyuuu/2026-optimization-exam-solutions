#import "@preview/cetz:0.5.3"
#align(center, cetz.canvas(length: 0.0172cm, {
  import cetz.draw: *
  let P(x, y) = (x, -y)
  let lab(p, body, anchor: "center") = content(p, anchor: anchor, padding: 5, box(fill: white, inset: 1pt, text(size: 8pt, body)))
  let ell = (paint: black, thickness: 0.6pt)
  // 等值线
  circle(P(1289, 283), radius: (204, 146), stroke: ell)
  circle(P(1284, 282), radius: (136, 88), stroke: ell)
  circle(P(1290, 280), radius: (78, 43), stroke: ell)
  lab(P(1140, 165), $f=7$)
  lab(P(1190, 210), $f=4$)
  lab(P(1262, 242), $f=1$)
  // 极小点 x-bar 及初始点
  circle(P(1282, 282), radius: 3, fill: black)
  lab(P(1282, 282), $overline(x)$, anchor: "north-east")
  circle(P(1420, 172), radius: 3, fill: black)
  lab(P(1420, 172), $overline(x)_0$, anchor: "south-west")
}))
