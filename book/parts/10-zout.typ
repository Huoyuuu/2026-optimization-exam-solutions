#import "/book/lib.typ": *

// 求方向的线性规划：各顶点和目标值排成一张表
#let vt(..cs) = {
  let cs = cs.pos()
  align(center, three-line(columns: cs.len() + 1,
    ([顶点 $p$], ..cs.map(c => c.at(0))),
    [目标值], ..cs.map(c => c.at(1))))
}

= Zoutendijk 容许方向法 <part-zout>

== 用 Zoutendijk 法迭代 <s-zout>

#flow(title: [做法])[
  + *化成标准形*：max 改成 min；“$<=$”约束两边乘 $-1$，不等式写成 $A x >= b$，等式写成 $C x = d$。写出 $nabla f(x)$。
  + *分解*：把 $overline(x)_k$ 代入每个不等式约束，取等号的组成 $A'_k$、$b'_k$（起作用约束），其余组成 $A''_k$、$b''_k$。
  + *求下降容许方向*：解线性规划
    $ min quad & nabla f(overline(x)_k)^T p \
      "s.t." quad & A'_k p >= 0, quad C p = 0, \
      & -1 <= p_j <= 1, quad j = 1, dots, n. $
    最优值为 0 就停止，$overline(x)_k$ 是 K-T 点；最优值小于 0，最优解就是 $p_k$。
  + *求步长上界*：$u = A''_k overline(x)_k - b''_k$，$v = A''_k p_k$，
    $ overline(t) = min{ -u_i / v_i | v_i < 0 }, $
    $v >= 0$ 时 $overline(t) = +oo$。
  + *直线搜索*：$phi(t) = f(overline(x)_k + t p_k)$，在 $[0, overline(t)]$ 上求极小。$phi'(t) = 0$ 的根在区间内就取它；$phi'$ 在区间上恒负就取 $t_k = overline(t)$。然后 $overline(x)_(k+1) = overline(x)_k + t_k p_k$。
  + *判断最优*：在 $overline(x)_(k+1)$ 重新分解。$nabla f(overline(x)_(k+1))$ 能写成起作用约束梯度的非负组合（等式约束的系数不限号）时，线性规划的最优值是 0，$overline(x)_(k+1)$ 是 K-T 点（定理 4.15）；凸规划的 K-T 点就是全局最优解（定理 4.13）。
]

#dlg[
  #Q[为什么要加 $-1 <= p_j <= 1$？]
  #A[只有 $A' p >= 0$、$C p = 0$ 时，$p$ 的可行集是一个锥，$p$ 放大几倍，目标值也放大几倍，最优值是 $-oo$。加上这组界限，线性规划才有有限的最优解。它只限制方向向量的长短，实际走多远由后面的步长 $t$ 决定。]
  #Q[求方向的线性规划怎么解？]
  #A[考题一般只有两个变量。可行域是正方形 $[-1, 1]^2$ 被几条过原点的直线截下的凸多边形，最优值在顶点取到：求出各顶点，代入目标函数比较。有等式约束 $C p = 0$ 时先用它消去一个分量（如 $p_2 = -p_1$），剩下一个变量，直接看出最优解。最优顶点不唯一时任取一个。]
  #Q[为什么起作用约束和等式约束不限制步长？]
  #A[$A'(overline(x)_k + t p) - b' = t A' p >= 0$，$C(overline(x)_k + t p) - d = t C p = 0$，对任何 $t >= 0$ 都成立。只有不起作用的约束 $u_i + t v_i >= 0$ 可能被破坏：$v_i >= 0$ 时永远成立，$v_i < 0$ 时要求 $t <= -u_i \/ v_i$。所以 $overline(t)$ 只对 $v_i < 0$ 的项取最小。]
  #Q[直线搜索的结果为什么常常是 $overline(t)$？]
  #A[$phi'(0) = nabla f(overline(x)_k)^T p_k < 0$，$phi$ 一开始是下降的。$phi'$ 的零点落在 $overline(t)$ 之后（或者没有零点）时，整个区间上 $phi$ 都在下降，最小点就是右端点 $overline(t)$，新点落在一条新的约束边界上。]
  #Q[终止准则是什么？怎样用它判断最优解？]
  #A[终止准则是 $nabla f(overline(x)_k)^T p_k = 0$（实际计算时用 $|nabla f(overline(x)_k)^T p_k| < epsilon$）。$A'_k$ 和 $C$ 的行向量线性无关时，它等价于 $overline(x)_k$ 是 K-T 点（定理 4.15）。所以“判断是否为最优解”就是在新点再解一次求方向的线性规划，看最优值是不是 0；是 0 而且问题是凸规划，就是全局最优解。]
]

#exam-q("2023-2024", "七")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_2^2 - ln(1 + 2 x_1) \
    "s.t." quad & -2 x_1 - x_2 >= -6, \
    & x_1 + x_2 >= 4, \
    & x_1 >= 0, quad x_2 >= 0. $
  $ A = mat(-2, -1; 1, 1; 1, 0; 0, 1), quad b = vec(-6, 4, 0, 0), quad nabla f(overline(x)) = vec(-2 / (1 + 2 x_1), 2 x_2). $

  #step[分解]
  $ A overline(x)_0 - b = (-1 - 5 + 6, 1/2 + 5 - 4, 1/2, 5)^T = (0, 3/2, 1/2, 5)^T, $
  只有第 1 个约束起作用：
  $ A'_0 = (-2, -1), quad b'_0 = -6; quad A''_0 = mat(1, 1; 1, 0; 0, 1), quad b''_0 = vec(4, 0, 0). $
  $ g_0 = nabla f(overline(x)_0) = (-2/2, 10)^T = (-1, 10)^T. $

  #step[求下降容许方向]
  $ min quad & -p_1 + 10 p_2 \
    "s.t." quad & -2 p_1 - p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  可行域是正方形在直线 $p_2 = -2 p_1$ 左下方的部分：

  #align(center, cetz.canvas(length: 1.2cm, {
    import cetz.draw: *
    line((-1, -1), (0.5, -1), (-0.5, 1), (-1, 1), close: true, fill: luma(225), stroke: none)
    rect((-1, -1), (1, 1), stroke: 0.5pt + luma(120))
    line((-1.5, 0), (1.5, 0), mark: (end: ">"), stroke: 0.5pt)
    content((1.75, 0), $p_1$)
    line((0, -1.4), (0, 1.5), mark: (end: ">"), stroke: 0.5pt)
    content((0, 1.72), $p_2$)
    line((-0.65, 1.3), (0.65, -1.3), stroke: 0.8pt)
    content((-0.7, 1.35), text(size: 8pt)[$-2 p_1 - p_2 = 0$], anchor: "south-east", padding: 0.05)
    for pt in ((-1, 1), (-0.5, 1), (0.5, -1), (-1, -1)) {
      circle(pt, radius: 0.045, fill: black)
    }
    content((0.5, -1), text(size: 8pt)[$p_0$], anchor: "north-east", padding: 0.08)
  }))

  #vt(($(-1, 1)$, $11$), ($(-1/2, 1)$, $21/2$), ($(1/2, -1)$, $-21/2$), ($(-1, -1)$, $-9$))
  $ p_0 = (1/2, -1)^T, quad g_0^T p_0 = -21/2 < 0. $

  #step[求步长上界]
  $ u &= A''_0 overline(x)_0 - b''_0 = (11/2 - 4, 1/2, 5)^T = (3/2, 1/2, 5)^T, \
    v &= A''_0 p_0 = (1/2 - 1, 1/2, -1)^T = (-1/2, 1/2, -1)^T, \
    overline(t) &= min{ (3/2) / (1/2), 5 / 1 } = min{3, 5} = 3. $

  #step[直线搜索]
  $ overline(x)_0 + t p_0 &= (1/2 + t/2, 5 - t)^T, \
    phi(t) &= (5 - t)^2 - ln(2 + t), quad 0 <= t <= 3, \
    phi'(t) &= -2 (5 - t) - 1 / (2 + t) < 0 quad (0 <= t <= 3). $
  $phi$ 在 $[0, 3]$ 上递减，取 $t_0 = overline(t) = 3$：
  $ overline(x)_1 = overline(x)_0 + 3 p_0 = (1/2 + 3/2, 5 - 3)^T = (2, 2)^T. $

  #step[判断 $overline(x)_1$ 是否为最优解]
  $ A overline(x)_1 - b = (0, 0, 2, 2)^T, quad g_1 = nabla f(overline(x)_1) = (-2/5, 4)^T. $
  前两个约束起作用。令 $g_1 = mu_1 (-2, -1)^T + mu_2 (1, 1)^T$：
  $ -2 mu_1 + mu_2 &= -2/5, \
    -mu_1 + mu_2 &= 4. $
  两式相减得 $mu_1 = 22/5$，$mu_2 = 42/5$，都大于 0。于是对满足 $A'_1 p >= 0$ 的任何 $p$，
  $ g_1^T p = mu_1 (-2 p_1 - p_2) + mu_2 (p_1 + p_2) >= 0, $
  求方向的线性规划最优值是 0（$p = 0$），满足终止准则，$overline(x)_1$ 是 K-T 点。$x_2^2$ 和 $-ln(1 + 2 x_1)$ 都是凸函数，约束是线性的，这是凸规划，K-T 点就是全局最优解。

  #concl[$overline(x)_1 = (2, 2)^T$ *是*最优解，最优值 $f(overline(x)_1) = 4 - ln 5$。]
]

