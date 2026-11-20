#import "/book/lib.typ": *
#show: conf.with(compact: true, course: [最优化方法#h(0.6em)历年期末试卷（2009–2025）])
// 每套卷子一页：A3 横排、左右两栏，和原卷版式一样
#set page(paper: "a3", flipped: true, margin: (x: 1.9cm, top: 1.7cm, bottom: 1.6cm), header: none)
#show heading.where(level: 1): it => align(center, block(above: 0pt, below: 1.4em, text(size: 15pt, weight: "bold", it.body)))

#for id in exam-ids { render-exam(id) }
