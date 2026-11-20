"""约束问题最优性条件真题验算（教材 4.1 节：min f，s(x) >= 0，h(x) = 0；
K-T 条件 ∇f - Σμ_i∇s_i - Σλ_j∇h_j = 0，μ_i s_i = 0，μ_i >= 0）。运行：uv run scripts/check/kkt.py"""
import sys
from pathlib import Path

import sympy as sp

sys.path.insert(0, str(Path(__file__).parent))
from optlib import kkt_points  # noqa: E402

x1, x2, x3, t = sp.symbols("x1 x2 x3 t", real=True)
X2, X3 = (x1, x2), (x1, x2, x3)
R = sp.Rational


def grad(e, X):
    return sp.Matrix([sp.diff(e, v) for v in X])


def direction(name, f, ineq, eq, X, x0, ps):
    """ineq 写成 s >= 0，eq 写成 h = 0。线性约束 a^T p >= 0 充要；非线性起作用约束 > 0 充分，= 0 时看 s(x0 + t p)。"""
    print(f"\n===== {name}")
    sub = dict(zip(X, x0))
    for j, h in enumerate(eq):
        print(f"  h{j + 1}(x0) = {h.subs(sub)}")
    act = []
    for i, s in enumerate(ineq):
        v = s.subs(sub)
        lin = all(sp.diff(s, a, b) == 0 for a in X for b in X)
        print(f"  s{i + 1}(x0) = {v} {'起作用' if v == 0 else ''} {'线性' if lin else '非线性'} ∇s = {list(grad(s, X).subs(sub))}")
        if v == 0:
            act.append((i, s, lin))
    gf = grad(f, X).subs(sub) if f is not None else None
    for k, p in enumerate(ps):
        p = sp.Matrix(p)
        out = []
        for j, h in enumerate(eq):
            out.append(f"∇h{j + 1}ᵀp={(grad(h, X).subs(sub).T * p)[0]}")
        for i, s, lin in act:
            d = (grad(s, X).subs(sub).T * p)[0]
            extra = ""
            if d == 0 and not lin:
                extra = f"（s(x0+tp)={sp.expand(s.subs(dict(zip(X, list(sp.Matrix(x0) + t * p)))))}）"
            out.append(f"∇s{i + 1}ᵀp={d}{extra}")
        if gf is not None:
            out.append(f"∇fᵀp={(gf.T * p)[0]}（∇f={list(gf)}）")
        print(f"  p{k + 1}={list(p)}: " + "，".join(out))


def kkt(name, f, ineq, eq, X):
    print(f"\n===== {name}: f = {f}")
    for x, mu, lam in kkt_points(f, ineq, eq, X):
        print(f"  K-T 点 x={x} μ={mu} λ={lam} f={sp.simplify(f.subs(dict(zip(X, x))))}")


# 容许方向
direction("2009 八", None, [-2 * x1 + 5 * x2 - 4, 2 - x1 - x3, x1, x2, x3], [x1 + 2 * x2 - x3 - 6], X3, (2, 2, 0), [(1, 0, 1)])
direction("2013 二(2)", None, [10 + 3 * x1 - 10 * x2 - 6 * x3, 6 * x1 - x2 + 4 * x3 - 15], [x1 + x2 + x3 - 4], X3, (2, 1, 1), [(1, 1, -2)])
direction("2019 六", 3 * x1**2 - x2**2 - 2 * x3**2, [3 - x1**2 - x2**2 - x3**2, -x1 + 2 * x2], [-x1 + x2 + 3 * x3 - 3], X3, (1, 1, 1), [(-2, 1, -1)])
direction("2020 二(1)", x1**2 + 3 * x2**2 + 2 * x3**2,
          [2 * x1 + 2 * x2 - 3 * x3 - 1, -x1 + 3 * x2 - x3, 5 - 2 * x1**2 + 3 * x2**2 - x3, x2**2 + 3 * x3**2 - 4],
          [x1 + x2 + x3 - 3], X3, (1, 1, 1), [(0, 1, -1)])
direction("2024A 六", x1**2 + 3 * x2**2 - 5 * x3**2 + 1,
          [x1 - x1**2 - x2**2, x1 - 2 * x2 + 3 * x3, -x1 - 3 * x2 + x3, -2 * x1 + 5 * x2 + 3 * x3 - 1],
          [x1 + 2 * x2 + x3 - 2], X3, (1, 0, 1), [(0, -1, 2), (-1, 1, 2)])
