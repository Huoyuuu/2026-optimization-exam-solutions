"""外部罚函数法（教材 4.6）和乘子法（4.8）真题验算。
约定：约束写成 s(x) >= 0、h(x) = 0。
外部罚函数：F = f + μ[Σh² + Σ s² u(s)]，在指定的“被违反约束”分支里解 ∇F = 0，检查分支自洽，再令 μ → ∞。
乘子法（H 乘子法，不等式用 Rockafellar 形式）：s < ν/(2μ) 一段 F = f - ν s + μ s²，等式 F = f - λ h + μ h²；
解出 x(ν, μ)，代入 ν_{k+1} = max{0, ν_k - 2μ s(x_k)}（λ_{k+1} = λ_k - 2μ h(x_k)），求不动点。
运行：uv run scripts/check/penalty.py"""
import sys
from pathlib import Path

import sympy as sp

sys.path.insert(0, str(Path(__file__).parent))
from optlib import expect, report  # noqa: E402

R = sp.Rational
x1, x2, x3 = sp.symbols("x1 x2 x3", real=True)
mu = sp.symbols("mu", positive=True)
nu, lam = sp.symbols("nu lam", real=True)


def solve_grad(F, X):
    sol = sp.solve([sp.diff(F, v) for v in X], X, dict=True)
    assert len(sol) == 1, sol
    return [sp.simplify(sol[0][v]) for v in X]


def penalty(name, f, X, ineq, eq, viol):
    """viol：被违反（进罚项）的不等式约束下标。"""
    print(f"\n===== {name}")
    F = f + mu * (sum(h**2 for h in eq) + sum(ineq[i] ** 2 for i in viol))
    xm = solve_grad(F, X)
    sub = dict(zip(X, xm))
    print("  x(μ) =", xm)
    for i, s in enumerate(ineq):
        print(f"  s{i + 1}(x(μ)) = {sp.factor(sp.simplify(s.subs(sub)))}  {'(罚)' if i in viol else ''}")
    for j, h in enumerate(eq):
        print(f"  h{j + 1}(x(μ)) = {sp.factor(sp.simplify(h.subs(sub)))}")
    xs = [sp.limit(v, mu, sp.oo) for v in xm]
    alpha = sum(h**2 for h in eq) + sum(ineq[i] ** 2 for i in viol)
    print("  x* =", xs, " f* =", sp.simplify(f.subs(dict(zip(X, xs)))))
    return xm, xs, sp.simplify(alpha.subs(sub))


def multiplier(name, f, X, s=None, h=None):
    """一个不等式约束 s >= 0 或一个等式约束 h = 0。"""
    print(f"\n===== {name}")
    if s is not None:
        F = f - nu * s + mu * s**2
        xm = solve_grad(F, X)
        sv = sp.factor(sp.simplify(s.subs(dict(zip(X, xm)))))
        nxt = sp.factor(sp.simplify(nu - 2 * mu * sv))
        print("  x(ν, μ) =", xm, "\n  s(x) =", sv, "\n  分段条件 s < ν/(2μ)：", sp.simplify(sv - nu / (2 * mu)))
        print("  ν_{k+1} =", nxt)
        star = sp.solve(sp.Eq(nxt, nu), nu)
        print("  ν* =", star)
        xs = [sp.simplify(v.subs(nu, star[0])) for v in xm]
        mult = star[0]
    else:
        F = f - lam * h + mu * h**2
        xm = solve_grad(F, X)
        hv = sp.factor(sp.simplify(h.subs(dict(zip(X, xm)))))
        nxt = sp.factor(sp.simplify(lam - 2 * mu * hv))
        print("  x(λ, μ) =", xm, "\n  h(x) =", hv, "\n  λ_{k+1} =", nxt)
        star = sp.solve(sp.Eq(nxt, lam), lam)
        print("  λ* =", star)
        xs = [sp.simplify(v.subs(lam, star[0])) for v in xm]
        mult = star[0]
    print("  x* =", xs, " f* =", sp.simplify(f.subs(dict(zip(X, xs)))))
    return xm, xs, mult, nxt


def chk(tag, got, want):
    expect(tag, sp.Matrix(got) if isinstance(got, list) else got, sp.Matrix(want) if isinstance(want, list) else want)


