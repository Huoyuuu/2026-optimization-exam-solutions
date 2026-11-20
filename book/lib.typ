// 真题数据的读取和排版。真题题干只存在 data/exams/<id>.typ 里，这里负责取出来。
#import "/template.typ": *
#import "@preview/cetz:0.5.3"

// 全部试卷，按时间排
#let exam-ids = (
  "2009-2010", "2010-2011", "2011-2012", "2013-2014", "2014-2015", "2015-2016",
  "2016-2017", "2017-2018", "2018-2019", "2019-2020", "2020-2021", "2021-2022",
  "2022-2023", "2023-2024", "2024-2025A", "2024-2025B",
)

// 题型：编号 → 名称（不考的题型以 x- 开头）
#let topics = (
  "grad": [梯度、Hesse 矩阵、Taylor 展开],
  "convex": [凸集、凸函数、凸规划],
  "optcond": [无约束极值的判定条件],
  "basic": [基本概念、图解法、算法概念],
  "lp-basic": [线性规划的标准形与基本可行解],
  "simplex": [单纯形法],
  "linesearch": [一维搜索],
  "sd": [最速下降法],
  "newton": [Newton 法],
  "cg": [共轭方向法与共轭梯度法],
  "qn": [拟 Newton 法],
  "hj": [步长加速法],
  "lsq": [最小二乘问题],
  "kkt": [约束问题的最优性条件],
  "zout": [Zoutendijk 容许方向法],
  "penalty": [外部罚函数法],
  "multiplier": [乘子法],
  "x-revised": [修正单纯形法],
  "x-degen": [退化的处理],
  "x-dual": [对偶理论],
  "x-dualsimplex": [对偶单纯形法],
  "x-sens": [灵敏度分析],
  "x-powell": [方向加速法],
  "x-simplexsearch": [单纯形替换法],
  "x-lsq": [最小二乘],
  "x-rosen": [Rosen 梯度投影法],
  "x-wolfe": [Wolfe 简约梯度法],
  "x-fw": [Frank-Wolfe 法],
  "x-interior": [内部罚函数法],
  "x-multi": [多目标规划],
  "x-other": [其他],
)

#let load-exam(id) = {
  import "/data/exams/" + id + ".typ": exam
  exam
}

// 年份写法：2019-2020 → 2019–2020，2024-2025A → 2024–2025 A 卷
#let exam-name(id) = {
  let s = id.replace("-", "–")
  if s.ends-with("A") or s.ends-with("B") { s.slice(0, -1) + " " + s.at(s.len() - 1) + " 卷" } else { s }
}

// 题号写法：“二” → 第二题；“一(1)” → 第一题(1)；“3” → 第 3 题
#let no-name(no) = {
  let m = no.match(regex("^([^(（]+)(.*)$"))
  let main = m.captures.at(0)
  let rest = m.captures.at(1)
  if main.match(regex("^\d+$")) != none [第 #main 题#rest] else [第#main;题#rest]
}

// 取一道题；拆开的小题 “二(1)” 同时带上它所在大题的标题行（题干常写在那里）
#let find-q(id, no) = {
  let e = load-exam(id)
  let head = none
  let found = none
  for it in e.items {
    if "head" in it { head = it.head } else if it.no == no {
      found = it
      if no.match(regex("[(（]")) == none { head = none }
      break
    } else if it.no.match(regex("[(（]")) == none { head = none }
  }
  assert(found != none, message: "找不到题目 " + id + " " + no)
  (q: found, head: head)
}

