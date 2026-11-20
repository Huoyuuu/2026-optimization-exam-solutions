// 2020–2021 学年最优化方法期末试卷。来源：素材/其他资料/最优化2020-2021.pdf（扫描件，优先）；素材/真题答案/2020-2021最优化期末试卷.pdf（照片，对照）
#let exam = (
  id: "2020-2021",
  term: [第一学期],
  items: (
    (head: [一、计算题（每题 6 分，共 18 分）]),
    (no: "一(1)", score: 6, topic: "optcond", body: [
      利用极小点判定条件求解无约束问题
      $ min f(x) = x_1^3 - 3 x_1 + (x_1 - 2 x_2)^2. $
    ]),
    (no: "一(2)", score: 6, topic: "kkt", body: [
      用拉格朗日乘子法解等式约束问题
      $ max quad & (x_1 - 1)^2 + x_2^2 + (x_3 + 1)^2; \
        "s.t." quad & x_1 + x_2 + x_3 = 2. $
    ]),
    (no: "一(3)", score: 6, topic: "basic", body: [
      图解约束问题
      $ max quad & (x_1 - 1)^2 + (x_2 + 1)^2; \
        "s.t." quad & -x_1^(1/3) + x_2 <= 0, \
        & x_1^2 - x_2 <= 2, \
        & x_1 <= 0. $
    ]),

    (head: [二、计算题（每题 6 分，共 12 分）]),
    (no: "二(1)", score: 6, topic: "kkt", body: [
      考虑约束问题
      $ min quad & x_1^2 + 3 x_2^2 + 2 x_3^2; \
        "s.t." quad & 2 x_1 + 2 x_2 - 3 x_3 >= 1, quad x_1 - 3 x_2 + x_3 <= 0, quad x_1 + x_2 + x_3 = 3, \
        & 2 x_1^2 - 3 x_2^2 + x_3 <= 5, quad x_2^2 + 3 x_3^2 >= 4. $
      已知容许点 $overline(x)_0 = (1, 1, 1)^T$，试判断方向 $overline(p) = (0, 1, -1)^T$ 是 $overline(x)_0$ 处的容许方向吗？是 $overline(x)_0$ 处的下降方向吗？给出判断过程。
    ]),
    (no: "二(2)", score: 6, topic: "lsq", body: [
      已知物理量 $y$ 与物理量 $t$ 之间的一组试验数据：
      #table(columns: 6, stroke: 0.4pt, align: center,
        $t$, [-2], [-1.5], [-1], [0], [1],
        $y$, [0.85], [-2.81], [-1.26], [1.60], [-2.10])
      (1) 从下面四个函数中选择最适合的函数作数据拟合，建立最小二乘问题数学模型：
      A. $y = x_1 / t + x_2$；B. $y = x_1 cos(x_2 t + x_3)$；C. $y = x_1 t^2 + x_2 t + x_3$；D. $y = ln(x_1 t + x_2)$。 \
      (2) 简述非线性最小二乘问题解法思路。
    ]),

    (head: [三、计算题（8 分）]),
    (no: "三", score: 8, topic: "cg", body: [
      用 Fletcher-Reeves 共轭梯度法解极值问题
      $ min x_1^2 - x_1 x_2 + x_2^2 - 2 x_1 + x_3^2, $
      初始点 $overline(x)_0 = (1, 1, 1)^T$。
    ]),

    (head: [四、计算题（8 分）]),
    (no: "四", score: 8, topic: "hj", body: [
      用步长加速法求解无约束极小化问题
      $ min f(overline(x)) = x_1^2 + x_2^2 - 4 x_1 + 2 x_2 + 7. $
      初始点 $overline(x)_0 = (0, 0)^T$，初始步长向量 $overline(s)_0 = (1, 1)^T$，模式移动公式：$overline(r)_(k+1) = 2 overline(b)_(k+1) - overline(b)_k$，迭代到开始缩小步长向量为止。
    ]),

    (head: [五、计算题（6 分）]),
    (no: "五", score: 6, topic: "grad", body: [
      对函数 $f(x, y) = e^(x + 2 y)$ 在 $(0, 0)^T$ 作 Taylor 展开，展到二次项为止。
    ]),

    (head: [六、计算题（14 分）]),
    (no: "六", score: 14, topic: "simplex", body: [
      用两阶段单纯形法求解线性规划问题
      $ max quad & -4 x_1 + 10 x_2 - 5 x_3, \
        "s.t." quad & -x_1 + 2 x_2 - x_3 = -2, \
        & x_1 + 3 x_2 - x_3 <= 14, \
        & -x_2 + 2 x_3 >= 2, \
        & x_1, x_2 >= 0, quad x_3 "自由变量". $
      注：不允许化简主约束。
    ]),

    (head: [七、计算题（14 分）]),
    (no: "七", score: 14, topic: "newton", body: [
      用修正 Newton 法解极小化问题
      $ min x_1^2 + 2 x_2^2 - x_1^2 x_2. $
      试分别从以下三个初始点开始，各迭代一次，求 $overline(x)_1$。 \
      (1) $overline(x)_0 = (2, 3/2)^T$；(2) $overline(x)_0 = (1, 1/2)^T$；(3) $overline(x)_0 = (1, 1/4)^T$。
    ]),

    (head: [八、计算题（8 分）]),
    (no: "八", score: 8, topic: "kkt", body: [
      利用 Kuhn-Tucker 条件解约束问题
      $ min quad (x_1 - 1)^2 + (x_2 - 2)^2 \
        "s.t." quad 2 x_1 + x_2 <= 1, quad x_2 >= 0. $
    ]),

    (head: [九、计算题（12 分）]),
    (no: "九", score: 12, topic: "multiplier", body: [
      用乘子法解约束问题
      $ min quad x_1 x_2 + (x_1 - 3)^2 + (x_2 - 3)^2 \
        "s.t." quad x_1 + x_2 - 6 >= 0. $
      注：$ F(overline(x), overline(lambda), overline(v), mu) = f(overline(x)) - sum_(j=1)^l lambda_j h_j(overline(x)) + mu sum_(j=1)^l h_j^2(overline(x)) + 1/(4 mu) sum_(i=1)^m { [max(0, v_i - 2 mu s_i(overline(x)))]^2 - v_i^2 }, $
      $ lambda_j^((t+1)) = lambda_j^((t)) - 2 mu h_j(overline(x)_k), quad j = 1, 2, dots, l, quad v_i^((t+1)) = max{0, v_i^((t)) - 2 mu s_i(overline(x)_k)}, quad i = 1, 2, dots, m. $
    ]),
  ),
)
