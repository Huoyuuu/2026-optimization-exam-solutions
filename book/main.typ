#import "/book/lib.typ": *
#show: conf.with(course: [最优化方法#h(0.6em)往年试题参考解析])
#show heading.where(level: 2): it => { pred-counter.update(0); it }

#include "front.typ"
#include "parts/01-calc.typ"
#include "parts/02-convex.typ"
#include "parts/03-lp.typ"
#include "parts/04-newton.typ"
#include "parts/05-cg.typ"
#include "parts/06-qn.typ"
#include "parts/07-hj.typ"
#include "parts/08-lsq.typ"
#include "parts/09-kkt.typ"
#include "parts/10-zout.typ"
#include "parts/11-penalty.typ"
