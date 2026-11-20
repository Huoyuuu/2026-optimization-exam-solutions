// 2011–2012 学年最优化方法期末试卷（第 1 学期）。来源：素材/其他资料/最优化2011-2012.pdf（扫描件，优先）；素材/真题答案/2011-2012 最优化期末试卷.pdf 照片对照。
#import "/template.typ": blank
#let exam = (
  id: "2011-2012",
  term: [第一学期],
  items: (
    (head: [一、（18 分）]),
    (no: "一(1)", topic: "simplex", body: [
      试用两阶段单纯形法解线性规划
      $ min quad & 2 x_1 + 3 x_2 + 4 x_3 \
        "s.t." quad & x_1 + 2 x_2 + x_3 >= 3, \
        & 2 x_1 - x_2 + 3 x_3 >= 4, \
        & x_i >= 0, quad i = 1, 2, 3. $
    ]),
    (no: "一(2)", topic: "lp-basic", body: [
      设一个求极小的线性规划的容许集 $D$、目标函数的负梯度向量 $-vec(c)$ 及初始点 $x^((0))$ 的位置如右图所示。试在图上画出至少 3 条等值线，及从初始点 $x^((0))$ 到最优点的迭代路径（要求标出各迭代点）。#include "/book/figs/2011-2012-1-2.typ"
    ]),
    (head: [二、（6 分）下面是三个二元正定二次函数的等值线图。从指定初始点 $x^((0))$ 出发，各图按指定算法画出求极小点的迭代路径，其中最速下降法要求只迭代二次。]),
    (no: "二(1)", topic: "sd", body: [图 1：最速下降法。#include "/book/figs/2011-2012-2-1.typ"]),
    (no: "二(2)", topic: "newton", body: [图 2：Newton 法。#include "/book/figs/2011-2012-2-2.typ"]),
    (no: "二(3)", topic: "cg", body: [图 3：共轭梯度法。#include "/book/figs/2011-2012-2-3.typ"]),
    (no: "三", score: 10, topic: "cg", body: [
      用 F-R 共轭梯度法解无约束极小化问题
      $ min quad f(overline(x)) = 3/2 x_1^2 + 1/2 x_2^2 + x_3^2 - x_1 x_2, $
      初始点取为 $overline(x)_0 = [1, 1, 1]^T$。按 F-R 共轭梯度法现已迭代出 $overline(x)_1 = [1/5, 1, 1/5]^T$，要求继续迭代一次，求出 $overline(x)_2$，并判断 $overline(x)_2$ 是否为局部最优解。
    ]),
    (no: "四", score: 10, topic: "qn", body: [
      用 DFP 法解无约束极小化问题
      $ min quad f(overline(x)) = x_1^2 + 2 x_2^2 - x_1^2 x_2, $
      初始点取为 $overline(x)_0 = [1, 1]^T$。按 DFP 法现已迭代出 $overline(x)_1 = [1, 1/4]^T$，要求继续迭代一次，求出 $overline(x)_2$，并判断 $overline(x)_2$ 是否为局部最优解。
      （公式：$H_(k+1) = H_k + s_k s_k^T / (s_k^T y_k) - (H_k y_k y_k^T H_k) / (y_k^T H_k y_k)$，$H_0 = mat(1, 0; 0, 1)$；$sqrt(146) approx 12.08$，$sqrt(148) approx 12.17$。）
    ]),
    (no: "五", score: 10, topic: "hj", body: [
      用步长加速法解无约束极小化问题
      $ min quad f(overline(x)) = 4 x_1^2 + x_2^2. $
      设初始点 $overline(x)_0 = [1, 2.5]^T$，初始步长向量 $overline(delta)_0 = [1, 1]^T$，要求迭代到模式移动作废为止。
    ]),
    (head: [六、（14 分）]),
    (no: "六(1)", topic: "basic", body: [
      叙述下降方向法的 3 个主要过程：① 确定当前迭代点处的#blank(4)；② 通过#blank(4)确定下一个#blank(4)；③ 判断新#blank(4)是否为 K-T 点。
    ]),
    (no: "六(2)", topic: "zout", body: [
      求解如下线性约束问题
      $ min quad & f(x_1, x_2, x_3) = x_1^2 + 2 x_2^2 - x_3^2 - 3 x_2 x_3 \
        "s.t." quad & x_1 + x_2 + x_3 = 1, \
        & 3 x_1 + 4 x_2 + 2 x_3 <= 6, \
        & x_i >= 0, quad i = 1, 2, 3. $
      设初始点取为 $overline(x)_0 = [1, 0, 0]^T$。 \
      (1) 检验 $overline(p)_0 = [-2, 1, 1]^T$ 是否为 $overline(x)_0$ 处的下降容许方向。 \
      (2) 如果 $overline(p)_0 = [-2, 1, 1]^T$ 是 $overline(x)_0$ 处的下降容许方向，那么沿 $overline(p)_0$ 作直线搜索，求出下一迭代点 $overline(x)_1$，然后停止计算；否则，直接停止计算。
    ]),
    (head: [七、（14 分）]),
    (no: "七(1)", topic: "penalty", body: [
      简述外部罚函数法的“罚”思想，乘子法是外部罚函数法的改进方法，简述“改进”的表现。
    ]),
    (no: "七(2)", topic: "multiplier", body: [
      试用乘子法解如下的约束问题
      $ min quad & f(x_1, x_2) = x_1^2 + x_1 x_2 + x_2^2 \
        "s.t." quad & x_1 + x_2 >= 1. $
    ]),
    (no: "八", score: 10, topic: "kkt", body: [
      试利用 K-T 条件解如下的约束极小化问题
      $ min quad & f(x_1, x_2, x_3) = x_1 + x_2 - x_3 \
        "s.t." quad & x_1 - x_2 = 0, \
        & 1 - x_1^2 - x_2^2 - x_3^2 >= 0. $
    ]),
    (no: "九", score: 8, topic: "basic", body: [
      某工厂向用户提供发动机，合同规定交货量和交货日期分别是：第一季度末交 40 台，第二季度末交 60 台，第三季度末交 80 台。工厂每季的最大生产能力为 100 台，每季的生产费用函数为 $f(x) = 50 x + 0.2 x^2$（元），$x$ 为生产台数。如果某季生产过剩，则多余的发动机可用于下季交货，但工厂需要支付存储费用：每台每季 4 元。试建立工厂能够完成合同而费用最少的数学模型（假定第一季度开始时发动机无存货）。
    ]),
  ),
)
