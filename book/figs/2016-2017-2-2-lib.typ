#import "@preview/cetz:0.5.3"

// 2016–2017 二(2)：容许域 R 由 s1（圆弧）、s2（线段）、s3（圆弧）和两条坐标轴围成；
// 等值线是以 C 为心的圆弧，f 越往右上越小。ans: true 时画出各梯度方向。
#let fig(ans: false) = align(center, cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let X1 = (1.9, 2.7)
  let X2 = (4.6, 1.3)
  let C = (7.5, 4.5)
  let dist(p) = calc.sqrt(calc.pow(p.at(0) - C.at(0), 2) + calc.pow(p.at(1) - C.at(1), 2))
  let arc-pts(cx, cy, r, a0, a1) = range(0, 25).map(i => {
    let t = (a0 + (a1 - a0) * i / 24) * 1deg
    (cx + r * calc.cos(t), cy + r * calc.sin(t))
  })
  // s1：圆心 (1.9, 0.51)，半径 2.19，从 y 轴到 x1；s3：圆心 (2.69, 0)，半径 2.31，从 x2 到 x1 轴
  let a1 = arc-pts(1.9, 0.51, 2.19, 180 - 29.85, 90)
  let a3 = arc-pts(2.69, 0, 2.31, 34.3, 0)
  line((0, 0), ..a1, ..a3, close: true, fill: luma(235), stroke: none)
  line(..a1, stroke: 0.8pt)
  line(X1, X2, stroke: 0.8pt)
  line(..a3, stroke: 0.8pt)
  line((0, 0), (6.6, 0), mark: (end: ">", scale: 0.6), stroke: 0.6pt)
  line((0, 0), (0, 3.6), mark: (end: ">", scale: 0.6), stroke: 0.6pt)
  content((6.6, 0), anchor: "west", padding: 0.08, $x_1$)
  content((0, 3.6), anchor: "south", padding: 0.08, $x_2$)
  content((1.3, 0.8), $R$)
  let ds = (dash: "dotted", thickness: 0.7pt)
  for (r, lab) in ((3.1, $f = 3$), (3.7, $f = 5$), (dist(X2), $f = 7$)) {
    line(..arc-pts(C.at(0), C.at(1), r, 182, 238), stroke: ds)
    content(arc-pts(C.at(0), C.at(1), r, 238, 238).at(0), anchor: "north", padding: 0.05, text(size: 7.5pt, lab))
  }
  line(..arc-pts(C.at(0), C.at(1), dist(X1), 175, 190), stroke: ds)
  content((0.95, 1.75), text(size: 7.5pt, $s_1(x) = 0$))
  content((3.55, 2.4), text(size: 7.5pt, $s_2(x) = 0$))
  content((5.3, 0.45), anchor: "west", text(size: 7.5pt, $s_3(x) = 0$))
  for (p, lab, an) in ((X1, $overline(x)_1$, "south"), (X2, $overline(x)_2$, "south-west")) {
    circle(p, radius: 0.05, fill: black)
    content(p, anchor: an, padding: 0.1, lab)
  }
  if ans {
    let ar(p, d, lab, an) = {
      let n = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
      let q = (p.at(0) + 0.9 * d.at(0) / n, p.at(1) + 0.9 * d.at(1) / n)
      line(p, q, mark: (end: ">", fill: black, scale: 0.5), stroke: 0.8pt)
      content(q, anchor: an, padding: 0.05, text(size: 7pt, lab))
    }
    ar(X1, (0, -1), $nabla s_1$, "north")
    ar(X1, (-1.4, -2.7), $nabla s_2$, "north-east")
    ar(X1, (-5.6, -1.8), $nabla f$, "east")
    ar(X2, (-1.4, -2.7), $nabla s_2$, "north")
    ar(X2, (-1.91, -1.3), $nabla s_3$, "east")
    ar(X2, (-2.9, -3.2), $nabla f$, "north-east")
  }
}))
