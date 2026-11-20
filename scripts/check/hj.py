"""步长加速法（教材算法 3.11a、3.11b）真题验算，同时生成答案里的探测过程和路径图。
输出 book/parts/gen/hj-<tag>.typ（探测过程）和 hj-<tag>-fig.typ（cetz 路径图）。
记号：b_0 = x_0；Ⅰ型探测成功或Ⅱ型探测后模式移动成功得到 b_1, b_2, …；模式移动 r_k = 2 b_k - b_(k-1)。
运行：uv run scripts/check/hj.py"""
from fractions import Fraction as Fr
from pathlib import Path

HDR = '#import "/book/lib.typ": *\n\n'
GEN = Path(__file__).resolve().parents[2] / "book" / "parts" / "gen"


def num(x):
    x = Fr(x)
    if x.denominator == 1:
        return str(x.numerator)
    d = x.denominator
    while d % 2 == 0:
        d //= 2
    while d % 5 == 0:
        d //= 5
    if d == 1:  # 有限小数
        s = f"{float(x):.6f}".rstrip("0").rstrip(".")
        return s
    return f"{x.numerator}/{x.denominator}"


def pt(p):
    return "(" + ", ".join(num(v) for v in p) + ")"


def vec(p):
    return pt(p) + "^T"


def run(f, x0, s, stop="shrink"):
    """返回 (events, points)。events 是要写进答案的步骤；points 记录每个点的角色。"""
    n = len(x0)
    x0 = tuple(Fr(v) for v in x0)
    s = tuple(Fr(v) for v in s)
    F = lambda p: Fr(f(*p))
    roles = {}  # 点 → 角色集合

    def mark(p, r):
        roles.setdefault(p, set()).add(r)

    def explore(r):
        b, fb = r, F(r)
        lines = []
        for i in range(n):
            e = tuple(s[i] if j == i else 0 for j in range(n))
            p1 = tuple(b[j] + e[j] for j in range(n))
            f1 = F(p1)
            mark(p1, "try")
            if f1 < fb:
                lines.append((i, [(p1, f1, fb, True)], p1))
                b, fb = p1, f1
                continue
            p2 = tuple(b[j] - e[j] for j in range(n))
            f2 = F(p2)
            mark(p2, "try")
            if f2 < fb:
                lines.append((i, [(p1, f1, fb, False), (p2, f2, fb, True)], p2))
                b, fb = p2, f2
            else:
                lines.append((i, [(p1, f1, fb, False), (p2, f2, fb, False)], None))
        return b, fb, lines

    ev = []
    bases = [x0]
    mark(x0, "base")
    mark(x0, "ref")
    r = x0
    kind = 1
    refs = []
    while True:
        fr = F(r)
        b, fb, lines = explore(r)
        if kind == 1:
            k = len(bases) - 1
            ev.append(("explore1", r, fr, lines, b, fb, k))
            if fb < fr:
                bases.append(b)
                mark(b, "base")
                ev.append(("ok1", b, fb, len(bases) - 1, fr))
            else:
                ev.append(("fail1", r, fr, k))
                break
        else:
            k = len(bases) - 1
            ev.append(("explore2", r, fr, lines, b, fb, len(refs)))
            fbase = F(bases[-1])
            if fb < fbase:
                bases.append(b)
                mark(b, "base")
                ev.append(("ok2", b, fb, len(bases) - 1, fbase))
            else:
                ev.append(("fail2", b, fb, k, fbase, bases[-1]))
                if stop == "patternfail":
                    break
                r = bases[-1]
                mark(r, "ref")
                kind = 1
                continue
        # 模式移动
        bk, bprev = bases[-1], bases[-2]
        r = tuple(2 * bk[j] - bprev[j] for j in range(n))
        refs.append(r)
        mark(r, "ref")
        ev.append(("move", r, F(r), len(bases) - 1, len(refs)))
        kind = 2
    return ev, roles, bases, refs


def typst(ev, n=2):
    out = []

    def expl(lines):
        rows = []
        for i, tries, to in lines:
            parts = []
            for p, fv, fb, ok in tries:
                parts.append(f"f{pt(p)} = {num(fv)} {'<' if ok else '>='} {num(fb)}")
            tail = f'"前进到" {vec(to)}' if to is not None else '"不动"'
            rows.append(f'  x_{i + 1} "方向：" & ' + ", quad ".join(parts) + f", quad {tail}")
        return "$ " + ("; \\\n  ").join(r.strip() for r in rows) + ". $"

    for e in ev:
        t = e[0]
        if t == "explore1":
            _, r, fr, lines, b, fb, k = e
            out.append(f"#step[Ⅰ型探测（参考点 $r = b_{k} = {vec(r)}$，$f(r) = {num(fr)}$）]")
            out.append(expl(lines))
        elif t == "ok1":
            _, b, fb, k, fr = e
            out.append(f"探测终点 ${vec(b)}$，$f = {num(fb)} < f(b_{k - 1}) = {num(fr)}$，探测成功，得基点 $b_{k} = {vec(b)}$。")
            out.append("")
        elif t == "fail1":
            _, r, fr, k = e
            out.append(f"所有试探点都不优于 $b_{k}$，探测失败，开始缩小步长。")
            out.append("")
        elif t == "move":
            _, r, fr, k, j = e
            out.append("#step[模式移动]")
            out.append(f"$ r_{j} = 2 b_{k} - b_{k - 1} = {vec(r)}, quad f(r_{j}) = {num(fr)}. $")
            out.append("")
        elif t == "explore2":
            _, r, fr, lines, b, fb, j = e
            out.append(f"#step[Ⅱ型探测（参考点 $r_{j} = {vec(r)}$）]")
            out.append(expl(lines))
        elif t == "ok2":
            _, b, fb, k, fbase = e
            out.append(f"探测终点 ${vec(b)}$，$f = {num(fb)} < f(b_{k - 1}) = {num(fbase)}$，模式移动成功，得基点 $b_{k} = {vec(b)}$。")
            out.append("")
        elif t == "fail2":
            _, b, fb, k, fbase, bk = e
            out.append(f"探测终点 ${vec(b)}$，$f = {num(fb)} >= f(b_{k}) = {num(fbase)}$，模式移动失败（作废），退回 $r = b_{k} = {vec(bk)}$。")
            out.append("")
    return "\n".join(out).rstrip() + "\n"


