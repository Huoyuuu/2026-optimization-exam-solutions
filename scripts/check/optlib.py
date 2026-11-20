"""验算用的小工具库：精确有理数运算，按教材（张薇、薛嘉庆）的约定输出每一步。

每道题写一个 scripts/check/<题号>.py，调用这里的函数算出中间量，再用 expect() 和答卷里写的数比对。
运行：uv run scripts/check/<题号>.py；全部：uv run scripts/check/run_all.py
"""
from __future__ import annotations

import itertools
from fractions import Fraction

import sympy as sp

R = sp.Rational
FAILS: list[str] = []


# ---------- 比对 ----------
def _eq(a, b, tol):
    a, b = sp.sympify(a), sp.sympify(b)
    if isinstance(a, sp.MatrixBase) or isinstance(b, sp.MatrixBase):
        a, b = sp.Matrix(a), sp.Matrix(b)
        if a.shape != b.shape:
            if a.shape == b.T.shape:
                b = b.T
            else:
                return False
        return all(_eq(x, y, tol) for x, y in zip(a, b))
    d = sp.simplify(a - b)
    if d == 0:
        return True
    try:
        return abs(float(d)) <= tol
    except TypeError:
        return False


def expect(name, got, want, tol=1e-9):
    """got 是脚本算出来的，want 是答卷里写的。不一致就记下来，最后 report() 统一报。"""
    ok = _eq(got, want, tol)
    print(f"[{'OK' if ok else 'FAIL'}] {name}: 算得 {fmt(got)}，答卷 {fmt(want)}")
    if not ok:
        FAILS.append(name)
    return ok


def report():
    if FAILS:
        print(f"\n不一致 {len(FAILS)} 处：" + "、".join(FAILS))
        raise SystemExit(1)
    print("\n全部一致")


def fmt(x):
    if isinstance(x, sp.MatrixBase):
        if x.shape[1] == 1:
            return "(" + ", ".join(str(sp.nsimplify(v)) for v in x) + ")^T"
        return "[" + "; ".join(", ".join(str(v) for v in x.row(i)) for i in range(x.rows)) + "]"
    if isinstance(x, (list, tuple)):
        return "(" + ", ".join(fmt(v) for v in x) + ")"
    return str(x)


def vec(*xs):
    return sp.Matrix([sp.nsimplify(x) for x in xs])


# ---------- 微分 ----------
def symbols(n):
    return sp.symbols(f"x1:{n + 1}", real=True)


def grad(f, X):
    return sp.Matrix([sp.diff(f, v) for v in X])


def hess(f, X):
    return sp.hessian(f, X)


def at(expr, X, x):
    return expr.subs(dict(zip(X, list(x))))


def is_posdef(H):
    """顺序主子式全正。返回 (结论, 各阶主子式)"""
    minors = [sp.simplify(H[:k, :k].det()) for k in range(1, H.rows + 1)]
    return all(m > 0 for m in minors), minors


