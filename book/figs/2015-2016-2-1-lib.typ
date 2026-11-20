#import "@preview/cetz:0.5.3"

// 2015–2016 二(1) 的三张图；ans: true 时画出迭代路径
#let arrow-st = (mark: (end: ">", fill: black, scale: 0.6), stroke: 0.9pt)
#let dot(p) = cetz.draw.circle(p, radius: 0.05, fill: black)

#let fig-a(ans) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  line((0.9, 2.6), (0.85, 1.15), (1.5, 0.88), (2.3, 1.25), (2.6, 2.6), stroke: 0.7pt)
  content((1.7, 1.9), $D$)
  line((3.0, 2.6), (3.0, 2.2), mark: (end: ">", fill: black, scale: 0.5), stroke: 0.6pt)
  content((3.25, 2.4), $c$)
  dot((1.5, 0.88))
  content((1.5, 0.88), anchor: "north", padding: 0.08, $overline(x)_0$)
  if ans {
    line((1.5, 0.88), (2.3, 1.25), ..arrow-st)
    line((2.3, 1.25), (2.55, 2.35), ..arrow-st)
    dot((2.3, 1.25))
    content((2.3, 1.25), anchor: "west", padding: 0.1, $overline(x)_1$)
  }
})

#let fig-b(ans) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let v = ((4.45, 2.62), (5.2, 2.55), (5.45, 2.0), (5.35, 1.4), (4.85, 0.95), (4.2, 0.88), (3.65, 1.2), (3.6, 1.9))
  line(..v, close: true, stroke: 0.7pt)
  line((5.6, 1.9), (5.85, 2.32), mark: (end: ">", fill: black, scale: 0.5), stroke: 0.6pt)
  content((6.0, 2.1), $c$)
  dot((5.2, 2.55))
  content((5.2, 2.55), anchor: "south-west", padding: 0.05, $overline(x)_0$)
  if ans {
    line((5.2, 2.55), (4.45, 2.62), ..arrow-st)
    line((4.45, 2.62), (3.6, 1.9), ..arrow-st)
    line((3.6, 1.9), (3.65, 1.2), ..arrow-st)
    line((3.65, 1.2), (4.2, 0.88), stroke: 2pt)
    for (i, p) in ((1, (4.45, 2.62)), (2, (3.6, 1.9)), (3, (3.65, 1.2))) {
      dot(p)
      content(p, anchor: "east", padding: 0.08, $overline(x)_#i$)
    }
  }
})

#let fig-c(ans) = cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let base = ((0, 1.0), (-0.6, 0.45), (-0.95, -0.35), (-0.6, -0.75), (0.6, -0.75), (0.95, -0.35), (0.6, 0.45))
  for s in (0.3, 0.6, 0.9, 1.2, 1.5) {
    catmull(..base.map(((x, y)) => (x * s, y * s + 0.05)), close: true, stroke: 0.6pt)
  }
  dot((0, 0.05))
  content((0, 0.05), anchor: "east", padding: 0.08, $overline(x)^*$)
  dot((0.8, -1.3))
  content((0.8, -1.3), anchor: "north", padding: 0.08, $overline(x)_0$)
  if ans {
    let p = ((0.8, -1.3), (0.78, -0.62), (0.08, -0.6), (0.06, -0.1))
    for i in range(3) { line(p.at(i), p.at(i + 1), ..arrow-st) }
    for (i, q) in p.enumerate().slice(1) {
      dot(q)
      content(q, anchor: "west", padding: 0.08, text(size: 7pt, $overline(x)_#i$))
    }
  }
})

#let fig(ans: false) = align(center, grid(columns: 3, column-gutter: 1.5em, row-gutter: 0.4em, align: center + bottom,
  fig-a(ans), fig-b(ans), fig-c(ans), [(a)], [(b)], [(c)]))
