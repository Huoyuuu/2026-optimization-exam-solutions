"""Zoutendijk 容许方向法真题验算（教材 4.2 节，算法 4.1）。
约束写成 a^T x >= b（不等式）和 c^T x = d（等式）。每次迭代：分解 A'、A''，
解线性规划 min ∇f^T p，A'p >= 0，Cp = 0，-1 <= p_j <= 1（枚举顶点），
u = A''x - b''，v = A''p，t̄ = min{-u_i/v_i | v_i < 0}，在 [0, t̄] 上求 φ(t) = f(x + t p) 的极小。
运行：uv run scripts/check/zout.py"""
import itertools
import sys
from pathlib import Path

import sympy as sp

sys.path.insert(0, str(Path(__file__).parent))
from optlib import expect, report  # noqa: E402

R = sp.Rational
x1, x2, x3, t = sp.symbols("x1 x2 x3 t", real=True)
X2, X3 = (x1, x2), (x1, x2, x3)


def M(*v):
    return sp.Matrix([sp.nsimplify(a) for a in v])


def grad(f, X, x):
    return sp.Matrix([sp.diff(f, v) for v in X]).subs(dict(zip(X, x)))


def split(ineq, x):
    act, ina = [], []
    for i, (a, b) in enumerate(ineq):
        r = (M(*a).T * x)[0] - b
        (act if r == 0 else ina).append((i + 1, M(*a), b, r))
    return act, ina


def lp(g, act, eq, n):
    """枚举 {A'p >= 0, Cp = 0, -1 <= p <= 1} 的顶点，返回 [(值, p)]，按值升序。"""
    rows = [(a, 0, ">=") for _, a, _, _ in act] + [(M(*c), 0, "=") for c, _ in eq]
    for j in range(n):
        e = sp.zeros(n, 1)
        e[j] = 1
        rows += [(e, 1, "<="), (e, -1, ">=")]
    eqs = [r for r in rows if r[2] == "="]
    rest = [r for r in rows if r[2] != "="]
    P = sp.symbols(f"p1:{n + 1}")
    pv = sp.Matrix(P)
    verts = []
    for comb in itertools.combinations(rest, n - len(eqs)):
        sys_ = [(a.T * pv)[0] - r for a, r, _ in eqs + list(comb)]
        sol = sp.solve(sys_, P, dict=True)
        if len(sol) != 1 or len(sol[0]) != n:
            continue
        p = pv.subs(sol[0])
        ok = all(((a.T * p)[0] >= r if k == ">=" else (a.T * p)[0] <= r if k == "<=" else (a.T * p)[0] == r)
                 for a, r, k in rows)
        if ok and p not in [q for _, q in verts]:
            verts.append(((g.T * p)[0], p))
    verts.sort(key=lambda z: z[0])
    return verts


def kkt_mult(g, act, eq):
    """解 g = Σ μ_i a_i + Σ λ_j c_j（起作用约束），返回解或 None。"""
    cols = [a for _, a, _, _ in act] + [M(*c) for c, _ in eq]
    if not cols:
        return {} if g == sp.zeros(*g.shape) else None
    ms = sp.symbols(f"m1:{len(cols) + 1}")
    expr = sum((m * c for m, c in zip(ms, cols)), sp.zeros(*g.shape)) - g
    sol = sp.solve(list(expr), ms, dict=True)
    return sol[0] if sol else None


