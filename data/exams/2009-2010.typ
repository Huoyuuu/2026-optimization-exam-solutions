// 2009-2010 学年最优化方法期末试卷（A 卷）。来源：素材/真题答案/2009-2010 最优化期末试卷.pdf
#let exam = (
  id: "2009-2010",
  term: [第一学期],
  items: (
    (no: "一", score: 14, topic: "simplex", body: [
      试用两阶段单纯形法求解线性规划
      $ min quad & -2 x_1 + 3 x_2 - x_3; \
        "s.t." quad & x_1 - 2 x_2 + x_3 <= 2, \
        & 2 x_1 - x_2 - x_3 <= -3, \
        & 2 x_1 - x_3 = 1, \
        & x_i >= 0, quad i = 1, 2, 3. $
    ]),
    (no: "二", score: 10, topic: "newton", body: [
      用 Newton 法求解极小化问题
      $ min quad 3 x_1^2 + x_2^2 - x_1^2 x_2. $
      初始点取为 $overline(x)_0 = [1, 1]^T$，迭代一次，并说明 $overline(x)_1$ 是局部最优解吗？
    ]),
    (no: "三", score: 10, topic: "cg", body: [
      用 F-R 共轭梯度法求解无约束优化问题
      $ min quad f(overline(x)) = e^(x_1^2 + 2 x_1 x_2 + 2 x_2^2). $
      初始点取为 $overline(x)_0 = [2, -1]^T$。已知第一次沿 $overline(p)_0 = -nabla f(overline(x)_0)$ 方向迭代得到的迭代点 $overline(x)_1 = [1, -1]^T$ 不是最优解，求第二个迭代点。（提示：计算过程中不要将数据四舍五入，例如：不要将 $e$ 用 $2.71828$ 代替。）
    ]),
    (no: "四", score: 10, topic: "qn", body: [
      试用 DFP 法求解无约束优化问题
      $ min quad f(x) = x_1^2 + 2 x_2^2 - 2 x_1 x_2. $
      初始点取为 $overline(x)_0 = [1, 1]^T$，已知第一次沿 $overline(p)_0 = -nabla f(overline(x)_0)$ 方向迭代得到的迭代点 $overline(x)_1 = [1, 1/2]^T$。
      （公式：$H_(k+1) = H_k + (overline(s)_k overline(s)_k^T)/(overline(s)_k^T overline(y)_k) - (H_k overline(y)_k overline(y)_k^T H_k)/(overline(y)_k^T H_k overline(y)_k)$，$H_0 = mat(1, 0; 0, 1)$。）
    ]),
    (no: "五", score: 12, topic: "zout", body: [
      考虑约束最优化问题
      $ min quad & f(overline(x)) = x_1^2 - 2 x_1 x_2 + 4 x_2^2; \
        "s.t." quad & 3 x_1 + x_2 >= 2, \
        & 2 x_1 - 5 x_2 >= -10, \
        & x_1 - 2 x_2 <= 2, \
        & x_1 >= 0, quad x_2 >= 0. $
      初始点取为 $overline(x)_0 = [0, 2]^T$。用 Zoutendijk 容许方向法迭代一次。
    ]),
    (no: "六", score: 12, topic: "penalty", body: [
      用外部罚函数法求解约束问题
      $ min quad & (x_1 - x_2)^2 - 5 x_1 - x_2; \
        "s.t." quad & 2 - x_1 - x_2 >= 0, \
        & x_2 >= 0. $
    ]),
    (no: "七", score: 10, topic: "lsq", body: [
      用最小二乘法解方程组
      $ cases(x_1 + x_2 = 1, -2 x_1 + x_2 = 0, x_1 + 2 x_2 = 4) $
    ]),
    (no: "八", score: 6, topic: "kkt", body: [
      试判断向量 $overline(p) = [1, 0, 1]^T$ 是否是如下线性约束
      $ x_1 + 2 x_2 - x_3 = 6, \
        -2 x_1 + 5 x_2 >= 4, \
        x_1 + x_3 <= 2, \
        x_i >= 0, quad i = 1, 2, 3 $
      在点 $overline(x) = [2, 2, 0]^T$ 处的容许方向向量。
    ]),
    (no: "九", score: 10, topic: "kkt", body: [
      利用 K-T 条件求解约束问题
      $ min quad e^(-x_1) + e^(-x_2); \
        "s.t." quad x_1 + x_2 <= 1. $
    ]),
    (no: "十", score: 6, topic: "basic", body: [
      某公司以 100 元/公斤的价格最多购买一种化工原料 17.25 公斤，然后以 30 元的费用把每公斤这种化工原料加工成一公斤的产品 1。以 50 元的费用把每公斤这种化工原料加工成一公斤的产品 2。如果产品 1 的售价将是（300 − 产品 1 的产量）元/公斤，产品 2 的售价是（500 − 产品 2 的产量 × 2）元/公斤。建立使该公司获利（收入减去费用）最大的数学模型。
    ]),
  ),
)