def figure(roles, bases, refs, s, length=0.8):
    xs = [p[0] for p in roles]
    ys = [p[1] for p in roles]
    x0, x1 = min(xs) - s[0], max(xs) + s[0]
    y0, y1 = min(ys) - s[1], max(ys) + s[1]
    L = []
    L.append(f"#align(center, cetz.canvas(length: {length}cm, {{")
    L.append("  import cetz.draw: *")
    # 网格（按步长画）
    L.append(f"  grid(({float(x0)}, {float(y0)}), ({float(x1)}, {float(y1)}), step: ({float(s[0])}, {float(s[1])}), stroke: 0.3pt + luma(190))")
    if x0 <= 0 <= x1:
        L.append(f"  line((0, {float(y0)}), (0, {float(y1) + 0.3}), mark: (end: \">\"), stroke: 0.5pt)")
        L.append(f"  content((0, {float(y1) + 0.65}), text(size: 8pt, $x_2$))")
    if y0 <= 0 <= y1:
        L.append(f"  line(({float(x0)}, 0), ({float(x1) + 0.3}, 0), mark: (end: \">\"), stroke: 0.5pt)")
        L.append(f"  content(({float(x1) + 0.7}, 0), text(size: 8pt, $x_1$))")
    for k in range(1, len(bases)):
        a, b = bases[k - 1], bases[k]
        L.append(f"  line(({float(a[0])}, {float(a[1])}), ({float(b[0])}, {float(b[1])}), stroke: 0.9pt, mark: (end: \">\", scale: 0.6))")
    # 模式移动：从基点 b_(j+1) 到参考点 r_(j+1) 的虚线
    for j, r in enumerate(refs):
        b = bases[j + 1]
        L.append(f"  line(({float(b[0])}, {float(b[1])}), ({float(r[0])}, {float(r[1])}), stroke: (thickness: 0.6pt, dash: \"dashed\"), mark: (end: \">\", scale: 0.5))")
    for p, rs in roles.items():
        x, y = float(p[0]), float(p[1])
        if "base" in rs and "ref" in rs:
            L.append(f"  rect(({x - 0.22}, {y - 0.22}), ({x + 0.22}, {y + 0.22}), stroke: 0.6pt, fill: white)")
            L.append(f"  circle(({x}, {y}), radius: 0.09, fill: black, stroke: none)")
        elif "base" in rs:
            L.append(f"  circle(({x}, {y}), radius: 0.13, fill: black, stroke: none)")
        elif "ref" in rs:
            L.append(f"  rect(({x - 0.2}, {y - 0.2}), ({x + 0.2}, {y + 0.2}), stroke: 0.6pt, fill: white)")
        else:
            L.append(f"  circle(({x}, {y}), radius: 0.12, stroke: 0.5pt, fill: white)")
    for k, b in enumerate(bases):
        L.append(f"  content(({float(b[0])}, {float(b[1])}), text(size: 7.5pt, $b_{k}$), anchor: \"south-west\", padding: 0.12)")
    L.append("}))")
    return "\n".join(L) + "\n"


def write(tag, f, x0, s, stop="shrink", fig=True, length=0.8):
    ev, roles, bases, refs = run(f, x0, s, stop)
    (GEN / f"hj-{tag}.typ").write_text(HDR + typst(ev), encoding="utf-8", newline="\n")
    if fig:
        (GEN / f"hj-{tag}-fig.typ").write_text(HDR + figure(roles, bases, refs, s, length), encoding="utf-8", newline="\n")
    last = bases[-1]
    print(f"{tag}: 基点 {[pt(b) for b in bases]}，参考点 {[pt(r) for r in refs]}，停在 {pt(last)} f = {num(f(*last))}")
    return bases, refs


H = Fr(1, 2)
write("2010", lambda a, b: 4 * a**2 + b**2 - a**2 * b, (-1, 1), (1, 1))
write("2011", lambda a, b: 4 * a**2 + b**2, (1, Fr(5, 2)), (1, 1), stop="patternfail")
write("2016", lambda a, b: (a - 1) ** 4 + 2 * b**2, (4, 3), (1, 1))
write("2017", lambda a, b: 2 * a**2 + b**2 - 2 * a * b, (-1, 2), (1, 1), length=0.9)
write("2020", lambda a, b: a**2 + b**2 - 4 * a + 2 * b + 7, (0, 0), (1, 1))
write("2021", lambda a, b: a**2 + 2 * b**2 - 2 * a * b, (5, 0), (2, 1))
write("2022", lambda a, b: a**2 + b**2 - 4 * a - 4 * b + 8, (0, 0), (1, 1))
write("2024A", lambda a, b: a**2 + a + 2 * b**2, (1, 2), (1, 1))
write("2024B", lambda a, b: a**2 + a * b + b**2, (2, 2), (1, 1))
# 预测题：教材例 3.5、习题 3.24
write("P1", lambda a, b: a**2 + 4 * b**2, (Fr(9, 2), 4), (1, 1))
write("P2", lambda a, b: a**2 + b**2, (3, -4), (1, 1))