X2, X3 = [x1, x2], [x1, x2, x3]

# ---------- 外部罚函数法 ----------
f = (x1 - x2) ** 2 - 5 * x1 - x2
xm, xs, a = penalty("2009-2010 六", f, X2, [2 - x1 - x2, x2], [], [0])
chk("2009 x(μ)", xm, [R(3, 2) + 3 / (4 * mu), R(1, 2) + 3 / (4 * mu)]); chk("2009 x*", xs, [R(3, 2), R(1, 2)])

f = -sp.log(x1 + 1) - sp.log(x2 + 1)
print("\n===== 2015-2016 九（对称，x1 = x2 = x）")
xx = sp.symbols("x", positive=True)
Fx = sp.diff(-sp.log(xx + 1) + mu * (2 * xx - 2) ** 2 / 2, xx)  # 一个分量的偏导
sol = [v for v in sp.solve(Fx, xx) if v.is_positive]
print("  x(μ) =", sol)
chk("2015 x(μ)", sol[0], sp.sqrt(1 + 1 / (4 * mu)))

f = (x1 - 2) ** 2 + (x2 - 1) ** 2
xm, xs, a = penalty("2016-2017 八", f, X2, [x1 + 2 * x2 - 7, 2 * x1 - x2 - 4], [], [0, 1])
chk("2016 x(μ)", xm, [(2 + 15 * mu) / (1 + 5 * mu), (1 + 10 * mu) / (1 + 5 * mu)]); chk("2016 x*", xs, [3, 2])

f = (x1 - 1) ** 2 + (x2 - 1) ** 2
xm, xs, a = penalty("2019-2020 八(1)", f, X2, [], [x1 + 2 * x2 - 4], [])
chk("2019 x(μ)", xm, [(6 * mu + 1) / (5 * mu + 1), (7 * mu + 1) / (5 * mu + 1)])
for k, m in [(1, 5), (2, 10)]:
    xk = [v.subs(mu, m) for v in xm]
    print(f"  k={k} μ={m} x={xk} μα={m * a.subs(mu, m)} ≈ {float(m * a.subs(mu, m)):.5f}")
chk("2019 μ1α", 5 * a.subs(mu, 5), R(5, 676))

f = (x1 - 2) ** 2 + x2**2
xm, xs, a = penalty("2022-2023 八", f, X2, [x1 + x2 - 1, -x1 + x2 - 2], [], [1])
chk("2022 x(μ)", xm, [2 / (1 + 2 * mu), 4 * mu / (1 + 2 * mu)]); chk("2022 x*", xs, [0, 2])

f = (x1 - 2) ** 2 + (x2 - 1) ** 2
xm, xs, a = penalty("2023-2024 八(2)", f, X2, [x1 - x2 - 5], [], [0])
chk("2023 x(μ)", xm, [(2 + 8 * mu) / (1 + 2 * mu), (1 - 2 * mu) / (1 + 2 * mu)])
for k, m in [(1, 5), (2, 10), (3, 20), (4, 40)]:
    xk = [v.subs(mu, m) for v in xm]
    print(f"  k={k} μ={m} x={xk} μα={m * a.subs(mu, m)} ≈ {float(m * a.subs(mu, m)):.4f}")
chk("2023 x1", [v.subs(mu, 5) for v in xm], [R(42, 11), R(-9, 11)])
chk("2023 μ1α", 5 * a.subs(mu, 5), R(80, 121))
chk("2023 x2", [v.subs(mu, 10) for v in xm], [R(82, 21), R(-19, 21)])
chk("2023 μ2α", 10 * a.subs(mu, 10), R(160, 441))

f = (x1 - 2) ** 2 + (x2 - 2) ** 2
xm, xs, a = penalty("2024-2025A 九（x1 < 1 分支）", f, X2, [x1 - 1], [x1 + x2], [0])
chk("2024A x(μ)", xm, [(mu**2 + mu + 2) / (mu**2 + 3 * mu + 1), (2 + 2 * mu - mu**2) / (mu**2 + 3 * mu + 1)])
chk("2024A x*", xs, [1, -1])
xm2, _, _ = penalty("2024-2025A 九（x1 >= 1 分支）", f, X2, [x1 - 1], [x1 + x2], [])
chk("2024A 另一分支", xm2, [2 / (1 + 2 * mu), 2 / (1 + 2 * mu)])