#exam-q("2022-2023", "七")
#ans[
  #step[化成标准形]
  max 改成 min：
  $ min quad & f(overline(x)) = -ln(1 + x_1) - ln(1 + x_2) \
    "s.t." quad & -x_1 - 2 x_2 >= -3, \
    & x_2 >= 0. $
  $ A = mat(-1, -2; 0, 1), quad b = vec(-3, 0), quad nabla f(overline(x)) = vec(-1 / (1 + x_1), -1 / (1 + x_2)). $

  #step[分解]
  $ A x^((0)) - b = (-1 + 3, 0)^T = (2, 0)^T, $
  第 2 个约束起作用：
  $ A'_0 = (0, 1), quad b'_0 = 0; quad A''_0 = (-1, -2), quad b''_0 = -3. $
  $ g_0 = nabla f(x^((0))) = (-1/2, -1)^T. $

  #step[求下降容许方向]
  $ min quad & -1/2 p_1 - p_2 \
    "s.t." quad & p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  可行域是矩形 $[-1, 1] times [0, 1]$：
  #vt(($(1, 0)$, $-1/2$), ($(1, 1)$, $-3/2$), ($(-1, 1)$, $-1/2$), ($(-1, 0)$, $1/2$))
  $ p_0 = (1, 1)^T, quad g_0^T p_0 = -3/2 < 0. $

  #step[求步长上界]
  $ u &= A''_0 x^((0)) - b''_0 = -1 + 3 = 2, \
    v &= A''_0 p_0 = -1 - 2 = -3, \
    overline(t) &= 2/3. $

  #step[直线搜索]
  $ x^((0)) + t p_0 &= (1 + t, t)^T, \
    phi(t) &= -ln(2 + t) - ln(1 + t), quad 0 <= t <= 2/3, \
    phi'(t) &= -1 / (2 + t) - 1 / (1 + t) < 0. $
  取 $t_0 = overline(t) = 2/3$：
  $ x^((1)) = x^((0)) + 2/3 p_0 = (5/3, 2/3)^T. $

  #step[判断 $x^((1))$ 是否为最优解]
  $ A x^((1)) - b = (-5/3 - 4/3 + 3, 2/3)^T = (0, 2/3)^T, quad g_1 = (-1 / (8\/3), -1 / (5\/3))^T = (-3/8, -3/5)^T. $
  第 1 个约束起作用，在 $x^((1))$ 处解求方向的线性规划：
  $ min quad & -3/8 p_1 - 3/5 p_2 \
    "s.t." quad & -p_1 - 2 p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  #vt(($(1, -1/2)$, $-3/40$), ($(-1, 1/2)$, $3/40$), ($(1, -1)$, $9/40$), ($(-1, -1)$, $39/40$))
  最优值 $-3/40 < 0$，不满足终止准则：沿 $p = (1, -1/2)^T$ 还能下降。

  #concl[$x^((1)) = (5/3, 2/3)^T$ *不是*最优解。（再迭代一次：$overline(t) = 4/3$，$phi'(t) = 0$ 得 $t = 1/3$，到达最优解 $(2, 1/2)^T$，原问题最大值 $ln(9/2)$。）]
]

#exam-q("2021-2022", "八")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_1^2 + 1/2 x_2^2 - 8 x_1 - 2 x_2 \
    "s.t." quad & -3 x_1 + 2 x_2 >= 0, \
    & -3 x_1 - x_2 >= -9. $
  $ A = mat(-3, 2; -3, -1), quad b = vec(0, -9), quad nabla f(overline(x)) = vec(2 x_1 - 8, x_2 - 2). $

  #step[分解]
  $ A overline(x)_0 - b = (-3 + 4, -3 - 2 + 9)^T = (1, 4)^T, $
  两个约束都不起作用：$A'_0$ 不存在，$A''_0 = A$，$b''_0 = b$。
  $ g_0 = nabla f(overline(x)_0) = (-6, 0)^T. $

  #step[求下降容许方向]
  $ min quad & -6 p_1 \
    "s.t." quad & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  只要 $p_1 = 1$，$p_2$ 在 $[-1, 1]$ 中任取都是最优解，最优值 $-6$。取顶点
  $ p_0 = (1, 1)^T, quad g_0^T p_0 = -6 < 0. $

  #step[求步长上界]
  $ u &= A''_0 overline(x)_0 - b''_0 = (1, 4)^T, \
    v &= A''_0 p_0 = (-3 + 2, -3 - 1)^T = (-1, -4)^T, \
    overline(t) &= min{ 1/1, 4/4 } = 1. $

  #step[直线搜索]
  $ overline(x)_0 + t p_0 &= (1 + t, 2 + t)^T, \
    phi(t) &= (1 + t)^2 + 1/2 (2 + t)^2 - 8 (1 + t) - 2 (2 + t) = 3/2 t^2 - 6 t - 9, \
    phi'(t) &= 3 t - 6 < 0 quad (0 <= t <= 1). $
  取 $t_0 = overline(t) = 1$：
  $ overline(x)_1 = overline(x)_0 + p_0 = (2, 3)^T. $

  #step[判断 $overline(x)_1$ 是否为最优解]
  $ A overline(x)_1 - b = (-6 + 6, -6 - 3 + 9)^T = (0, 0)^T, quad g_1 = (4 - 8, 3 - 2)^T = (-4, 1)^T. $
  两个约束都起作用。令 $g_1 = mu_1 (-3, 2)^T + mu_2 (-3, -1)^T$：
  $ -3 mu_1 - 3 mu_2 &= -4, \
    2 mu_1 - mu_2 &= 1. $
  由第 2 式 $mu_2 = 2 mu_1 - 1$，代入第 1 式得 $-9 mu_1 + 3 = -4$，$mu_1 = 7/9$，$mu_2 = 5/9$，都大于 0。所以对满足 $A'_1 p >= 0$ 的 $p$ 都有 $g_1^T p >= 0$，线性规划最优值为 0，$overline(x)_1$ 是 K-T 点。$f$ 的 Hesse 矩阵 $"diag"(2, 1)$ 正定，约束线性，是凸规划。

  #concl[$overline(x)_1 = (2, 3)^T$ *是*最优解，最优值 $-27/2$。]

  #step[另一种取法]
  方向取 $p_0 = (1, 0)^T$（负梯度方向）也对：$v = (-3, -3)^T$，$overline(t) = min{1/3, 4/3} = 1/3$；$phi(t) = t^2 - 6 t - 9$ 在 $[0, 1/3]$ 上递减，$t_0 = 1/3$，$overline(x)_1 = (4/3, 2)^T$。这时只有第 1 个约束起作用，$g_1 = (-16/3, 0)^T$，线性规划
  $ min -16/3 p_1, quad "s.t." -3 p_1 + 2 p_2 >= 0, quad -1 <= p_1, p_2 <= 1 $
  在 $p = (2/3, 1)^T$ 处取最优值 $-32/9 < 0$，所以这样得到的 $overline(x)_1$ 不是最优解。两种取法按步骤算对都可以。
]

