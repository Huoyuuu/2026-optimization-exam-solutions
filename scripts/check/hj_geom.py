"""步长加速法图上作业的公用部分：
- smooth_ring：过手读的点画光滑闭曲线（周期 Catmull-Rom）；
- RingField：按“第几圈”给平面上的点估函数值（中心 0，第 k 圈上为 k，圈间按距离线性插值）；
- run：教材算法 3.11 的Ⅰ型、Ⅱ型探测和模式移动（整数格点，步长 1），到需要缩小步长为止；
- text / figure：生成答卷过程（Typst）和 cetz 图。"""
import numpy as np


def smooth_ring(pts, per=24):
    P = np.asarray(pts, float)
    n = len(P)
    out = []
    for i in range(n):
        p0, p1, p2, p3 = P[i - 1], P[i], P[(i + 1) % n], P[(i + 2) % n]
        for t in np.linspace(0, 1, per, endpoint=False):
            t2, t3 = t * t, t * t * t
            out.append(0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
                              + (-p0 + 3 * p1 - 3 * p2 + p3) * t3))
    return np.array(out)


def inside(poly, p):
    x, y = p
    xs, ys = poly[:, 0], poly[:, 1]
    xj, yj = np.roll(xs, 1), np.roll(ys, 1)
    c = ((ys > y) != (yj > y)) & (x < (xj - xs) * (y - ys) / (yj - ys + 1e-12) + xs)
    return bool(np.count_nonzero(c) % 2)


def dist(poly, p):
    a, b = poly, np.roll(poly, -1, 0)
    ab = b - a
    t = np.clip(((p - a) * ab).sum(1) / ((ab * ab).sum(1) + 1e-12), 0, 1)
    return float(np.min(np.hypot(*(a + t[:, None] * ab - p).T)))


class RingField:
    def __init__(self, rings, center):
        self.rings = [smooth_ring(r) for r in rings]
        self.c = np.asarray(center, float)

    def __call__(self, p):
        p = np.asarray(p, float)
        R = self.rings
        k = next((i for i, r in enumerate(R) if inside(r, p)), len(R))  # 在第 k 圈（0 起）之内
        if k == len(R):  # 最外圈之外：按最外两圈的间距外推
            d = dist(R[-1], p)
            gap = max(dist(R[-2], R[-1][0]) if len(R) > 1 else 1.0, 0.3)
            return round(len(R) + d / gap, 3)
        dout = dist(R[k], p)
        if k == 0:
            din = float(np.hypot(*(p - self.c)))
            return round(1 - dout / (din + dout + 1e-9), 3)
        din = dist(R[k - 1], p)
        return round(k + 1 - dout / (din + dout + 1e-9), 3)


def run(f, x0):
    steps, b, r, bases, refs = [], x0, x0, [x0], []
    while True:
        cur, lines = r, []
        for j in range(2):
            tries = []
            for s in (1, -1):
                z = tuple(cur[i] + (s if i == j else 0) for i in range(2))
                ok = f(z) < f(cur)
                tries.append((z, f(z), f(cur), ok))
                if ok:
                    break
            if tries[-1][3]:
                cur = tries[-1][0]
            lines.append((j, tries, cur if tries[-1][3] else None))
        st = dict(kind=1 if r == b else 2, r=r, lines=lines, end=cur, base=b, k=len(bases))
        if f(cur) < f(b):
            bases.append(cur)
            nr = tuple(2 * cur[i] - b[i] for i in range(2))
            st.update(res="new", nr=nr)
            refs.append((cur, nr))
            b, r = cur, nr
        elif r != b:
            st["res"] = "back"
            r = b
        else:
            st["res"] = "stop"
        steps.append(st)
        if st["res"] == "stop" or len(steps) > 40:
            return steps, bases, refs


def P(p):
    return f"({p[0]:g}, {p[1]:g})"


