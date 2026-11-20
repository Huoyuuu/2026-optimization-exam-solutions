"""极值判定与 Taylor 展开真题验算。运行：uv run scripts/check/calc.py"""
import sympy as sp

x1, x2, x3, x, y = sp.symbols("x1 x2 x3 x y", real=True)


def crit(name, f, v=(x1, x2)):
    g = [sp.diff(f, s) for s in v]
    H = sp.hessian(f, v)
    print(f"== {name}\n  grad = {g}\n  H = {H.tolist()}")
    for sol in sp.solve(g, v, dict=True):
        Hs = H.subs(sol)
        ev = Hs.eigenvals()
        minors = [Hs[:k, :k].det() for k in range(1, len(v) + 1)]
        kind = "极小" if all(m > 0 for m in minors) else ("极大" if all((-1) ** (k + 1) * m > 0 for k, m in enumerate(minors)) else "非极值/待定")
        print(f"  {sol}: H = {Hs.tolist()}, 顺序主子式 {minors}, 特征值 {list(ev)}, f = {f.subs(sol)}  -> {kind}")


def taylor(name, f, v, p):
    sub = dict(zip(v, p))
    g = sp.Matrix([sp.diff(f, s) for s in v]).subs(sub)
    H = sp.hessian(f, v).subs(sub)
    d = sp.Matrix([s - c for s, c in zip(v, p)])
    T = f.subs(sub) + (g.T * d)[0] + sp.Rational(1, 2) * (d.T * H * d)[0]
    print(f"== {name}: f0 = {f.subs(sub)}, grad = {g.T.tolist()[0]}, H = {H.tolist()}")
    print("  展开式 =", sp.expand(T))


crit("2013 三(1)", x1**2 + x2**2 - x1**2 * x2)
crit("2014 二(3)", x1**3 + x1 * x2 + (1 + x2) ** 2)
crit("2015 三",x1**3 + 3 * x1 * x2**2 - 15 * x1 - 12 * x2)
crit("2020 一(1)", x1**3 - 3 * x1 + (x1 - 2 * x2) ** 2)
crit("2024A 一(1)", x1**3 + 2 * x2**3 + 3 * x1**2 + 5 * x2**2 - 9 * x1 - 4 * x2)
crit("2024B 一(1)", x1**3 / 3 + x2**3 / 3 - x2**2 - x1)
taylor("2020 五", sp.exp(x + 2 * y), (x, y), (0, 0))
taylor("2024A 一(2)", x1**3 / 3 + x2**3 / 3 + x1 * x2**2 - x2**2 - x1, (x1, x2), (1, 1))
taylor("2024B 一(2)", x1**4 + 2 * x2**3 + 3 * x3**2 - x1**2 * x2 + 4 * x2 * x3 - x1 * x3**2, (x1, x2, x3), (0, 1, 0))
# 预测题
taylor("P1", x1**3 + x1 * x2 + x2**2, (x1, x2), (1, 0))
crit("P2", x1**3 + x2**2 - 3 * x1 * x2)