#exam-q("2019-2020", "七")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = -ln(1 + x_1) - 2 ln(1 + x_2) \
    "s.t." quad & x_1 - 2 x_2 >= -4, \
    & -x_1 + x_2 >= -2, \
    & x_1 >= 0, quad x_2 >= 0. $
  $ A = mat(1, -2; -1, 1; 1, 0; 0, 1), quad b = vec(-4, -2, 0, 0), quad nabla f(overline(x)) = vec(-1 / (1 + x_1), -2 / (1 + x_2)). $

  #step[分解]
  $ A overline(x)_0 - b = (4 - 8 + 4, -4 + 4 + 2, 4, 4)^T = (0, 2, 4, 4)^T, $
  $ A'_0 = (1, -2), quad b'_0 = -4; quad A''_0 = mat(-1, 1; 1, 0; 0, 1), quad b''_0 = vec(-2, 0, 0). $
  $ g_0 = nabla f(overline(x)_0) = (-1/5, -2/5)^T. $

  #step[检验所给方向]
  $ A'_0 p_0 = 1 - 2 dot 1/2 = 0 >= 0, quad g_0^T p_0 = -1/5 - 1/5 = -2/5 < 0, $
  $p_0$ 是下降容许方向。它也是求方向的线性规划（约束 $p_1 - 2 p_2 >= 0$）的最优解：
  #vt(($(1, 1/2)$, $-2/5$), ($(1, -1)$, $1/5$), ($(-1, -1)$, $3/5$), ($(-1, -1/2)$, $2/5$))

  #step[求步长上界]
  $ u &= A''_0 overline(x)_0 - b''_0 = (2, 4, 4)^T, \
    v &= A''_0 p_0 = (-1 + 1/2, 1, 1/2)^T = (-1/2, 1, 1/2)^T, \
    overline(t) &= 2 / (1/2) = 4. $

  #step[直线搜索]
  $ overline(x)_0 + t p_0 &= (4 + t, 4 + t/2)^T, \
    phi(t) &= -ln(5 + t) - 2 ln(5 + t/2), quad 0 <= t <= 4, \
    phi'(t) &= -1 / (5 + t) - 1 / (5 + t/2) < 0. $
  取 $t_0 = overline(t) = 4$：
  $ overline(x)_1 = overline(x)_0 + 4 p_0 = (8, 6)^T. $

  #step[判断 $overline(x)_1$ 是否为最优解]
  $ A overline(x)_1 - b = (8 - 12 + 4, -8 + 6 + 2, 8, 6)^T = (0, 0, 8, 6)^T, quad g_1 = (-1/9, -2/7)^T. $
  前两个约束起作用。令 $g_1 = mu_1 (1, -2)^T + mu_2 (-1, 1)^T$：
  $ mu_1 - mu_2 &= -1/9, \
    -2 mu_1 + mu_2 &= -2/7. $
  两式相加得 $-mu_1 = -25/63$，所以 $mu_1 = 25/63$，$mu_2 = mu_1 + 1/9 = 32/63$，都大于 0，线性规划最优值为 0，$overline(x)_1$ 是 K-T 点。$-ln(1 + x_i)$ 是凸函数，约束线性，是凸规划。

  #concl[$overline(x)_1 = (8, 6)^T$ *是*最优解，最优值 $-ln 9 - 2 ln 7 = -ln 441$。]
]

#exam-q("2017-2018", "六(2)")
#ans[
  #step[化成标准形]
  约束已经是标准形：
  $ C = (1, 1), quad d = 2; quad A = mat(1, 3; 1, 0), quad b = vec(3, 1); quad nabla f(overline(x)) = vec(2 x_1 + x_2, x_1 + 4 x_2 + 2). $

  #step[分解]
  $ A overline(x)_0 - b = (1 + 3 - 3, 1 - 1)^T = (1, 0)^T, $
  $ A'_0 = (1, 0), quad b'_0 = 1; quad A''_0 = (1, 3), quad b''_0 = 3. $
  $ g_0 = nabla f(overline(x)_0) = (3, 7)^T. $

  #step[求下降容许方向]
  $ min quad & 3 p_1 + 7 p_2 \
    "s.t." quad & p_1 >= 0, \
    & p_1 + p_2 = 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  由 $p_2 = -p_1$，目标函数为 $-4 p_1$，$0 <= p_1 <= 1$，取 $p_1 = 1$：
  $ p_0 = (1, -1)^T, quad g_0^T p_0 = -4 < 0. $

  #step[求步长上界]
  $ u &= A''_0 overline(x)_0 - b''_0 = 1 + 3 - 3 = 1, \
    v &= A''_0 p_0 = 1 - 3 = -2, \
    overline(t) &= 1/2. $

  #step[直线搜索]
  $ overline(x)_0 + t p_0 &= (1 + t, 1 - t)^T, \
    phi(t) &= (1 + t)^2 + 2 (1 - t)^2 + (1 + t)(1 - t) + 2 (1 - t) = 2 t^2 - 4 t + 6, \
    phi'(t) &= 4 t - 4 < 0 quad (0 <= t <= 1/2). $
  取 $t_0 = overline(t) = 1/2$：
  $ overline(x)_1 = overline(x)_0 + 1/2 p_0 = (3/2, 1/2)^T. $

  #step[判断 $overline(x)_1$ 是否为最优解]
  $ A overline(x)_1 - b = (3/2 + 3/2 - 3, 3/2 - 1)^T = (0, 1/2)^T, $
  $ A'_1 = (1, 3), quad b'_1 = 3; quad A''_1 = (1, 0), quad b''_1 = 1; quad g_1 = (7/2, 11/2)^T. $
  在 $overline(x)_1$ 处求方向：
  $ min quad & 7/2 p_1 + 11/2 p_2 \
    "s.t." quad & p_1 + 3 p_2 >= 0, \
    & p_1 + p_2 = 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  由 $p_2 = -p_1$，约束化为 $-2 p_1 >= 0$，即 $p_1 <= 0$；目标函数 $-2 p_1 >= 0$。最优解 $p_1 = (0, 0)^T$，最优值 0，满足终止准则。$A'_1$ 和 $C$ 的行向量 $(1, 3)$、$(1, 1)$ 线性无关，由定理 4.15，$overline(x)_1$ 是 K-T 点（乘子 $mu = 1 >= 0$，$lambda = 5/2$）。$f$ 的 Hesse 矩阵 $mat(2, 1; 1, 4)$ 正定，约束线性，是凸规划。

  #concl[$overline(x)_1 = (3/2, 1/2)^T$ *是*最优解，最优值 $9/2$。理由：满足终止准则 $nabla f(overline(x)_1)^T p_1 = 0$，是 K-T 点，而问题是凸规划。]
]