// 解析书里引用真题：原题框。lbl 可选，用来给查找表算页码。
// with-head: false 时不带大题标题行（同一大题的上一小题刚引用过）
#let exam-q(id, no, lbl: none, with-head: true) = {
  let (q, head) = find-q(id, no)
  let title = [#exam-name(id)#h(0.5em)#no-name(no)#if q.at("score", default: none) != none [#h(0.5em)#q.score 分]]
  [#metadata((exam: id, no: no))<used-q>]
  if lbl != none [#metadata(none)#lbl]
  prob(title, [#if with-head and head != none [#head \ ]#q.body#if q.at("oos", default: none) != none [#h(0.4em)#box(stroke: 0.5pt, inset: (x: 2pt, y: 1pt), text(size: 8pt, weight: "bold")[#q.oos 不考])]])
}

// 预测题：原题框，标题写“预测题 n”
#let pred-counter = counter("pred")
#let pred-q(title: none, body) = {
  pred-counter.step()
  context prob([预测题 #pred-counter.display()#if title != none [#h(0.5em)#title]], body)
}

// 一段内容开头的文字（跳过空白），用来判断题干是否自带编号
#let first-text(c) = {
  if c.func() == enum.item or c.func() == enum { return "1." }
  if c.has("text") { return if type(c.text) == str { c.text } else { first-text(c.text) } }
  if c.has("children") {
    for ch in c.children {
      let t = first-text(ch)
      if t != none and t.trim() != "" { return t }
    }
    return none
  }
  if c.has("body") { return first-text(c.body) }
  none
}

// 试卷数字版：整套卷子
#let render-exam(id) = {
  let e = load-exam(id)
  // 每道题一块；大题标题行并进它后面那道题，不和题目分开
  let blocks = ()
  let pending = none
  for it in e.items {
    if "head" in it {
      pending = block(width: 100%, below: 0.45em, text(weight: "bold", it.head))
    } else {
      let m = it.no.match(regex("^[^(（]+[(（]"))
      // 不拆小题的大题如果已有标题行（“三、计算题（8 分）”），题号和分值就不再重复
      let titled = m == none and pending != none
      // 小题题干自带编号（“1. ……”“（1）……”）时，不再加“(1)”
      let t0 = first-text(it.body)
      let own = m != none and t0 != none and t0.trim().match(regex("^(\d+\s*[.．、]|[(（]\d+[)）])")) != none
      let lab = if titled or own [] else if m != none { it.no.slice(m.end - 1) } else if it.no.match(regex("^\d+$")) != none { it.no + "." } else { it.no + "、" }
      let out = it.topic.starts-with("x-")
      let q = grid(
        columns: (2.4em, 1fr),
        text(weight: "bold", lab),
        {
          if out { box(stroke: 0.5pt + black, inset: (x: 2pt, y: 1pt), text(size: 8pt, weight: "bold")[不考]); h(0.4em) }
          if it.at("score", default: none) != none and not titled [（#it.score 分）]
          it.body
          if it.at("oos", default: none) != none [#h(0.4em)#box(stroke: 0.5pt + black, inset: (x: 2pt, y: 1pt), text(size: 8pt, weight: "bold")[#it.oos 不考])]
        },
      )
      blocks.push(block(width: 100%, { if pending != none { pending }; q }))
      pending = none
    }
  }
  let s = id.replace("-", "–")
  let (years, ab) = if s.ends-with("A") or s.ends-with("B") { (s.slice(0, -1), "（" + s.at(s.len() - 1) + " 卷）") } else { (s, "") }
  let title = heading(level: 1, numbering: none)[#years 学年#if "term" in e [#e.term]#h(0.8em)最优化方法期末试卷#ab]
  // 每套卷子排成一页、左右两栏（和原卷一样）：按高度把题目分成前后两半，每栏内题目之间等距撑开
  let gutter = 1.4cm
  // 放不下时先把这一页的上下边距调小，还放不下再逐步缩小字号（否则 v(1fr) 变负，题目互相压住）
  let split(w, s) = {
    let hs = blocks.map(b => measure(block(width: w, text(size: s, b))).height)
    let th = measure(block(width: w, text(size: s, title))).height
    let total = hs.sum() + th
    let (best, acc, k) = (none, th, 0)
    for (i, h) in hs.enumerate() {
      acc += h
      let d = calc.abs(2 * acc - total)
      if best == none or d < best { best = d; k = i + 1 }
    }
    let left = th + hs.slice(0, k).sum(default: 0pt)
    (k, calc.max(left, total - left))
  }
  let body = layout(size => {
    let w = (size.width - gutter) / 2
    let s = 10pt
    let (k, hmax) = split(w, s)
    while hmax > size.height * 0.97 and s > 7pt {
      s -= 0.25pt
      (k, hmax) = split(w, s)
    }
    set text(size: s)
    let col(xs) = block(height: size.height, breakable: false, width: 100%, {
      for (i, b) in xs.enumerate() {
        if i > 0 { v(1fr) }
        b
      }
    })
    grid(columns: (1fr, 1fr), column-gutter: gutter, col((title,) + blocks.slice(0, k)), col(blocks.slice(k)))
  })
  pagebreak(weak: true)
  context {
    // 页边距和 book/exams.typ 里的 set page 一致
    let (_, hmax) = split((page.width - 2 * 1.9cm - gutter) / 2, 10pt)
    if hmax > (page.height - 1.7cm - 1.6cm) * 0.97 {
      set page(margin: (x: 1.9cm, top: 0.8cm, bottom: 1.1cm))
      body
    } else { body }
  }
}
