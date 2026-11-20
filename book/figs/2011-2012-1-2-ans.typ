#import "@preview/cetz:0.5.3"
#align(center, cetz.canvas(length: 0.0172cm, {
  import cetz.draw: *
  let P(x, y) = (x, -y)
  let lab(p, body, anchor: "center") = content(p, anchor: anchor, padding: 5, box(fill: white, inset: 1pt, text(size: 8pt, body)))
  // 容许集 D
  line(P(150, 228), P(240, 153), P(345, 140), P(440, 190), P(440, 318), P(340, 408), P(220, 412), P(150, 340), close: true, stroke: 0.7pt)
  // 目标函数的等值线（虚线，与 -c 垂直）
  let dash = (paint: black, thickness: 0.6pt, dash: "dashed")
  line(P(45, 360), P(255, 55), stroke: dash)
  line(P(195, 269), P(335, 64), stroke: dash)
  line(P(265, 375), P(480, 40), stroke: dash)
  // 负梯度 -c
  line(P(135, 98), P(205, 128), mark: (end: ">", fill: black, scale: 0.8), stroke: 0.6pt)
  lab(P(238, 110), $-vec(c)$, anchor: "west")
  // 初始点及标注
  circle(P(150, 228), radius: 3, fill: black)
  lab(P(150, 228), $x^((0))$, anchor: "north-east")
  lab(P(300, 275), $D$)
  let st = (mark: (end: ">", fill: black, scale: 0.6), stroke: 1pt)
  line(P(150, 228), P(150, 340), ..st)
  line(P(150, 340), P(220, 412), ..st)
  line(P(220, 412), P(340, 408), ..st)
  line(P(340, 408), P(440, 318), ..st)
  for (p, l, a) in (((150, 340), $x^((1))$, "east"), ((220, 412), $x^((2))$, "north"), ((340, 408), $x^((3))$, "north"), ((440, 318), $x^((4)) = x^*$, "west")) {
    circle(P(..p), radius: 3, fill: black)
    lab(P(..p), l, anchor: a)
  }
}))
