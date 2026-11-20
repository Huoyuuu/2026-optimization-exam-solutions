"""2013-2014 五 图上作业：等值线按极坐标拟合（data/hj-2013-rad.npy，来自 013 项目 polar.py），
按“圈数”估函数值，模拟步长加速法，生成 book/parts/gen/hj-g2013.typ（过程）和 hj-g2013-fig.typ（图）。
坐标：网格左下角 (0,0)，每格 1，x0 = (2,1)。运行：uv run scripts/check/hj_graph.py"""
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
GEN = ROOT / "book" / "parts" / "gen"
HDR = '#import "/book/lib.typ": *\n\n'
rad = np.load(Path(__file__).with_name("data") / "hj-2013-rad.npy")
NB = len(rad)
C0, C1, R0, R1, CX, CY = 42, 409, 7, 411, 219, 186  # 原图像素：网格左右、上下边线，x* 位置


def ring(px, py):
    t = np.arctan2(-(py - CY), px - CX)
    r = np.hypot(px - CX, py - CY)
    u = (t + np.pi) / (2 * np.pi) * NB - 0.5
    i0 = int(np.floor(u)) % NB
    w = u - np.floor(u)
    rr = (1 - w) * rad[i0] + w * rad[(i0 + 1) % NB]
    if r <= rr[6]:
        return float(np.interp(r, rr, np.arange(7)))
    return 6 + (r - rr[6]) / (rr[6] - rr[5])


def g(p):
    return round(ring(C0 + (C1 - C0) * p[0] / 14, R1 - (R1 - R0) * p[1] / 16), 2)


def run(x0):
    steps, b, r, bases, refs = [], x0, x0, [x0], []
    while True:
        cur, lines = r, []
        for j in range(2):
            tries = []
            for s in (1, -1):
                z = tuple(cur[i] + (s if i == j else 0) for i in range(2))
                ok = g(z) < g(cur)
                tries.append((z, g(z), g(cur), ok))
                if ok:
                    break
            if tries[-1][3]:
                cur = tries[-1][0]
            lines.append((j, tries, cur if tries[-1][3] else None))
        st = dict(kind=1 if r == b else 2, r=r, lines=lines, end=cur, base=b, k=len(bases))
        if g(cur) < g(b):
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
        if st["res"] == "stop":
            return steps, bases, refs


def P(p):
    return f"({p[0]}, {p[1]})"


def text(steps):
    out = []
    for st in steps:
        k = st["k"]
        if st["kind"] == 1:
            out.append(f"#step[在基点 $b_{k} = {P(st['r'])}$ 处作Ⅰ型探测（圈数 ${g(st['r'])}$）]")
        else:
            out.append(f"#step[在参考点 $r = {P(st['r'])}$ 处作Ⅱ型探测（圈数 ${g(st['r'])}$）]")
        rows = []
        for j, tries, to in st["lines"]:
            parts = [f"{P(z)}\": \" {gz:.2f} {'<' if ok else '>='} {gc:.2f}" for z, gz, gc, ok in tries]
            tail = f'"前进到" {P(to)}' if to else '"不动"'
            rows.append(f"{'x' if j == 0 else 'y'} \"方向：\" & " + ", quad ".join(parts) + f", quad {tail}")
        out.append("$ " + "; \\\n  ".join(rows) + ". $")
        e, gb = st["end"], g(st["base"])
        if st["res"] == "new":
            out.append(f"终点 ${P(e)}$ 的圈数 ${g(e)} < {gb}$（基点 $b_{k}$），得基点 $b_{k + 1} = {P(e)}$；"
                       f"模式移动 $r = 2 b_{k + 1} - b_{k} = {P(st['nr'])}$。")
        elif st["res"] == "back":
            out.append(f"终点 ${P(e)}$ 的圈数 ${g(e)} >= {gb}$（基点 $b_{k}$），模式移动作废，退回 $b_{k} = {P(st['base'])}$。")
        else:
            out.append(f"四个试探点都不优于 $b_{k}$，开始缩小步长，作业结束。")
        out.append("")
    return "\n".join(out).rstrip() + "\n"