direction("2024B 六", x1**2 - 2 * x2**2 + 3 * x3**2,
          [5 + x1**2 - 2 * x2**2 - 3 * x3, x1 - 2 * x2 + 3 * x3, 4 * x1 + 3 * x2 - 2 * x3 - 1, 5 * x1 + x2 - x3],
          [3 * x1 + x2 + 4 * x3 - 5], X3, (0, 1, 1), [(3, -1, -2), (-1, -1, 1)])
direction("P1", x1 + 2 * x2 + 3 * x3, [3 - x1**2 - x2**2 - x3**2, x1 - x2], [x1 + x2 - 2 * x3], X3, (1, 1, 1),
          [(1, -1, 0), (-1, -3, -2)])
# 2017 六(1)：x̄ 满足等式，起作用的是 x2 >= 0、x4 >= 0
x4 = sp.symbols("x4", real=True)
p1, p2, p3, p4 = sp.symbols("p1:5", real=True)
C = sp.Matrix([[1, -2, 1, 3], [3, 5, -4, -2]])
print("\n===== 2017 六(1)：C x̄ =", list(C * sp.Matrix([R(24, 7), 0, R(11, 7), 0])))
print("  Cp = 0 解出：", sp.solve(list(C * sp.Matrix([p1, p2, p3, p4])), [p1, p3]))

# K-T 点
kkt("2009 九", sp.exp(-x1) + sp.exp(-x2), [1 - x1 - x2], [], X2)
kkt("2010 六", sp.log(x1) - x2, [x1 - x2**2 - 1], [], X2)
g10 = sp.log(1 + x2**2) - x2
print("  2010 沿边界 x1 = 1 + x2²：f =", g10, " 导数 =", sp.factor(sp.diff(g10, x2)), " x2→∞ 极限", sp.limit(g10, x2, sp.oo))
kkt("2011 八", x1 + x2 - x3, [1 - x1**2 - x2**2 - x3**2], [x1 - x2], X3)
kkt("2013 六(1)", -sp.log(1 + x1) - 2 * sp.log(1 + x2), [2 - x1 - x2], [], X2)
kkt("2014 九", x1**2 - x2, [x1 - 1], [x1 + x2 - 6], X2)
kkt("2016 六(1)", -x1 + x2, [1 - x1**2 - x2**2], [x1 + x2 - 1], X2)
kkt("2017 七(1)", 3 * x1**2 + x2**2 + 2 * x3**2, [-x1 + x2 - 1], [], X3)
kkt("2020 八", (x1 - 1) ** 2 + (x2 - 2) ** 2, [1 - 2 * x1 - x2, x2], [], X2)
kkt("2021 一", (1 - x1) ** 2 + x2**2, [1 + x1 - x2, x1 + x2 - 3], [], X2)
kkt("2022 五", (x1 - 3) ** 2 + (x2 - 1) ** 2, [1 - x1**2 - x2**2], [], X2)
kkt("2023 六(1)", x1**2 + 4 * x2**2, [-1 - x1 + x2], [], X2)
kkt("2024A 七", (x1 - 4) ** 2 + (x2 - 3) ** 2, [1 - x1**2 - x2**2], [], X2)
kkt("2024B 七", (x1 - 2) ** 2 + (x2 - 4) ** 2, [5 - x1**2 - x2**2], [], X2)
kkt("2020 一(2)（min -f）", -((x1 - 1) ** 2 + x2**2 + (x3 + 1) ** 2), [], [x1 + x2 + x3 - 2], X3)
kkt("P2", (x1 - 4) ** 2 + (x2 - 3) ** 2, [4 - x1 - 2 * x2, 5 - 2 * x1 - x2], [], X2)
kkt("P3（min -f）", -(x1 * x2 + x2 * x3 + x3 * x1), [], [x1 + x2 + x3 - 3], X3)

# 2015 十：检查两个给定点
f15, s1, s2 = x1, 16 - (x1 - 4) ** 2 - x2**2, (x1 - 3) ** 2 + (x2 - 2) ** 2 - 13
for pt in [(0, 0), (3, 2 - sp.sqrt(13))]:
    sub = dict(zip(X2, pt))
    print(f"\n===== 2015 十 点 {pt}: s1={sp.simplify(s1.subs(sub))} s2={sp.simplify(s2.subs(sub))} "
          f"∇s1={list(grad(s1, X2).subs(sub))} ∇s2={[sp.simplify(v) for v in grad(s2, X2).subs(sub)]}")
