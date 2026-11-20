#import "/book/lib.typ": *

= 罚函数法与乘子法 <part-penalty>

== 外部罚函数法 <s-penalty>

#flow(title: [做法])[
  + *化成标准形*：约束写成 $s_i (overline(x)) >= 0$、$h_j (overline(x)) = 0$。
  + *写增广目标函数*：
    $ F(overline(x), mu) = f(overline(x)) + mu alpha(overline(x)), quad alpha(overline(x)) = sum_(j=1)^l h_j^2 (overline(x)) + sum_(i=1)^m s_i^2 (overline(x)) u(s_i (overline(x))), $
    $u(t) = 0$（$t >= 0$），$u(t) = 1$（$t < 0$）：不等式约束只在被违反时才罚。
  + *判断哪些约束被违反*：看 $f$ 的无约束极小点（或 $f$ 往哪个方向无限下降）违反哪些约束，先假定这些约束 $s_i < 0$、其余 $s_i >= 0$。
  + *求 $overline(x)_mu$*：在这个分支里令 $nabla_x F = 0$，解出含 $mu$ 的 $overline(x)_mu$；再代回检查分支假定（被罚的 $s_i (overline(x)_mu) < 0$，没罚的 $>= 0$）。
  + *令 $mu -> +oo$*：$overline(x)^* = lim overline(x)_mu$，算出最优值。
  + *数值迭代*（题目给了 $mu_1$、$c$、$epsilon$）：$mu_k = c^(k-1) mu_1$，$overline(x)_k = overline(x)_(mu_k)$，算 $mu_k alpha(overline(x)_k)$；小于 $epsilon$ 就停止（算法 4.6）。
]

#dlg[
  #Q[为什么找到一个自洽的分支就够了？]
  #A[$s_i^2 u(s_i) = [min{0, s_i}]^2$。$f$ 是凸函数、约束是线性函数时，$h_j^2$ 和 $[min{0, s_i}]^2$ 都是凸函数，$F$ 是凸函数，驻点就是全局极小点。所以只要某个分支解出的点符合这个分支的假定，它就是 $F$ 的极小点，不用再试别的分支。]
  #Q[$overline(x)_mu$ 为什么总在容许集外面？]
  #A[容许点处 $alpha = 0$，不受惩罚；最优解一般在约束边界上，$f$ 在那里还有往外下降的趋势，$F$ 的极小点会稍微越过边界，用一点惩罚换更小的 $f$。所以这个方法也叫外点法，只有 $mu -> +oo$ 时 $overline(x)_mu$ 才落到容许集上。]
  #Q[$f$ 的无约束极小点本身就容许时怎么办？]
  #A[容许点处 $F = f$，这个点就是 $F$ 的极小点，也是约束问题的最优解（定理 4.22），和 $mu$ 无关。]
  #Q[罚因子很大有什么问题？]
  #A[$F$ 的 Hesse 矩阵里有 $2 mu nabla h nabla h^T$ 这样的项，$mu$ 很大时条件数很大，矩阵病态，无约束极小化在数值上很难算准。乘子法就是为了避开这一点。]
  #Q[终止准则 $mu_k alpha(overline(x)_k) < epsilon$ 怎么理解？]
  #A[$mu_k alpha(overline(x)_k)$ 是惩罚项的大小，也是 $F$ 和 $f$ 之差。它小于 $epsilon$ 说明 $overline(x)_k$ 离容许集已经很近（定理 4.24 的证明中 $mu_k alpha(overline(x)_k) -> 0$）。数值计算题按 $k = 1, 2, dots$ 列出 $mu_k$、$overline(x)_k$、$mu_k alpha(overline(x)_k)$，直到小于 $epsilon$。]
]

#exam-q("2024-2025A", "九")
#ans[
  #step[化成标准形]
  $ h(overline(x)) = x_1 + x_2 = 0, quad s(overline(x)) = x_1 - 1 >= 0. $

  #step[增广目标函数]
  $ F(overline(x), mu) = (x_1 - 2)^2 + (x_2 - 2)^2 + mu [(x_1 + x_2)^2 + (x_1 - 1)^2 u(x_1 - 1)]. $

  #step[判断约束是否被违反]
  在直线 $x_1 + x_2 = 0$ 上，$f = (x_1 - 2)^2 + (x_1 + 2)^2 = 2 x_1^2 + 8$ 在 $x_1 = 0$ 处最小，违反 $x_1 >= 1$。假定 $x_1 < 1$，这时 $u = 1$：
  $ F = (x_1 - 2)^2 + (x_2 - 2)^2 + mu (x_1 + x_2)^2 + mu (x_1 - 1)^2. $

  #step[求 $overline(x)_mu$]
  $ (partial F) / (partial x_1) &= 2 (x_1 - 2) + 2 mu (x_1 + x_2) + 2 mu (x_1 - 1) = 0, \
    (partial F) / (partial x_2) &= 2 (x_2 - 2) + 2 mu (x_1 + x_2) = 0. $
  整理成线性方程组：
  $ (1 + 2 mu) x_1 + mu x_2 &= 2 + mu, \
    mu x_1 + (1 + mu) x_2 &= 2. $
  系数行列式 $(1 + 2 mu)(1 + mu) - mu^2 = mu^2 + 3 mu + 1$，解得
  $ overline(x)_mu = ((mu^2 + mu + 2) / (mu^2 + 3 mu + 1), (-mu^2 + 2 mu + 2) / (mu^2 + 3 mu + 1))^T. $
  检查分支：
  $ x_1 - 1 = (1 - 2 mu) / (mu^2 + 3 mu + 1) < 0 quad (mu > 1/2), $
  $mu -> +oo$ 时假定成立。（$mu <= 1/2$ 时落在 $x_1 >= 1$ 一侧，$overline(x)_mu = (2/(1 + 2 mu), 2/(1 + 2 mu))^T$，不影响极限。）

  #step[令 $mu -> +oo$]
  $ overline(x)^* = lim_(mu -> +oo) overline(x)_mu = (1, -1)^T, quad f(overline(x)^*) = 1 + 9 = 10. $

  #concl[最优解 $overline(x)^* = (1, -1)^T$，最优值 $10$。]
]

