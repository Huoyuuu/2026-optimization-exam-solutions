"""F-R 共轭梯度法真题验算（教材 3.4 节：p0 = -g0，α_k = |g_{k+1}|²/|g_k|²，p_{k+1} = -g_{k+1} + α_k p_k）。
运行：uv run scripts/check/cg.py"""
import sys
from pathlib import Path

import sympy as sp

sys.path.insert(0, str(Path(__file__).parent))
from optlib import fmt  # noqa: E402

x1, x2, x3, t = sp.symbols("x1 x2 x3 t", real=True)
X2, X3 = (x1, x2), (x1, x2, x3)


def ls(f, X, x, p):
    """精确直线搜索：返回 (t, φ(t), φ'(t))"""
    phi = sp.expand(f.subs(dict(zip(X, list(x + t * p)))))
    dphi = sp.factor(sp.diff(phi, t))
    roots = [r for r in sp.solve(sp.diff(phi, t), t) if r.is_real and r > 0]
    best = min(roots, key=lambda r: phi.subs(t, r))
    return sp.nsimplify(sp.simplify(best)), phi, dphi


def fr(name, f, X, x0, iters=2, given=None):
    print(f"\n===== {name}: f = {f}")
    g_, G_ = sp.Matrix([sp.diff(f, v) for v in X]), sp.hessian(f, X)
    print("  ∇f =", list(g_), "  G =", G_.tolist())
    x = sp.Matrix([sp.nsimplify(v) for v in x0])
    g = sp.simplify(g_.subs(dict(zip(X, x))))
    p = -g
    print(f"  x0={fmt(x)} f0={sp.simplify(f.subs(dict(zip(X, x))))} g0={fmt(g)} |g0|²={(g.T * g)[0]} p0={fmt(p)}")
    for k in range(iters):
        tk, phi, dphi = ls(f, X, x, p)
        x = sp.simplify(x + tk * p)
        if given is not None and k < len(given):
            print(f"  [{'OK' if x == sp.Matrix(given[k]) else 'FAIL'}] 题给 x{k + 1} = {given[k]}")
        g1 = sp.simplify(g_.subs(dict(zip(X, x))))
        fx = sp.simplify(f.subs(dict(zip(X, x))))
        print(f"  k={k}: φ(t)={phi}  φ'(t)={dphi}  t{k}={tk}")
        print(f"        x{k + 1}={fmt(x)} f={fx} g{k + 1}={fmt(g1)} |g|²={sp.simplify((g1.T * g1)[0])}")
        if all(v == 0 for v in g1):
            print("        g = 0，停止")
            break
        a = sp.simplify((g1.T * g1)[0] / (g.T * g)[0])
        p = sp.simplify(-g1 + a * p)
        print(f"        α{k}={a}  p{k + 1}={fmt(p)}  p^T g={sp.simplify((p.T * g1)[0])}")
        g = g1
    G = sp.simplify(G_.subs(dict(zip(X, x))))
    print(f"  终点 G={G.tolist()} 主子式={[sp.simplify(G[:i, :i].det()) for i in range(1, G.rows + 1)]}")
    return x


# 2009 三：f = e^q，q = x1²+2x1x2+2x2²。e^q 单调增，沿直线极小化 f 等于极小化 q
q = x1**2 + 2 * x1 * x2 + 2 * x2**2
print("\n===== 2009 三：f = exp(q)")
gq = sp.Matrix([sp.diff(q, v) for v in X2])
xa, xb = sp.Matrix([2, -1]), sp.Matrix([1, -1])
g0 = sp.exp(q.subs({x1: 2, x2: -1})) * gq.subs({x1: 2, x2: -1})
g1 = sp.exp(q.subs({x1: 1, x2: -1})) * gq.subs({x1: 1, x2: -1})
p0 = -g0
t0, phi0, d0 = ls(q, X2, xa, p0)
print(f"  g0={fmt(g0)} p0={fmt(p0)} 沿 p0 得 t0={t0}，x1={fmt(sp.simplify(xa + t0 * p0))}")
a0 = sp.simplify((g1.T * g1)[0] / (g0.T * g0)[0])
p1 = sp.simplify(-g1 + a0 * p0)
t1, phi1, d1 = ls(q, X2, xb, p1)
xc = sp.simplify(xb + t1 * p1)
print(f"  g1={fmt(g1)} α0={a0} p1={fmt(p1)}")
print(f"  q(x1+t p1)={sp.collect(phi1, t)}  t1={sp.factor(t1)}  x2={fmt(xc)} ≈ {fmt(xc.evalf(6))}")
print(f"  q(x2)={sp.simplify(q.subs({x1: xc[0], x2: xc[1]}))}")

