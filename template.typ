// 考试资料通用版式（屏幕阅读）。各科复用：改 conf 的 course 参数，框和问答直接用。
// 框的样式沿用 2026-distributed-database-exam-solutions：黑底部分标题、做法框左侧粗黑条、
// 参考答案双线框、注意虚线框、原题深灰标题条。正文用黑体；行距、框距放宽，每部分另起一页。

#let sans = ("Noto Sans CJK SC", "Microsoft YaHei", "SimHei")
#let mathf = ("New Computer Modern Math",)

// ---------- 页面 ----------
// compact：试卷数字版用紧凑设置（每套卷子要排满两页）；解析书用宽松设置
#let conf(course: "", compact: false, body) = {
  let c(a, b) = if compact { a } else { b }
  set page(
    paper: "a4",
    margin: c((top: 1.55cm, bottom: 1.4cm, x: 1.45cm), (top: 2.1cm, bottom: 1.9cm, x: 2.1cm)),
    header-ascent: 40%,
    footer-descent: 40%,
    header: context {
      let p = here().page()
      if p == 1 { return }
      // 本页有新的一级标题就显示它，否则显示前面最后一个
      let all = query(heading.where(level: 1))
      let here-hs = all.filter(h => h.location().page() == p)
      let hs = if here-hs.len() > 0 { here-hs } else { all.filter(h => h.location().page() < p) }
      set text(size: 8.5pt)
      grid(
        columns: (1fr, auto),
        course,
        if hs.len() > 0 {
          let hd = if here-hs.len() > 0 { hs.first() } else { hs.last() }
          if hd.numbering != none [第 #counter(heading).at(hd.location()).first() 部分#h(0.6em)#hd.body] else [#hd.body]
        },
      )
      v(-0.55em)
      line(length: 100%, stroke: 0.5pt)
    },
    footer: context align(center, text(size: 8.5pt)[— #counter(page).display() —]),
  )
  set text(font: sans, size: c(10pt, 10.5pt), lang: "zh", region: "cn")
  set par(leading: c(0.62em, 0.95em), spacing: c(0.75em, 1.25em), justify: true, first-line-indent: 0pt)
  show math.equation: set text(font: mathf + sans)
  set math.equation(numbering: none)
  show math.equation.where(block: true): set block(above: c(0.75em, 1em), below: c(0.75em, 1em))
  // 解析书的行内矩阵按正常字号排，不缩小
  show math.equation.where(block: false): it => { show math.mat: m => if compact { m } else { math.display(m) }; it }
  set list(indent: 0.4em, body-indent: 0.5em, spacing: c(0.55em, 0.95em))
  set enum(indent: 0.2em, body-indent: 0.5em, spacing: c(0.55em, 0.95em))
  set table(stroke: none, inset: c((x: 4pt, y: 2.6pt), (x: 5pt, y: 3.5pt)))
  set strong(delta: 300)

  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    // 带编号的部分另起一页（试卷数字版的标题不编号，在容器里，不能分页）
    if it.numbering != none { pagebreak(weak: true) }
    set text(size: c(13.5pt, 15pt), weight: "bold")
    block(above: 0.4em, below: c(0.7em, 1.6em), sticky: true, width: 100%, {
      set par(spacing: 0.55em)
      if it.numbering != none {
        box(fill: black, inset: (x: 5pt, y: 3.5pt), outset: (y: 0pt),
          text(fill: white)[第 #counter(heading).display("1") 部分])
        h(0.7em)
      }
      it.body
      line(length: 100%, stroke: 1.2pt)
    })
  }
  show heading.where(level: 2): it => block(above: 2.4em, below: 1em, sticky: true, {
    set text(size: 12.5pt, weight: "bold")
    if it.numbering != none { counter(heading).display("1.1"); h(0.6em) }
    it.body
  })
  show heading.where(level: 3): it => block(above: 1.8em, below: 0.9em, sticky: true,
    text(size: 11pt, weight: "bold", it.body))
  body
}

// ---------- 工具 ----------
// 页码：按标签查所在页
#let pg(lbl) = context {
  let q = query(lbl)
  if q.len() > 0 { str(counter(page).at(q.first().location()).first()) } else [?]
}
// 一个框的标题标签：dark 为真时黑底白字，否则白底黑框
#let tab-label(title, dark: true, stroke: 0.5pt + black) = box(
  fill: if dark { black } else { white },
  stroke: if dark { none } else { stroke },
  inset: (x: 5pt, y: 2.6pt),
  text(size: 9pt, weight: "bold", fill: if dark { white } else { black }, title),
)
// 正文开头第一个块的 above 间距（不是块就返回 0pt）
#let lead-gap(body) = {
  let c = body
  while c.func() == [].func() {
    let ch = c.children.filter(x => x.func() not in ([ ].func(), parbreak))
    if ch.len() == 0 { return 0pt }
    c = ch.first()
  }
  if c.func() == block and c.has("above") { c.above } else { 0pt }
}