#exam-q("2023-2024", "八(2)")
#ans[
  #step[(1) 增广目标函数]
  约束 $s = x_1 - x_2 - 5 >= 0$：
  $ F(overline(x); mu) = (x_1 - 2)^2 + (x_2 - 1)^2 + mu (x_1 - x_2 - 5)^2 u(x_1 - x_2 - 5). $

  #step[(2) 求 $overline(x)_mu^*$]
  无约束极小点 $(2, 1)$ 处 $s = -4 < 0$，取 $u = 1$ 的一段：
  $ (partial F) / (partial x_1) &= 2 (x_1 - 2) + 2 mu (x_1 - x_2 - 5) = 0, \
    (partial F) / (partial x_2) &= 2 (x_2 - 1) - 2 mu (x_1 - x_2 - 5) = 0. $
  两式相加得 $x_1 + x_2 = 3$。令 $x_1 = 2 + w$，$x_2 = 1 - w$，则 $x_1 - x_2 - 5 = 2 w - 4$，代入第 1 式：
  $ 2 w + 2 mu (2 w - 4) = 0 quad => quad w = (4 mu) / (1 + 2 mu). $
  $ overline(x)_mu^* = ((8 mu + 2) / (2 mu + 1), (1 - 2 mu) / (2 mu + 1))^T, quad s(overline(x)_mu^*) = -4 / (2 mu + 1) < 0. $

  #step[(3) 第 1 次迭代]
  $mu_1 = 5$：
  $ overline(x)_1 = (42/11, -9/11)^T, quad mu_1 alpha(overline(x)_1) = 5 dot (-4/11)^2 = 80/121 approx 0.661 > epsilon = 0.1, $
  不满足终止准则（$overline(x)_1$ 处 $x_1 - x_2 = 51/11 < 5$，不是容许点），所以 $overline(x)_1$ 不是最优解。

  #step[(4) 第 2 次迭代]
  $mu_2 = c mu_1 = 10$：
  $ overline(x)_2 = (82/21, -19/21)^T, quad mu_2 alpha(overline(x)_2) = 10 dot (4/21)^2 = 160/441 approx 0.363 > 0.1. $

  #step[继续迭代]
  #align(center, three-line(columns: 4,
    ($k$, $mu_k$, $overline(x)_k$, $mu_k alpha(overline(x)_k)$),
    $1$, $5$, $(42\/11, -9\/11)$, $0.661$,
    $2$, $10$, $(82\/21, -19\/21)$, $0.363$,
    $3$, $20$, $(162\/41, -39\/41)$, $0.190$,
    $4$, $40$, $(322\/81, -79\/81)$, $0.0975$,
  ))
  第 4 次 $mu_4 alpha(overline(x)_4) < 0.1$，停止。$mu -> +oo$ 时 $overline(x)_mu^* -> (4, -1)^T$。

  #concl[(1) 如上。(2) $overline(x)_mu^* = ((8 mu + 2)/(2 mu + 1), (1 - 2 mu)/(2 mu + 1))^T$。(3) $overline(x)_1 = (42/11, -9/11)^T$，因为 $mu_1 alpha(overline(x)_1) = 80/121 > 0.1$。(4) $overline(x)_2 = (82/21, -19/21)^T$。]
]

#exam-q("2022-2023", "八")
#ans[
  #step[化成标准形]
  $ s_1 = x_1 + x_2 - 1 >= 0, quad s_2 = -x_1 + x_2 - 2 >= 0. $

  #step[增广目标函数]
  $ F(overline(x), mu) = (x_1 - 2)^2 + x_2^2 + mu [s_1^2 u(s_1) + s_2^2 u(s_2)]. $

  #step[判断约束是否被违反]
  无约束极小点 $(2, 0)$ 处 $s_1 = 1 >= 0$，$s_2 = -4 < 0$。假定只违反 $s_2$：
  $ F = (x_1 - 2)^2 + x_2^2 + mu (x_2 - x_1 - 2)^2. $

  #step[求 $overline(x)_mu$]
  $ (partial F) / (partial x_1) &= 2 (x_1 - 2) - 2 mu (x_2 - x_1 - 2) = 0, \
    (partial F) / (partial x_2) &= 2 x_2 + 2 mu (x_2 - x_1 - 2) = 0. $
  两式相加得 $x_1 - 2 + x_2 = 0$，即 $x_1 = 2 - x_2$。代入第 2 式：
  $ x_2 + mu (2 x_2 - 4) = 0 quad => quad x_2 = (4 mu) / (1 + 2 mu), quad x_1 = 2 / (1 + 2 mu). $
  检查分支：
  $ s_1 (overline(x)_mu) = (2 + 4 mu) / (1 + 2 mu) - 1 = 1 > 0, quad s_2 (overline(x)_mu) = -4 / (1 + 2 mu) < 0. $
  假定成立。

  #step[令 $mu -> +oo$]
  $ overline(x)^* = lim_(mu -> +oo) (2 / (1 + 2 mu), (4 mu) / (1 + 2 mu))^T = (0, 2)^T, quad f(overline(x)^*) = 4 + 4 = 8. $

  #concl[最优解 $overline(x)^* = (0, 2)^T$，最优值 $8$。]
]

#exam-q("2019-2020", "八(1)")
#ans[
  #step[(1) 增广目标函数]
  $ F(overline(x); mu) = (x_1 - 1)^2 + (x_2 - 1)^2 + mu (x_1 + 2 x_2 - 4)^2. $

  #step[(2) 约束问题的最优解]
  $ overline(x)^* = lim_(mu -> +oo) ((6 mu + 1) / (5 mu + 1), (7 mu + 1) / (5 mu + 1))^T = (6/5, 7/5)^T. $

  #step[(3) 数值迭代]
  $h(overline(x)_mu) = (6 mu + 1 + 14 mu + 2 - 20 mu - 4) / (5 mu + 1) = -1 / (5 mu + 1)$，所以
  $ mu alpha(overline(x)_mu) = mu / (5 mu + 1)^2. $
  #align(center, three-line(columns: 4,
    ($k$, $mu_k$, $overline(x)_k$, $mu_k alpha(overline(x)_k)$),
    $1$, $5$, $(31\/26, 18\/13)$, $5\/676 approx 0.0074$,
    $2$, $10$, $(61\/51, 71\/51)$, $10\/2601 approx 0.0038$,
  ))
  按终止准则，第 1 次 $mu_1 alpha(overline(x)_1) = 5/676 < 0.01$ 就可以停止，输出 $overline(x)_1 = (31/26, 18/13)^T approx (1.192, 1.385)^T$；表中第 2 行是题目要求的第二次迭代。

  #concl[(1) $F = (x_1 - 1)^2 + (x_2 - 1)^2 + mu (x_1 + 2 x_2 - 4)^2$。(2) $overline(x)^* = (6/5, 7/5)^T$。(3) $overline(x)_1 = (31/26, 18/13)^T$，$mu_1 alpha(overline(x)_1) = 5/676 < 0.01$，停止；第二次 $overline(x)_2 = (61/51, 71/51)^T$。]
]

#exam-q("2016-2017", "八")
#ans[
  #step[化成标准形]
  $ s_1 = x_1 + 2 x_2 - 7 >= 0, quad s_2 = 2 x_1 - x_2 - 4 >= 0. $

  #step[增广目标函数]
  $ F(overline(x), mu) = (x_1 - 2)^2 + (x_2 - 1)^2 + mu [s_1^2 u(s_1) + s_2^2 u(s_2)]. $

  #step[判断约束是否被违反]
  无约束极小点 $(2, 1)$ 处 $s_1 = -3 < 0$，$s_2 = -1 < 0$。假定两个约束都被违反：
  $ F = (x_1 - 2)^2 + (x_2 - 1)^2 + mu (x_1 + 2 x_2 - 7)^2 + mu (2 x_1 - x_2 - 4)^2. $

  #step[求 $overline(x)_mu$]
  $ 1/2 (partial F) / (partial x_1) &= (x_1 - 2) + mu (x_1 + 2 x_2 - 7) + 2 mu (2 x_1 - x_2 - 4) = (1 + 5 mu) x_1 - (2 + 15 mu) = 0, \
    1/2 (partial F) / (partial x_2) &= (x_2 - 1) + 2 mu (x_1 + 2 x_2 - 7) - mu (2 x_1 - x_2 - 4) = (1 + 5 mu) x_2 - (1 + 10 mu) = 0. $
  $ overline(x)_mu = ((2 + 15 mu) / (1 + 5 mu), (1 + 10 mu) / (1 + 5 mu))^T. $
  检查分支：
  $ s_1 (overline(x)_mu) = -3 / (1 + 5 mu) < 0, quad s_2 (overline(x)_mu) = -1 / (1 + 5 mu) < 0. $
  假定成立。

  #step[令 $mu -> +oo$]
  $ overline(x)^* = lim_(mu -> +oo) overline(x)_mu = (3, 2)^T, quad f(overline(x)^*) = 1 + 1 = 2. $

  #concl[最优解 $overline(x)^* = (3, 2)^T$，最优值 $2$（两个约束都起作用）。]
]

