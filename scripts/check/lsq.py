"""最小二乘真题验算：法方程组 A^T A x = A^T b 精确求解。运行：uv run scripts/check/lsq.py"""
import sympy as sp

R = sp.Rational


def ls(name, A, b):
    A, b = sp.Matrix(A), sp.Matrix(b)
    N, r = A.T * A, A.T * b
    print(f"== {name}")
    print("  A^T A =", N.tolist(), " A^T b =", r.T.tolist()[0])
    if N.det() == 0:
        print("  A^T A 奇异，rank =", N.rank())
        return None
    x = N.LUsolve(r)
    res = A * x - b
    print("  det =", N.det(), " x* =", [sp.nsimplify(v) for v in x], "≈", [round(float(v), 4) for v in x])
    print("  残差 =", res.T.tolist()[0], " s =", sp.nsimplify((res.T * res)[0]), "≈", round(float((res.T * res)[0]), 4))
    return x


ls("2009 七", [[1, 1], [-2, 1], [1, 2]], [1, 0, 4])
ls("2010 五.2", [[1, 1], [-1, 2], [3, -1]], [1, -1, 1])
ls("2015 二(2)", [[1, 1, 1], [2, -3, -1], [-1, 2, -2], [-1, 0, 1]], [1, -2, -4, 1])
ls("2016 六(2)", [[3, 1], [4, 1], [5, 1], [6, 1]], [R(5, 2), 3, 4, R(9, 2)])
xs = [-2, -1, 0, 1, 2]
ls("2017 七(2)", [[1, x**2] for x in xs], [R(7, 2), 2, R(9, 10), 2, 4])
ts = [-3, -2, -1, 0, 1]
ys = [R(7, 2), R(3, 2), R(1, 2), 1, R(7, 2)]
ls("2022 四", [[t, 1] for t in ts], [y - t**2 for t, y in zip(ts, ys)])
A = sp.Matrix([[1, 1, 0, -2], [2, -1, 1, -1], [1, -1, -1, 0]])
b = sp.Matrix([-2, 1, 0])
print("== 2021 四：A^T A =", (A.T * A).tolist(), " A^T b =", (A.T * b).T.tolist()[0], " rank A =", A.rank())
print("  原方程组的通解：", sp.linsolve((A, b)))
# 2014–2015 二(2)：比较一次、二次拟合的残差
t = [-1, R(-7, 10), 0, R(7, 10), 1]
y = [R(-9, 10), -1, -2, R(-7, 2), R(-22, 5)]
ls("2014 一次", [[v, 1] for v in t], y)
ls("2014 二次", [[v**2, v, 1] for v in t], y)
# 2010–2011 五.1：一次、二次拟合
t = [0, 1, 2, 3, 4]
y = [1, 3, 5, 4, 2]
ls("2010 一次", [[v, 1] for v in t], y)
ls("2010 二次", [[v**2, v, 1] for v in t], y)
# 2019–2020 五 第 2 组：一次拟合
t = [R(-3, 2), R(-1, 2), R(3, 2), R(5, 2), R(7, 2)]
y = [R(-11, 5), R(1, 10), 4, R(29, 5), R(41, 5)]
ls("2019 第2组 一次", [[v, 1] for v in t], y)
# 2013–2014 二(1)：只列法方程组
X, Y, Z = [3, 5, 6, 8, 12, 14], [16, 10, 7, 4, 3, 2], [90, 72, 54, 42, 30, 12]
ls("2013 二(1)", [[1, x, y] for x, y in zip(X, Y)], Z)
# 预测题：教材例 3.8；一次拟合
ls("P1 例3.8", [[1, 1], [2, -3], [-1, 4]], [3, 2, 4])
ls("P2", [[t, 1] for t in [0, 1, 2, 3]], [1, 2, R(5, 2), 4])