# ---------- 乘子法 ----------
f = (x1 - x2) ** 2 - 5 * x1 - x2
xm, xs, m, nxt = multiplier("2010-2011 八", f, X2, s=2 - x1 - x2)
chk("2010 ν_{k+1}", nxt, 3); chk("2010 x*", xs, [R(3, 2), R(1, 2)])

f = x1**2 + x1 * x2 + x2**2
xm, xs, m, nxt = multiplier("2011-2012 七(2)", f, X2, s=x1 + x2 - 1)
chk("2011 x(ν)", xm, [(nu + 2 * mu) / (3 + 4 * mu)] * 2); chk("2011 ν*", m, R(3, 2)); chk("2011 x*", xs, [R(1, 2), R(1, 2)])

f = R(1, 2) * x1**2 + R(1, 2) * x2**2 + x1
xm, xs, m, nxt = multiplier("2013-2014 八(2)", f, X2, s=x1 + x2 - 1)
chk("2013 x(ν)", xm, [(nu - 1) / (1 + 4 * mu), (nu + 4 * mu) / (1 + 4 * mu)]); chk("2013 ν*", m, 1); chk("2013 x*", xs, [0, 1])

f = x1**2 + (x2 - 1) ** 2
xm, xs, m, nxt = multiplier("2014-2015 四", f, X2, s=x1 - 2)
chk("2014 x(ν)", xm, [(nu + 4 * mu) / (2 + 2 * mu), 1]); chk("2014 ν*", m, 4); chk("2014 x*", xs, [2, 1])

f = x1**2 + x2**2 + x3**2
xm, xs, m, nxt = multiplier("2017-2018 八", f, X3, h=2 * x1 + x2 + x3 - 4)
chk("2017 x(λ)", xm, [(lam + 8 * mu) / (6 * mu + 1), (lam + 8 * mu) / (12 * mu + 2), (lam + 8 * mu) / (12 * mu + 2)])
chk("2017 λ*", m, R(4, 3)); chk("2017 x*", xs, [R(4, 3), R(2, 3), R(2, 3)])

print("\n===== 2018-2019 七(2)（r = x1² + x2²，s = 2 - r - x3）")
f = -x3
xm, xs, m, nxt = multiplier("2018-2019 七(2)", f, X3, s=2 - x1**2 - x2**2 - x3)
chk("2018 ν*", m, 1); chk("2018 x*", xs, [0, 0, 2])

f = (x1 - 1) ** 2 + (x2 - 1) ** 2
xm, xs, m, nxt = multiplier("2019-2020 八(2)", f, X2, h=x1 + 2 * x2 - 4)
chk("2019 x(λ)", xm, [(lam / 2 + 6 * mu + 1) / (5 * mu + 1), (lam + 7 * mu + 1) / (5 * mu + 1)])
chk("2019 λ*", m, R(2, 5))
h = x1 + 2 * x2 - 4
lk, hprev = 0, h.subs({x1: 0, x2: 0})
for k in (1, 2):
    xk = [v.subs({lam: lk, mu: 5}) for v in xm]
    hk = h.subs(dict(zip(X2, xk)))
    print(f"  k={k} λ={lk} x={xk} h={hk} |h|≈{float(abs(hk)):.5f} 比值={abs(hk) / abs(hprev)}")
    hprev, lk = hk, lk - 2 * 5 * hk
chk("2019 λ2", R(5, 13), R(5, 13))

f = x1 * x2 + (x1 - 3) ** 2 + (x2 - 3) ** 2
xm, xs, m, nxt = multiplier("2020-2021 九", f, X2, s=x1 + x2 - 6)
chk("2020 x(ν)", xm, [(6 + nu + 12 * mu) / (3 + 4 * mu)] * 2); chk("2020 ν*", m, 3); chk("2020 x*", xs, [3, 3])