#exam-q("2015-2016", "九")
#ans[
  #step[化成标准形]
  $ s_1 = 2 - x_1 - x_2 >= 0, quad s_2 = x_1 >= 0. $

  #step[增广目标函数]
  $ F(overline(x), mu) = -ln(x_1 + 1) - ln(x_2 + 1) + mu [s_1^2 u(s_1) + x_1^2 u(x_1)]. $

  #step[判断约束是否被违反]
  $f$ 对 $x_1$、$x_2$ 都单调递减，没有无约束极小点，$x_1 + x_2 <= 2$ 一定会被突破。假定 $s_1 < 0$、$x_1 >= 0$：
  $ F = -ln(x_1 + 1) - ln(x_2 + 1) + mu (x_1 + x_2 - 2)^2. $

  #step[求 $overline(x)_mu$]
  $ (partial F) / (partial x_1) &= -1 / (x_1 + 1) + 2 mu (x_1 + x_2 - 2) = 0, \
    (partial F) / (partial x_2) &= -1 / (x_2 + 1) + 2 mu (x_1 + x_2 - 2) = 0. $
  两式相减得 $x_1 = x_2 = x$，代入：
  $ 1 / (x + 1) = 4 mu (x - 1) quad => quad x^2 - 1 = 1 / (4 mu) quad => quad x = sqrt(1 + 1 / (4 mu)) quad (text("取正根")). $
  检查分支：$x > 1$，所以 $s_1 = 2 - 2 x < 0$，$x_1 = x > 0$，假定成立。

  #step[令 $mu -> +oo$]
  $ overline(x)^* = lim_(mu -> +oo) (sqrt(1 + 1/(4 mu)), sqrt(1 + 1/(4 mu)))^T = (1, 1)^T, quad f(overline(x)^*) = -2 ln 2. $

  #concl[最优解 $overline(x)^* = (1, 1)^T$，最优值 $-2 ln 2$。]
]

#exam-q("2009-2010", "六")
#ans[
  #step[增广目标函数]
  $ F(overline(x), mu) = (x_1 - x_2)^2 - 5 x_1 - x_2 + mu [(2 - x_1 - x_2)^2 u(2 - x_1 - x_2) + x_2^2 u(x_2)]. $

  #step[判断约束是否被违反]
  $f$ 沿方向 $(1, 1)^T$ 无限下降：$f(x_1 + t, x_2 + t) = f(x_1, x_2) - 6 t$，所以 $x_1 + x_2 <= 2$ 会被突破。假定 $2 - x_1 - x_2 < 0$、$x_2 >= 0$：
  $ F = (x_1 - x_2)^2 - 5 x_1 - x_2 + mu (x_1 + x_2 - 2)^2. $

  #step[求 $overline(x)_mu$]
  $ (partial F) / (partial x_1) &= 2 (x_1 - x_2) - 5 + 2 mu (x_1 + x_2 - 2) = 0, \
    (partial F) / (partial x_2) &= -2 (x_1 - x_2) - 1 + 2 mu (x_1 + x_2 - 2) = 0. $
  两式相减：$4 (x_1 - x_2) - 4 = 0$，$x_1 - x_2 = 1$；两式相加：$-6 + 4 mu (x_1 + x_2 - 2) = 0$，$x_1 + x_2 = 2 + 3/(2 mu)$。
  $ overline(x)_mu = (3/2 + 3/(4 mu), 1/2 + 3/(4 mu))^T. $
  检查分支：$2 - x_1 - x_2 = -3/(2 mu) < 0$，$x_2 > 0$，假定成立。

  #step[令 $mu -> +oo$]
  $ overline(x)^* = (3/2, 1/2)^T, quad f(overline(x)^*) = 1 - 15/2 - 1/2 = -7. $

  #concl[最优解 $overline(x)^* = (3/2, 1/2)^T$，最优值 $-7$。]
]

=== 预测题

#pred-q[
  用外部罚函数法求解 $min x_1^2 + 2 x_2^2$，s.t. $x_1 + x_2 >= 1$。并取初始罚因子 $mu_1 = 1$，放大系数 $c = 10$，终止限 $epsilon = 0.01$，列出数值计算的迭代过程。
]
#ans[
  #step[增广目标函数]
  $ F(overline(x), mu) = x_1^2 + 2 x_2^2 + mu (x_1 + x_2 - 1)^2 u(x_1 + x_2 - 1). $

  #step[求 $overline(x)_mu$]
  无约束极小点 $(0, 0)$ 违反约束，取 $u = 1$ 的一段：
  $ (partial F) / (partial x_1) &= 2 x_1 + 2 mu (x_1 + x_2 - 1) = 0, \
    (partial F) / (partial x_2) &= 4 x_2 + 2 mu (x_1 + x_2 - 1) = 0. $
  两式相减得 $x_1 = 2 x_2$，代入第 2 式：$4 x_2 + 2 mu (3 x_2 - 1) = 0$。
  $ overline(x)_mu = ((2 mu) / (2 + 3 mu), mu / (2 + 3 mu))^T, quad x_1 + x_2 - 1 = -2 / (2 + 3 mu) < 0. $

  #step[令 $mu -> +oo$]
  $ overline(x)^* = (2/3, 1/3)^T, quad f(overline(x)^*) = 4/9 + 2/9 = 2/3. $

  #step[数值迭代]
  $mu alpha(overline(x)_mu) = (4 mu) / (2 + 3 mu)^2$：
  #align(center, three-line(columns: 4,
    ($k$, $mu_k$, $overline(x)_k$, $mu_k alpha(overline(x)_k)$),
    $1$, $1$, $(2\/5, 1\/5)$, $0.16$,
    $2$, $10$, $(5\/8, 5\/16)$, $0.039$,
    $3$, $100$, $(100\/151, 50\/151)$, $0.0044$,
  ))
  第 3 次小于 $epsilon$，停止，$overline(x)_3 approx (0.662, 0.331)^T$。

  #concl[最优解 $overline(x)^* = (2/3, 1/3)^T$，最优值 $2/3$；数值计算在第 3 次迭代停止。]
]