# ---------- 线性规划：单纯形表 ----------
class Tableau:
    """教材格式的单纯形表：行 = 各基变量，最后一行是判别数 σ 和 z̄。
    min c^T x, Ax = b (b >= 0)。判别数 σ_j = c_B^T B^-1 a_j - c_j，全部 <= 0 时最优。"""

    def __init__(self, A, b, c, basis, names=None):
        self.m, self.n = len(A), len(A[0])
        self.T = [[Fraction(v) for v in row] + [Fraction(bi)] for row, bi in zip(A, b)]
        self.T.append([-Fraction(v) for v in c] + [Fraction(0)])  # 准备表的 -c^T 行
        self.basis = list(basis)  # 下标从 0 开始
        self.names = names or [f"x{j + 1}" for j in range(self.n)]
        self.history = []
        self.show("准备表")
        for i, j in enumerate(self.basis):  # 基变量列化成单位向量，判别数行的基变量列消成 0
            self._pivot(i, j)
        self.show("初始表")

    def _pivot(self, r, k):
        p = self.T[r][k]
        self.T[r] = [v / p for v in self.T[r]]
        for i in range(len(self.T)):
            if i != r and self.T[i][k] != 0:
                f = self.T[i][k]
                self.T[i] = [a - f * b for a, b in zip(self.T[i], self.T[r])]
        self.basis[r] = k

    @property
    def sigma(self):
        return self.T[-1][:-1]

    @property
    def zbar(self):
        return self.T[-1][-1]

    def x(self):
        x = [Fraction(0)] * self.n
        for i, j in enumerate(self.basis):
            x[j] = self.T[i][-1]
        return x

    def show(self, title):
        snap = [row[:] for row in self.T]
        self.history.append((title, list(self.basis), snap))
        print(f"--- {title} ---")
        print("x_B\t" + "\t".join(self.names) + "\tb̄")
        for i, j in enumerate(self.basis):
            print(self.names[j] + "\t" + "\t".join(str(v) for v in self.T[i]))
        print("σ\t" + "\t".join(str(v) for v in self.T[-1]))

    def step(self, enter=None, row=None):
        """一次换基。enter 不给时取最大正判别数（同值取下标小的）。row 给定时强制在该行换基（人工变量出基用）。
        返回 'optimal' / 'unbounded' / (换入, 换出, 主元)"""
        sig = self.sigma
        if enter is None:
            mx = max(sig)
            if mx <= 0:
                return "optimal"
            enter = sig.index(mx)
        col = [self.T[i][enter] for i in range(self.m)]
        if row is None:
            ratios = [(self.T[i][-1] / col[i], i) for i in range(self.m) if col[i] > 0]
            if not ratios:
                return "unbounded"
            _, r = min(ratios)
            rat = {i: self.T[i][-1] / col[i] for i in range(self.m) if col[i] > 0}
        else:
            r, rat = row, {}
        leave = self.basis[r]
        piv = self.T[r][enter]
        self.history[-1] = self.history[-1] + ((r, enter, rat),)
        print(f"换入 {self.names[enter]}，换出 {self.names[leave]}，主元 {piv}（第 {r + 1} 行）")
        self._pivot(r, enter)
        self.show(f"换基后")
        return (self.names[enter], self.names[leave], piv)

    def solve(self, max_iter=20):
        for _ in range(max_iter):
            s = self.step()
            if s in ("optimal", "unbounded"):
                print("结论：", s)
                return s
        raise RuntimeError("迭代次数过多")

    def typst(self, names_typ=None, skip_prep=False):
        """把迭代过程写成 template.typ 里 stab(...) 的调用。names_typ：各列的 Typst 写法，默认 $x_1$ 等。"""
        nt = names_typ or [f"${n[0]}_{n[1:]}$" for n in self.names]
        hist = self.history[1:] if skip_prep else self.history
        out = ["#stab((" + ", ".join(nt) + ",),"]
        k = 0
        for idx, h in enumerate(hist):
            title, basis, snap = h[0], h[1], h[2]
            piv = h[3] if len(h) > 3 else None
            if title == "准备表":
                name = "准备表"
            elif title == "初始表":
                name = "初始表"
            elif idx == len(hist) - 1:
                name = "最终表"
            else:
                k += 1
                name = f"第 {k} 表"
            out.append(f"  [{name}], (")
            for i, j in enumerate(basis):
                cells = [tnum(v) for v in snap[i]]
                if piv and piv[0] == i:
                    cells[piv[1]] = f"pv({tnum(snap[i][piv[1]], dollar=True)})"
                ratio = tnum(piv[2][i]) if piv and i in piv[2] else "[]"
                out.append(f"    ({nt[j]}, " + ", ".join(cells) + f", {ratio}),")
            lab = "$-c^T$" if title == "准备表" else "$sigma^T$"
            out.append(f"    ({lab}, " + ", ".join(tnum(v) for v in snap[-1]) + "),")
            out.append("  ),")
        out.append(")")
        return "\n".join(out)


def tnum(v, dollar=False):
    """Fraction → Typst：整数原样，分数写成 $-3/2$"""
    v = Fraction(v)
    if v.denominator == 1:
        return f"${v.numerator}$" if dollar else str(v.numerator)
    s = "-" if v < 0 else ""
    return f"${s}{abs(v.numerator)}/{v.denominator}$"


