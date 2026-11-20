#import "@preview/cetz:0.5.3"

// 每条边上的刻度线（垂直于边、指向容许集内侧，左手法向）
#let ticks(p, q, gap: 0.5, len: 0.18) = {
  let dx = q.at(0) - p.at(0)
  let dy = q.at(1) - p.at(1)
  let big = calc.sqrt(dx * dx + dy * dy)
  let k = calc.floor(big / gap)
  let nx = -dy / big
  let ny = dx / big
  range(1, k + 1).map(i => {
    let t = i / (k + 1)
    let mx = p.at(0) + t * dx
    let my = p.at(1) + t * dy
    ((mx, my), (mx + len * nx, my + len * ny))
  })
}

#cetz.canvas(length: 0.9cm, {
  import cetz.draw: *
  // 边界折线：4 个有限顶点 a、b、x0、c，两端是射线（无界）
  let top = (-0.70, 4.15)
  let a = (-1.10, 2.20)
  let b = (-1.10, 0.80)
  let x0 = (0, 0)
  let c = (1.70, 0.15)
  let e = (2.80, 2.15)
  // 射线的延伸，只用于填充和虚线示意无界
  let topx = (-0.30, 5.55)
  let ex = (3.90, 4.15)
  line(topx, top, a, b, x0, c, e, ex, close: true, fill: luma(230), stroke: none)
  line(top, a, b, x0, c, e, stroke: 0.7pt + black)
  line(topx, top, stroke: (paint: black, thickness: 0.7pt, dash: "dashed"))
  line(e, ex, stroke: (paint: black, thickness: 0.7pt, dash: "dashed"))
  for (p, q) in ((top, a), (a, b), (b, x0), (x0, c), (c, e)) {
    for (s, t) in ticks(p, q) {
      line(s, t, stroke: 0.7pt + black)
    }
  }
  // 基本容许解 x̄_0 所在顶点
  circle(x0, radius: 0.05, stroke: 0.7pt + black, fill: white)
  content((0, -0.45), text(size: 8pt)[$overline(x)_0$])
  content((0.8, 2.4), text(size: 8pt)[$D$])
  // 坐标轴，带箭头
  line((-2.0, -0.8), (3.6, -0.8), stroke: 0.7pt + black, mark: (end: ">", fill: black, scale: 0.6))
  line((-2.0, -0.8), (-2.0, 4.8), stroke: 0.7pt + black, mark: (end: ">", fill: black, scale: 0.6))
  content((3.7, -1.1), text(size: 8pt)[$x_1$])
  content((-2.0, 5.1), text(size: 8pt)[$x_2$])
})