#pred-q[
  用外部罚函数法求解 $min (x_1 - 3)^2 + (x_2 - 2)^2$，s.t. $x_1 + x_2 = 4$，$x_1 <= 2$。
]
#ans[
  #step[增广目标函数]
  $h = x_1 + x_2 - 4$，$s = 2 - x_1 >= 0$：
  $ F(overline(x), mu) = (x_1 - 3)^2 + (x_2 - 2)^2 + mu [(x_1 + x_2 - 4)^2 + (2 - x_1)^2 u(2 - x_1)]. $

  #step[判断约束是否被违反]
  在直线 $x_1 + x_2 = 4$ 上，$f = (x_1 - 3)^2 + (2 - x_1)^2$ 在 $x_1 = 5/2$ 处最小，违反 $x_1 <= 2$。假定 $2 - x_1 < 0$。

  #step[求 $overline(x)_mu$]
  $ 1/2 (partial F) / (partial x_1) &= (x_1 - 3) + mu (x_1 + x_2 - 4) - mu (2 - x_1) = 0, \
    1/2 (partial F) / (partial x_2) &= (x_2 - 2) + mu (x_1 + x_2 - 4) = 0. $
  $ (1 + 2 mu) x_1 + mu x_2 &= 3 + 6 mu, \
    mu x_1 + (1 + mu) x_2 &= 2 + 4 mu. $
  系数行列式 $mu^2 + 3 mu + 1$：
  $ overline(x)_mu = ((2 mu^2 + 7 mu + 3) / (mu^2 + 3 mu + 1), (2 mu^2 + 5 mu + 2) / (mu^2 + 3 mu + 1))^T, quad 2 - x_1 = -(mu + 1) / (mu^2 + 3 mu + 1) < 0. $

  #step[令 $mu -> +oo$]
  $ overline(x)^* = (2, 2)^T, quad f(overline(x)^*) = 1. $

  #concl[最优解 $overline(x)^* = (2, 2)^T$，最优值 $1$。]
]

#pit[
  - 不等式约束的罚项是 $s^2 u(s)$，只在 $s < 0$ 时出现；先判断违反了哪些约束，解出后一定要代回检查。
  - “$<=$”约束先化成 $s >= 0$，罚项里的符号别弄反（平方后虽然一样，判断 $s < 0$ 时会错）。
  - 解出的 $overline(x)_mu$ 是含 $mu$ 的式子，最后一步是取极限，不是代某个具体的 $mu$。
  - 数值迭代题终止准则是 $mu_k alpha(overline(x)_k) < epsilon$，不是 $alpha(overline(x)_k) < epsilon$。
]

== 乘子法 <s-multiplier>

#flow(title: [做法])[
  + *写增广目标函数*（H 乘子法）。等式约束：
    $ F(overline(x), lambda, mu) = f - sum lambda_j h_j + mu sum h_j^2, quad lambda_j^((k+1)) = lambda_j^((k)) - 2 mu h_j (overline(x)_k). $
    不等式约束：
    $ F(overline(x), nu, mu) = f + 1/(4 mu) sum {[max(0, nu_i - 2 mu s_i)]^2 - nu_i^2}, quad nu_i^((k+1)) = max{0, nu_i^((k)) - 2 mu s_i (overline(x)_k)}. $
  + *不等式约束分两段*：$s >= nu/(2 mu)$ 时这一项是 $-nu^2/(4 mu)$；$s < nu/(2 mu)$ 时是 $-nu s + mu s^2$。
  + *求 $overline(x)(nu, mu)$*：第一段只剩 $f$，它的极小点通常违反约束，不在这一段，舍去。在第二段令 $nabla_x F = 0$，解出含 $nu$、$mu$ 的 $overline(x)(nu, mu)$，验证 $s < nu/(2 mu)$。
  + *乘子迭代*：把 $s(overline(x)(nu_k, mu))$ 代入乘子公式，得到 $nu_(k+1) = a nu_k + b$（$0 < a < 1$）。
  + *求极限*：令 $k -> oo$，解不动点方程得 $nu^*$；$overline(x)^* = overline(x)(nu^*, mu)$，$mu$ 会自动消掉。
  + *数值迭代*（算法 4.8、4.10）：$norm(h(overline(x)_k)) < epsilon$ 就停止（不等式约束用 $phi_k = |min{s(overline(x)_k), nu_k / (2 mu)}|$）；否则比值 $norm(h(overline(x)_k)) \/ norm(h(overline(x)_(k-1))) <= theta$ 时 $mu$ 不变，大于 $theta$ 时 $mu = c mu$，再更新乘子。
]

#dlg[
  #Q[乘子法比外部罚函数法好在哪里？]
  #A[惩罚项加在 Lagrange 函数上，并且每步修正乘子。乘子收敛到最优乘子 $lambda^*$ 时，$overline(x)(lambda^*, mu)$ 就是最优解（定理 4.29）。罚因子只要大于某个有限的 $mu^*$（定理 4.28），不必趋于无穷大，Hesse 矩阵不会病态，数值计算稳定。]
  #Q[不等式约束的增广目标函数为什么是分段的？]
  #A[教材引入松弛变量，把 $s >= 0$ 化成 $s - z^2 = 0$，再对 $z$ 求极小消去 $z$，就得到带 $max$ 的形式。$nu - 2 mu s <= 0$ 时约束“松”，这一项是常数 $-nu^2/(4 mu)$；$nu - 2 mu s > 0$ 时展开得 $-nu s + mu s^2$，和等式约束的形式一样。]
  #Q[怎样确定极小点落在哪一段？]
  #A[第一段 $F = f - nu^2/(4 mu)$，驻点就是 $f$ 的无约束极小点，它满足 $s >= nu/(2 mu)$ 时才算数。考题里 $f$ 的无约束极小点都违反约束（$s < 0 <= nu/(2 mu)$），或者 $f$ 根本没有无约束极小点，所以都落在第二段。]
  #Q[最优乘子为什么和 $mu$ 无关？]
  #A[不动点满足 $nu^* = max{0, nu^* - 2 mu s(overline(x)^*)}$，$nu^* > 0$ 时就是 $s(overline(x)^*) = 0$；这时 $nabla_x F = 0$ 化为 $nabla f(overline(x)^*) = nu^* nabla s(overline(x)^*)$，正是 K-T 条件。所以 $nu^*$ 是 K-T 乘子，由问题本身决定。$mu$ 只影响递推系数 $a$，$mu$ 越大 $a$ 越小，收敛越快。]
  #Q[有时 $nu_(k+1)$ 算出来是常数，这是怎么回事？]
  #A[2010–2011 第八题、2018–2019 第七题(2)、2021–2022 第九题都是这样：$s(overline(x)(nu, mu)) = (nu - c)/(2 mu)$，代入后 $nu_(k+1) = c$，和 $nu_k$ 无关。不管初值是多少，第 2 次迭代就到最优解。]
]