// 带“骑线标题”的框：标题压在上边框上，左移 4mm
#let titled(title, body, dark: true, stroke: 0.6pt + black, frame: (:), breakable: true,
  title-stroke: 0.5pt + black, inset: (x: 10pt, top: 13pt, bottom: 9pt), above: 1.9em, below: 1.4em) = block(
  width: 100%, breakable: breakable, above: above, below: below,
  stroke: frame, inset: inset,
  {
    // 标题放在一个粘住下文的空块里，避免框的标题单独留在页底；
    // 再抵消正文第一个块（如 #step）的 above 间距，框顶留白和原来一样
    if title != none {
      block(sticky: true, above: 0pt, below: 0pt, width: 100%,
        place(top + left, dx: 2mm, dy: -inset.top - 7.4pt, tab-label(title, dark: dark, stroke: title-stroke)))
      let g = lead-gap(body)
      if g != 0pt { v(-g) }
    }
    body
  },
)

// ---------- 几种框 ----------
// 做法：左侧粗黑条，黑底标题
#let flow(title: none, body) = titled(title, body, dark: true,
  frame: (left: 3.5pt + black, rest: 0.6pt + black))

// 参考答案：双线框，白底黑框标题
#let ans(title: none, body) = {
  let t = if title == none [参考答案] else [参考答案：#title]
  block(width: 100%, breakable: true, above: 1.5em, below: 2.2em,
    stroke: 0.5pt + black, inset: 1.8pt,
    titled(t, body, dark: false, frame: 0.5pt + black, above: 0pt, below: 0pt,
      inset: (x: 9pt, top: 12pt, bottom: 9pt)))
}

// 答案里的步骤标题：单独一行，加粗，和下面的算式不分页
#let step(body) = block(above: 1.15em, below: 0.6em, sticky: true, text(weight: "bold", body))
// 答案里的结论：灰底框，突出最后的答案
#let concl(body) = block(width: 100%, above: 1em, below: 0.4em, fill: luma(232), inset: (x: 8pt, y: 6pt),
  [#text(weight: "bold")[结论] #h(0.5em) #body])

// 注意：虚线框
#let pit(title: none, body) = {
  let t = if title == none [注意] else [注意：#title]
  titled(t, body, dark: false, title-stroke: none,
    frame: (paint: black, thickness: 0.7pt, dash: "dashed"), breakable: false)
}

// 其他：细灰框
#let var(title: none, body) = titled(title, body, dark: false,
  title-stroke: 0.4pt + luma(100), frame: 0.4pt + luma(100))

// 原题：深灰标题条（试卷、题号、分值），题干小一号；和下面的答卷尽量同页
#let prob(title, body) = block(
  width: 100%, breakable: false, sticky: true, above: 2.2em, below: 1.2em,
  stroke: 0.4pt + black,
  stack(
    block(width: 100%, fill: luma(64), inset: (x: 7pt, y: 4pt),
      text(size: 9pt, weight: "bold", fill: white, title)),
    block(width: 100%, inset: (x: 9pt, y: 8pt), text(size: 10pt, body)),
  ),
)

