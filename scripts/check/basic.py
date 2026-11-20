"""第 2 部分（建模、图解法）验算，并生成图解题的 cetz 图到 book/parts/gen/basic-*.typ。
运行：uv run scripts/check/basic.py"""
from pathlib import Path

import numpy as np
from scipy.optimize import linprog, minimize

GEN = Path(__file__).resolve().parents[2] / "book" / "parts" / "gen"
HDR = '#import "/book/lib.typ": *\n\n'
PHI = (1 + 5 ** 0.5) / 2


def grid(box, n=1601):
    x1, x2 = np.meshgrid(np.linspace(box[0], box[1], n), np.linspace(box[2], box[3], n))
    return x1, x2


def report(name, f, feas, box, sense=1):
    x1, x2 = grid(box)
    m = feas(x1, x2)
    v = np.where(m, sense * f(x1, x2), np.inf)
    i = np.unravel_index(np.argmin(v), v.shape)
    print(f"{name}: 网格最优点 ({x1[i]:.4f}, {x2[i]:.4f})，f = {f(x1[i], x2[i]):.4f}")


# ---------- 图解题验算 ----------
f14 = lambda a, b: (a - 1) ** 2 + b ** 2
feas14 = lambda a, b: (a - b ** 2 <= 1) & (a - b >= 2) & (a >= 0) & (b >= 0)
report("2014-2015 二(1) min", f14, feas14, (0, 8, 0, 4))
print(f"  解析：A = ({2 + PHI:.4f}, {PHI:.4f})，f = 5 + 2√5 = {5 + 2 * 5 ** 0.5:.4f}")

f20 = lambda a, b: (a - 1) ** 2 + (b + 1) ** 2
feas20 = lambda a, b: (-np.cbrt(a) + b <= 0) & (a ** 2 - b <= 2) & (a <= 0)
report("2020-2021 一(3) max", f20, feas20, (-3, 0, -3, 1), sense=-1)
u = np.linspace(0, 1, 1001)
h = u ** 4 - u ** 2 + 2 * u + 2
print(f"  h(u) = u^4 - u^2 + 2u + 2 在 [0,1] 上单调增：{bool(np.all(np.diff(h) > 0))}，h(1) = {h[-1]}")

fP = lambda a, b: (a - 2) ** 2 + (b - 2) ** 2
feasP = lambda a, b: (a + 2 * b <= 4) & (a ** 2 + b ** 2 <= 5) & (a >= 0) & (b >= 0)
report("预测题 min", fP, feasP, (0, 3, 0, 3))
report("预测题 max", fP, feasP, (0, 3, 0, 3), sense=-1)

# ---------- 建模题：解一下，确认模型有界、可行 ----------
# 2009-2010 十：max 170x1 - x1^2 + 350x2 - 2x2^2，x1 + x2 <= 17.25
r = minimize(lambda x: -(170 * x[0] - x[0] ** 2 + 350 * x[1] - 2 * x[1] ** 2), [1, 1],
             bounds=[(0, None)] * 2, constraints=[{"type": "ineq", "fun": lambda x: 17.25 - x[0] - x[1]}])
print(f"2009-2010 十：x = {np.round(r.x, 4)}，最大利润 {-r.fun:.4f}")

# 2011-2012 九：发动机
cost = lambda x: sum(50 * v + 0.2 * v * v for v in x) + 4 * (x[0] - 40) + 4 * (x[0] + x[1] - 100)
r = minimize(cost, [60, 60, 60], bounds=[(0, 100)] * 3, constraints=[
    {"type": "ineq", "fun": lambda x: x[0] - 40}, {"type": "ineq", "fun": lambda x: x[0] + x[1] - 100},
    {"type": "eq", "fun": lambda x: x[0] + x[1] + x[2] - 180}])
print(f"2011-2012 九：x = {np.round(r.x, 4)}，最少费用 {r.fun:.4f}")

# 2018-2019 六(2)：糖果，变量 x_ij（原料 i = A,B,C，糖果 j = 甲乙丙），按行展开
price, proc, raw = [3.40, 2.85, 2.25], [0.50, 0.40, 0.30], [2.00, 1.50, 1.00]
c = [-((price[j] - proc[j]) - raw[i]) for i in range(3) for j in range(3)]
idx = lambda i, j: 3 * i + j
A, b = [], []
for i, lim in enumerate([2000, 2500, 1200]):
    row = [0] * 9
    for j in range(3):
        row[idx(i, j)] = 1
    A.append(row); b.append(lim)