#exam-q("2016-2017", "七")
#ans[
  #step[(1) 化成标准形]
  $ min quad & f(overline(x)) = 2 x_1^2 + x_1 x_2 + 2 x_2^2 \
    "s.t." quad & -2 x_1 - 7 x_2 >= -10, \
    & -x_1 + 3 x_2 >= -4, \
    & x_1 + 2 x_2 >= 4, \
    & x_1 >= 0. $
  $ A = mat(-2, -7; -1, 3; 1, 2; 1, 0), quad b = vec(-10, -4, 4, 0), quad nabla f(overline(x)) = vec(4 x_1 + x_2, x_1 + 4 x_2). $

  #step[分解]
  $ A overline(x)_0 - b = (-8 + 10, -4 + 4, 4 - 4, 4)^T = (2, 0, 0, 4)^T, $
  $ A'_0 = mat(-1, 3; 1, 2), quad b'_0 = vec(-4, 4); quad A''_0 = mat(-2, -7; 1, 0), quad b''_0 = vec(-10, 0). $
  $ g_0 = nabla f(overline(x)_0) = (16, 4)^T. $

  #step[求下降容许方向]
  $ min quad & 16 p_1 + 4 p_2 \
    "s.t." quad & -p_1 + 3 p_2 >= 0, \
    & p_1 + 2 p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  可行域在两条直线 $p_2 = p_1 / 3$、$p_2 = -p_1 / 2$ 的上方：
  #vt(($(-1, 1/2)$, $-14$), ($(-1, 1)$, $-12$), ($(0, 0)$, $0$), ($(1, 1/3)$, $52/3$), ($(1, 1)$, $20$))
  $ p_0 = (-1, 1/2)^T, quad g_0^T p_0 = -14 < 0. $

  #step[求步长上界]
  $ u &= A''_0 overline(x)_0 - b''_0 = (-8 + 10, 4)^T = (2, 4)^T, \
    v &= A''_0 p_0 = (2 - 7/2, -1)^T = (-3/2, -1)^T, \
    overline(t) &= min{ 2 / (3/2), 4 / 1 } = min{4/3, 4} = 4/3. $

  #step[直线搜索]
  $ overline(x)_0 + t p_0 &= (4 - t, t/2)^T, \
    phi(t) &= 2 (4 - t)^2 + (4 - t) t/2 + 2 (t/2)^2 = 2 t^2 - 14 t + 32, \
    phi'(t) &= 4 t - 14 < 0 quad (0 <= t <= 4/3). $
  取 $t_0 = overline(t) = 4/3$：
  $ overline(x)_1 = overline(x)_0 + 4/3 p_0 = (8/3, 2/3)^T. $

  #step[(2) 终止准则]
  设 $p_k$ 是第 $k$ 步求方向的线性规划的最优解，终止准则是
  $ nabla f(overline(x)_k)^T p_k = 0 quad (text("实际计算中") |nabla f(overline(x)_k)^T p_k| < epsilon). $
  $A'_k$ 和 $C$ 的行向量线性无关时，它成立当且仅当 $overline(x)_k$ 是 K-T 点（定理 4.15）。

  #step[(3) 判断 $overline(x)_0$、$overline(x)_1$]
  $overline(x)_0$：$g_0^T p_0 = -14 != 0$，不满足终止准则。

  $overline(x)_1$：
  $ A overline(x)_1 - b = (-16/3 - 14/3 + 10, -8/3 + 2 + 4, 8/3 + 4/3 - 4, 8/3)^T = (0, 10/3, 0, 8/3)^T, $
  第 1、3 个约束起作用，$g_1 = (32/3 + 2/3, 8/3 + 8/3)^T = (34/3, 16/3)^T$。
  $ min quad & 34/3 p_1 + 16/3 p_2 \
    "s.t." quad & -2 p_1 - 7 p_2 >= 0, \
    & p_1 + 2 p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  可行域是夹在 $p_2 = -2 p_1 / 7$ 和 $p_2 = -p_1 / 2$ 之间的窄角（只含 $p_1 >= 0$ 的部分）：
  #vt(($(0, 0)$, $0$), ($(1, -1/2)$, $26/3$), ($(1, -2/7)$, $206/21$))
  最优解 $p_1 = (0, 0)^T$，$g_1^T p_1 = 0$，满足终止准则。

  #concl[(1) $overline(x)_1 = (8/3, 2/3)^T$。(2) 终止准则 $nabla f(overline(x)_k)^T p_k = 0$。(3) $overline(x)_0$ 不满足，$overline(x)_1$ 满足，是 K-T 点；问题是凸规划，$overline(x)_1$ 就是最优解，最优值 $152/9$。]
]

#exam-q("2016-2017", "二(1)")
#ans[
  两种方法都按 $x_(k+1) = x_k + t_k p_k$ 迭代，区别在于：

  #align(center, three-line(columns: (auto, 1fr, 1fr), align: left,
    ([], [最速下降法], [Z-容许方向法]),
    [适用问题], [无约束问题], [线性约束问题，每个迭代点都必须是容许点],
    [方向 $p_k$], [负梯度方向 $p_k = -g_k$], [解线性规划 $min nabla f(x_k)^T p$，$A' p >= 0$，$C p = 0$，$-e <= p <= e$ 得到的下降容许方向，一般不是负梯度方向],
    [步长 $t_k$], [在 $t >= 0$ 上精确直线搜索], [只在 $[0, overline(t)]$ 上搜索，$overline(t) = min{-u_i \/ v_i | v_i < 0}$，保证新点仍然容许],
    [终止准则], [$norm(g_k) < epsilon$], [$|nabla f(x_k)^T p_k| < epsilon$，这时 $x_k$ 是 K-T 点],
  ))
]

#exam-q("2015-2016", "六(1)")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_1^2 + 4 x_2^2 - x_1 x_2 \
    "s.t." quad & -2 x_1 - 3 x_2 >= -5, \
    & x_1 >= 0, quad x_2 >= 0, \
    & x_1 + x_2 = 2. $
  $ A = mat(-2, -3; 1, 0; 0, 1), quad b = vec(-5, 0, 0), quad C = (1, 1), quad d = 2, quad nabla f(overline(x)) = vec(2 x_1 - x_2, 8 x_2 - x_1). $

  #step[分解]
  $ A x^((0)) - b = (-2 - 3 + 5, 1, 1)^T = (0, 1, 1)^T, $
  $ A'_0 = (-2, -3), quad b'_0 = -5; quad A''_0 = mat(1, 0; 0, 1), quad b''_0 = vec(0, 0). $
  $ g_0 = nabla f(x^((0))) = (1, 7)^T. $

  #step[求下降容许方向]
  $ min quad & p_1 + 7 p_2 \
    "s.t." quad & -2 p_1 - 3 p_2 >= 0, \
    & p_1 + p_2 = 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  由 $p_2 = -p_1$，约束化为 $p_1 >= 0$，目标函数为 $-6 p_1$，取 $p_1 = 1$：
  $ p_0 = (1, -1)^T, quad g_0^T p_0 = -6 < 0. $

  #step[求步长上界]
  $ u &= A''_0 x^((0)) - b''_0 = (1, 1)^T, \
    v &= A''_0 p_0 = (1, -1)^T, \
    overline(t) &= 1 / 1 = 1. $

  #step[直线搜索]
  $ x^((0)) + t p_0 &= (1 + t, 1 - t)^T, \
    phi(t) &= (1 + t)^2 + 4 (1 - t)^2 - (1 + t)(1 - t) = 6 t^2 - 6 t + 4, \
    phi'(t) &= 12 t - 6 = 0 quad => quad t = 1/2 in [0, 1]. $
  $ t_0 = 1/2, quad x^((1)) = x^((0)) + 1/2 p_0 = (3/2, 1/2)^T. $

  #concl[$x^((1)) = (3/2, 1/2)^T$，$f(x^((1))) = 5/2$。]
]