// ---------- 问答 ----------
// 一组问答，小一号
#let dlg(body) = block(above: 1.6em, below: 1.6em, { set text(size: 10pt); body })
#let qa-col = 2.3em
#let Q(body) = block(sticky: true, above: 1.1em, below: 0.55em,
  grid(columns: (qa-col, 1fr),
    box(fill: black, inset: (x: 2.6pt, y: 1.8pt), text(size: 8.5pt, weight: "bold", fill: white)[问]),
    text(weight: "bold", body)))
#let A(body) = block(above: 0.55em, below: 0.9em,
  grid(columns: (qa-col, 1fr),
    box(stroke: 0.5pt + black, inset: (x: 2.6pt, y: 1.8pt), text(size: 8.5pt, weight: "bold")[答]),
    body))

// ---------- 表格 ----------
// 三线表：hdr 是表头一行，其余是数据
#let three-line(columns: auto, align: center, hdr, ..cells) = table(
  columns: columns, align: align,
  table.hline(stroke: 0.8pt),
  ..hdr.map(c => text(weight: "bold", c)),
  table.hline(stroke: 0.5pt),
  ..cells,
  table.hline(stroke: 0.8pt),
)

// 填空题的横线：n 是原卷横线的长短（下划线个数）
#let blank(n) = box(width: calc.min(calc.max(n * 0.55, 4), 9) * 1em, stroke: (bottom: 0.5pt), outset: (bottom: 2pt))

// 主元：加方框
#let pv(x) = box(stroke: 0.6pt + black, inset: (x: 2pt, y: 1.6pt), outset: (y: 0.5pt), x)

// 单纯形表（教材格式）：列为 x_B、各变量、b̄、比值；每张表最后一行是判别数行。
// vars：变量名数组；blocks：交替给出表名和行数组，每行 = (基变量, 各列数, b̄, 比值)，比值可省。
// 数字可以直接写整数，分数写 $1/2$，主元写 pv($2$)。
// 各张表（准备表、初始表、第 1 表……）两两并排；只有出现比值的表才带“比值”列。
#let stab(vars, ratio: true, ..blocks) = {
  let fmt(c) = if type(c) == int or type(c) == float { $#c$ } else { c }
  let m = vars.len() + 2
  let bl = blocks.pos()
  let one(name, rows) = {
    let has-ratio = ratio and rows.any(r => r.len() > m and r.at(m) != [])
    let n = m + if has-ratio { 1 } else { 0 }
    let cells = ()
    for (k, r) in rows.enumerate() {
      let row = r.map(fmt).slice(0, calc.min(r.len(), n))
      while row.len() < n { row.push([]) }
      cells += row
      if k == rows.len() - 2 { cells.push(table.hline(stroke: (thickness: 0.4pt, dash: "dashed"))) }
    }
    block(breakable: false, {
      text(weight: "bold", name)
      v(-0.4em)
      table(
        columns: n,
        align: center + horizon,
        inset: (x: 3pt, y: 2.6pt),
        table.hline(stroke: 0.8pt),
        $x_B$, ..vars, $overline(b)$, ..if has-ratio { ([比值],) } else { () },
        table.hline(stroke: 0.5pt),
        ..cells,
        table.hline(stroke: 0.8pt),
      )
    })
  }
  // 表名前标序号；先排满左列再排右列，每张表靠左
  let marks = "①②③④⑤⑥⑦⑧⑨⑩".clusters()
  let tabs = range(0, bl.len(), step: 2).enumerate().map(((k, i)) => one([#marks.at(k) #bl.at(i)], bl.at(i + 1)))
  let half = calc.ceil(tabs.len() / 2)
  block(width: 100%, above: 1.1em, below: 1.1em, {
    set text(top-edge: "ascender", bottom-edge: "descender", size: 8.5pt)
    grid(columns: (1fr, 1fr), column-gutter: 1em, align: top + left,
      stack(spacing: 1.1em, ..tabs.slice(0, half)),
      stack(spacing: 1.1em, ..tabs.slice(half)))
  })
}

// 公式速查用的一行：左名右式
#let fml(name, body) = grid(columns: (7.5em, 1fr), column-gutter: 0.6em,
  text(weight: "bold", name), body)