def share(i, j, k, ge):  # 原料 i 在糖果 j 中占比 >= k（ge）或 <= k
    row = [0] * 9
    for ii in range(3):
        row[idx(ii, j)] = k
    row[idx(i, j)] -= 1
    A.append(row if ge else [-v for v in row]); b.append(0)
share(0, 0, 0.60, True); share(2, 0, 0.20, False); share(0, 1, 0.15, True); share(2, 1, 0.60, False); share(2, 2, 0.50, False)
r = linprog(c, A_ub=A, b_ub=b, bounds=[(0, None)] * 9)
print(f"2018-2019 六(2)：利润系数 {[-v for v in c]}")
print(f"  x = {np.round(r.x, 2)}，最大利润 {-r.fun:.2f}")


# ---------- 画图 ----------
def fmt(p):
    return f"({p[0]:.3f}, {p[1]:.3f})"


def inside(p, box, eps=1e-9):
    return box[0] - eps <= p[0] <= box[1] + eps and box[2] - eps <= p[1] <= box[3] + eps


def clip_runs(pts, box):
    runs, cur = [], []
    for p in pts:
        if inside(p, box):
            cur.append(p)
        elif cur:
            runs.append(cur); cur = []
    if cur:
        runs.append(cur)
    return [r for r in runs if len(r) > 1]


def poly(pts, box, style):
    return [f"  line({', '.join(fmt(p) for p in r)}, {style})" for r in clip_runs(pts, box)]


def circle_pts(c, r, n=360):
    t = np.linspace(0, 2 * np.pi, n + 1)
    return list(zip(c[0] + r * np.cos(t), c[1] + r * np.sin(t)))


def axes(box):
    x0, x1, y0, y1 = box
    out = [f"  line(({x0}, 0), ({x1}, 0), mark: (end: \"stealth\", fill: black, scale: 0.7), stroke: 0.5pt)",
           f"  line((0, {y0}), (0, {y1}), mark: (end: \"stealth\", fill: black, scale: 0.7), stroke: 0.5pt)",
           f"  content(({x1}, 0), anchor: \"north-east\", padding: 0.12, text(size: 8pt, $x_1$))",
           f"  content((0, {y1}), anchor: \"north-west\", padding: 0.12, text(size: 8pt, $x_2$))",
           "  content((0, 0), anchor: \"north-east\", padding: 0.08, text(size: 7pt, $O$))"]
    for k in range(int(np.ceil(x0)), int(np.floor(x1)) + 1):
        if k != 0 and k < x1 - 0.5:
            out.append(f"  line(({k}, 0), ({k}, 0.07), stroke: 0.5pt)")
            out.append(f"  content(({k}, 0), anchor: \"north\", padding: 0.08, text(size: 7pt, ${k}$))")
    for k in range(int(np.ceil(y0)), int(np.floor(y1)) + 1):
        if k != 0 and k < y1 - 0.5:
            out.append(f"  line((0, {k}), (0.07, {k}), stroke: 0.5pt)")
            out.append(f"  content((0, {k}), anchor: \"east\", padding: 0.08, text(size: 7pt, ${k}$))")
    return out


def dot(p, label=None, anchor="west", fill="black", size="8pt"):
    out = [f"  circle({fmt(p)}, radius: 0.06, fill: {fill}, stroke: 0.5pt)"]
    if label:
        out.append(f"  content({fmt(p)}, anchor: \"{anchor}\", padding: 0.12, box(fill: white, inset: 1pt, text(size: {size}, {label})))")
    return out


def tag(p, label, anchor):
    return [f"  content({fmt(p)}, anchor: \"{anchor}\", padding: 0.05, box(fill: white, inset: 1pt, text(size: 7.5pt, {label})))"]


def canvas(name, length, box, body):
    s = HDR + f"#align(center, cetz.canvas(length: {length}cm, {{\n  import cetz.draw: *\n"
    s += "\n".join(body) + "\n}))\n"
    (GEN / f"basic-{name}-fig.typ").write_text(s, encoding="utf-8", newline="\n")