#exam-q("2014-2015", "八")
#ans[
  #step[化成标准形]
  $ A = mat(-3, -1; 1, 0; 0, 1), quad b = vec(-3, 0, 0), quad nabla f(overline(x)) = vec(2 x_1 - x_2 - 2, 2 x_2 - x_1). $

  #step[分解]
  $ A x^((0)) - b = (-2 + 3, 2/3, 0)^T = (1, 2/3, 0)^T, $
  第 3 个约束 $x_2 >= 0$ 起作用：
  $ A'_0 = (0, 1), quad b'_0 = 0; quad A''_0 = mat(-3, -1; 1, 0), quad b''_0 = vec(-3, 0). $
  $ g_0 = nabla f(x^((0))) = (4/3 - 2, -2/3)^T = (-2/3, -2/3)^T. $

  #step[求下降容许方向]
  $ min quad & -2/3 p_1 - 2/3 p_2 \
    "s.t." quad & p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  可行域是矩形 $[-1, 1] times [0, 1]$：
  #vt(($(1, 0)$, $-2/3$), ($(1, 1)$, $-4/3$), ($(-1, 1)$, $0$), ($(-1, 0)$, $2/3$))
  $ p_0 = (1, 1)^T, quad g_0^T p_0 = -4/3 < 0. $

  #step[求步长上界]
  $ u &= A''_0 x^((0)) - b''_0 = (1, 2/3)^T, \
    v &= A''_0 p_0 = (-3 - 1, 1)^T = (-4, 1)^T, \
    overline(t) &= 1/4. $

  #step[直线搜索]
  $ x^((0)) + t p_0 &= (2/3 + t, t)^T, \
    phi(t) &= (2/3 + t)^2 - (2/3 + t) t + t^2 - 2 (2/3 + t) = t^2 - 4/3 t - 8/9, \
    phi'(t) &= 2 t - 4/3 < 0 quad (0 <= t <= 1/4). $
  $phi'$ 的零点 $t = 2/3$ 超出 $[0, 1/4]$，取 $t_0 = overline(t) = 1/4$：
  $ x^((1)) = x^((0)) + 1/4 p_0 = (11/12, 1/4)^T. $

  #concl[$x^((1)) = (11/12, 1/4)^T$，$f(x^((1))) = -167/144$。]
]

#exam-q("2013-2014", "七")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_1^2 + x_2^2 - 2 x_1 - 4 x_2 \
    "s.t." quad & -2 x_1 + x_2 >= -1, \
    & -x_1 - x_2 >= -2, \
    & x_1 >= 0, quad x_2 >= 0. $
  $ A = mat(-2, 1; -1, -1; 1, 0; 0, 1), quad b = vec(-1, -2, 0, 0), quad nabla f(overline(x)) = vec(2 x_1 - 2, 2 x_2 - 4). $

  #step[分解]
  $ A x^((0)) - b = (-2 + 1 + 1, -2 + 2, 1, 1)^T = (0, 0, 1, 1)^T, $
  $ A'_0 = mat(-2, 1; -1, -1), quad b'_0 = vec(-1, -2); quad A''_0 = mat(1, 0; 0, 1), quad b''_0 = vec(0, 0). $
  $ g_0 = nabla f(x^((0))) = (0, -2)^T. $

  #step[求下降容许方向]
  $ min quad & -2 p_2 \
    "s.t." quad & -2 p_1 + p_2 >= 0, \
    & -p_1 - p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  可行域在直线 $p_2 = 2 p_1$ 上方、$p_2 = -p_1$ 下方：
  #vt(($(-1, 1)$, $-2$), ($(0, 0)$, $0$), ($(-1/2, -1)$, $2$), ($(-1, -1)$, $2$))
  $ p_0 = (-1, 1)^T, quad g_0^T p_0 = -2 < 0. $

  #step[求步长上界]
  $ u &= A''_0 x^((0)) - b''_0 = (1, 1)^T, \
    v &= A''_0 p_0 = (-1, 1)^T, \
    overline(t) &= 1 / 1 = 1. $

  #step[直线搜索]
  $ x^((0)) + t p_0 &= (1 - t, 1 + t)^T, \
    phi(t) &= (1 - t)^2 + (1 + t)^2 - 2 (1 - t) - 4 (1 + t) = 2 t^2 - 2 t - 4, \
    phi'(t) &= 4 t - 2 = 0 quad => quad t = 1/2 in [0, 1]. $
  $ t_0 = 1/2, quad x^((1)) = x^((0)) + 1/2 p_0 = (1/2, 3/2)^T. $

  #concl[$x^((1)) = (1/2, 3/2)^T$，$f(x^((1))) = -9/2$。]
]

#exam-q("2010-2011", "七")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_1^2 + 2 x_2^2 - x_1 x_2 \
    "s.t." quad & -x_1 - 4 x_2 >= -5, \
    & x_1 >= 0, quad x_2 >= 0, \
    & x_1 + x_2 = 2. $
  $ A = mat(-1, -4; 1, 0; 0, 1), quad b = vec(-5, 0, 0), quad C = (1, 1), quad d = 2, quad nabla f(overline(x)) = vec(2 x_1 - x_2, 4 x_2 - x_1). $

  #step[分解]
  $ A x^((0)) - b = (-1 - 4 + 5, 1, 1)^T = (0, 1, 1)^T, $
  $ A'_0 = (-1, -4), quad b'_0 = -5; quad A''_0 = mat(1, 0; 0, 1), quad b''_0 = vec(0, 0). $
  $ g_0 = nabla f(x^((0))) = (1, 3)^T. $

  #step[求下降容许方向]
  $ min quad & p_1 + 3 p_2 \
    "s.t." quad & -p_1 - 4 p_2 >= 0, \
    & p_1 + p_2 = 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  由 $p_2 = -p_1$，约束化为 $3 p_1 >= 0$，目标函数为 $-2 p_1$，取 $p_1 = 1$：
  $ p_0 = (1, -1)^T, quad g_0^T p_0 = -2 < 0. $

  #step[求步长上界]
  $ u &= A''_0 x^((0)) - b''_0 = (1, 1)^T, \
    v &= A''_0 p_0 = (1, -1)^T, \
    overline(t) &= 1 / 1 = 1. $

  #step[直线搜索]
  $ x^((0)) + t p_0 &= (1 + t, 1 - t)^T, \
    phi(t) &= (1 + t)^2 + 2 (1 - t)^2 - (1 + t)(1 - t) = 4 t^2 - 2 t + 2, \
    phi'(t) &= 8 t - 2 = 0 quad => quad t = 1/4 in [0, 1]. $
  $ t_0 = 1/4, quad x^((1)) = x^((0)) + 1/4 p_0 = (5/4, 3/4)^T. $

  #concl[$x^((1)) = (5/4, 3/4)^T$，$f(x^((1))) = 7/4$。]
]

#exam-q("2009-2010", "五")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_1^2 - 2 x_1 x_2 + 4 x_2^2 \
    "s.t." quad & 3 x_1 + x_2 >= 2, \
    & 2 x_1 - 5 x_2 >= -10, \
    & -x_1 + 2 x_2 >= -2, \
    & x_1 >= 0, quad x_2 >= 0. $
  $ A = mat(3, 1; 2, -5; -1, 2; 1, 0; 0, 1), quad b = vec(2, -10, -2, 0, 0), quad nabla f(overline(x)) = vec(2 x_1 - 2 x_2, -2 x_1 + 8 x_2). $

  #step[分解]
  $ A overline(x)_0 - b = (2 - 2, -10 + 10, 4 + 2, 0, 2)^T = (0, 0, 6, 0, 2)^T, $
  第 1、2、4 个约束起作用：
  $ A'_0 = mat(3, 1; 2, -5; 1, 0), quad b'_0 = vec(2, -10, 0); quad A''_0 = mat(-1, 2; 0, 1), quad b''_0 = vec(-2, 0). $
  $ g_0 = nabla f(overline(x)_0) = (-4, 16)^T. $

  #step[求下降容许方向]
  $ min quad & -4 p_1 + 16 p_2 \
    "s.t." quad & 3 p_1 + p_2 >= 0, \
    & 2 p_1 - 5 p_2 >= 0, \
    & p_1 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  #vt(($(1, -1)$, $-20$), ($(1/3, -1)$, $-52/3$), ($(0, 0)$, $0$), ($(1, 2/5)$, $12/5$))
  $ p_0 = (1, -1)^T, quad g_0^T p_0 = -20 < 0. $

  #step[求步长上界]
  $ u &= A''_0 overline(x)_0 - b''_0 = (4 + 2, 2)^T = (6, 2)^T, \
    v &= A''_0 p_0 = (-1 - 2, -1)^T = (-3, -1)^T, \
    overline(t) &= min{ 6/3, 2/1 } = 2. $

  #step[直线搜索]
  $ overline(x)_0 + t p_0 &= (t, 2 - t)^T, \
    phi(t) &= t^2 - 2 t (2 - t) + 4 (2 - t)^2 = 7 t^2 - 20 t + 16, \
    phi'(t) &= 14 t - 20 = 0 quad => quad t = 10/7 in [0, 2]. $
  $ t_0 = 10/7, quad overline(x)_1 = overline(x)_0 + 10/7 p_0 = (10/7, 4/7)^T. $

  #concl[$overline(x)_1 = (10/7, 4/7)^T$，$f(overline(x)_1) = 12/7$。]
]