#exam-q("2024-2025B", "九")
#ans[
  #step[化成标准形]
  $ s(overline(x)) = -1 - x_1 - x_2 >= 0. $

  #step[增广目标函数]
  $ F(overline(x), nu, mu) = 2 (x_1 - 1)^2 + x_2^2 + 1/(4 mu) {[max(0, nu - 2 mu s)]^2 - nu^2}, $
  分段写出：
  $ F = cases(
    2 (x_1 - 1)^2 + x_2^2 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    2 (x_1 - 1)^2 + x_2^2 + nu (1 + x_1 + x_2) + mu (1 + x_1 + x_2)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段的驻点 $(1, 0)$ 处 $s = -2 < nu/(2 mu)$，不在这一段，舍去。第二段：
  $ (partial F) / (partial x_1) &= 4 (x_1 - 1) + nu + 2 mu (1 + x_1 + x_2) = 0, \
    (partial F) / (partial x_2) &= 2 x_2 + nu + 2 mu (1 + x_1 + x_2) = 0. $
  两式相减得 $x_2 = 2 x_1 - 2$，代入第 2 式：$4 x_1 - 4 + nu + 2 mu (3 x_1 - 1) = 0$。
  $ x_1 = (4 + 2 mu - nu) / (4 + 6 mu), quad x_2 = -(nu + 4 mu) / (2 + 3 mu), quad s(overline(x)) = (3 nu - 8) / (4 + 6 mu). $
  验证：$s < nu/(2 mu) <=> 2 mu (3 nu - 8) < nu (4 + 6 mu) <=> -16 mu < 4 nu$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu (3 nu_k - 8) / (4 + 6 mu)} = (2 nu_k + 8 mu) / (2 + 3 mu). $

  #step[求极限]
  系数 $2/(2 + 3 mu) < 1$，序列收敛。令 $k -> oo$：
  $ nu^* = (2 nu^* + 8 mu) / (2 + 3 mu) quad => quad 3 mu nu^* = 8 mu quad => quad nu^* = 8/3. $
  $ overline(x)^* = ((4 + 2 mu - 8\/3) / (4 + 6 mu), -(8\/3 + 4 mu) / (2 + 3 mu))^T = (1/3, -4/3)^T. $

  #concl[最优解 $overline(x)^* = (1/3, -4/3)^T$，最优值 $2 dot 4/9 + 16/9 = 8/3$，乘子 $nu^* = 8/3$。]
]

#exam-q("2023-2024", "八(1)")
#ans[
  #step[增广目标函数]
  $s = x_1 - x_2 - 5 >= 0$：
  $ F = cases(
    (x_1 - 2)^2 + (x_2 - 1)^2 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    (x_1 - 2)^2 + (x_2 - 1)^2 - nu (x_1 - x_2 - 5) + mu (x_1 - x_2 - 5)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段的驻点 $(2, 1)$ 处 $s = -4 < nu/(2 mu)$，舍去。第二段：
  $ (partial F) / (partial x_1) &= 2 (x_1 - 2) - nu + 2 mu (x_1 - x_2 - 5) = 0, \
    (partial F) / (partial x_2) &= 2 (x_2 - 1) + nu - 2 mu (x_1 - x_2 - 5) = 0. $
  两式相加得 $x_1 + x_2 = 3$。令 $x_1 = 2 + w$，$x_2 = 1 - w$，$s = 2 w - 4$，代入第 1 式：
  $ 2 w - nu + 2 mu (2 w - 4) = 0 quad => quad w = (nu + 8 mu) / (2 + 4 mu), quad s(overline(x)) = (nu - 4) / (1 + 2 mu). $
  验证：$s < nu/(2 mu) <=> 2 mu (nu - 4) < nu (1 + 2 mu) <=> -8 mu < nu$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu (nu_k - 4) / (1 + 2 mu)} = (nu_k + 8 mu) / (1 + 2 mu). $

  #step[求极限]
  $ nu^* = (nu^* + 8 mu) / (1 + 2 mu) quad => quad nu^* = 4, quad w = (4 + 8 mu) / (2 + 4 mu) = 2. $
  $ overline(x)^* = (2 + 2, 1 - 2)^T = (4, -1)^T. $

  #concl[最优解 $overline(x)^* = (4, -1)^T$，最优值 $4 + 4 = 8$，乘子 $nu^* = 4$。]
]

#exam-q("2021-2022", "九")
#ans[
  #step[1. 增广目标函数]
  $s = x_1 x_2 - 1 >= 0$，没有等式约束：
  $ F(overline(x); nu, mu) = cases(
    x_1^2 + x_2^2 - 3 x_1 + 3 x_2 - nu^2 / (4 mu) & (x_1 x_2 - 1 >= nu / (2 mu)),
    x_1^2 + x_2^2 - 3 x_1 + 3 x_2 - nu (x_1 x_2 - 1) + mu (x_1 x_2 - 1)^2 quad & (x_1 x_2 - 1 < nu / (2 mu)).
  ) $

  #step[2. 求最优解]
  题给的 $overline(x)_k$ 满足 $x_1 - x_2 = 3/2$，$x_1 + x_2 = sqrt(Q)$，$Q = 9/4 + (4 mu + 2 nu_k - 4)/mu$，所以
  $ x_1 x_2 = ((x_1 + x_2)^2 - (x_1 - x_2)^2) / 4 = (Q - 9\/4) / 4 = 1 + (nu_k - 2) / (2 mu), quad s(overline(x)_k) = (nu_k - 2) / (2 mu). $
  代入乘子公式：
  $ nu_(k+1) = max{0, nu_k - 2 mu dot (nu_k - 2) / (2 mu)} = 2. $
  所以 $nu^* = 2$，这时 $Q = 9/4 + 4 = 25/4$，$sqrt(Q) = 5/2$：
  $ overline(x)^* = (3/4 + 5/4, -3/4 + 5/4)^T = (2, 1/2)^T, quad s(overline(x)^*) = 0, quad f(overline(x)^*) = 4 + 1/4 - 6 + 3/2 = -1/4. $
  （把 $(x_1, x_2)$ 换成 $(-x_2, -x_1)$，目标函数和约束都不变，所以 $(-1/2, -2)^T$ 也是最优解，最优值相同。）

  #step[3. 迭代两次]
  第 1 次：$nu_1 = 0$，$mu = 1$，$Q = 9/4$：
  $ overline(x)_1 = (3/4 + 3/4, -3/4 + 3/4)^T = (3/2, 0)^T, quad s(overline(x)_1) = -1, quad nu_2 = max{0, 0 - 2 dot (-1)} = 2. $
  第 2 次：$nu_2 = 2$，$Q = 25/4$：
  $ overline(x)_2 = (2, 1/2)^T, quad s(overline(x)_2) = 0, quad nu_3 = max{0, 2 - 0} = 2. $
  终止判别 $phi_2 = |min{s(overline(x)_2), nu_2/(2 mu)}| = |min{0, 1}| = 0 < epsilon$。

  #concl[最优解 $overline(x)^* = (2, 1/2)^T$（或 $(-1/2, -2)^T$），最优值 $-1/4$。两次迭代得 $overline(x)_1 = (3/2, 0)^T$、$nu_2 = 2$，$overline(x)_2 = (2, 1/2)^T$、$nu_3 = 2$；$overline(x)_2$ 已满足终止准则，不需要第三次迭代。]
]