def two_phase(A, b, c, names, unit_rows=None):
    """两阶段法（教材格式）。A x = b 已是标准形且 b >= 0。
    unit_rows：{行号: 列号}，这些行已有现成单位列（如松弛变量），其余行加人工变量 u_i（列放在最前）。
    返回 (第一阶段表, 第二阶段表或 None)。"""
    m, n = len(A), len(A[0])
    unit_rows = unit_rows or {}
    art = [i for i in range(m) if i not in unit_rows]
    un = [f"u{i + 1}" for i in art]
    A1 = [[1 if r == i else 0 for i in art] + list(A[r]) for r in range(m)]
    c1 = [1] * len(art) + [0] * n
    basis = [art.index(r) if r in art else len(art) + unit_rows[r] for r in range(m)]
    print("===== 第一阶段 =====")
    T1 = Tableau(A1, b, c1, basis, names=un + list(names))
    T1.solve()
    if T1.zbar != 0:
        print("w > 0，原问题无容许解")
        return T1, None
    # 人工变量还在基中：在该行任选原变量的非零系数作主元换出
    for r, j in enumerate(list(T1.basis)):
        if j < len(art):
            nz = [k for k in range(len(art), len(art) + n) if T1.T[r][k] != 0]
            if nz:
                T1.step(enter=nz[0], row=r)
            else:
                print(f"第 {r + 1} 行多余，删去")
    rows = [(r, j) for r, j in enumerate(T1.basis) if j >= len(art)]
    A2 = [T1.T[r][len(art):-1] for r, _ in rows]
    b2 = [T1.T[r][-1] for r, _ in rows]
    print("===== 第二阶段 =====")
    T2 = Tableau(A2, b2, c, [j - len(art) for _, j in rows], names=list(names))
    T2.solve()
    print("x* =", [str(v) for v in T2.x()], " z* =", T2.zbar)
    return T1, T2


# ---------- 一维搜索 ----------
def exact_step(f, X, x, p):
    """精确线搜索：t* = argmin_{t>0} f(x + t p)。返回 (t*, phi(t))"""
    t = sp.symbols("t", real=True)
    phi = sp.expand(f.subs(dict(zip(X, list(sp.Matrix(x) + t * sp.Matrix(p))))))
    crit = [r for r in sp.solve(sp.diff(phi, t), t) if r.is_real and r > 0]
    if not crit:
        raise ValueError("没有正的驻点")
    best = min(crit, key=lambda r: phi.subs(t, r))
    return sp.nsimplify(best), phi


def quad_step(g, p, G):
    """二次函数的精确步长 t = -g^T p / (p^T G p)"""
    return sp.nsimplify((-(g.T * p)[0]) / ((p.T * G * p)[0]))


def golden(phi, a, b, eps, n=None):
    """0.618 法：返回每步 (a, b, λ, μ, φ(λ), φ(μ))，λ = a + 0.382(b-a)，μ = a + 0.618(b-a)"""
    rows = []
    lam, mu = a + 0.382 * (b - a), a + 0.618 * (b - a)
    k = 0
    while (b - a) > eps and (n is None or k < n):
        fl, fm = phi(lam), phi(mu)
        rows.append((a, b, lam, mu, fl, fm))
        if fl > fm:
            a, lam = lam, mu
            mu = a + 0.618 * (b - a)
        else:
            b, mu = mu, lam
            lam = a + 0.382 * (b - a)
        k += 1
    rows.append((a, b, lam, mu, None, None))
    return rows


# ---------- 无约束迭代 ----------
def _it(name, k, **kw):
    print(f"[{name}] k={k}: " + "，".join(f"{a}={fmt(b)}" for a, b in kw.items()))


def steepest(f, X, x0, iters):
    x = sp.Matrix(x0)
    g_ = grad(f, X)
    out = [x]
    for k in range(iters):
        g = at(g_, X, x)
        if g.norm() == 0:
            break
        p = -g
        t, _ = exact_step(f, X, x, p)
        x = x + t * p
        _it("最速下降", k, g=g, p=p, t=t, x_next=x)
        out.append(x)
    return out