=== 预测题

#pred-q[
  用 Zoutendijk 容许方向法求解
  $ min quad & (x_1 - 4)^2 + (x_2 - 3)^2 \
    "s.t." quad & -x_1 + 2 x_2 <= 4, quad x_1 + 2 x_2 <= 6, quad x_1 - x_2 <= 2, \
    & x_1 >= 0, quad x_2 >= 0. $
  初始点 $overline(x)_0 = (0, 2)^T$，迭代到满足终止准则为止。
]
#ans[
  #step[化成标准形]
  $ A = mat(1, -2; -1, -2; -1, 1; 1, 0; 0, 1), quad b = vec(-4, -6, -2, 0, 0), quad nabla f(overline(x)) = vec(2 (x_1 - 4), 2 (x_2 - 3)). $

  #step[第 1 次迭代：分解]
  $ A overline(x)_0 - b = (0, 2, 4, 0, 2)^T, $
  $ A'_0 = mat(1, -2; 1, 0), quad b'_0 = vec(-4, 0); quad A''_0 = mat(-1, -2; -1, 1; 0, 1), quad b''_0 = vec(-6, -2, 0); quad g_0 = (-8, -2)^T. $

  #step[第 1 次迭代：求方向]
  $ min quad & -8 p_1 - 2 p_2 \
    "s.t." quad & p_1 - 2 p_2 >= 0, quad p_1 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  #vt(($(1, 1/2)$, $-9$), ($(1, -1)$, $-6$), ($(0, 0)$, $0$), ($(0, -1)$, $2$))
  $ p_0 = (1, 1/2)^T, quad g_0^T p_0 = -9 < 0. $

  #step[第 1 次迭代：步长]
  $ u &= (2, 4, 2)^T, quad v = A''_0 p_0 = (-2, -1/2, 1/2)^T, quad overline(t) = min{2/2, 4 / (1/2)} = 1, \
    phi(t) &= (t - 4)^2 + (t/2 - 1)^2 = 5/4 t^2 - 9 t + 17, \
    phi'(t) &= 5/2 t - 9 < 0 quad (0 <= t <= 1). $
  零点 $t = 18/5$ 超出区间，取 $t_0 = 1$：
  $ overline(x)_1 = overline(x)_0 + p_0 = (1, 5/2)^T. $

  #step[第 2 次迭代：分解]
  $ A overline(x)_1 - b = (0, 0, 7/2, 1, 5/2)^T, $
  $ A'_1 = mat(1, -2; -1, -2), quad b'_1 = vec(-4, -6); quad A''_1 = mat(-1, 1; 1, 0; 0, 1), quad b''_1 = vec(-2, 0, 0); quad g_1 = (-6, -1)^T. $

  #step[第 2 次迭代：求方向]
  $ min quad & -6 p_1 - p_2 \
    "s.t." quad & p_1 - 2 p_2 >= 0, quad -p_1 - 2 p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  #vt(($(1, -1/2)$, $-11/2$), ($(1, -1)$, $-5$), ($(0, 0)$, $0$), ($(-1, -1/2)$, $13/2$), ($(-1, -1)$, $7$))
  $ p_1 = (1, -1/2)^T, quad g_1^T p_1 = -11/2 < 0. $

  #step[第 2 次迭代：步长]
  $ u &= (7/2, 1, 5/2)^T, quad v = A''_1 p_1 = (-3/2, 1, -1/2)^T, quad overline(t) = min{ (7/2)/(3/2), (5/2)/(1/2) } = 7/3, \
    phi(t) &= (t - 3)^2 + 1/4 (t + 1)^2 = 5/4 t^2 - 11/2 t + 37/4, \
    phi'(t) &= 5/2 t - 11/2 = 0 quad => quad t = 11/5 in [0, 7/3]. $
  $ t_1 = 11/5, quad overline(x)_2 = overline(x)_1 + 11/5 p_1 = (16/5, 7/5)^T. $

  #step[检验 $overline(x)_2$]
  $ A overline(x)_2 - b = (22/5, 0, 1/5, 16/5, 7/5)^T, quad g_2 = (-8/5, -16/5)^T = 8/5 (-1, -2)^T. $
  只有第 2 个约束起作用，$g_2 = mu a_2$，$mu = 8/5 > 0$，对满足 $a_2^T p >= 0$ 的 $p$ 都有 $g_2^T p >= 0$，线性规划最优值为 0，满足终止准则。目标函数凸，约束线性，是凸规划。

  #align(center, cetz.canvas(length: 0.95cm, {
    import cetz.draw: *
    line((0, 0), (2, 0), (10 / 3, 4 / 3), (1, 2.5), (0, 2), close: true, fill: luma(225), stroke: 0.6pt)
    line((-0.3, 0), (4.6, 0), mark: (end: ">"), stroke: 0.5pt)
    content((4.85, 0), $x_1$)
    line((0, -0.3), (0, 3.5), mark: (end: ">"), stroke: 0.5pt)
    content((0, 3.75), $x_2$)
    for r in (0.9, 1.789, 2.7) {
      arc((4, 3), start: 180deg, stop: 270deg, radius: r, anchor: "origin", stroke: (paint: luma(110), dash: "dashed", thickness: 0.5pt))
    }
    circle((4, 3), radius: 0.05, fill: black)
    content((4, 3), text(size: 8pt)[$(4, 3)$], anchor: "south-west", padding: 0.08)
    line((0, 2), (1, 2.5), mark: (end: ">"), stroke: 1pt)
    line((1, 2.5), (3.2, 1.4), mark: (end: ">"), stroke: 1pt)
    for (pt, lbl, anc) in (((0, 2), $overline(x)_0$, "east"), ((1, 2.5), $overline(x)_1$, "south"), ((3.2, 1.4), $overline(x)_2$, "north-west")) {
      circle(pt, radius: 0.05, fill: black)
      content(pt, text(size: 8pt, lbl), anchor: anc, padding: 0.1)
    }
  }))

  #concl[$overline(x)_2 = (16/5, 7/5)^T$ 是最优解，最优值 $16/5$。第 1 步沿边界 $-x_1 + 2 x_2 = 4$ 走到顶点 $overline(x)_1$，第 2 步沿边界 $x_1 + 2 x_2 = 6$ 走到 $(4, 3)$ 在这条边上的投影。]
]