#exam-q("2020-2021", "九")
#ans[
  #step[增广目标函数]
  $s = x_1 + x_2 - 6 >= 0$：
  $ F = cases(
    x_1 x_2 + (x_1 - 3)^2 + (x_2 - 3)^2 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    x_1 x_2 + (x_1 - 3)^2 + (x_2 - 3)^2 - nu (x_1 + x_2 - 6) + mu (x_1 + x_2 - 6)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段：$f$ 的驻点满足 $x_2 + 2 (x_1 - 3) = 0$、$x_1 + 2 (x_2 - 3) = 0$，即 $(2, 2)$，$s = -2 < nu/(2 mu)$，舍去。第二段：
  $ (partial F) / (partial x_1) &= x_2 + 2 (x_1 - 3) - nu + 2 mu (x_1 + x_2 - 6) = 0, \
    (partial F) / (partial x_2) &= x_1 + 2 (x_2 - 3) - nu + 2 mu (x_1 + x_2 - 6) = 0. $
  两式相减得 $x_1 = x_2 = t$，代入：$3 t - 6 - nu + 2 mu (2 t - 6) = 0$。
  $ t = (6 + nu + 12 mu) / (3 + 4 mu), quad s(overline(x)) = 2 t - 6 = (2 nu - 6) / (3 + 4 mu). $
  验证：$s < nu/(2 mu) <=> 2 mu (2 nu - 6) < nu (3 + 4 mu) <=> -12 mu < 3 nu$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu (2 nu_k - 6) / (3 + 4 mu)} = (3 nu_k + 12 mu) / (3 + 4 mu). $

  #step[求极限]
  $ nu^* = (3 nu^* + 12 mu) / (3 + 4 mu) quad => quad 4 mu nu^* = 12 mu quad => quad nu^* = 3, quad t = (9 + 12 mu) / (3 + 4 mu) = 3. $

  #concl[最优解 $overline(x)^* = (3, 3)^T$，最优值 $9$，乘子 $nu^* = 3$。]
]

#exam-q("2019-2020", "八(2)")
#ans[
  #step[(1) 增广目标函数]
  $ F(overline(x); lambda, mu) = (x_1 - 1)^2 + (x_2 - 1)^2 - lambda (x_1 + 2 x_2 - 4) + mu (x_1 + 2 x_2 - 4)^2. $

  #step[(2) 求最优解]
  把题给的 $overline(x)(lambda, mu)$ 代入约束：
  $ h(overline(x)(lambda, mu)) = (lambda\/2 + 6 mu + 1 + 2 lambda + 14 mu + 2 - 20 mu - 4) / (5 mu + 1) = (5\/2 lambda - 1) / (5 mu + 1). $
  乘子迭代：
  $ lambda_(k+1) = lambda_k - 2 mu (5\/2 lambda_k - 1) / (5 mu + 1) = 1/(5 mu + 1) lambda_k + (2 mu) / (5 mu + 1). $
  令 $k -> oo$：
  $ lambda^* = 1/(5 mu + 1) lambda^* + (2 mu) / (5 mu + 1) quad => quad 5 mu lambda^* = 2 mu quad => quad lambda^* = 2/5. $
  $ overline(x)^* = ((1\/5 + 6 mu + 1) / (5 mu + 1), (2\/5 + 7 mu + 1) / (5 mu + 1))^T = (6/5, 7/5)^T. $

  #step[(3) 数值迭代]
  $overline(x)_0 = (0, 0)^T$，$h(overline(x)_0) = -4$；$lambda_1 = 0$，$mu = 5$。

  第 1 次：
  $ overline(x)_1 = overline(x)(0, 5) = (31/26, 18/13)^T, quad h(overline(x)_1) = -1/26, quad norm(h(overline(x)_1)) approx 0.0385 > epsilon. $
  比值 $norm(h(overline(x)_1)) \/ norm(h(overline(x)_0)) = 1/104 <= theta = 0.7$，$mu$ 不变；
  $ lambda_2 = lambda_1 - 2 mu h(overline(x)_1) = 0 + 10/26 = 5/13. $
  第 2 次：
  $ overline(x)_2 = overline(x)(5/13, 5) = (811/676, 473/338)^T approx (1.1997, 1.3994)^T, quad h(overline(x)_2) = -1/676, quad norm(h(overline(x)_2)) approx 0.0015 < epsilon. $
  满足终止准则，停止。

  #concl[(1) 如上。(2) $lambda^* = 2/5$，$overline(x)^* = (6/5, 7/5)^T$。(3) $overline(x)_1 = (31/26, 18/13)^T$，$lambda_2 = 5/13$；$overline(x)_2 = (811/676, 473/338)^T$ 满足 $norm(h) < 0.01$，输出 $overline(x)_2$。]
]

#exam-q("2018-2019", "七(2)")
#ans[
  #step[增广目标函数]
  $s = 2 - x_1^2 - x_2^2 - x_3 >= 0$：
  $ F = cases(
    -x_3 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    -x_3 - nu s + mu s^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段 $partial F \/ partial x_3 = -1 != 0$，没有驻点。第二段（$partial s \/ partial x_3 = -1$，$partial s \/ partial x_i = -2 x_i$）：
  $ (partial F) / (partial x_3) &= -1 + nu - 2 mu s = 0 quad => quad s = (nu - 1) / (2 mu), \
    (partial F) / (partial x_1) &= 2 x_1 (nu - 2 mu s) = 2 x_1 = 0, quad (partial F) / (partial x_2) = 2 x_2 = 0. $
  $ overline(x)(nu, mu) = (0, 0, 2 - (nu - 1)/(2 mu))^T. $
  验证：$s = (nu - 1)/(2 mu) < nu/(2 mu)$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu dot (nu_k - 1) / (2 mu)} = 1. $
  不论初值，$nu^* = 1$，这时 $s = 0$。

  #concl[最优解 $overline(x)^* = (0, 0, 2)^T$，最优值 $-2$，乘子 $nu^* = 1$。]
]

#exam-q("2017-2018", "八")
#ans[
  #step[1(1) 乘子与罚因子的关系]
  无关。乘子迭代的极限 $nu^*$ 满足 K-T 条件，是约束问题的 K-T 乘子，由问题本身决定。罚因子 $mu$ 只要取得足够大，保证增广目标函数有极小点、乘子序列收敛即可；它影响收敛快慢，不影响极限。

  #step[1(2) 罚因子的差异]
  外部罚函数法的罚因子必须趋于 $+oo$ 才能得到最优解；乘子法的罚因子取适当大的有限值就够了。实际作用：乘子法避免了罚因子过大使增广目标函数的 Hesse 矩阵病态（条件数变坏），数值计算稳定。

  #step[2. 增广目标函数]
  $ F(x_1, x_2, x_3; lambda, mu) = x_1^2 + x_2^2 + x_3^2 - lambda (2 x_1 + x_2 + x_3 - 4) + mu (2 x_1 + x_2 + x_3 - 4)^2. $

  #step[求 $overline(x)(lambda, mu)$]
  记 $h = 2 x_1 + x_2 + x_3 - 4$，令 $nabla F = 0$：
  $ 2 x_1 - 2 lambda + 4 mu h &= 0, \
    2 x_2 - lambda + 2 mu h &= 0, \
    2 x_3 - lambda + 2 mu h &= 0. $
  所以 $x_1 = 2 x_2 = 2 x_3 = lambda - 2 mu h$。设 $x_2 = x_3 = a$，$x_1 = 2 a$，则 $h = 6 a - 4$，$2 a = lambda - 2 mu (6 a - 4)$：
  $ overline(x)(lambda, mu) = ((lambda + 8 mu) / (6 mu + 1), (lambda + 8 mu) / (12 mu + 2), (lambda + 8 mu) / (12 mu + 2))^T. $

  #step[乘子迭代]
  $h(overline(x)(lambda, mu)) = (3 lambda - 4) / (6 mu + 1)$：
  $ lambda_(k+1) = lambda_k - 2 mu (3 lambda_k - 4) / (6 mu + 1) = (lambda_k + 8 mu) / (6 mu + 1). $

  #step[求极限]
  $ lambda^* = 1/(6 mu + 1) lambda^* + (8 mu) / (6 mu + 1) quad => quad 6 mu lambda^* = 8 mu quad => quad lambda^* = 4/3. $
  $ overline(x)^* = (4/3, 2/3, 2/3)^T, quad f(overline(x)^*) = 16/9 + 4/9 + 4/9 = 8/3. $

  #concl[1. 见上。2. 最优解 $overline(x)^* = (4/3, 2/3, 2/3)^T$，最优值 $8/3$，$lambda^* = 4/3$。]
]

