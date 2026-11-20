"""步长加速法图上作业（2014 年以后的几张图）：按 hj_cfg.py 的等值线模拟，
生成 book/figs/<卷>-hj.typ（题目图）、book/parts/gen/hj-g<键>.typ（过程）和 hj-g<键>-fig.typ（答案图），
并和原卷上学生画的基点序列对照。运行：uv run scripts/check/hj_graphs.py [键 ...] [--grid]"""
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from hj_cfg import CFG  # noqa: E402
from hj_geom import RingField, figure, run, text  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
GEN = ROOT / "book/parts/gen"
FIGS = ROOT / "book/figs"
HDR = '#import "/book/lib.typ": *\n\n'
EXAM = {"2013": "2013-2014-5", "2014": "2014-2015-7", "2015": "2015-2016-5", "2018": "2018-2019-4", "2019": "2019-2020-4"}


def main():
    keys = [a for a in sys.argv[1:] if not a.startswith("--")] or list(CFG)
    for k in keys:
        c = CFG[k]
        f = RingField(c["rings"], c["center"])
        if "--grid" in sys.argv:
            for y in range(c["ny"], -1, -1):
                print(f"{y:3d} " + " ".join(f"{f((x, y)):5.2f}" for x in range(c["nx"] + 1)))
        steps, bases, refs = run(f, c["x0"])
        print(k, "基点", bases)
        print(k, "学生", c.get("student"))
        print(k, "一致" if bases == c.get("student") else "不一致")
        for st in steps:
            print("  ", st["kind"], st["r"], "->", st["end"], st["res"],
                  [(z, gz) for _, tr, _ in st["lines"] for z, gz, _, _ in tr], "base f", f(st["base"]))
        kw = dict(nx=c["nx"], ny=c["ny"], x0=c["x0"], star=c.get("star"), length=c.get("length", 0.5))
        head = '#import "@preview/cetz:0.5.3"\n'
        (FIGS / f"{EXAM[k]}-hj.typ").write_text(head + figure(c["rings"], **kw), encoding="utf-8", newline="\n")
        (GEN / f"hj-g{k}.typ").write_text(HDR + text(f, steps), encoding="utf-8", newline="\n")
        (GEN / f"hj-g{k}-fig.typ").write_text(
            HDR + figure(c["rings"], steps=steps, bases=bases, refs=refs, **kw), encoding="utf-8", newline="\n")


if __name__ == "__main__":
    np.set_printoptions(precision=2)
    main()
