"""DFP 法真题验算（教材 3.5 节：H0 = I，p_k = -H_k g_k，精确直线搜索，
H_{k+1} = H_k + s s^T/(s^T y) - H y y^T H/(y^T H y)，s = x_{k+1} - x_k，y = g_{k+1} - g_k）。
运行：uv run scripts/check/qn.py"""
import sys
from pathlib import Path

import sympy as sp

sys.path.insert(0, str(Path(__file__).parent))
from optlib import fmt  # noqa: E402

x1, x2, x3, t = sp.symbols("x1 x2 x3 t", real=True)
X2, X3 = (x1, x2), (x1, x2, x3)


def M(A):
    return "[" + "; ".join(", ".join(str(sp.nsimplify(v)) for v in A.row(i)) for i in range(A.rows)) + "]"


def ls(f, X, x, p):
    phi = sp.expand(f.subs(dict(zip(X, list(x + t * p)))))
    roots = [r for r in sp.solve(sp.diff(phi, t), t) if r.is_real and r > 0]
    best = min(roots, key=lambda r: phi.subs(t, r))
    return sp.radsimp(sp.simplify(best)), phi, sp.factor(sp.diff(phi, t))


def dfp(name, f, X, x0, iters=2, given=None):
    print(f"\n===== {name}: f = {f}")
    n = len(X)
    g_, G_ = sp.Matrix([sp.diff(f, v) for v in X]), sp.hessian(f, X)
    print("  ∇f =", list(g_), "  G =", M(G_), " 主子式", [G_[:i, :i].det() for i in range(1, n + 1)])
    x = sp.Matrix([sp.nsimplify(v) for v in x0])
    H = sp.eye(n)
    g = g_.subs(dict(zip(X, x)))
    print(f"  x0={fmt(x)} f0={f.subs(dict(zip(X, x)))} g0={fmt(g)}")
    for k in range(iters):
        p = sp.simplify(-H * g)
        tk, phi, dphi = ls(f, X, x, p)
        xn = sp.simplify(x + tk * p)
        if given is not None and k < len(given):
            print(f"  [{'OK' if xn == sp.Matrix(given[k]) else 'FAIL'}] 题给 x{k + 1} = {given[k]}")
        gn = sp.simplify(g_.subs(dict(zip(X, xn))))
        print(f"  k={k}: p{k}={fmt(p)}  φ(t)={phi}  φ'={dphi}  t{k}={tk}")
        print(f"        x{k + 1}={fmt(xn)} f={sp.simplify(f.subs(dict(zip(X, xn))))} g{k + 1}={fmt(gn)}")
        if all(v == 0 for v in gn):
            print("        g = 0，停止")
            x = xn
            break
        s, y = sp.simplify(xn - x), sp.simplify(gn - g)
        sy = sp.simplify((s.T * y)[0])
        Hy = sp.simplify(H * y)
        yHy = sp.simplify((y.T * Hy)[0])
        A, B = sp.simplify(s * s.T / sy), sp.simplify(Hy * Hy.T / yHy)
        H = sp.simplify(H + A - B)
        print(f"        s{k}={fmt(s)} y{k}={fmt(y)} s^T y={sy} H y={fmt(Hy)} y^T H y={yHy}")
        print(f"        ss^T/(s^T y)={M(A)}  Hyy^TH/(y^THy)={M(B)}")
        print(f"        H{k + 1}={M(H)}")
        x, g = xn, gn
    G = sp.simplify(G_.subs(dict(zip(X, x))))
    print(f"  终点 x={fmt(x)} G={M(G)} 主子式={[sp.simplify(G[:i, :i].det()) for i in range(1, n + 1)]}")
    if G_.free_symbols == set():
        print(f"  Q^-1={M(G_.inv())}  H==Q^-1? {sp.simplify(H - G_.inv()) == sp.zeros(n)}")
    return x