#exam-q("2014-2015", "四")
#ans[
  #step[增广目标函数]
  $s = x_1 - 2 >= 0$：
  $ F = cases(
    x_1^2 + (x_2 - 1)^2 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    x_1^2 + (x_2 - 1)^2 - nu (x_1 - 2) + mu (x_1 - 2)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段的驻点 $(0, 1)$ 处 $s = -2 < nu/(2 mu)$，舍去。第二段：
  $ (partial F) / (partial x_1) &= 2 x_1 - nu + 2 mu (x_1 - 2) = 0 quad => quad x_1 = (nu + 4 mu) / (2 + 2 mu), \
    (partial F) / (partial x_2) &= 2 (x_2 - 1) = 0 quad => quad x_2 = 1. $
  $ s(overline(x)) = (nu - 4) / (2 + 2 mu). $
  验证：$s < nu/(2 mu) <=> 2 mu (nu - 4) < nu (2 + 2 mu) <=> -8 mu < 2 nu$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu (nu_k - 4) / (2 + 2 mu)} = (nu_k + 4 mu) / (1 + mu). $

  #step[求极限]
  $ nu^* = (nu^* + 4 mu) / (1 + mu) quad => quad nu^* = 4, quad x_1 = (4 + 4 mu) / (2 + 2 mu) = 2. $

  #concl[最优解 $overline(x)^* = (2, 1)^T$，最优值 $4$，乘子 $nu^* = 4$。]
]

#exam-q("2013-2014", "八(2)")
#ans[
  #step[增广目标函数]
  $s = x_1 + x_2 - 1 >= 0$：
  $ F = cases(
    1/2 x_1^2 + 1/2 x_2^2 + x_1 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    1/2 x_1^2 + 1/2 x_2^2 + x_1 - nu (x_1 + x_2 - 1) + mu (x_1 + x_2 - 1)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段的驻点 $(-1, 0)$ 处 $s = -2 < nu/(2 mu)$，舍去。第二段：
  $ (partial F) / (partial x_1) &= x_1 + 1 - nu + 2 mu (x_1 + x_2 - 1) = 0, \
    (partial F) / (partial x_2) &= x_2 - nu + 2 mu (x_1 + x_2 - 1) = 0. $
  两式相减得 $x_2 = x_1 + 1$，$s = 2 x_1$，代入第 1 式：$x_1 + 1 - nu + 4 mu x_1 = 0$。
  $ overline(x)(nu, mu) = ((nu - 1) / (1 + 4 mu), (nu + 4 mu) / (1 + 4 mu))^T, quad s(overline(x)) = (2 (nu - 1)) / (1 + 4 mu). $
  验证：$s < nu/(2 mu) <=> 4 mu (nu - 1) < nu (1 + 4 mu) <=> -4 mu < nu$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - (4 mu (nu_k - 1)) / (1 + 4 mu)} = (nu_k + 4 mu) / (1 + 4 mu). $

  #step[求极限]
  $ nu^* = (nu^* + 4 mu) / (1 + 4 mu) quad => quad nu^* = 1, quad overline(x)^* = (0, 1)^T. $

  #concl[最优解 $overline(x)^* = (0, 1)^T$，最优值 $1/2$，乘子 $nu^* = 1$。]
]

#exam-q("2011-2012", "七(2)")
#ans[
  #step[增广目标函数]
  $s = x_1 + x_2 - 1 >= 0$：
  $ F = cases(
    x_1^2 + x_1 x_2 + x_2^2 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    x_1^2 + x_1 x_2 + x_2^2 - nu (x_1 + x_2 - 1) + mu (x_1 + x_2 - 1)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段的驻点 $(0, 0)$ 处 $s = -1 < nu/(2 mu)$，舍去。第二段：
  $ (partial F) / (partial x_1) &= 2 x_1 + x_2 - nu + 2 mu (x_1 + x_2 - 1) = 0, \
    (partial F) / (partial x_2) &= x_1 + 2 x_2 - nu + 2 mu (x_1 + x_2 - 1) = 0. $
  两式相减得 $x_1 = x_2 = t$，代入：$3 t - nu + 2 mu (2 t - 1) = 0$。
  $ t = (nu + 2 mu) / (3 + 4 mu), quad s(overline(x)) = 2 t - 1 = (2 nu - 3) / (3 + 4 mu). $
  验证：$s < nu/(2 mu) <=> 2 mu (2 nu - 3) < nu (3 + 4 mu) <=> -6 mu < 3 nu$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu (2 nu_k - 3) / (3 + 4 mu)} = (3 nu_k + 6 mu) / (3 + 4 mu). $

  #step[求极限]
  $ nu^* = (3 nu^* + 6 mu) / (3 + 4 mu) quad => quad 4 mu nu^* = 6 mu quad => quad nu^* = 3/2, quad t = (3\/2 + 2 mu) / (3 + 4 mu) = 1/2. $

  #concl[最优解 $overline(x)^* = (1/2, 1/2)^T$，最优值 $3/4$，乘子 $nu^* = 3/2$。]
]

#exam-q("2010-2011", "八")
#ans[
  #step[增广目标函数]
  $s = 2 - x_1 - x_2 >= 0$：
  $ F = cases(
    (x_1 - x_2)^2 - 5 x_1 - x_2 - nu^2 / (4 mu) & (s >= nu / (2 mu)),
    (x_1 - x_2)^2 - 5 x_1 - x_2 - nu (2 - x_1 - x_2) + mu (2 - x_1 - x_2)^2 quad & (s < nu / (2 mu)).
  ) $

  #step[求 $overline(x)(nu, mu)$]
  第一段：$partial f \/ partial x_1 + partial f \/ partial x_2 = -6 != 0$，没有驻点。第二段：
  $ (partial F) / (partial x_1) &= 2 (x_1 - x_2) - 5 + nu - 2 mu (2 - x_1 - x_2) = 0, \
    (partial F) / (partial x_2) &= -2 (x_1 - x_2) - 1 + nu - 2 mu (2 - x_1 - x_2) = 0. $
  两式相减：$x_1 - x_2 = 1$；两式相加：$-6 + 2 nu - 4 mu (2 - x_1 - x_2) = 0$，
  $ s(overline(x)) = 2 - x_1 - x_2 = (nu - 3) / (2 mu), quad overline(x)(nu, mu) = (3/2 - (nu - 3)/(4 mu), 1/2 - (nu - 3)/(4 mu))^T. $
  验证：$s = (nu - 3)/(2 mu) < nu/(2 mu)$，成立。

  #step[乘子迭代]
  $ nu_(k+1) = max{0, nu_k - 2 mu dot (nu_k - 3) / (2 mu)} = 3. $
  所以 $nu^* = 3$，$s(overline(x)^*) = 0$。

  #step[填空]
  乘子法的罚因子不必趋于无穷大，取适当大的有限值即可；外部罚函数法的罚因子必须趋于 $+oo$。

  #concl[最优解 $overline(x)^* = (3/2, 1/2)^T$，最优值 $-7$，乘子 $nu^* = 3$。]
]