#pred-q[
  用 Zoutendijk 容许方向法求解
  $ min quad & -ln(1 + x_1) - 2 ln(1 + x_2) \
    "s.t." quad & x_1 + x_2 <= 2, quad x_1 >= 0, quad x_2 >= 0. $
  初始点 $overline(x)_0 = (0, 0)^T$，迭代到满足终止准则为止。
]
#ans[
  #step[化成标准形]
  $ A = mat(-1, -1; 1, 0; 0, 1), quad b = vec(-2, 0, 0), quad nabla f(overline(x)) = vec(-1 / (1 + x_1), -2 / (1 + x_2)). $

  #step[第 1 次迭代]
  $A overline(x)_0 - b = (2, 0, 0)^T$，后两个约束起作用；$g_0 = (-1, -2)^T$。
  $ min quad & -p_1 - 2 p_2 \
    "s.t." quad & p_1 >= 0, quad p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  两项分别取最小：$p_0 = (1, 1)^T$，$g_0^T p_0 = -3 < 0$。
  $ u &= 2, quad v = (-1, -1) p_0 = -2, quad overline(t) = 1, \
    phi(t) &= -ln(1 + t) - 2 ln(1 + t) = -3 ln(1 + t), quad phi'(t) = -3 / (1 + t) < 0. $
  $ t_0 = overline(t) = 1, quad overline(x)_1 = (1, 1)^T. $

  #step[第 2 次迭代]
  $A overline(x)_1 - b = (0, 1, 1)^T$，第 1 个约束起作用：
  $ A'_1 = (-1, -1), quad b'_1 = -2; quad A''_1 = mat(1, 0; 0, 1), quad b''_1 = vec(0, 0); quad g_1 = (-1/2, -1)^T. $
  $ min quad & -1/2 p_1 - p_2 \
    "s.t." quad & -p_1 - p_2 >= 0, \
    & -1 <= p_1 <= 1, quad -1 <= p_2 <= 1. $
  #vt(($(-1, 1)$, $-1/2$), ($(1, -1)$, $1/2$), ($(-1, -1)$, $3/2$))
  $ p_1 = (-1, 1)^T, quad g_1^T p_1 = -1/2 < 0. $
  $ u &= (1, 1)^T, quad v = A''_1 p_1 = (-1, 1)^T, quad overline(t) = 1, \
    phi(t) &= -ln(2 - t) - 2 ln(2 + t), \
    phi'(t) &= 1 / (2 - t) - 2 / (2 + t) = 0 quad => quad 2 + t = 4 - 2 t quad => quad t = 2/3 in [0, 1]. $
  $ t_1 = 2/3, quad overline(x)_2 = overline(x)_1 + 2/3 p_1 = (1/3, 5/3)^T. $

  #step[检验 $overline(x)_2$]
  $A overline(x)_2 - b = (0, 1/3, 5/3)^T$，第 1 个约束起作用；
  $ g_2 = (-1 / (4\/3), -2 / (8\/3))^T = (-3/4, -3/4)^T = 3/4 (-1, -1)^T, $
  $mu = 3/4 > 0$，线性规划最优值为 0，满足终止准则。$-ln(1 + x_i)$ 是凸函数，约束线性，是凸规划。

  #concl[$overline(x)_2 = (1/3, 5/3)^T$ 是最优解，最优值 $-ln(4/3) - 2 ln(8/3) = -ln(256/27)$。]
]

#pit[
  - “$<=$”约束要先乘 $-1$ 化成“$>=$”，$A''$、$b''$ 的符号跟着变。$u = A'' overline(x)_k - b''$ 的各分量一定是正数，算出负数说明分解错了或点不容许。
  - 求方向的线性规划别漏掉 $-1 <= p_j <= 1$；有等式约束时还要 $C p = 0$。
  - $overline(t)$ 只对 $v_i < 0$ 的项取最小；$v >= 0$ 时 $overline(t) = +oo$，直线搜索在 $t >= 0$ 上做。
  - $phi'(t) = 0$ 的根超出 $[0, overline(t)]$ 时取 $overline(t)$，不能直接用这个根，否则新点不容许。
  - max 问题先化成 min，梯度跟着变号。
  - 说“是最优解”要两步：满足终止准则（或乘子都非负）得到 K-T 点，再说明是凸规划。
]

== 检验给定的方向 <s-zout-given>

#flow(title: [做法])[
  + 化成 $A x >= b$、$C x = d$，验证 $overline(x)_0$ 容许，找出起作用约束。
  + 容许：$C p = 0$，且起作用约束 $A' p >= 0$（定理 4.14，线性约束时是充要条件）。
  + 下降：$nabla f(overline(x)_0)^T p < 0$。
  + 是下降容许方向，就照常求 $overline(t)$、做直线搜索；给定的 $p$ 不必满足 $-1 <= p_j <= 1$，步长按给的 $p$ 算。
  + 判断 K-T 点：在新点找起作用约束，解 $nabla f = sum mu_i a_i + sum lambda_j c_j$，看是否有解、$mu_i$ 是否都 $>= 0$。
]

#dlg[
  #Q[题目给的方向不满足 $-1 <= p_j <= 1$，有关系吗？]
  #A[没有关系。这组界限只是为了让求方向的线性规划有界。方向是否容许、是否下降只看 $A' p$、$C p$、$nabla f^T p$ 的符号，和长度无关。直线搜索时 $t$ 按给的 $p$ 算：$p$ 放大一倍，$t$ 缩小一半，新点不变。]
  #Q[怎样最快判断新点是不是 K-T 点？]
  #A[线性约束时直接解 $nabla f(overline(x)) = sum mu_i a_i + sum lambda_j c_j$，只用起作用约束。无解，或者某个 $mu_i < 0$，就不是 K-T 点；有解且 $mu >= 0$ 就是。新点没有起作用的不等式约束时只剩等式约束，看 $nabla f$ 是不是等式约束梯度的组合。]
  #Q[给定方向不是容许方向时怎么办？]
  #A[按 Zoutendijk 法自己求方向：在 $overline(x)_0$ 解线性规划 $min nabla f^T p$，$A' p >= 0$，$C p = 0$，$-1 <= p_j <= 1$。三个变量时先用等式约束消去一个分量，再按两个变量的线性规划解，注意被消去的分量也要满足 $-1 <= p_j <= 1$。]
]

#exam-q("2018-2019", "五")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = (x_1 + 3)^2 + (x_2 - 2)^2 + x_3^2 \
    "s.t." quad & -2 x_1 - 3 x_2 + 2 x_3 >= 3, \
    & -x_1 - 3 x_2 + x_3 >= -2, \
    & -2 x_2 + x_3 >= 0, \
    & 2 x_1 + x_2 + 4 x_3 = 7. $
  $ A = mat(-2, -3, 2; -1, -3, 1; 0, -2, 1), quad b = vec(3, -2, 0), quad C = (2, 1, 4), quad d = 7, quad nabla f(overline(x)) = vec(2 (x_1 + 3), 2 (x_2 - 2), 2 x_3). $

  #step[(1) 起作用约束]
  在 $overline(x)_0 = (-1, 1, 2)^T$：
  $ C overline(x)_0 = -2 + 1 + 8 = 7, quad A overline(x)_0 - b = (2 - 3 + 4 - 3, 1 - 3 + 2 + 2, -2 + 2)^T = (0, 2, 0)^T, $
  第 1、3 个约束起作用：
  $ A' = mat(-2, -3, 2; 0, -2, 1), quad A'' = (-1, -3, 1), quad b'' = -2. $

  #step[检验 $overline(p) = (-2, 0, 1)^T$]
  $ C overline(p) &= -4 + 0 + 4 = 0, \
    A' overline(p) &= (4 + 0 + 2, 0 + 0 + 1)^T = (6, 1)^T >= 0, \
    nabla f(overline(x)_0)^T overline(p) &= (4, -2, 4) (-2, 0, 1)^T = -8 + 4 = -4 < 0. $
  由定理 4.14，$overline(p)$ 是容许方向；又 $nabla f^T overline(p) < 0$，是下降方向。

  #concl[$overline(p)$ *是* $overline(x)_0$ 处的下降容许方向。]

  #step[(2) 求步长上界]
  $ u &= A'' overline(x)_0 - b'' = 1 - 3 + 2 + 2 = 2, \
    v &= A'' overline(p) = 2 + 0 + 1 = 3 >= 0, $
  所以 $overline(t) = +oo$，在 $t >= 0$ 上搜索。

  #step[直线搜索]
  $ overline(x)_0 + t overline(p) &= (-1 - 2 t, 1, 2 + t)^T, \
    phi(t) &= (2 - 2 t)^2 + (-1)^2 + (2 + t)^2 = 5 t^2 - 4 t + 9, \
    phi'(t) &= 10 t - 4 = 0 quad => quad t_0 = 2/5. $
  $ overline(x)_1 = overline(x)_0 + 2/5 overline(p) = (-9/5, 1, 12/5)^T. $

  #step[判断 $overline(x)_1$ 是否为 K-T 点]
  $ C overline(x)_1 = -18/5 + 1 + 48/5 = 7, quad A overline(x)_1 - b = (12/5, 16/5, 2/5)^T > 0, $
  三个不等式约束都不起作用，只有等式约束。
  $ nabla f(overline(x)_1) = (12/5, -2, 24/5)^T. $
  K-T 条件要求 $nabla f(overline(x)_1) = lambda (2, 1, 4)^T$：第 1 个分量给出 $lambda = 6/5$，第 2 个分量给出 $lambda = -2$，矛盾，无解。

  #concl[$overline(x)_1 = (-9/5, 1, 12/5)^T$ *不是* K-T 点。]
]

