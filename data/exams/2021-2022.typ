// 2021–2022 学年最优化方法期末试卷（第一学期）。来源：素材/真题答案/2021-2022最优化期末试卷.png
#import "/template.typ": blank
#let exam = (
  id: "2021-2022",
  term: [第一学期],
  items: (
    (no: "一", score: 10, topic: "kkt", body: [
      已知约束问题

      $ min quad & (1 - x_1)^2 + x_2^2; \
        "s.t." quad & -x_1 + x_2 <= 1, \
        & x_1 + x_2 >= 3. $

      写出其 Kuhn-Tucker 条件，并利用该条件求最优解。
    ]),
    (head: [二、（16 分）]),
    (no: "二(1)", topic: "lp-basic", body: [
      简答：标准线性规划有容许解，则必有#blank(6)；有最优解，则必有#blank(6)。两阶段单纯形法是针对#blank(6)线性规划的解法。单纯形法的迭代点，术语称为#blank(6)，几何上则称#blank(6)。
    ]),
    (no: "二(2)", topic: "simplex", body: [
      用两阶段单纯形法解线性规划

      $ min quad & 2 x_1 + 2 x_2 - x_3 \
        "s.t." quad & -3 x_1 - x_3 <= -2, \
        & 2 x_1 + 3 x_3 = 2, \
        & 4 x_1 + x_2 + 2 x_3 >= 3, \
        & x_i >= 0, quad i = 1, 2, 3. $

      注：不允许化简主约束。
    ]),
    (no: "三", score: 8, topic: "newton", body: [
      用 Newton 法解无约束问题

      $ min quad x_1^2 + x_2^2 + x_3^2 + x_1 x_2 + 2 x_1 - 3 x_2. $

      初始点 $overline(x)_0$ 自己任意选取。
    ]),
    (no: "四", score: 8, topic: "lsq", body: [
      已知方程组

      $ cases(
        x_1 + x_2 - 2 x_4 = -2,
        2 x_1 - x_2 + x_3 - x_4 = 1,
        x_1 - x_2 - x_3 = 0,
      ) $

      1\. 建立解该方程组的最小二乘模型。

      2\. 简述方程组与解其最小二乘问题的关系。

      3\. 写出 1 中最小二乘问题的法方程组（不求解）。

      4\. 简述在数值计算上，解原方程组与解法方程组，孰优孰劣。
    ]),
    (no: "五", score: 10, topic: "cg", body: [
      用 Fletcher-Reeves 共轭梯度法解无约束问题

      $ min quad x_1^2 (1 + x_2) + x_2^2. $

      设初始点 $overline(x)_0 = [1, -1]^T$。如果 $overline(x)_1$ 不是最优解，则再迭代一次，并判断 $overline(x)_2$ 的最优性。
    ]),
    (no: "六", score: 10, topic: "hj", body: [
      用步长加速法解无约束问题

      $ min quad f(overline(x)) = x_1^2 + 2 x_2^2 - 2 x_1 x_2. $

      设初始点 $overline(x)_0 = [5, 0]^T$，初始步长向量 $overline(s)_0 = [2, 1]^T$，模式移动公式：$overline(r)_(k+1) = 2 overline(b)_(k+1) - overline(b)_k$，迭代到开始缩小步长向量为止。
    ]),
    (no: "七", score: 10, topic: "qn", body: [
      用 DFP 法解无约束问题

      $ min quad f(overline(x)) = x_1^2 - x_1 x_2 + x_2^2 + x_1 - x_2. $

      设初始点 $overline(x)_0 = [0, 1/2]^T$，并已得 $overline(x)_1 = [-1/4, 1/2]^T$。

      注：校正公式
      $ H_(k+1) = H_k + (overline(s)_k overline(s)_k^T)/(overline(s)_k^T overline(y)_k) - (H_k overline(y)_k overline(y)_k^T H_k)/(overline(y)_k^T H_k overline(y)_k), $
      其中 $k = 0, 1, 2, dots.c$，$H_0$ 为单位矩阵。

      不要把分数写成近似小数。
    ]),
    (no: "八", score: 14, topic: "zout", body: [
      用 Z—容许方向法解约束问题

      $ min quad & x_1^2 + (1/2) x_2^2 - 8 x_1 - 2 x_2; \
        "s.t." quad & -3 x_1 + 2 x_2 >= 0, \
        & 3 x_1 + x_2 <= 9. $

      设初始点 $overline(x)_0 = [1, 2]^T$，迭代一次求 $overline(x)_1$，并判断 $overline(x)_1$ 是否为最优解。
    ]),
    (no: "九", score: 14, topic: "multiplier", body: [
      用 H-乘子法解约束问题

      $ min quad & f(overline(x)) = x_1^2 + x_2^2 - 3 x_1 + 3 x_2; \
        "s.t." quad & x_1 x_2 >= 1. $

      1\. 写出该问题 H-乘子法的增广目标函数 $F(overline(x); nu, mu)$。（如果是分段函数，需写出分段形式）

      2\. 已得 $min F(overline(x); nu_k, mu)$ 的一个最优解为
      $ overline(x)_k = overline(x) (nu_k, mu) = ( 3/4 + (1/2) sqrt(9/4 + (4 mu + 2 nu_k - 4)/mu), quad -3/4 + (1/2) sqrt(9/4 + (4 mu + 2 nu_k - 4)/mu) )^T. $
      据此求约束问题的最优解。

      3\. 设初始点 $overline(x)_0 = [1, 0]^T$，初始乘子 $nu_1 = 0$，初始罚因子 $mu = 1$。迭代两次，列出这两次迭代的解与更新的乘子（不考虑计算误差），并说明是否需要进行第三次迭代。

      注：$ F(overline(x); overline(lambda), overline(nu), mu) = f(overline(x)) - sum_(j=1)^l lambda_j h_j(overline(x)) + mu sum_(j=1)^l h_j^2(overline(x)) + 1/(4 mu) sum_(i=1)^m \{ [max(0, nu_i - 2 mu s_i(overline(x)))]^2 - nu_i^2 \}. $

      $ lambda_j^((k+1)) = lambda_j^((k)) - 2 mu h_j(overline(x)_k), quad j = 1, 2, dots, l, \
        quad nu_i^((k+1)) = max \{ 0, nu_i^((k)) - 2 mu s_i(overline(x)_k) \}, quad i = 1, 2, dots, m. $
    ]),
  ),
)