=== 预测题

#pred-q[
  用 H 乘子法求解 $min x_1^2 + x_1 x_2 + x_2^2$，s.t. $x_1 + x_2 >= 4$。再取 $nu_1 = 0$，$mu = 1$，迭代三次，列出各次的解和乘子。
]
#ans[
  #step[增广目标函数]
  $s = x_1 + x_2 - 4$，第二段（$s < nu/(2 mu)$）：
  $ F = x_1^2 + x_1 x_2 + x_2^2 - nu (x_1 + x_2 - 4) + mu (x_1 + x_2 - 4)^2. $
  第一段的驻点 $(0, 0)$ 处 $s = -4 < nu/(2 mu)$，舍去。

  #step[求 $overline(x)(nu, mu)$]
  两个偏导相减得 $x_1 = x_2 = t$，代入 $3 t - nu + 2 mu (2 t - 4) = 0$：
  $ t = (nu + 8 mu) / (3 + 4 mu), quad s(overline(x)) = (2 nu - 12) / (3 + 4 mu). $

  #step[乘子迭代与极限]
  $ nu_(k+1) = nu_k - 2 mu (2 nu_k - 12) / (3 + 4 mu) = (3 nu_k + 24 mu) / (3 + 4 mu), quad nu^* = 6, quad t = (6 + 8 mu) / (3 + 4 mu) = 2. $

  #step[数值迭代（$mu = 1$）]
  $nu_(k+1) = 3/7 nu_k + 24/7$：
  #align(center, three-line(columns: 4,
    ($k$, $nu_k$, $overline(x)_k$, $s(overline(x)_k)$),
    $1$, $0$, $(8\/7, 8\/7)$, $-12\/7$,
    $2$, $24\/7$, $(80\/49, 80\/49)$, $-36\/49$,
    $3$, $240\/49$, $(632\/343, 632\/343)$, $-108\/343$,
  ))
  每次 $nu_k$ 与 6 的差缩小为原来的 $3/7$。

  #concl[最优解 $overline(x)^* = (2, 2)^T$，最优值 $12$，乘子 $nu^* = 6$。]
]

#pred-q[
  用 H 乘子法求解 $min x_1^2 + x_1 x_2 + x_2^2$，s.t. $x_1 + 2 x_2 = 4$。
]
#ans[
  #step[增广目标函数]
  $ F(overline(x), lambda, mu) = x_1^2 + x_1 x_2 + x_2^2 - lambda (x_1 + 2 x_2 - 4) + mu (x_1 + 2 x_2 - 4)^2. $

  #step[求 $overline(x)(lambda, mu)$]
  记 $h = x_1 + 2 x_2 - 4$，$c = lambda - 2 mu h$：
  $ (partial F) / (partial x_1) &= 2 x_1 + x_2 - c = 0, \
    (partial F) / (partial x_2) &= x_1 + 2 x_2 - 2 c = 0. $
  解得 $x_1 = 0$，$x_2 = c$。于是 $h = 2 c - 4$，$c = lambda - 2 mu (2 c - 4)$：
  $ overline(x)(lambda, mu) = (0, (lambda + 8 mu) / (1 + 4 mu))^T, quad h(overline(x)) = (2 (lambda - 2)) / (1 + 4 mu). $

  #step[乘子迭代与极限]
  $ lambda_(k+1) = lambda_k - (4 mu (lambda_k - 2)) / (1 + 4 mu) = (lambda_k + 8 mu) / (1 + 4 mu), quad lambda^* = 2. $
  $ overline(x)^* = (0, (2 + 8 mu) / (1 + 4 mu))^T = (0, 2)^T. $

  #concl[最优解 $overline(x)^* = (0, 2)^T$，最优值 $4$，乘子 $lambda^* = 2$。]
]

#pit[
  - 不等式约束的增广目标函数要写成分段形式，两段的分界是 $s = nu/(2 mu)$，不是 $s = 0$。
  - 舍去第一段时要写理由：驻点处 $s < nu/(2 mu)$，或者没有驻点。
  - 乘子更新公式里是 $max{0, dots}$，结果为负时取 0；考题里通常为正，写一句“括号内为正”。
  - 求出 $nu^*$ 后代回 $overline(x)(nu, mu)$，$mu$ 应该消掉；消不掉说明算错了。
  - 等式约束乘子的符号约定是 $L = f - lambda^T h$，更新用减号 $lambda - 2 mu h$。
]

== 简答与填空 <s-penalty-concept>

#exam-q("2018-2019", "七(1)")
#ans[
  #step[(1) 罚因子很大会怎样]
  增广目标函数 $F(overline(x), mu)$ 的 Hesse 矩阵条件数随 $mu$ 增大而变坏（病态），无约束极小化难以算准，数值计算不稳定，甚至得不到正确结果。

  #step[(2) 乘子法中罚因子的作用]
  罚因子大于某个有限值 $mu^*$ 时，最优解 $overline(x)^*$ 是 $F(overline(x), lambda^*, mu)$ 的严格局部极小点（定理 4.28），无约束问题有解，乘子迭代收敛；$mu$ 越大收敛越快。它不需要趋于无穷大。

  #step[(3) 乘子法的数值表现]
  罚因子保持有限，Hesse 矩阵不会病态，数值稳定性好，收敛也快。计算实践表明乘子法优于外部罚函数法。
]

#exam-q("2013-2014", "八(1)")
#ans[
  #step[填空]
  非容许；容许；$mu_k > 0$ 单调增大并趋于 $+oo$；在 Lagrange 函数上加惩罚项，并迭代修正乘子；不必趋于无穷大（取适当大的有限值即可）。
]

#exam-q("2011-2012", "七(1)")
#ans[
  #step[“罚”的思想]
  在目标函数上加惩罚项 $mu alpha(overline(x))$：容许点处 $alpha = 0$，不受惩罚；非容许点处 $alpha > 0$，离容许集越远罚得越重。$mu$ 越大惩罚越重，迫使 $min f + mu alpha$ 的极小点靠近容许集。这样把约束问题化成一系列无约束问题，$mu_k -> +oo$ 时极小点收敛到约束问题的最优解。

  #step[乘子法的改进]
  外部罚函数法必须让 $mu_k -> +oo$，$mu$ 很大时增广目标函数的 Hesse 矩阵病态，数值计算困难。乘子法把惩罚项加在 Lagrange 函数上，并迭代修正乘子，罚因子取适当大的有限值就能收敛到最优解，避免了病态，数值稳定、收敛快。
]
