"""Newton 法、修正 Newton 法真题验算（教材 3.3 节约定）。运行：uv run scripts/check/newton.py"""
import sys
from pathlib import Path

import sympy as sp

sys.path.insert(0, str(Path(__file__).parent))
from optlib import fmt  # noqa: E402

x1, x2, x3, t = sp.symbols("x1 x2 x3 t", real=True)


def ls(f, X, x, p):
    """精确直线搜索 min_{t>0} f(x + t p)，返回 (t, 新点, φ(t))"""
    phi = sp.expand(f.subs(dict(zip(X, list(x + t * p)))))
    roots = [r for r in sp.solve(sp.diff(phi, t), t) if r.is_real and r > 0]
    if not roots:
        print(f"  φ(t)={phi} 在 t>0 上没有极小点（无下界）")
        return None, x, phi
    best = min(roots, key=lambda r: phi.subs(t, r))
    return sp.nsimplify(best), sp.simplify(x + best * p), phi


def mnewton(name, f, X, x0, steps=1, modified=True):
    print(f"\n===== {name}: f = {f}")
    g_, G_ = sp.Matrix([sp.diff(f, v) for v in X]), sp.hessian(f, X)
    print("  ∇f =", list(g_), "  G =", G_.tolist())
    x = sp.Matrix([sp.nsimplify(v) for v in x0])
    for k in range(steps):
        g, G = sp.simplify(g_.subs(dict(zip(X, x)))), sp.simplify(G_.subs(dict(zip(X, x))))
        fx = sp.simplify(f.subs(dict(zip(X, x))))
        print(f"  k={k}: x={fmt(x)} f={fx} g={fmt(g)} G={G.tolist()} detG={sp.simplify(G.det())}")
        if all(v == 0 for v in g):
            print("  g = 0，停止")
            break
        if G.det() == 0:
            p = -g
            tt, xn, phi = ls(f, X, x, p)
            print(f"  G 奇异，p=-g={fmt(p)}，φ(t)={phi}，t={tt}，x_next={fmt(xn)}，f={sp.simplify(f.subs(dict(zip(X, xn))))}")
            x = xn
            continue
        p = sp.simplify(-G.inv() * g)
        xn = sp.simplify(x + p)
        fn = sp.simplify(f.subs(dict(zip(X, xn))))
        gp = sp.simplify((g.T * p)[0])
        print(f"  p={fmt(p)} x+p={fmt(xn)} f(x+p)={fn} g^T p={gp} {'有效' if fn < fx else '无效'}")
        if fn < fx or not modified:
            x = xn
            continue
        d = p if gp < 0 else -p
        tt, xn, phi = ls(f, X, x, d)
        if tt is None:
            break
        print(f"  沿 {'p' if gp < 0 else '-p'}={fmt(d)} 搜索：φ(t)={phi}，t={tt}，x_next={fmt(xn)}，f={sp.simplify(f.subs(dict(zip(X, xn))))}")
        x = xn
    gl = sp.simplify(g_.subs(dict(zip(X, x))))
    Gl = sp.simplify(G_.subs(dict(zip(X, x))))
    print(f"  终点 x={fmt(x)} g={fmt(gl)} G={Gl.tolist()} 主子式={[sp.simplify(Gl[:i, :i].det()) for i in range(1, Gl.rows + 1)]}")


X2 = (x1, x2)
mnewton("2009 二", 3 * x1**2 + x2**2 - x1**2 * x2, X2, (1, 1), modified=False)
mnewton("2010 二", (x1 - 1) ** 2 + (x1**2 - x2) ** 2, X2, (1, 2))
mnewton("2015 六(2)", x1**3 + 3 * x1 * x2**2 - 15 * x1 - 12 * x2, X2, (2, 3), modified=False)
mnewton("2016 三(1)", x1**2 * x2 + 2 * x1 * x2**2 - 4 * x1 * x2, X2, (1, 1), modified=False)
mnewton("2017 二", (x1 - 1) ** 4 + 2 * x2**2, X2, (0, 2), steps=2)
mnewton("2019 二(1)", -(x1**2) + x2**2 - x1 * x2, X2, (1, 1))
for x0 in [(2, sp.Rational(3, 2)), (1, sp.Rational(1, 2)), (1, sp.Rational(1, 4))]:
    mnewton(f"2020 七 {x0}", x1**2 + 2 * x2**2 - x1**2 * x2, X2, x0)
mnewton("2021 三", x1**2 + x2**2 + x3**2 + x1 * x2 + 2 * x1 - 3 * x2, (x1, x2, x3), (0, 0, 0))
mnewton("2022 一", x1**3 - 3 * x1 * x2**2 + x1**2 + x2**2, X2, (1, 0), steps=2, modified=False)
mnewton("2023 四", x1**3 + x1 * x2**2 - x1**2, X2, (sp.Rational(1, 6), 0), steps=2)
for x0 in [(2, 0), (1, -1), (sp.Rational(1, 3), sp.sqrt(sp.Rational(2, 3)))]:
    mnewton(f"2024A 三 {x0}", x1**2 + x2**2 - x1 * x2**2, X2, x0)
for x0 in [(0, -1), (1 / sp.sqrt(3), sp.Rational(1, 6)), (2, sp.Rational(1, 2))]:
    mnewton(f"2024B 三 {x0}", sp.Rational(1, 2) * x1**2 + x2**2 - x1**2 * x2, X2, x0)

# 预测题
for x0 in [(2, 1), (0, 0), (sp.Rational(-1, 2), 0)]:
    mnewton(f"P1 {x0}", x1**3 / 3 - x1 + x2**2, X2, x0)
mnewton("P2", (x1 - 2) ** 4 + (x1 - 2 * x2) ** 2, X2, (0, 3), steps=2, modified=False)