def step(name, f, X, ineq, eq, x0, p=None, show=True):
    x0 = M(*x0)
    n = len(X)
    print(f"\n===== {name}  x = {list(x0)}  f = {f.subs(dict(zip(X, x0)))}")
    g = grad(f, X, x0)
    act, ina = split(ineq, x0)
    for c, d in eq:
        assert (M(*c).T * x0)[0] == d, "等式约束不满足"
    assert all(r >= 0 for *_, r in act + ina), "初始点不容许"
    print(f"  g = {list(g)}")
    print(f"  起作用 A': {[(i, list(a), b) for i, a, b, _ in act]}")
    print(f"  不起作用 A'': {[(i, list(a), b, r) for i, a, b, r in ina]}")
    V = lp(g, act, eq, n)
    print("  LP 顶点:", [(str(v), list(q)) for v, q in V])
    best = [q for v, q in V if v == V[0][0]]
    print(f"  LP 最优值 {V[0][0]}，最优顶点 {[list(q) for q in best]}")
    if p is None:
        p = best[0]
    else:
        p = M(*p)
        print(f"  给定 p = {list(p)}：A'p = {[(a.T * p)[0] for _, a, _, _ in act]}，Cp = {[(M(*c).T * p)[0] for c, _ in eq]}，g^T p = {(g.T * p)[0]}")
    gp = (g.T * p)[0]
    if gp == 0:
        mu = kkt_mult(g, act, eq)
        print(f"  g^T p = 0，满足终止准则；乘子 {mu}")
        return x0, p, None, None
    u = [r for *_, r in ina]
    v = [(a.T * p)[0] for _, a, _, _ in ina]
    neg = [-ui / vi for ui, vi in zip(u, v) if vi < 0]
    tbar = min(neg) if neg else sp.oo
    print(f"  u = {u}，v = {v}，t̄ = {tbar}")
    phi = sp.expand(f.subs(dict(zip(X, x0 + t * p))))
    dphi = sp.simplify(sp.diff(phi, t))
    print(f"  φ(t) = {phi}\n  φ'(t) = {dphi}")
    st = [s for s in sp.solve(sp.Eq(dphi, 0), t) if s.is_real and s > 0]
    print(f"  φ' = 0 的正根: {st}")
    cand = [s for s in st if s <= tbar]
    tk = cand[0] if cand else tbar
    xn = x0 + tk * p
    fn = sp.nsimplify(f.subs(dict(zip(X, xn))))
    print(f"  t = {tk}，x_new = {list(xn)}，f = {fn}")
    act1, ina1 = split(ineq, xn)
    g1 = grad(f, X, xn)
    print(f"  新点 g = {list(g1)}，起作用 {[i for i, *_ in act1]}，乘子 {kkt_mult(g1, act1, eq)}")
    V1 = lp(g1, act1, eq, n)
    print(f"  新点 LP 顶点: {[(str(v), list(q)) for v, q in V1]}")
    return xn, p, tk, tbar


def chk(tag, got, want):
    expect(tag, got, want)


