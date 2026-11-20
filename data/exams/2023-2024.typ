// 2023–2024 学年最优化方法期末试卷（A 卷）。来源：素材/真题答案/东大最优化2023-2024期末试卷.pdf 第 1 页
#import "/template.typ": blank
#let exam = (
  id: "2023-2024",
  term: [第一学期],
  items: (
    (no: "一", score: 10, topic: "hj", body: [
      采用图上作业方式，用步长加速法求解无约束问题 $ min f(overline(x)) $
      $f(overline(x))$ 的等值线图如〔图略〕所示，图中 $x^*$ 表示目标函数的极小值点，取初始点为 $overline(x)_0 = [0, 15]^T$。设步长向量的分量均取 1（图中网格为单位格），迭代到开始缩小步长为止。

      注意：（a）在图左下方所示的直角坐标系上标出探测搜索方向的先后顺序；
      （b）按指定标识方式：基点、参考点、基点与参考点的重合点、探测经历点，标出作业过程中的全部基点、参考点和探测经历点；
      （c）按进行的顺序，对基点和参考点分别标号：$1, 2, dots.c$。
    ]),
    (no: "二", score: 16, topic: "simplex", body: [
      用两阶段单纯形法求解线性规划问题（不能化简约束条件）
      $ max quad & -3 x_1 + x_2 - 4 x_3 \
        "s.t." quad & x_1 + x_2 + 2 x_3 <= 4, \
        & 2 x_1 - x_2 + x_3 <= -2, \
        & 2 x_2 + x_3 = 5, \
        & x_i >= 0, quad i = 1, 2, 3. $
      （1）线性规划问题的解有哪几种情况：#blank(22)。 \
      （2）线性规划问题的容许集是#blank(16)；如果线性规划问题有最优解，则必有#blank(16)。
    ]),
    (no: "三", score: 12, topic: "qn", body: [
      用 DFP 方法求解无约束极小化问题
      $ min quad 2 x_1^2 + x_2^2 + x_1 x_2 + 2 x_1 - x_2 + 3 $
      取初始点为 $overline(x)_0 = [-1, 2]^T$。
      （校正公式 $H_(k+1) = H_k + (s_k s_k^T)/(s_k^T y_k) - (H_k y_k y_k^T H_k)/(y_k^T H_k y_k)$，$k = 0, 1, 2, dots.c$，$H_0$ 为单位矩阵。）
    ]),
    (no: "四", score: 12, topic: "newton", body: [
      无约束极小化问题
      $ min quad x_1^3 + x_1 x_2^2 - x_1^2 $
      取初始点为 $overline(x)_0 = [1/6, 0]^T$， \
      (1) 用 Newton 法迭代一次求出 $overline(x)_1$； \
      (2) 判断点 $overline(x)_1$ 是否有效，若有效，求出 $overline(x)_2$；若无效，用修正 Newton 法求出 $overline(x)_2$。
    ]),
    (no: "五", score: 12, topic: "cg", body: [
      用 F-R 共轭梯度法求解无约束极小化问题
      $ min quad x_1^2 + x_2^2 + x_3^2 + x_1 x_3 + 4 x_1 - x_2. $
      取初始点为 $overline(x)_0 = [-2, 1/2, 0]^T$，迭代两次，求出 $overline(x)_2$ 并判断其最优性。
    ]),
    (no: "六", score: 12, topic: "kkt", body: [
      (1) 利用 K-T 条件求解约束优化问题
      $ min quad & x_1^2 + 4 x_2^2 \
        "s.t." quad & x_1 - x_2 <= -1. $
      (2) 请写出如下等式约束优化问题极小值点满足的二阶充分条件
      $ min quad f(overline(x)) \
        "s.t." quad h_j(overline(x)) = 0, quad j = 1, 2, dots.c, l. $
    ]),
    (no: "七", score: 12, topic: "zout", body: [
      利用 Z-容许方向法求解约束优化问题
      $ min quad & x_2^2 - ln(1 + 2 x_1) \
        "s.t." quad & 2 x_1 + x_2 <= 6, \
        & x_1 + x_2 >= 4, \
        & x_1 >= 0, \
        & x_2 >= 0. $
      取始点为 $overline(x)_0 = [1/2, 5]^T$，迭代一次求出 $overline(x)_1$，并判断 $overline(x)_1$ 是否为最优解。
    ]),
    (head: [八、（14 分）已知不等式约束极小化问题如下：
      $ min quad & (x_1 - 2)^2 + (x_2 - 1)^2 \
        "s.t." quad & x_1 - x_2 >= 5. $]),
    (no: "八(1)", topic: "multiplier", body: [
      1. 试用 H 乘子法求解上述问题。
      （公式：
      $ F(overline(x), overline(lambda), overline(v), mu) = f(overline(x)) - sum_(j=1)^l lambda_j h_j(overline(x)) + mu sum_(j=1)^l h_j^2 (overline(x)) + 1/(4 mu) sum_(i=1)^m {[max(0, v_i - 2 mu s_i(overline(x)))]^2 - v_i^2}, $
      $ v_i^((k+1)) = max{0, v_i^((k)) - 2 mu s_i(overline(x)_k)}, quad i = 1, dots.c, m; quad lambda_j^((k+1)) = lambda_j^((k)) - 2 mu h_j(overline(x)_k), quad j = 1, dots.c, l. $
      ）
    ]),
    (no: "八(2)", topic: "penalty", body: [
      2. 取初始点 $overline(x)_0 = [0, 0]^T$，初始罚因子 $mu_1 = 5$，罚因子放大系数 $c = 2$，终止限 $epsilon = 0.1$，试给出外部罚函数法的数值计算迭代过程： \
      （1）增广目标函数 $F(overline(x); mu) =$ #blank(18)； \
      （2）$min F(overline(x); mu)$ 的最优解 $overline(x)_mu^* =$ #blank(16)； \
      （3）迭代点 $overline(x)_1 =$ #blank(14)，因为#blank(14)，所以 $overline(x)_1$ 不是最优解； \
      （4）迭代点 $overline(x)_2 =$ #blank(14)。
    ]),
  ),
)