REGION = "fill: luma(220), stroke: none"
BND = "stroke: 0.9pt"
CON = "stroke: (paint: luma(110), thickness: 0.5pt, dash: \"dashed\")"
CON0 = "stroke: (paint: black, thickness: 0.7pt, dash: \"dashed\")"

# 2014-2015 二(1)
box = (-0.8, 6.4, -0.8, 3.8)
t = np.linspace(PHI, np.sqrt(box[1] - 1), 80)
reg = [(2 + PHI, PHI), (2 + box[3], box[3]), (box[1], box[3])] + [(1 + v * v, v) for v in t[::-1]]
body = [f"  line({', '.join(fmt(p) for p in reg)}, close: true, {REGION})"]
for r in (1, 2, 4):
    body += poly(circle_pts((1, 0), r), box, CON)
body += poly(circle_pts((1, 0), np.sqrt(5 + 2 * np.sqrt(5))), box, CON0)
body += axes(box)
tt = np.linspace(-3, 3, 300)
body += poly([(1 + v * v, v) for v in tt], box, BND)
body += poly([(2 + v, v) for v in np.linspace(-1, 4, 50)], box, BND)
body += tag((6.35, 2.05), "$x_1 - x_2^2 = 1$", "north-east")
body += tag((4.15, 3.1), "$x_1 - x_2 = 2$", "east")
body += dot((1, 0), "$(1, 0)$", "south-east", size="7pt")
body += dot((2 + PHI, PHI), "$x^*$", "south-east")
canvas("2014", 1.0, box, body)

# 2020-2021 一(3)
box = (-2.4, 3.4, -3.4, 1.8)
s = np.linspace(-1, 0, 80)
reg = [(v, np.cbrt(v)) for v in s] + [(0, -2)] + [(v, v * v - 2) for v in s[::-1]]
body = [f"  line({', '.join(fmt(p) for p in reg)}, close: true, {REGION})"]
for r in (1, 3):
    body += poly(circle_pts((1, -1), r), box, CON)
body += poly(circle_pts((1, -1), 2), box, CON0)
body += axes(box)
body += poly([(v, np.cbrt(v)) for v in np.linspace(-2.4, 3.4, 400)], box, BND)
body += poly([(v, v * v - 2) for v in np.linspace(-2.4, 2.4, 300)], box, BND)
body += [f"  line((0, -3.4), (0, 1.8), {BND})"]
body += tag((3.35, 1.25), "$x_2 = root(3, x_1)$", "north-east")
body += tag((-1.45, -0.25), "$x_2 = x_1^2 - 2$", "north-east")
body += tag((0.05, -3.3), "$x_1 = 0$", "south-west")
body += dot((1, -1), "$(1, -1)$", "west", size="7pt")
body += dot((-1, -1), "$x^*$", "east")
canvas("2020", 0.95, box, body)

# 预测题
box = (-0.6, 4.6, -0.6, 3.2)
ang = np.linspace(0, np.arctan2(1, 2), 60)
reg = [(0, 0)] + [(np.sqrt(5) * np.cos(a), np.sqrt(5) * np.sin(a)) for a in ang] + [(0, 2)]
body = [f"  line({', '.join(fmt(p) for p in reg)}, close: true, {REGION})"]
body += poly(circle_pts((2, 2), 1.5), box, CON)
body += poly(circle_pts((2, 2), np.sqrt(0.8)), box, CON0)
body += poly(circle_pts((2, 2), 2 * np.sqrt(2)), box, CON0)
body += axes(box)
body += poly(circle_pts((0, 0), np.sqrt(5)), box, BND)
body += poly([(v, (4 - v) / 2) for v in np.linspace(-0.6, 4.6, 20)], box, BND)
body += tag((3.95, 0.3), "$x_1 + 2 x_2 = 4$", "south-west")
body += tag((0.62, 2.2), "$x_1^2 + x_2^2 = 5$", "south-west")
body += dot((2, 2), "$(2, 2)$", "west", size="7pt")
body += dot((1.6, 1.2), "$A$", "north-east")
body += dot((0, 0))
canvas("P", 1.1, box, body)
print("图已写入", GEN)