fr("2010 三", 3 * x1**2 + 2 * x1 * x2 + x2**2 - 6 * x1 + 2 * x2, X2, (1, 0))
fr("2011 三", sp.Rational(3, 2) * x1**2 + x2**2 / 2 + x3**2 - x1 * x2, X3, (1, 1, 1), iters=3,
   given=[(sp.Rational(1, 5), 1, sp.Rational(1, 5))])
fr("2013/2014 三", x1**2 + x2**2 - x1**2 * x2, X2, (1, 1), given=[(1, sp.Rational(1, 2))])
fr("2015 七", 2 * (x1 - x2**2) ** 2 + (x2 - 1) ** 2, X2, (0, 0))
fr("2016 三(2)", x1**2 + 2 * x1 * x2 + 2 * x2**2, X2, (2, -1))
fr("2017 三", (x1 + x2) ** 4 + 2 * (x1 - 1) ** 2, X2, (0, 1))
fr("2018 二(2)", sp.Rational(2, 3) * x1**3 + x2**2 / 2 - x1 * x2 - 2 * x1 - x3**3, X3, (0, 0, 0))
fr("2019 二(2)", (x1 - x2) ** 2 - x1**2 * x2 + x2, X2, (0, 0))
fr("2020 三", x1**2 - x1 * x2 + x2**2 - 2 * x1 + x3**2, X3, (1, 1, 1), iters=3)
fr("2021 五", x1**2 * (1 + x2) + x2**2, X2, (1, -1))
fr("2023 五", x1**2 + x2**2 + x3**2 + x1 * x3 + 4 * x1 - x2, X3, (-2, sp.Rational(1, 2), 0))
fr("2024A 五", x1**4 - 2 * x1**2 * x2 + x1**2 + 2 * x2**2 - 2 * x1 + 1, X2, (2, sp.Rational(17, 4)))
fr("2024B 五", (x1 + x2) ** 2 + x2**4, X2, (-3, 1))

# 预测题
fr("P1", x1**2 + 2 * x2**2 + 2 * x3**2 - 2 * x1 * x2 - 2 * x2 * x3 - 2 * x1, X3, (0, 0, 0), iters=3)
Q = sp.Matrix([[2, -2, 0], [-2, 4, -2], [0, -2, 4]])
P = [sp.Matrix([2, 0, 0]), sp.Matrix([2, 2, 0]), sp.Matrix([2, 2, 2])]
print("  P1 共轭检验 p_i^T Q p_j：", [(P[i].T * Q * P[j])[0] for i, j in [(0, 1), (0, 2), (1, 2)]])
fr("P2", (x1 - x2) ** 4 + (x1 - 1) ** 2, X2, (-1, -2))
fr("P3", x1**2 + 2 * x2**2 - x1 * x2**2 + 2 * x1, X2, (1, 2))

# 答卷里写的化简式和近似值
from optlib import expect, report  # noqa: E402

E, s13 = sp.E, sp.sqrt(13)
expect("2009 x2 化简式", xc, sp.Matrix([(2 * E - 1) * (E - 1), -(E - 1) ** 2]) / (2 * E**2 - 2 * E + 1))
expect("2009 x2 近似", xc, sp.Matrix([0.7372, -0.2855]), tol=1e-4)
expect("2013 x2 近似", sp.Matrix([(5 - s13) / 6, (2 - s13) / 6]), sp.Matrix([0.2324, -0.2676]), tol=1e-4)
expect("2019 x2 近似", sp.Matrix([(1 - s13) / 6, -(2 + s13) / 6]), sp.Matrix([-0.4343, -0.9343]), tol=1e-4)
expect("2021 x2 近似", sp.Matrix([(5 - s13) / 6, (s13 - 2) / 6]), sp.Matrix([0.2324, 0.2676]), tol=1e-4)
f3 = x1**2 + 2 * x2**2 - x1 * x2**2 + 2 * x1
crit = sp.solve([sp.diff(f3, x1), sp.diff(f3, x2)], [x1, x2], dict=True)
print("  P3 驻点：", crit, " det G：", [sp.hessian(f3, X2).subs(c).det() for c in crit])
report()
