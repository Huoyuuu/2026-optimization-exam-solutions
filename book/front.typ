#import "/book/lib.typ": *

#v(2.5cm)
#align(center)[
  #text(size: 22pt, weight: "bold")[最优化方法#h(0.8em)往年试题参考解析]
  #v(0.4em)
  #text(size: 11pt)[2009–2025 年期末真题与预测题参考解析#h(1em)教材：张薇、薛嘉庆《最优化方法》]
  #v(1.2em)
  #set text(size: 10pt)
  资料个人整理，难免疏漏，欢迎大家私聊指正，或者提 Issue/PR。祝大家期末顺利！
  #v(1.6em)
  邮箱：#text(fill: rgb("#1f5fa8"), link("mailto:huoyuuu@gmail.com")[huoyuuu\@gmail.com]) \
  GitHub：#text(fill: rgb("#1f5fa8"), link("https://github.com/Huoyuuu/2026-optimization-exam-solutions")[https://github.com/Huoyuuu/2026-optimization-exam-solutions])
]
#v(2cm)

#{
  show outline.entry.where(level: 1): it => {
    set block(above: 1.3em)
    strong(it)
  }
  show outline.entry.where(level: 2): set block(above: 0.7em)
  outline(title: none, depth: 2, indent: 2em)
}