R = sp.Rational
dfp("2009 四", x1**2 + 2 * x2**2 - 2 * x1 * x2, X2, (1, 1), given=[(1, R(1, 2))])
dfp("2011 四", x1**2 + 2 * x2**2 - x1**2 * x2, X2, (1, 1), given=[(1, R(1, 4))])
dfp("2013 四", (x1 - 2) ** 2 + 2 * x2**2, X2, (0, 1), given=[(R(4, 3), R(-1, 3))])
dfp("2014 五", x1**2 + x2**2 + x3**2 / 2 + x1 * x2 - x3, X3, (-2, 1, 1), iters=3, given=[(R(-1, 2), 1, 1)])
dfp("2015 四", x1**2 + 2 * x2**2 + 2 * x1 * x2 - x1 + x2, X2, (0, 0))
dfp("2016 四", x1**2 + 2 * x2**2 - 2 * x1 * x2 + x3**2, X3, (1, 1, 1), iters=3, given=[(1, R(1, 3), R(1, 3))])
dfp("2017 四", (x1 - 1) ** 2 + x1 * x2 + 2 * x2**2, X2, (1, 0))
dfp("2018 三", 2 * x1**2 + x2**2 + (x1 + x2 - 1) ** 2, X2, (0, 1))
dfp("2019 三", x1**2 / 2 + x2**2 - x1 * x2, X2, (1, 1))
dfp("2021 七", x1**2 - x1 * x2 + x2**2 + x1 - x2, X2, (0, R(1, 2)), given=[(R(-1, 4), R(1, 2))])
dfp("2022 三", x1**2 + x1 * x2 + x2**2 - x1 + 2 * x2 + x3**2, X3, (1, -1, 1), iters=3)
dfp("2023 三", 2 * x1**2 + x2**2 + x1 * x2 + 2 * x1 - x2 + 3, X2, (-1, 2))
dfp("2024A 四", 3 * x1**2 + 2 * x1 * x2 + x2**2 / 2 - 6 * x1 - 4 * x2, X2, (-2, 9))
dfp("2024B 四", 2 * x1**2 - 2 * x1 * x2 + x2**2 - 2 * x1 + x2, X2, (1, 1))

# 预测题
xP1 = dfp("P1", 2 * x1**2 + 2 * x1 * x2 + x2**2 - 2 * x1, X2, (-1, 2))
# P1 验算拟 Newton 条件 H1 y0 = s0，并补算 H2 = Q^-1（推论 3.9）
Q1 = sp.Matrix([[4, 2], [2, 2]])
H1 = sp.Matrix([[R(1, 2), R(-1, 2)], [R(-1, 2), R(3, 2)]])
s0, y0 = sp.Matrix([2, -2]), Q1 * sp.Matrix([2, -2])
s1 = sp.Matrix([1, 0]) * 0 + (xP1 - sp.Matrix([1, 0]))
y1 = Q1 * s1
H2 = H1 + s1 * s1.T / (s1.T * y1)[0] - H1 * y1 * y1.T * H1 / (y1.T * H1 * y1)[0]
print("  P1 y0=", list(y0), " H1 y0 == s0?", H1 * y0 == s0, " s1=", list(s1), " y1=", list(y1), " H2=", H2.tolist(), " Q^-1=", Q1.inv().tolist())
dfp("P2", 2 * x1**2 + 2 * x2**2 + x3**2 - 2 * x1 * x2 - 2 * x2 * x3 - 2 * x1 - 2 * x3, X3, (1, 1, 1), iters=2)
dfp("P3", (x1 - x2 + 1) ** 4 + 2 * (x1 - 1) ** 2, X2, (0, 0))

# 答卷里另写的式子和近似值
from optlib import expect, report  # noqa: E402

s = sp.symbols("s", real=True)
f11 = x1**2 + 2 * x2**2 - x1**2 * x2
expect("2011 ψ(s)", sp.expand(f11.subs({x1: 1 - 2 * s, x2: R(1, 4) - s})), 4 * s**3 + s**2 - 3 * s + R(7, 8))
s37 = sp.sqrt(37)
expect("2011 s 近似", (s37 - 1) / 12, 0.4236, tol=1e-4)
xb = sp.Matrix([(7 - s37) / 6, (4 - s37) / 12])
expect("2011 x2", xb, sp.Matrix([1, R(1, 4)]) + (s37 - 1) / 12 * sp.Matrix([-2, -1]))
expect("2011 x2 近似", xb, sp.Matrix([0.1529, -0.1736]), tol=1e-4)
expect("2011 f(x2) 近似", f11.subs({x1: xb[0], x2: xb[1]}), 0.0877, tol=1e-4)
g11 = sp.Matrix([sp.diff(f11, v) for v in X2]).subs({x1: xb[0], x2: xb[1]})
expect("2011 g2", g11, sp.Matrix([(19 - s37) / 36, (s37 - 19) / 18]))
expect("2011 g2 近似", g11, sp.Matrix([0.3588, -0.7176]), tol=1e-4)
report()
