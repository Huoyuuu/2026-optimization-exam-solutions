#import "@preview/cetz:0.5.3"

// 每条边上的刻度线（垂直于边、指向容许集内侧，左手法向，多边形取逆时针顶点）
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
  let P = ((0, 2.28), (0, 0), (2.69, -0.82), (4.15, 1.15), (2.52, 3.23))
  // 容许集（有界五边形）
  line(..P, close: true, fill: luma(230), stroke: 0.7pt + black)
  for i in range(5) {
    for (a, b) in ticks(P.at(i), P.at(calc.rem(i + 1, 5))) {
      line(a, b, stroke: 0.7pt + black)
    }
  }
  content((1.9, 1.2), text(size: 8pt)[$D$])
  // 坐标轴，带箭头
  line((-0.6, -1.2), (4.8, -1.2), stroke: 0.7pt + black, mark: (end: ">", fill: black, scale: 0.6))
  line((-0.6, -1.2), (-0.6, 3.8), stroke: 0.7pt + black, mark: (end: ">", fill: black, scale: 0.6))
  content((4.9, -1.5), text(size: 8pt)[$x_1$])
  content((-0.6, 4.1), text(size: 8pt)[$x_2$])
})