#exam-q("2011-2012", "六(2)")
#ans[
  #step[化成标准形]
  $ min quad & f(overline(x)) = x_1^2 + 2 x_2^2 - x_3^2 - 3 x_2 x_3 \
    "s.t." quad & -3 x_1 - 4 x_2 - 2 x_3 >= -6, \
    & x_1 >= 0, quad x_2 >= 0, quad x_3 >= 0, \
    & x_1 + x_2 + x_3 = 1. $
  $ nabla f(overline(x)) = (2 x_1, 4 x_2 - 3 x_3, -2 x_3 - 3 x_2)^T. $

  #step[(1) 起作用约束]
  在 $overline(x)_0 = (1, 0, 0)^T$：等式约束成立；$-3 + 6 = 3 > 0$，$x_1 = 1 > 0$，这两个不起作用；$x_2 = 0$、$x_3 = 0$ 起作用。
  $ A' = mat(0, 1, 0; 0, 0, 1), quad A'' = mat(-3, -4, -2; 1, 0, 0), quad b'' = vec(-6, 0). $

  #step[检验 $overline(p)_0 = (-2, 1, 1)^T$]
  $ C overline(p)_0 &= -2 + 1 + 1 = 0, \
    A' overline(p)_0 &= (1, 1)^T >= 0, \
    nabla f(overline(x)_0)^T overline(p)_0 &= (2, 0, 0) (-2, 1, 1)^T = -4 < 0. $

  #concl[$overline(p)_0$ *是* $overline(x)_0$ 处的下降容许方向。]

  #step[(2) 求步长上界]
  $ u &= A'' overline(x)_0 - b'' = (-3 + 6, 1)^T = (3, 1)^T, \
    v &= A'' overline(p)_0 = (6 - 4 - 2, -2)^T = (0, -2)^T, \
    overline(t) &= 1/2. $

  #step[直线搜索]
  $ overline(x)_0 + t overline(p)_0 &= (1 - 2 t, t, t)^T, \
    phi(t) &= (1 - 2 t)^2 + 2 t^2 - t^2 - 3 t^2 = 2 t^2 - 4 t + 1, \
    phi'(t) &= 4 t - 4 < 0 quad (0 <= t <= 1/2). $
  取 $t_0 = overline(t) = 1/2$：
  $ overline(x)_1 = overline(x)_0 + 1/2 overline(p)_0 = (0, 1/2, 1/2)^T. $

  #concl[$overline(x)_1 = (0, 1/2, 1/2)^T$，$f(overline(x)_1) = -1/2$。]
]

=== 预测题

#pred-q[
  约束问题
  $ min quad & (x_1 - 1)^2 + x_2^2 + (x_3 - 2)^2 \
    "s.t." quad & x_1 + x_2 + x_3 = 2, quad x_1 >= x_2, quad x_1, x_2, x_3 >= 0. $
  初始点 $overline(x)_0 = (1, 1, 0)^T$。(1) 判断 $overline(p) = (-1, 0, 1)^T$ 是否为 $overline(x)_0$ 处的下降容许方向；(2) 用 Z-容许方向法求 $overline(x)_0$ 处的下降容许方向，迭代一次求 $overline(x)_1$；(3) 再迭代一次求 $overline(x)_2$，并判断 $overline(x)_2$ 是否为最优解。
]
#ans[
  #step[化成标准形]
  $ A = mat(1, -1, 0; 1, 0, 0; 0, 1, 0; 0, 0, 1), quad b = vec(0, 0, 0, 0), quad C = (1, 1, 1), quad d = 2, quad nabla f(overline(x)) = vec(2 (x_1 - 1), 2 x_2, 2 (x_3 - 2)). $

  #step[(1) 检验 $overline(p)$]
  $A overline(x)_0 - b = (0, 1, 1, 0)^T$，第 1、4 个约束起作用；$g_0 = (0, 2, -4)^T$。
  $ C overline(p) = -1 + 0 + 1 = 0, quad (1, -1, 0) overline(p) = -1 < 0. $
  沿 $overline(p)$ 走，$x_1 - x_2 = -t < 0$，离开了容许集（虽然 $g_0^T overline(p) = -4 < 0$）。
  #concl[$overline(p)$ *不是*下降容许方向。]

  #step[(2) 求下降容许方向]
  $ min quad & 2 p_2 - 4 p_3 \
    "s.t." quad & p_1 - p_2 >= 0, quad p_3 >= 0, \
    & p_1 + p_2 + p_3 = 0, \
    & -1 <= p_j <= 1, quad j = 1, 2, 3. $
  消去 $p_3 = -p_1 - p_2$：目标函数 $4 p_1 + 6 p_2$，约束 $p_1 >= p_2$，$-1 <= p_1 + p_2 <= 0$，$-1 <= p_1, p_2 <= 1$。
  #vt(($(0, -1, 1)$, $-6$), ($(-1/2, -1/2, 1)$, $-5$), ($(1, -1, 0)$, $-2$), ($(0, 0, 0)$, $0$))
  $ p_0 = (0, -1, 1)^T, quad g_0^T p_0 = -6 < 0. $

  #step[步长和新点]
  $ u &= (1, 1)^T quad (x_1 >= 0, x_2 >= 0), quad v = (0, -1)^T, quad overline(t) = 1, \
    phi(t) &= (1 - t)^2 + (t - 2)^2 = 2 t^2 - 6 t + 5, quad phi'(t) = 4 t - 6 < 0 quad (0 <= t <= 1). $
  $ t_0 = 1, quad overline(x)_1 = (1, 0, 1)^T. $

  #step[(3) 第 2 次迭代]
  $A overline(x)_1 - b = (1, 1, 0, 1)^T$，只有 $x_2 >= 0$ 起作用；$g_1 = (0, 0, -2)^T$。
  $ min quad & -2 p_3 \
    "s.t." quad & p_2 >= 0, quad p_1 + p_2 + p_3 = 0, quad -1 <= p_j <= 1. $
  消去 $p_3$：目标函数 $2 p_1 + 2 p_2$，$p_2 >= 0$，取 $p_1 = -1$、$p_2 = 0$：
  $ p_1 = (-1, 0, 1)^T, quad g_1^T p_1 = -2 < 0. $
  $ u &= (1, 1, 1)^T quad (x_1 - x_2 >= 0, x_1 >= 0, x_3 >= 0), quad v = (-1, -1, 1)^T, quad overline(t) = 1, \
    phi(t) &= t^2 + (t - 1)^2, quad phi'(t) = 4 t - 2 = 0 quad => quad t_1 = 1/2. $
  $ overline(x)_2 = overline(x)_1 + 1/2 p_1 = (1/2, 0, 3/2)^T. $

  #step[判断 $overline(x)_2$]
  只有 $x_2 >= 0$ 起作用，$g_2 = (-1, 0, -1)^T$。令 $g_2 = mu (0, 1, 0)^T + lambda (1, 1, 1)^T$：
  $ lambda = -1, quad mu + lambda = 0, quad lambda = -1 quad => quad mu = 1 >= 0. $
  $overline(x)_2$ 是 K-T 点；目标函数凸、约束线性，是凸规划。

  #concl[$overline(x)_1 = (1, 0, 1)^T$，$overline(x)_2 = (1/2, 0, 3/2)^T$ 是最优解，最优值 $1/2$。]
]

#pit[
  - 给定方向先查等式约束 $C p = 0$，再查起作用约束 $A' p >= 0$，最后查下降；不起作用的约束不用查。
  - 下降但不容许的方向（如预测题的 $overline(p)$）不能用，必须两条都满足。
  - $v$ 的分量都 $>= 0$ 时 $overline(t) = +oo$，不要写成 0。
]