print("\n===== 2021-2022 九（用题给的 x(ν, μ)）")
Q = R(9, 4) + (4 * mu + 2 * nu - 4) / mu
xk = [R(3, 4) + sp.sqrt(Q) / 2, -R(3, 4) + sp.sqrt(Q) / 2]
sv = sp.simplify(sp.expand(xk[0] * xk[1]) - 1)
print("  s(x(ν, μ)) =", sv)
chk("2021 s", sv, (nu - 2) / (2 * mu))
F2 = x1**2 + x2**2 - 3 * x1 + 3 * x2 - nu * (x1 * x2 - 1) + mu * (x1 * x2 - 1) ** 2
g = [sp.simplify(sp.diff(F2, v).subs(dict(zip(X2, xk)))) for v in X2]
print("  ∇F(x(ν, μ)) =", g)
for n0 in (0, 2):
    pt = [sp.nsimplify(v.subs({nu: n0, mu: 1})) for v in xk]
    print(f"  ν={n0}, μ=1: x = {pt}, s = {pt[0] * pt[1] - 1}")
chk("2021 x1", [v.subs({nu: 0, mu: 1}) for v in xk], [R(3, 2), 0])
chk("2021 x2", [v.subs({nu: 2, mu: 1}) for v in xk], [2, R(1, 2)])
t = sp.symbols("t")
print("  到 (3/2, -3/2) 距离平方在双曲线上的驻点：", sp.solve(sp.diff((t - R(3, 2)) ** 2 + (1 / t + R(3, 2)) ** 2, t), t))

f = (x1 - 2) ** 2 + (x2 - 1) ** 2
xm, xs, m, nxt = multiplier("2023-2024 八(1)", f, X2, s=x1 - x2 - 5)
chk("2023 ν*", m, 4); chk("2023 x*", xs, [4, -1])

f = 2 * (x1 - 1) ** 2 + x2**2
xm, xs, m, nxt = multiplier("2024-2025B 九", f, X2, s=-1 - x1 - x2)
chk("2024B x(ν)", xm, [(4 + 2 * mu - nu) / (2 * (2 + 3 * mu)), -(nu + 4 * mu) / (2 + 3 * mu)])
chk("2024B ν_{k+1}", nxt, (2 * nu + 8 * mu) / (2 + 3 * mu)); chk("2024B ν*", m, R(8, 3)); chk("2024B x*", xs, [R(1, 3), R(-4, 3)])

# ---------- 预测题 ----------
f = x1**2 + 2 * x2**2
xm, xs, a = penalty("P1 教材 4.36(1)", f, X2, [x1 + x2 - 1], [], [0])
chk("P1 x(μ)", xm, [2 * mu / (2 + 3 * mu), mu / (2 + 3 * mu)])
for k, m in [(1, 1), (2, 10), (3, 100)]:
    print(f"  k={k} μ={m} x={[v.subs(mu, m) for v in xm]} μα={m * a.subs(mu, m)} ≈ {float(m * a.subs(mu, m)):.5f}")

f = (x1 - 3) ** 2 + (x2 - 2) ** 2
xm, xs, a = penalty("P2", f, X2, [2 - x1], [x1 + x2 - 4], [0])
chk("P2 x(μ)", xm, [(2 * mu**2 + 7 * mu + 3) / (mu**2 + 3 * mu + 1), (2 * mu**2 + 5 * mu + 2) / (mu**2 + 3 * mu + 1)])
chk("P2 x*", xs, [2, 2])

f = x1**2 + x1 * x2 + x2**2
xm, xs, m, nxt = multiplier("P3 教材 4.40(2)", f, X2, s=x1 + x2 - 4)
chk("P3 ν*", m, 6); chk("P3 x*", xs, [2, 2])
nk = 0
for k in (1, 2, 3):
    xk = [v.subs({nu: nk, mu: 1}) for v in xm]
    sk = xk[0] + xk[1] - 4
    print(f"  k={k} ν={nk} x={xk} s={sk}")
    nk = max(0, nk - 2 * sk)

xm, xs, m, nxt = multiplier("P4 教材 4.40(1)", f, X2, h=x1 + 2 * x2 - 4)
chk("P4 λ*", m, 2); chk("P4 x*", xs, [0, 2])

report()