def text(f, steps):
    out = []
    for st in steps:
        k = st["k"]
        if st["kind"] == 1:
            out.append(f"#step[在基点 $b_{k} = {P(st['r'])}$ 处作Ⅰ型探测]")
        else:
            out.append(f"#step[在参考点 $r = {P(st['r'])}$ 处作Ⅱ型探测]")
        rows = []
        for j, tries, to in st["lines"]:
            lo, hi = '"更低"', '"不更低"'
            parts = [f"{P(z)} {lo if ok else hi}" for z, gz, gc, ok in tries]
            tail = f'"前进到" {P(to)}' if to else '"不动"'
            rows.append(f"{'x_1' if j == 0 else 'x_2'} \"方向：\" & " + ", quad ".join(parts) + f", quad {tail}")
        out.append("$ " + "; \\\n  ".join(rows) + ". $")
        e = st["end"]
        if st["res"] == "new":
            out.append(f"终点 ${P(e)}$ 比基点 $b_{k}$ 低，得基点 $b_{k + 1} = {P(e)}$；"
                       f"模式移动 $r = 2 b_{k + 1} - b_{k} = {P(st['nr'])}$。")
        elif st["res"] == "back":
            out.append(f"终点 ${P(e)}$ 不比基点 $b_{k}$ 低，模式移动作废，退回 $b_{k} = {P(st['base'])}$。")
        else:
            out.append("四个试探点都不比基点低，开始缩小步长，作业结束。")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def roles_of(steps, bases):
    roles = {}
    for st in steps:
        roles.setdefault(st["r"], set()).add("ref")
        for _, tries, _ in st["lines"]:
            for z, *_ in tries:
                roles.setdefault(z, set()).add("try")
    for b in bases:
        roles.setdefault(b, set()).add("base")
    return roles


def figure(rings, nx, ny, x0, star, length=0.5, steps=None, bases=None, refs=None, x0_label="1",
           order_at=(-1.2, -1.3)):
    """steps 为 None 时只画题目（等值线、网格、初始点），否则画出作业过程。"""
    L = [f"#align(center, cetz.canvas(length: {length}cm, {{", "  import cetz.draw: *",
         f"  grid((0, 0), ({nx}, {ny}), step: 1, stroke: 0.35pt + luma(160))"]
    for r in rings:
        c = smooth_ring(r, per=8)
        L.append("  line(" + ", ".join(f"({x:.2f}, {y:.2f})" for x, y in c) + ", close: true, stroke: 0.7pt)")
    if star is not None:
        L.append(f"  content(({star[0]:.2f}, {star[1]:.2f}), text(size: 8pt, $x^*$))")
    if steps is None:
        L.append(f"  circle({P(x0)}, radius: 0.12, fill: black, stroke: none)")
        L.append(f"  content({P(x0)}, text(size: 8pt, [{x0_label}]), anchor: \"south-east\", padding: 0.15)")
    else:
        for a, b in zip(bases, bases[1:]):
            L.append(f"  line({P(a)}, {P(b)}, stroke: 1pt, mark: (end: \">\", scale: 0.6))")
        for b, r in refs:
            L.append(f"  line({P(b)}, {P(r)}, stroke: (thickness: 0.7pt, dash: \"dashed\"), mark: (end: \">\", scale: 0.5))")
        for p, rs in roles_of(steps, bases).items():
            x, y = p
            if "base" in rs and "ref" in rs:
                L.append(f"  rect(({x - 0.24}, {y - 0.24}), ({x + 0.24}, {y + 0.24}), stroke: 0.7pt, fill: white)")
                L.append(f"  circle({P(p)}, radius: 0.1, fill: black, stroke: none)")
            elif "base" in rs:
                L.append(f"  circle({P(p)}, radius: 0.14, fill: black, stroke: none)")
            elif "ref" in rs:
                L.append(f"  rect(({x - 0.22}, {y - 0.22}), ({x + 0.22}, {y + 0.22}), stroke: 0.7pt, fill: white)")
            else:
                L.append(f"  circle({P(p)}, radius: 0.13, stroke: 0.6pt, fill: white)")
        for i, b in enumerate(bases):
            L.append(f"  content({P(b)}, text(size: 8pt, weight: \"bold\", [{i + 1}]), anchor: \"south-east\", padding: 0.18)")
        o = order_at
        for (dx, dy), lab in (((1, 0), "①"), ((-1, 0), "②"), ((0, 1), "③"), ((0, -1), "④")):
            L.append(f"  line({o}, ({o[0] + 0.9 * dx}, {o[1] + 0.9 * dy}), stroke: 0.6pt, mark: (end: \">\", scale: 0.5))")
            L.append(f"  content(({o[0] + 1.3 * dx}, {o[1] + 1.25 * dy}), text(size: 7.5pt, [{lab}]))")
    L.append("}))")
    return "\n".join(L) + "\n"