def newton(f, X, x0, iters):
    x = sp.Matrix(x0)
    g_, G_ = grad(f, X), hess(f, X)
    out = [x]
    for k in range(iters):
        g, G = at(g_, X, x), at(G_, X, x)
        if g.norm() == 0:
            break
        p = -G.inv() * g
        x = sp.simplify(x + p)
        _it("Newton", k, g=g, G=G, p=p, x_next=x)
        out.append(x)
    return out


def fr(f, X, x0, iters=None):
    """FR 共轭梯度：p0=-g0，β_k = |g_{k+1}|^2/|g_k|^2，精确步长。"""
    x = sp.Matrix(x0)
    g_ = grad(f, X)
    g = at(g_, X, x)
    p = -g
    out = [x]
    for k in range(iters or len(X)):
        if g.norm() == 0:
            break
        t, _ = exact_step(f, X, x, p)
        x = x + t * p
        g1 = at(g_, X, x)
        beta = sp.nsimplify((g1.T * g1)[0] / (g.T * g)[0]) if g1.norm() != 0 else 0
        _it("FR", k, g=g, p=p, t=t, x_next=x, g_next=g1, beta=beta)
        p = -g1 + beta * p
        g = g1
        out.append(x)
    return out


def quasi_newton(f, X, x0, iters=None, H0=None, kind="DFP"):
    """DFP / BFGS（H 形式，近似 Hesse 逆），精确步长。s = x_{k+1}-x_k，y = g_{k+1}-g_k。"""
    n = len(X)
    x = sp.Matrix(x0)
    H = sp.Matrix(H0) if H0 is not None else sp.eye(n)
    g_ = grad(f, X)
    g = at(g_, X, x)
    out = [x]
    for k in range(iters or n):
        if g.norm() == 0:
            break
        p = -H * g
        t, _ = exact_step(f, X, x, p)
        x1 = x + t * p
        g1 = at(g_, X, x1)
        s, y = x1 - x, g1 - g
        sy = (s.T * y)[0]
        Hy = H * y
        yHy = (y.T * Hy)[0]
        if kind == "DFP":
            H1 = H + s * s.T / sy - Hy * Hy.T / yHy
        else:
            H1 = H + (1 + yHy / sy) * s * s.T / sy - (s * Hy.T + Hy * s.T) / sy
        H1 = sp.simplify(H1)
        _it(kind, k, g=g, p=p, t=t, x_next=x1, g_next=g1, s=s, y=y, Hy=Hy, H_next=H1)
        x, g, H = x1, g1, H1
        out.append(x)
    return out


# ---------- 约束问题 ----------
def kkt_points(f, ineq, eq, X):
    """教材约定待定：这里按 min f，s_i(x) >= 0，h_j(x) = 0。
    K-T 条件：∇f - Σ μ_i ∇s_i - Σ λ_j ∇h_j = 0，μ_i >= 0，μ_i s_i = 0。
    枚举起作用集，返回所有 K-T 点 [(x, μ, λ)]。"""
    ms = sp.symbols(f"mu1:{len(ineq) + 1}", real=True)
    ls = sp.symbols(f"lam1:{len(eq) + 1}", real=True)
    L = f - sum(m * s for m, s in zip(ms, ineq)) - sum(l * h for l, h in zip(ls, eq))
    res = []
    for r in range(len(ineq) + 1):
        for act in itertools.combinations(range(len(ineq)), r):
            eqs = [sp.diff(L, v) for v in X] + [ineq[i] for i in act] + list(eq)
            eqs += [ms[i] for i in range(len(ineq)) if i not in act]
            unknowns = list(X) + list(ms) + list(ls)
            for sol in sp.solve(eqs, unknowns, dict=True):
                if any(not v.is_real for v in sol.values()):
                    continue
                xv = [sol.get(v, v) for v in X]
                if any(e.free_symbols for e in xv):
                    continue
                mv = [sol.get(m, 0) for m in ms]
                if all(m >= 0 for m in mv) and all(s.subs(dict(zip(X, xv))) >= 0 for s in ineq):
                    res.append((tuple(xv), tuple(mv), tuple(sol.get(l, 0) for l in ls)))
    return list(dict.fromkeys(res))