def contours():
    k = np.exp(-0.5 * (np.arange(-3, 4) / 1.2) ** 2)
    k /= k.sum()
    rs = [np.convolve(np.r_[rad[-3:, i], rad[:, i], rad[:3, i]], k, "valid") for i in range(1, 7)]
    F = np.fft.rfft(rad[:, 1])
    F[3:] = 0
    rs[0] = np.fft.irfft(F, NB)  # 最内圈被 x* 字样干扰，只留 2 阶谐波
    t = (np.arange(NB) + 0.5) / NB * 2 * np.pi - np.pi
    tt = np.linspace(-np.pi, np.pi, 145)[:-1]
    cx, cy = (CX - C0) / (C1 - C0) * 14, (R1 - CY) / (R1 - R0) * 16
    res = []
    for r in rs:
        rr = np.interp(tt, t, r, period=2 * np.pi)
        res.append(list(zip(cx + rr * np.cos(tt) * 14 / (C1 - C0), cy + rr * np.sin(tt) * 16 / (R1 - R0))))
    return res, (cx, cy)


def figure(steps, bases, refs):
    roles = {}
    for st in steps:
        roles.setdefault(st["r"], set()).add("ref")
        for _, tries, _ in st["lines"]:
            for z, *_ in tries:
                roles.setdefault(z, set()).add("try")
    for b in bases:
        roles.setdefault(b, set()).add("base")
    cs, (cx, cy) = contours()
    L = ["#align(center, cetz.canvas(length: 0.62cm, {", "  import cetz.draw: *",
         "  grid((0, 0), (14, 16), step: 1, stroke: 0.4pt + luma(150))"]
    for c in cs:
        L.append("  line(" + ", ".join(f"({x:.2f}, {y:.2f})" for x, y in c) + ", close: true, stroke: 0.7pt)")
    L.append(f"  content(({cx - 0.8:.2f}, {cy - 0.4:.2f}), text(size: 8pt, $x^*$))")
    L.append("  content((2, 0.15), text(size: 8pt, $x_0$), anchor: \"north\", padding: 0.25)")
    for a, b in zip(bases, bases[1:]):
        L.append(f"  line({P(a)}, {P(b)}, stroke: 1pt, mark: (end: \">\", scale: 0.6))")
    for b, r in refs:
        L.append(f"  line({P(b)}, {P(r)}, stroke: (thickness: 0.7pt, dash: \"dashed\"), mark: (end: \">\", scale: 0.5))")
    for p, rs in roles.items():
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
    # 探测方向的先后顺序（左下方的小坐标系）
    o = (-1.1, -1.3)
    for (dx, dy), lab in (((1, 0), "①"), ((-1, 0), "②"), ((0, 1), "③"), ((0, -1), "④")):
        L.append(f"  line({o}, ({o[0] + 0.9 * dx}, {o[1] + 0.9 * dy}), stroke: 0.6pt, mark: (end: \">\", scale: 0.5))")
        L.append(f"  content(({o[0] + 1.3 * dx}, {o[1] + 1.25 * dy}), text(size: 7.5pt, [{lab}]))")
    L.append("}))")
    return "\n".join(L) + "\n"


steps, bases, refs = run((2, 1))
(GEN / "hj-g2013.typ").write_text(HDR + text(steps), encoding="utf-8", newline="\n")
(GEN / "hj-g2013-fig.typ").write_text(HDR + figure(steps, bases, refs), encoding="utf-8", newline="\n")
print("基点", bases)
print("参考点", [r for _, r in refs])
assert bases == [(2, 1), (2, 2), (3, 4), (5, 7), (8, 9), (7, 9)], "和 013 项目的解答不一致"
print("和 013 项目的解答一致")
