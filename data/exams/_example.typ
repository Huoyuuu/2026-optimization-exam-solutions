// 示例：格式说明用，不是真题。真题文件照这个格式写，文件名 = 试卷 id。
// 来源：素材/真题答案/xxxx.pdf 第 1–2 页
#let exam = (
  id: "_example",
  term: [第一学期],
  items: (
    (head: [一、简答题（每小题 4 分，共 12 分）]),
    (no: "一(1)", score: 4, topic: "lp-basic", body: [什么是线性规划的基本容许解？]),
    (no: "一(2)", score: 4, topic: "x-dual", body: [写出线性规划的对偶问题的定义。]),
    (no: "一(3)", score: 4, topic: "convex", body: [证明：凸函数的局部极小点是全局极小点。]),
    (no: "二", score: 12, topic: "grad", body: [
      求函数 $f(x) = x_1^2 + 2 x_1 x_2 + 3 x_2^2 - 4 x_1$ 在点 $x^((0)) = (1, 1)^T$ 处的梯度和 Hesse 矩阵，并写出 $f$ 在该点的二阶 Taylor 展开式。
    ]),
    (no: "三", score: 16, topic: "simplex", oos: "(2)", body: [
      已知线性规划
      $ max quad & z = 2 x_1 + 3 x_2 \
        "s.t." quad & x_1 + 2 x_2 <= 8, \
        & 4 x_1 <= 16, \
        & x_1, x_2 >= 0. $
      (1) 用单纯形法求解；(2) 写出它的对偶问题。
    ]),
    (no: "四", score: 10, topic: "qn", body: [
      用 DFP 方法求解
      $ min f(x) = x_1^2 + 2 x_2^2 - 2 x_1 x_2 - 4 x_1, $
      取初始点 $x^((0)) = (1, 1)^T$，$H_0 = I$。
      （校正公式：$H_(k+1) = H_k + (s_k s_k^T)/(s_k^T y_k) - (H_k y_k y_k^T H_k)/(y_k^T H_k y_k)$）
    ]),
    (no: "五", score: 8, topic: "kkt", body: [
      求下列问题的 K-T 点：
      $ min quad & (x_1 - 2)^2 + x_2^2 \
        "s.t." quad & x_1^2 + x_2 <= 1, quad x_1 >= 0. $
    ]),
    (no: "六", score: 6, topic: "simplex", body: [
      下表是某线性规划的单纯形表，〔?〕处看不清：
      #table(columns: 5, stroke: 0.4pt, align: center,
        [], $x_1$, $x_2$, $x_3$, $overline(b)$,
        $x_3$, [1], [2], [1], [4],
        $sigma$, [3], [〔?〕], [0], [0])
      判断它是否最优。
    ]),
  ),
)
