// 2024–2025 学年最优化方法期末试卷（B 卷）。来源：素材/真题答案/东大最优化2024-2025期末试卷(B卷).pdf 第 1–2 页
#import "/template.typ": blank
#let exam = (
  id: "2024-2025B",
  term: [第一学期],
  items: (
    (head: [一．（12 分）]),
    (no: "一(1)", topic: "optcond", body: [
      利用极小点的判定条件求解下面的无约束极小化问题
      $ min quad 1/3 x_1^3 + 1/3 x_2^3 - x_2^2 - x_1 . $
    ]),
    (no: "一(2)", topic: "grad", body: [
      求函数 $f(x) = x_1^4 + 2 x_2^3 + 3 x_3^2 - x_1^2 x_2 + 4 x_2 x_3 - x_1 x_3^2$ 在 $(0, 1, 0)^T$ 处的二阶 Taylor 展开式。
    ]),
    (no: "二", score: 18, topic: "simplex", body: [
      用两阶段单纯形法求解线性规划问题（不能化简约束条件）
      $ min quad & 3 x_1 - 2 x_2 + x_3 ; \
        "s.t." quad & -2 x_1 - x_2 + x_3 >= -5, \
        & 4 x_1 + 3 x_2 + x_3 >= 3, \
        & x_1 - x_2 - x_3 = -2, \
        & x_i >= 0, quad i = 1, 2, 3. $
      (1) 标准线性规划问题若有容许解，则必有 #blank(11)； \
      (2) 从几何方面理解，线性规划问题的基本容许解与容许集的 #blank(11) 对应。用单纯形法求解线性规划问题，其搜索方向是沿着容许集的 #blank(11) 方向。
    ]),
    (no: "三", score: 12, topic: "newton", body: [
      用修正 Newton 法求解无约束极小化问题
      $ min quad f(x_1, x_2) = 1/2 x_1^2 + x_2^2 - x_1^2 x_2 . $
      试分别从以下三个初始点开始，各迭代一次，求 $overline(x)_1$。 \
      (1) $overline(x)_0 = (0, -1)^T$；(2) $overline(x)_0 = (1/sqrt(3), 1/6)^T$；(3) $overline(x)_0 = (2, 1/2)^T$。
    ]),
    (no: "四", score: 10, topic: "qn", body: [
      用 DFP 法求解无约束极小化问题
      $ min quad f(x_1, x_2) = 2 x_1^2 - 2 x_1 x_2 + x_2^2 - 2 x_1 + x_2 . $
      初始点取为 $overline(x)_0 = (1, 1)^T$。
      （校正公式：$H_0$ 为单位矩阵，$H_(k+1) = H_k + (overline(s)_k overline(s)_k^T)/(overline(s)_k^T overline(y)_k) - (H_k overline(y)_k overline(y)_k^T H_k)/(overline(y)_k^T H_k overline(y)_k)$。）
    ]),
    (no: "五", score: 12, topic: "cg", body: [
      用 F-R 共轭梯度法求解无约束极小化问题
      $ min quad f(overline(x)) = (x_1 + x_2)^2 + x_2^4 . $
      初始点取为 $overline(x)_0 = (-3, 1)^T$，迭代两次，并判断第二个迭代点的最优性。
    ]),
    (no: "六", score: 6, topic: "kkt", body: [
      考虑约束优化问题
      $ min quad & x_1^2 - 2 x_2^2 + 3 x_3^2 ; \
        "s.t." quad & -x_1^2 + 2 x_2^2 + 3 x_3 <= 5, \
        & x_1 - 2 x_2 + 3 x_3 >= 0, \
        & 4 x_1 + 3 x_2 - 2 x_3 >= 1, \
        & -5 x_1 - x_2 + x_3 <= 0, \
        & 3 x_1 + x_2 + 4 x_3 = 5. $
      已知容许点 $overline(x)_0 = (0, 1, 1)^T$，分别判断方向 $overline(p)_1 = (3, -1, -2)^T$ 和 $overline(p)_2 = (-1, -1, 1)^T$ 是否是 $overline(x)_0$ 的容许方向？给出判断过程。
    ]),
    (no: "七", score: 8, topic: "kkt", body: [
      已知约束优化问题如下：
      $ min quad & (x_1 - 2)^2 + (x_2 - 4)^2 ; \
        "s.t." quad & -x_1^2 - x_2^2 >= -5. $
      写出该问题的 K-T 条件，依据 K-T 条件求出 K-T 点，并判断所求的 K-T 点是否为该问题的最优解。
    ]),
    (no: "八", score: 10, topic: "hj", body: [
      用步长加速法求解无约束优化问题
      $ min quad x_1^2 + x_1 x_2 + x_2^2 . $
      初始点取为 $overline(x)_0 = (2, 2)^T$，初始步长向量 $overline(s)_0 = (1, 1)^T$，迭代到开始缩小步长停止。
    ]),
    (no: "九", score: 12, topic: "multiplier", body: [
      用 H 乘子法求解约束优化问题
      $ min quad & 2 (x_1 - 1)^2 + x_2^2 ; \
        "s.t." quad & x_1 + x_2 <= -1. $
      公式：
      $ F(overline(x), overline(lambda), overline(v), overline(mu)) = f(overline(x)) - sum_(j=1)^l lambda_j h_j(overline(x)) + mu sum_(j=1)^l h_j^2(overline(x)) + 1/(4 mu) sum_(i=1)^m \{ [max(0, v_i - 2 mu s_i(overline(x)))]^2 - v_i^2 \}, $
      $ lambda_j^((k+1)) = lambda_j^((k)) - 2 mu h_j(overline(x)_k), quad j = 1, 2, dots, l, quad v_i^((k+1)) = max\{0, v_i^((k)) - 2 mu s_i(overline(x)_k)\}, quad i = 1, 2, dots, m. $
    ]),
  ),
)
