#import "@preview/cetz:0.5.3"
#align(center, cetz.canvas(length: 1cm, {
  import cetz.draw: *
  let grid = luma(170)
  // 水平网格线：x_2 = -2, ..., 3
  for y in range(-2, 4) {
    line((-2.9, y), (3.8, y), stroke: 0.3pt + grid)
  }
  // 竖直网格线：x_1 = -2, ..., 3
  for x in range(-2, 4) {
    line((x, -2.5), (x, 3.4), stroke: 0.3pt + grid)
  }
  // 坐标轴，带箭头
  line((-2.9, 0), (4.3, 0), stroke: 0.7pt + black, mark: (end: ">", fill: black, scale: 0.6))
  line((0, -2.6), (0, 3.6), stroke: 0.7pt + black, mark: (end: ">", fill: black, scale: 0.6))
  content((4.3, -0.4), text(size: 8pt)[$x_1$])
  content((-0.3, 3.75), text(size: 8pt)[$x_2$])
}))