# ---------- 真题 ----------
# 2009-2010 五
f = x1**2 - 2 * x1 * x2 + 4 * x2**2
ineq = [((3, 1), 2), ((2, -5), -10), ((-1, 2), -2), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2009-2010 五", f, X2, ineq, [], (0, 2))
chk("2009 p0", p, M(1, -1)); chk("2009 t̄", tb, 2); chk("2009 t0", tk, R(10, 7)); chk("2009 x1", xn, M(R(10, 7), R(4, 7)))

# 2010-2011 七
f = x1**2 + 2 * x2**2 - x1 * x2
ineq = [((-1, -4), -5), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2010-2011 七", f, X2, ineq, [((1, 1), 2)], (1, 1))
chk("2010 p0", p, M(1, -1)); chk("2010 t̄", tb, 1); chk("2010 t0", tk, R(1, 4)); chk("2010 x1", xn, M(R(5, 4), R(3, 4)))

# 2011-2012 六(2)，给定 p0
f = x1**2 + 2 * x2**2 - x3**2 - 3 * x2 * x3
ineq = [((-3, -4, -2), -6), ((1, 0, 0), 0), ((0, 1, 0), 0), ((0, 0, 1), 0)]
xn, p, tk, tb = step("2011-2012 六(2)", f, X3, ineq, [((1, 1, 1), 1)], (1, 0, 0), p=(-2, 1, 1))
chk("2011 t̄", tb, R(1, 2)); chk("2011 t0", tk, R(1, 2)); chk("2011 x1", xn, M(0, R(1, 2), R(1, 2)))

# 2013-2014 七
f = x1**2 + x2**2 - 2 * x1 - 4 * x2
ineq = [((-2, 1), -1), ((-1, -1), -2), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2013-2014 七", f, X2, ineq, [], (1, 1))
chk("2013 p0", p, M(-1, 1)); chk("2013 t̄", tb, 1); chk("2013 t0", tk, R(1, 2)); chk("2013 x1", xn, M(R(1, 2), R(3, 2)))

# 2014-2015 八
f = x1**2 - x1 * x2 + x2**2 - 2 * x1
ineq = [((-3, -1), -3), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2014-2015 八", f, X2, ineq, [], (R(2, 3), 0))
chk("2014 p0", p, M(1, 1)); chk("2014 t̄", tb, R(1, 4)); chk("2014 t0", tk, R(1, 4)); chk("2014 x1", xn, M(R(11, 12), R(1, 4)))

# 2015-2016 六(1)
f = x1**2 + 4 * x2**2 - x1 * x2
ineq = [((-2, -3), -5), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2015-2016 六(1)", f, X2, ineq, [((1, 1), 2)], (1, 1))
chk("2015 p0", p, M(1, -1)); chk("2015 t̄", tb, 1); chk("2015 t0", tk, R(1, 2)); chk("2015 x1", xn, M(R(3, 2), R(1, 2)))

# 2016-2017 七
f = 2 * x1**2 + x1 * x2 + 2 * x2**2
ineq = [((-2, -7), -10), ((-1, 3), -4), ((1, 2), 4), ((1, 0), 0)]
xn, p, tk, tb = step("2016-2017 七", f, X2, ineq, [], (4, 0))
chk("2016 p0", p, M(-1, R(1, 2))); chk("2016 t̄", tb, R(4, 3)); chk("2016 t0", tk, R(4, 3)); chk("2016 x1", xn, M(R(8, 3), R(2, 3)))
step("2016-2017 七 x1", f, X2, ineq, [], xn)

# 2017-2018 六(2)
f = x1**2 + 2 * x2**2 + x1 * x2 + 2 * x2
ineq = [((1, 3), 3), ((1, 0), 1)]
xn, p, tk, tb = step("2017-2018 六(2)", f, X2, ineq, [((1, 1), 2)], (1, 1))
chk("2017 p0", p, M(1, -1)); chk("2017 t̄", tb, R(1, 2)); chk("2017 t0", tk, R(1, 2)); chk("2017 x1", xn, M(R(3, 2), R(1, 2)))
step("2017-2018 六(2) x1", f, X2, ineq, [((1, 1), 2)], xn)

# 2018-2019 五，给定 p
f = (x1 + 3)**2 + (x2 - 2)**2 + x3**2
ineq = [((-2, -3, 2), 3), ((-1, -3, 1), -2), ((0, -2, 1), 0)]
xn, p, tk, tb = step("2018-2019 五", f, X3, ineq, [((2, 1, 4), 7)], (-1, 1, 2), p=(-2, 0, 1))
chk("2018 t̄=+∞", int(tb == sp.oo), 1); chk("2018 t0", tk, R(2, 5)); chk("2018 x1", xn, M(R(-9, 5), 1, R(12, 5)))

# 2019-2020 七，给定 p0
f = -sp.log(1 + x1) - 2 * sp.log(1 + x2)
ineq = [((1, -2), -4), ((-1, 1), -2), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2019-2020 七", f, X2, ineq, [], (4, 4), p=(1, R(1, 2)))
chk("2019 t̄", tb, 4); chk("2019 t0", tk, 4); chk("2019 x1", xn, M(8, 6))

# 2021-2022 八：LP 最优解不唯一，分别看 (1,0) 和 (1,1)
f = x1**2 + R(1, 2) * x2**2 - 8 * x1 - 2 * x2
ineq = [((-3, 2), 0), ((-3, -1), -9)]
xn, p, tk, tb = step("2021-2022 八 p=(1,0)", f, X2, ineq, [], (1, 2), p=(1, 0))
chk("2021 t̄", tb, R(1, 3)); chk("2021 t0", tk, R(1, 3)); chk("2021 x1", xn, M(R(4, 3), 2))
xn, p, tk, tb = step("2021-2022 八 p=(1,1)", f, X2, ineq, [], (1, 2), p=(1, 1))
chk("2021' t̄", tb, 1); chk("2021' t0", tk, 1); chk("2021' x1", xn, M(2, 3))

# 2022-2023 七（max 化成 min）
f = -sp.log(1 + x1) - sp.log(1 + x2)
ineq = [((-1, -2), -3), ((0, 1), 0)]
xn, p, tk, tb = step("2022-2023 七", f, X2, ineq, [], (1, 0))
chk("2022 p0", p, M(1, 1)); chk("2022 t̄", tb, R(2, 3)); chk("2022 t0", tk, R(2, 3)); chk("2022 x1", xn, M(R(5, 3), R(2, 3)))
xn, p, tk, tb = step("2022-2023 七 第 2 次", f, X2, ineq, [], xn)
chk("2022 p1", p, M(1, R(-1, 2))); chk("2022 t̄1", tb, R(4, 3)); chk("2022 t1", tk, R(1, 3)); chk("2022 x2", xn, M(2, R(1, 2)))

# 2023-2024 七
f = x2**2 - sp.log(1 + 2 * x1)
ineq = [((-2, -1), -6), ((1, 1), 4), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("2023-2024 七", f, X2, ineq, [], (R(1, 2), 5))
chk("2023 p0", p, M(R(1, 2), -1)); chk("2023 t̄", tb, 3); chk("2023 t0", tk, 3); chk("2023 x1", xn, M(2, 2))

# ---------- 预测题 ----------
# P1 教材习题 4.23
f = (x1 - 4)**2 + (x2 - 3)**2
ineq = [((1, -2), -4), ((-1, -2), -6), ((-1, 1), -2), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("P1 第 1 次", f, X2, ineq, [], (0, 2))
chk("P1 p0", p, M(1, R(1, 2))); chk("P1 t0", tk, 1); chk("P1 x1", xn, M(1, R(5, 2)))
xn, p, tk, tb = step("P1 第 2 次", f, X2, ineq, [], xn)
chk("P1 p1", p, M(1, R(-1, 2))); chk("P1 t̄1", tb, R(7, 3)); chk("P1 t1", tk, R(11, 5)); chk("P1 x2", xn, M(R(16, 5), R(7, 5)))
step("P1 x2", f, X2, ineq, [], xn)

# P2 教材习题 4.24
f = -sp.log(1 + x1) - 2 * sp.log(1 + x2)
ineq = [((-1, -1), -2), ((1, 0), 0), ((0, 1), 0)]
xn, p, tk, tb = step("P2 第 1 次", f, X2, ineq, [], (0, 0))
chk("P2 p0", p, M(1, 1)); chk("P2 t0", tk, 1); chk("P2 x1", xn, M(1, 1))
xn, p, tk, tb = step("P2 第 2 次", f, X2, ineq, [], xn)
chk("P2 p1", p, M(-1, 1)); chk("P2 t1", tk, R(2, 3)); chk("P2 x2", xn, M(R(1, 3), R(5, 3)))
step("P2 x2", f, X2, ineq, [], xn)

# P3 给定方向不是容许方向，改用 Z 法
f = (x1 - 1)**2 + x2**2 + (x3 - 2)**2
ineq = [((1, -1, 0), 0), ((1, 0, 0), 0), ((0, 1, 0), 0), ((0, 0, 1), 0)]
eq = [((1, 1, 1), 2)]
xn, p, tk, tb = step("P3 第 1 次", f, X3, ineq, eq, (1, 1, 0))
chk("P3 p0", p, M(0, -1, 1)); chk("P3 t̄0", tb, 1); chk("P3 t0", tk, 1); chk("P3 x1", xn, M(1, 0, 1))
xn, p, tk, tb = step("P3 第 2 次", f, X3, ineq, eq, xn)
chk("P3 p1", p, M(-1, 0, 1)); chk("P3 t̄1", tb, 1); chk("P3 t1", tk, R(1, 2)); chk("P3 x2", xn, M(R(1, 2), 0, R(3, 2)))
step("P3 x2", f, X3, ineq, eq, xn)

report()
