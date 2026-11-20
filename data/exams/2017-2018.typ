// 2017–2018 学年最优化方法期末试卷。来源：素材/其他资料/最优化2017-2018.pdf（扫描件，主用）；对照素材/真题答案/2017-2018 最优化期末试卷 .pdf
#import "/template.typ": blank
#let exam = (
  id: "2017-2018",
  term: [第一学期],
  items: (
    (head: [一、（18分）]),
    (no: "一(1)", topic: "lp-basic", body: [
      1. 简答题 \
      (1) 线性规划的容许集几何上是 #blank(8)，单纯形法的搜索方向是容许集的 #blank(6) 方向。 \
      (2) 线性规划单纯形法产生的迭代点都是容许集的 #blank(6) 点，即线性规划的 #blank(6) 解。 \
      (3) 解线性规划存在几种可能情形？答：#blank(4) 种，分别是 #blank(18)。
    ]),
    (no: "一(2)", topic: "simplex", body: [
      2. 用两阶段单纯形法解线性规划（说明：不允许通过化简方式更改主约束的个数）
      $ min quad & -x_1 - 2 x_2 + x_3; \
        "s.t." quad & x_1 - x_2 + x_3 >= 2, \
        & x_1 + x_2 >= 3, \
        & x_2 >= 1, \
        & x_i >= 0, quad i = 1, 2, 3. $
    ]),
    (head: [二、（8分）]),
    (no: "二", score: 8, topic: "newton", body: [
      试用 Newton 法求解极小化问题
      $ min quad f(x) = (x_1 - 1)^4 + 2 x_2^2, $
      初始点取为 $[0, 2]^T$，求 $x^((1))$。如果第一次迭代无效，则计算终止；否则，求 $x^((2))$，并判断其有效性。
    ]),
    (head: [三、（8分）]),
    (no: "三", score: 8, topic: "cg", body: [
      用 F-R 共轭梯度法求解极小化问题
      $ min quad f(x) = (x_1 + x_2)^4 + 2 (x_1 - 1)^2, $
      初始点取为 $[0, 1]^T$，迭代二次，并判断 $x^((2))$ 的最优性。
    ]),
    (head: [四、（12分）]),
    (no: "四", score: 12, topic: "qn", body: [
      试用 DFP 法求解极小化问题
      $ min quad f(x) = (x_1 - 1)^2 + x_1 x_2 + 2 x_2^2. $
      初始点取为 $[1, 0]^T$。（提示：不要把分数化成小数）
      （校正公式：$H_0$ 为单位矩阵，$H_(k+1) = H_k + (s_k s_k^T)/(s_k^T y_k) - (H_k y_k y_k^T H_k)/(y_k^T H_k y_k)$。）
    ]),
    (head: [五、（14分）]),
    (no: "五", score: 14, topic: "hj", body: [
      试用步长加速法求解无约束问题
      $ min quad f(x) = 2 x_1^2 + x_2^2 - 2 x_1 x_2. $
      取初始点 $[-1, 2]^T$，初始步长向量 $[1, 1]^T$。
      1. 计算到开始缩小步长为止。
      2. 在下图上画出与计算对应的迭代过程。
      要求：
      （a）按下面的标识方式标出作业过程中的全部基点、参考点和探测经历点。
      • 基点　□ 参考点　○ 探测经历点　■ 基点、参考点的重合点
      （b）按进行的先后顺序依次标号：1, 2, ……
      #include "/book/figs/2017-2018-5.typ"
    ]),
    (head: [六、（14分）]),
    (no: "六(1)", topic: "kkt", body: [
      1. 写出满足约束
      $ & x_1 - 2 x_2 + x_3 + 3 x_4 = 5, \
        & 3 x_1 + 5 x_2 - 4 x_3 - 2 x_4 = 4, \
        & x_i >= 0, quad i = 1, 2, 3, 4 $
      的点 $overline(x) = [24/7, 0, 11/7, 0]^T$ 处的容许方向向量 $overline(p)$ 满足的条件。
    ]),
    (no: "六(2)", topic: "zout", body: [
      2. 试用 Z-容许方向法求解约束问题
      $ min quad & f(x) = x_1^2 + 2 x_2^2 + x_1 x_2 + 2 x_2; \
        "s.t." quad & x_1 + x_2 - 2 = 0, \
        & x_1 + 3 x_2 - 3 >= 0, \
        & x_1 - 1 >= 0. $
      初始点取为 $overline(x)_0 = [1, 1]^T$，求 $overline(x)_1$。$overline(x)_1$ 是最优解吗？为什么？
    ]),
    (head: [七、（12分）]),
    (no: "七(1)", topic: "kkt", body: [
      1. 利用 Kuhn-Tucker 条件求约束问题
      $ min quad & 3 x_1^2 + x_2^2 + 2 x_3^2; \
        "s.t." quad & -x_1 + x_2 >= 1. $
      的最优解。
    ]),
    (no: "七(2)", topic: "lsq", body: [
      2. 有关于变量 $x, y$ 的一组数据：
      #table(columns: 6, stroke: 0.4pt, align: center,
        $x_i$, $-2$, $-1$, $0$, $1$, $2$,
        $y_i$, [3.5], [2], [0.9], [2], [4])
      (1) 在三个函数 $y = a_0 + a_1 x^2$、$y = a_0 + a_1 e^x$ 和 $y = a_0 + a_1 ln x$ 中选一个最合适的建立数据拟合最小二乘模型； \
      (2) 如果 (1) 中所建的是线性最小二乘模型，则求解之；否则，简单说明该用什么样的方式求解。
    ]),
    (head: [八、（14分）]),
    (no: "八", score: 14, topic: "multiplier", body: [
      1. 问答题 \
      (1) 乘子法中不等式约束的拉格朗日乘子与罚因子的取值有关吗？简述原由。 \
      (2) 简述乘子法的罚因子与外部罚函数法的罚因子的差异本质，以及这种差异本质的实际作用。
      2. 试用 H-乘子法求解约束问题
      $ min quad & f(x_1, x_2, x_3) = x_1^2 + x_2^2 + x_3^2; \
        "s.t." quad & 2 x_1 + x_2 + x_3 - 4 = 0. $
      注：$F(overline(x), overline(lambda), overline(v), mu) = f(overline(x)) - sum_(j=1)^l lambda_j h_j (overline(x)) + mu sum_(j=1)^l h_j^2 (overline(x)) + 1/(4 mu) sum_(i=1)^m \{[max(0, v_i - 2 mu s_i (overline(x)))]^2 - v_i^2\}$，
      $lambda_j^((k+1)) = lambda_j^((k)) - 2 mu h_j (overline(x)_k)$，$j = 1, 2, dots, l$；$v_i^((k+1)) = max \{0, v_i^((k)) - 2 mu s_i (overline(x)_k)\}$，$i = 1, 2, dots, m$。
    ]),
  ),
)
